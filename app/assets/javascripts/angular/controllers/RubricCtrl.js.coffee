@gradecraft.controller 'RubricCtrl', ($scope, Restangular, $http) -> 

  $scope.metrics = []
  INTEGER_REGEXP = /^\-?\d+$/
  Restangular.setRequestSuffix('.json')

  MetricPrototype = ()->
    this.tiers = []
    this.id = null
    this.name = ""
    this.max_points = null
    this.description = ""
    this.resetChanges()
  MetricPrototype.prototype =
    addTier: ()->
      self = this
      newTier = new TierPrototype(self.id)
      this.tiers.push newTier
    removeTier: (index)->
      this.tiers.splice(index,1)
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
    params: ()-> {
      name: this.name,
      max_points: this.max_points,
      order: this.order(),
      description: this.description
    }
    order: ()->
      1
    create: ()->
      self = this
      Restangular.all('metrics').post(this.params())
        .then (response)->
          self.id = response.id

    update: ()->
      self = this
      if this.hasChanges
        Restangular.one('metrics', self.id).customPUT(self.params())
          .then(
            ()-> alert("shit worked!"),
            ()-> alert("shit broke!")
          )
          self.resetChanges()

    delete: ()->
      if this.isSaved() and confirm("Are you sure you want to delete this metric?")
        Restangular.one('metrics', this.id).remove

  TierPrototype = (metric_id)->
    this.id = null
    this.metric_id = metric_id
    this.name = ""
    this.points = null
    this.description = ""
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
      name: this.name,
      points: this.points,
      description: this.description,
      metric_id: this.metric_id
    create: ()->
      self = this
      Restangular.all('tiers').post(this.params())
        .then(
          (response)->
            self.id = response.id
            alert("shit worked!")
          (response)->
            alert("shit blew up!")
        )

    modify: ()->
      if this.isNew()
        this.create()
      else
        this.update()

    update: ()->
      self = this
      Restangular.one('tiers', self.id).customPUT(self.params())
        .then(
          ()-> alert("shit worked!"),
          ()-> alert("shit broke!")
        )
        self.resetChanges()
    delete: ()->
      if this.isSaved() and confirm("Are you sure you want to delete this metric?")
        Restangular.one('tier', this.id).remove

  $scope.newMetric = ()->
    $scope.metrics.push new(MetricPrototype)

  $scope.getNewMetric = ()->
    $scope.newerMetric = Restangular.one('metrics', 'new.json').getList().then ()->
      alert("waffles!")

  $scope.destroyMetric = (index)->
    $scope.metrics.splice(index,1)

  $scope.sortableOptions =
    update: (e, ui) ->
      if ui.item.scope().item == "can't be moved"
        ui.item.sortable.cancel()
