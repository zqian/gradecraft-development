@gradecraft.controller 'RubricCtrl', ['$scope', 'Restangular', 'MetricBadgePrototype', 'CourseBadgePrototype', '$http', ($scope, Restangular, MetricBadgePrototype, CourseBadgePrototype, $http) -> 


 # hide modal window by default
 $scope.modalShown = false
 $scope.toggleModal = ->
   $scope.modalShown = not $scope.modalShown
   return

  INTEGER_REGEXP = /^\-?\d+$/
  Restangular.setRequestSuffix('.json')
  $scope.metrics = []
  $scope.courseBadges = {}
  $scope.savedMetricCount = 0

  $scope.init = (rubricId, pointTotal, metrics, courseBadges)->
    $scope.rubricId = rubricId
    $scope.pointTotal = parseInt(pointTotal)
    $scope.addCourseBadges(courseBadges)
    $scope.addMetrics(metrics)

  # distill key/value pairs for metric ids and relative order
  $scope.pointsAssigned = ()->
    points = 0
    angular.forEach($scope.metrics, (metric, index)->
      points += metric.max_points if metric.max_points
    )
    points or 0

  $scope.pointsDifference = ()->
    $scope.pointTotal - $scope.pointsAssigned()
 
  $scope.pointsRemaining = ()->
    pointsRemaining = $scope.pointsDifference()
    if pointsRemaining > 0 then pointsRemaining else 0

  # Methods for identifying point deficit/overage
  $scope.pointsMissing = ()->
    $scope.pointsDifference() > 0 and $scope.pointsAssigned() > 0

  # check whether points overview is hidden
  # $scope.pointsOverviewHidden = ()->
  #  element = angular.element(document.querySelector('#points-overview'))
  #  element.is('visible')

  $scope.pointsSatisfied = ()->
    $scope.pointsDifference() == 0 and $scope.pointsAssigned() > 0

  $scope.pointsOverage = ()->
    $scope.pointsDifference() < 0

  $scope.showMetric = (attrs)->
    new MetricPrototype(attrs)

  $scope.countSavedMetric = () ->
    $scope.savedMetricCount += 1

  $scope.addCourseBadges = (courseBadges)->
    angular.forEach(courseBadges, (badge, index)->
      courseBadge = new CourseBadgePrototype(badge)
      $scope.courseBadges[badge.id] = courseBadge
    )

  TierBadgePrototype = (tier, badge, attrs={create:false})->
    this.tier = tier
    this.id = null
    this.badge = badge
    if attrs.create
      this.create()
    this.name = badge.name
    this.description = badge.description
    this.point_total = badge.point_total
    this.icon = badge.icon
    this.multiple = badge.multiple

  TierBadgePrototype.prototype =
    create: ()->
      self = this

      $http.post("/tier_badges", self.createParams()).success(
        (data,status)->
          self.id = data.existing_tier_badge.id
      )
      .error((err)->
        alert("create failed!")
        return false
      )

    createParams: ()->
      tier_id: this.tier.id,
      badge_id: this.badge.id  

  # Metrics Section
  MetricPrototype = (attrs={})->
    this.tiers = []
    this.badges = {}
    # this.availableBadges = angular.copy($scope.courseBadges)
    # this.selectedBadge = ""
    this.id = if attrs.id then attrs.id else null
    this.fullCreditTier = null
    this.addTiers(attrs["tiers"]) if attrs["tiers"] #add tiers if passed on init
    # this.loadMetricBadges(attrs["metric_badges"]) if attrs["metric_badges"] #add badges if passed on init
    this.name = if attrs.name then attrs.name else ""
    this.rubricId = if attrs.rubric_id then attrs.rubric_id else $scope.rubricId
    if this.id
      this.max_points = if attrs.max_points then attrs.max_points else 0
    else
      this.max_points = if attrs.max_points then attrs.max_points else null

    this.description = if attrs.description then attrs.description else ""
    this.hasChanges = false
  MetricPrototype.prototype =
    # Tiers
    alert: ()->
      alert("snakes!")
    addTier: (attrs={})->
      self = this
      newTier = new TierPrototype(self, attrs)
      this.tiers.splice(-1, 0, newTier)
    addTiers: (tiers)->
      self = this
      angular.forEach(tiers, (tier,index)->
        self.loadTier(tier)
      )
    loadTier: (attrs={})->
      self = this
      newTier = new TierPrototype(self, attrs)
      this.tiers.push newTier

    loadMetricBadge: (metricBadge)->
      self = this
      courseBadge = self.availableBadges[metricBadge.badge_id]
      loadedBadge = new MetricBadgePrototype(self, angular.copy(courseBadge))
      self.badges[courseBadge.id] = loadedBadge # add metric badge to metric
      delete self.availableBadges[courseBadge.id] # remove badge from available badges on metric
     
    # Badges
    loadMetricBadges: (metricBadges)->
      self = this
      angular.forEach(metricBadges, (metricBadge, index)->
        if (self.availableBadges[metricBadge.badge_id])
          self.loadMetricBadge(metricBadge)
      )

    selectBadge: ()->
      self = this
      newBadge = new MetricBadgePrototype(self, angular.copy(self.selectedBadge))
      self.badges[newBadge.badge.id] = newBadge # add metric badge to metric
      delete self.availableBadges[self.selectedBadge.id] # remove badge from available badges on metric
      self.selectedBadge = "" # reset selected badge

    deleteMetricBadge: (badge)->
      self = this
      metricBadge = badge 

      if confirm("Are you sure you want to delete this badge from the metric?")
        $http.delete("/metric_badges/#{metricBadge.id}").success(
          (data,status)->
            self.availableBadges[metricBadge.badge.id] = angular.copy($scope.courseBadges[metricBadge.badge.id])
            delete self.badges[metricBadge.badge.id]
        )
        .error((err)->
          alert("delete failed!")
        )

    badgeIds: ()->
      # distill ids for all badges
      self = this
      badgeIds = []
      angular.forEach(self.badges, (badge, index)->
        badgeIds.push(badge.id)
      )
      badgeIds

    isNew: ()->
      this.id is null
    isSaved: ()->
      this.id != null
    change: ()->
      self = this
      if this.fullCreditTier
        this.updateFullCreditTier()
      if this.isSaved()
        self.hasChanges = true
    updateFullCreditTier: ()->
      this.tiers[0].points = this.max_points
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
          metric = response.existing_metric
          self.id = metric.id
          $scope.countSavedMetric()
          self.addTiers(metric.tiers)

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
      if this.isSaved()
        if confirm("Are you sure you want to delete this metric? Deleting this metric will delete its tiers as well.")
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
    this.badges = {}
    this.availableBadges = angular.copy($scope.courseBadges)
    this.selectedBadge = ""
    this.id = if attrs.id then attrs.id else null

    this.loadTierBadges(attrs["tier_badges"]) if attrs["tier_badges"] #add badges if passed on init
    this.metric_id = metric.id
    this.name = attrs.name or ""
    this.editingBadges = false
    this.points = attrs.points
    this.fullCredit = attrs.full_credit or false
    this.noCredit = attrs.no_credit or false
    this.durable = attrs.durable or false
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
    alert: ()->
      alert("snakes!")

    # Badges
    addBadge: (attrs={})->
      self = this
      newBadge = new TierBadgePrototype(self, attrs)
      this.badges.splice(-1, 0, newBadge)
    addBadges: (tiers)->
      self = this
      angular.forEach(badges, (badge,index)->
        self.loadBadge(badge)
      )

    loadTierBadge: (tierBadge)->
      self = this
      courseBadge = self.availableBadges[tierBadge.badge_id]
      loadedBadge = new TierBadgePrototype(self, angular.copy(courseBadge))
      loadedBadge.id = tierBadge.id
      self.badges[courseBadge.id] = loadedBadge # add tier badge to tier
      delete self.availableBadges[courseBadge.id] # remove badge from available badges on tier
     
    # Badges
    loadTierBadges: (tierBadges)->
      self = this
      angular.forEach(tierBadges, (tierBadge, index)->
        if (self.availableBadges[tierBadge.badge_id])
          self.loadTierBadge(tierBadge)
      )

    selectBadge: ()->
      self = this
      newBadge = new TierBadgePrototype(self, angular.copy(self.selectedBadge), {create: true})
      self.badges[newBadge.badge.id] = newBadge # add tier badge to tier
      delete self.availableBadges[self.selectedBadge.id] # remove badge from available badges on tier
      self.selectedBadge = "" # reset selected badge

    deleteTierBadge: (badge)->
      self = this
      tierBadge = badge 

      if confirm("Are you sure you want to delete this badge from the tier?")
        $http.delete("/tier_badges/#{tierBadge.id}").success(
          (data,status)->
            self.availableBadges[tierBadge.badge.id] = angular.copy($scope.courseBadges[tierBadge.badge.id])
            delete self.badges[tierBadge.badge.id]
        )
        .error((err)->
          alert("delete failed!")
        )


    resetChanges: ()->
      this.hasChanges = false
    editBadges: ()->
      this.editingBadges = true
    closeBadges: ()->
      this.editingBadges = false
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
      if this.isSaved()
        if confirm("Are you sure you want to delete this tier?")
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

  ]
