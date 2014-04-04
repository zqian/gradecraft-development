@gradecraft.controller 'GradeRubricCtrl', ($scope, Restangular, $http) -> 

  INTEGER_REGEXP = /^\-?\d+$/
  Restangular.setRequestSuffix('.json')
  $scope.metrics = []
  $scope.savedMetricCount = 0

  $scope.init = (rubricId, metrics)->
    $scope.rubricId = rubricId
    $scope.addMetrics(metrics)

  $scope.showMetric = (attrs)->
    new MetricPrototype(attrs)

  $scope.countSavedMetric = () ->
    $scope.savedMetricCount += 1

  MetricPrototype = (attrs={})->
    this.tiers = []
    this.id = if attrs.id then attrs.id else null
    this.addTiers(attrs["tiers"]) if attrs["tiers"] #add tiers if passed on init
    this.name = if attrs.name then attrs.name else ""
    this.rubricId = if attrs.rubric_id then attrs.rubric_id else $scope.rubricId
    this.max_points = if attrs.max_points then attrs.max_points else null
    this.description = if attrs.description then attrs.description else ""
    this.hasChanges = false
  MetricPrototype.prototype =
    addTier: (attrs={})->
      self = this
      newTier = new TierPrototype(self, attrs)
      this.tiers.push newTier
    addTiers: (tiers)->
      self = this
      angular.forEach(tiers, (tier,index)->
        self.addTier(tier)
      )
    isNew: ()->
      this.id is null
    isSaved: ()->
      this.id != null
    change: ()->
      self = this
      if this.isSaved()
        self.hasChanges = true
    resetChanges: ()->
      this.hasChanges = false
    resourceUrl: ()->
      "/metrics/#{self.id}"
    order: ()->
      jQuery.inArray(this, $scope.metrics)
    params: ()->
      self = this
      {
        name: self.name,
        max_points: self.max_points,
        order: self.order(),
        description: self.description,
        rubric_id: self.rubricId
      }
    index: ()->
      this.order()
    destroy: ()->

    remove:(index)->
      $scope.metrics.splice(index,1)
    create: ()->
      self = this
      Restangular.all('metrics').post(this.params())
        .then (response)->
          alert(response.id)
          self.id = response.id
          $scope.countSavedMetric()

    modify: (form)->
      if form.$valid
        if this.isNew()
          this.create()
        else
          this.update()

    update: ()->
      self = this
      if this.hasChanges
        Restangular.one('metrics', self.id).customPUT(self.params())
          .then(
            ()-> , #success
            ()-> # failure
          )
          self.resetChanges()

    delete: (index)->
      self = this
      if confirm("Are you sure you want to delete this metric? Deleting this metric will delete its tiers as well.")
        if this.isSaved()
          $http.delete("/metrics/#{self.id}").success(
            (data,status)->
              self.remove(index)
          )
          .error((err)->
            alert("delete failed!")
          )
        else
          self.remove(index)

  $scope.addMetrics = (existingMetrics)->
    angular.forEach(existingMetrics, (em, index)->
      emProto = new MetricPrototype(em)
      $scope.countSavedMetric() # indicate saved metric present
      $scope.metrics.push emProto
    )

  $scope.newMetric = ()->
    $scope.metrics.push new(MetricPrototype)

  $scope.getNewMetric = ()->
    $scope.newerMetric = Restangular.one('metrics', 'new.json').getList().then ()->
      alert("waffles!")

  $scope.viewMetrics = ()->
    if $scope.metrics.length > 0
      $scope.displayMetrics = []
      angular.forEach($scope.metrics, (value, key)->
        $scope.displayMetrics.push(value.name)
      )
      $scope.displayMetrics

  $scope.existingMetrics = []

  TierPrototype = (metric, attrs={})->
    this.id = attrs.id or null
    this.metric = metric
    this.metric_id = metric.id
    this.name = attrs.name or ""
    this.points = attrs.points || null
    this.description = attrs.description or ""
    this.resetChanges()
  TierPrototype.prototype =
    isNew: ()->
      this.id is null
    isSaved: ()->
      this.id > 0
    change: ()->
      self = this
      if this.isSaved()
        self.hasChanges = true
    resetChanges: ()->
      this.hasChanges = false
    params: ()->
      metric_id: this.metric_id,
      name: this.name,
      points: this.points,
      description: this.description
    create: ()->
      self = this
      Restangular.all('tiers').post(self.params())
        .then(
          (response)-> #success
            self.id = response.id
          (response)-> #error
        )

    modify: (form)->
      if form.$valid
        if this.isNew()
          this.create()
        else
          this.update()

    update: ()->
      if this.hasChanges
        self = this
        Restangular.one('tiers', self.id).customPUT(self.params())
          .then(
            ()-> #success
            ()-> #failure
          )
          self.resetChanges()

     metricName: ()->
       alert this.metric.name

     delete: (index)->
      self = this
      if confirm("Are you sure you want to delete this tier?")
        if this.isSaved()
          $http.delete("/tiers/#{self.id}").success(
            (data,status)->
              self.removeFromMetric(index)
              return true
          )
          .error((err)->
            alert("delete failed!")
            return false
          )
        else
          self.removeFromMetric(index)
     removeFromMetric: (index)->
       this.metric.tiers.splice(index,1)

  # declare a sortableEle variable for the sortable function
  sortableEle = undefined

  # action when a sortable drag begins
  $scope.dragStart = (e, ui) ->
    ui.item.data "start", ui.item.index()
    return

  # action when a sortable drag completes
  $scope.dragEnd = (e, ui) ->
    start = ui.item.data("start")
    end = ui.item.index()
    $scope.metrics.splice end, 0, $scope.metrics.splice(start, 1)[0]
    $scope.$apply()
    $scope.updateMetricOrder()
    return

  # send the metric order to the server with ids
  $scope.updateMetricOrder = ()->
    if $scope.savedMetricCount > 0
      $http.put("/metrics/update_order", metric_order: $scope.orderedMetrics()).success(
      )
      .error(
      )

  # distill key/value pairs for metric ids and relative order
  $scope.orderedMetrics = ()->
    metrics = {}
    angular.forEach($scope.metrics, (value, index)->
      metrics[value.id] = {order: index} if value.id != null
    )
    metrics

  sortableEle = $("#metric-box").sortable(
    start: $scope.dragStart
    update: $scope.dragEnd
  )
  return

