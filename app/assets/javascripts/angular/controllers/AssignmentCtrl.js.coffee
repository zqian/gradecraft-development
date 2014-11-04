@gradecraft.controller 'AssignmentCtrl', ['$scope', '$http', ($scope, $http) -> 

 
  $scope.toggleOverview = () ->
    $scope.collapseOverview = !$scope.collapseOverview
 
  # expand/show the overview on the show assignment page
  $scope.expandOverview = () ->
    $scope.collapseOverview = false
    $scope.updateCollapsedRubric()
 
  # hide the overview on the show assignment page
  $scope.hideOverview = () ->
    $scope.collapseOverview = true
    $scope.updateCollapsedRubric()
 
  $scope.overviewCollapsed = () ->
    $scope.collapseOverview

  # parameters for updating user ui settings
  $scope.collapseParams = () ->
    { collapse: $scope.collapseOverview }
 
  $scope.updateCollapsedRubric = () ->
    $http.put("/users/update_ui", $scope.collapseParams()).success(
      (data,status)->
    )
    .error((err)->
      alert("update failed!")
      return false
    )

  $scope.init = (sessionValue) ->
    if sessionValue != null
      $scope.collapseOverview = sessionValue
    else
      # hide Rubric Overview by default
      $scope.collapseOverview = true

]
