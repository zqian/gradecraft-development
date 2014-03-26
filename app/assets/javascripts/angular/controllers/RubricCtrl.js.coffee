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
    this.initialize()
  MetricPrototype.prototype =
    initialize: ()->
    addTier: ()->
      this.tiers.push {id: null}
    removeTier: (index)->
      this.tiers.splice(index,1)
    isNew: ()->
      this.id is null
    isSaved: ()->
      this.id > 0
    params: ()-> {
      name: this.name,
      max_points: this.max_points,
      order: this.order(),
      description: this.description
    }
    order: ()->
      1
    create: ()->
      Restangular.all('metrics').post(this.params())
        .then (response)->
          this.id = response.id

    update: ()->
      Restangular.one('metrics', this.id).put(this.params())
        .then (response)->
          alert(response.id)
    delete: ()->
      if this.isSaved() and confirm("Are you sure you want to delete this metric?")
        Restangular.one('metrics', this.id).remove

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
