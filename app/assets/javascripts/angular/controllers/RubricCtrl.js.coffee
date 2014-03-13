@gradecraft.controller 'RubricCtrl', ($scope, Restangular, $http) -> 

  # $scope.metrics.get()
  # $scope.metrics.push Restangular.one("metrics", "new").get()
  # $http.get("metrics/new.json")
  
  $scope.metrics = []

  MetricPrototype = ()->
  MetricPrototype.prototype =
    tiers: []
    addTier: ()->
      this.tiers.push {}

  $scope.newMetric = ()->
    $scope.metrics.push new(MetricPrototype)

  $scope.getNewMetric = ()->
    $scope.newerMetric = Restangular.one('metrics', 'new.json').getList().then ()->
      alert("waffles!")

  $scope.sortableOptions =
    update: (e, ui) ->
      if ui.item.scope().item == "can't be moved"
        ui.item.sortable.cancel()

#   # This is the rubric we use for the form
#   $scope.rubric = new Rubric()
# 
#   # Rubrics for the list
#   $scope.rubrics = Rubric.query()
# 
#   # Add a new rubric
#   $scope.add = ->
#     # add to the local array and also save to the server
#     $scope.rubrics.push Rubric.save title: $scope.rubric.title, body: $scope.rubric.body
#     # reset the rubric for the form
#     $scope.rubric = new Rubric()
# 
#   # Delete a rubric
#   $scope.delete = ($index) ->
#     # Yay, UX!
#     if confirm("Are you sure you want to delete this rubric?")
#       # Remove from the server
#       $scope.rubrics[$index].$delete()
#       # Remove from the local array
#       $scope.rubrics.splice($index, 1)
