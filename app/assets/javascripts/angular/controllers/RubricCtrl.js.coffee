@gradecraft.controller 'RubricCtrl', ($scope, Restangular, $http) -> 

  $scope.metrics = []
  INTEGER_REGEXP = /^\-?\d+$/

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
    create: ()->
      this.id = 1
    update: ()->
      alert("update!")

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




