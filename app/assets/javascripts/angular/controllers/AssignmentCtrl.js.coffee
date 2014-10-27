@gradecraft.controller 'AssignmentCtrl', ['$scope', '$http', ($scope, $http) -> 

 # hide Rubric Overview by default
 $scope.collapseRubricOverview = false

 $scope.init = (collapseRubricOverview) ->
   $scope.collapseRubricOverview = collapseRubricOverview
