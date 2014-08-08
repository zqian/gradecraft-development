@gradecraft.controller 'GradeRubricCtrl', ($scope, Restangular, $http) -> 

  $scope.metrics = []
  $scope.gradedMetrics = []

  $scope.pointsPossible = 0
  $scope.pointsGiven = 0

  $scope.init = (rubricId, metrics, assignmentId, studentId)->
    $scope.rubricId = rubricId
    $scope.assignmentId = assignmentId
    $scope.studentId = studentId
    $scope.addMetrics(metrics)

  # distill key/value pairs for metric ids and relative order
  $scope.pointsAssigned = ()->
    points = 0
    angular.forEach($scope.metrics, (metric, index)->
      points += metric.max_points if metric.max_points
    )
    points or 0

  $scope.pointsDifference = ()->
    $scope.pointsPossible - $scope.pointsGiven()

  $scope.pointsRemaining = ()->
    pointsRemaining = $scope.pointsDifference()
    if pointsRemaining > 0 then pointsRemaining else 0

  # Methods for identifying point deficit/overage
  $scope.pointsMissing = ()->
    $scope.pointsDifference() > 0 and $scope.pointsGiven() > 0

  $scope.pointsSatisfied = ()->
    $scope.pointsDifference() == 0 and $scope.pointsGiven() > 0

  $scope.pointsOverage = ()->
    $scope.pointsDifference() < 0

  $scope.showMetric = (attrs)->
    new MetricPrototype(attrs)

  # count how many tiers have been selected in the UI
  $scope.tiersSelected = []
  $scope.selectedTiers = ()->
    tiers = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        tiers.push metric.selectedTier
    )
    $scope.tiersSelected = tiers
    tiers

  # count how many points have been given from those tiers
  $scope.pointsGiven = ()->
    points = 0
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        points += metric.selectedTier.points
    )
    points 

  $scope.gradedMetrics = ()->
    metrics = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        metrics.push metric
    )
    $scope.gradedMetrics = metrics
    metrics 

  $scope.gradedMetricsParams = ()->
    params = []
    angular.forEach($scope.gradedMetrics(), (metric, index)->
       params.push {
        metric_name: metric.name,
        metric_description: metric.description,
        max_points: metric.max_points,
        order: index,
        tier_name: metric.selectedTier.name,
        tier_description: metric.selectedTier.description,
        points: metric.selectedTier.points,
        metric_id: metric.id,
        tier_id: metric.selectedTier.id,
        comments: metric.comments
       }
    )
    params

  $scope.gradedRubricParams = ()->
    {
      points_given: $scope.pointsGiven(),
      rubric_id: $scope.rubricId,
      student_id: $scope.studentId,
      points_possible: $scope.pointsPossible,
      rubric_grades: $scope.gradedMetricsParams()
    }

  $scope.submitGrade = ()->
    if confirm "Are you sure you want to submit the grade for this assignment?"
      self = this
      $http.put("/assignments/#{$scope.assignmentId}/grade/submit_rubric", self.gradedRubricParams()).success(
        window.location = "/assignments/#{$scope.assignmentId}"
      )
      .error(
      )

  MetricPrototype = (attrs={})->
    this.tiers = []
    this.id = if attrs.id then attrs.id else null
    this.addTiers(attrs["tiers"]) if attrs["tiers"] #add tiers if passed on init
    this.name = if attrs.name then attrs.name else ""
    this.rubricId = if attrs.rubric_id then attrs.rubric_id else $scope.rubricId
    this.max_points = if attrs.max_points then attrs.max_points else null
    this.description = if attrs.description then attrs.description else ""
    this.hasChanges = false
    this.selectedTier = null
    this.comments = ""
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
    createRubricGrade: ()->
      self = this
      $http.post("/rubric_grades.json", self.rubricGradeParams()).success(
      )
      .error(
      )
    gradeWithTier: (tier)->
      if this.isUsingTier(tier)
        this.selectedTier = null
      else
        this.selectedTier = tier
    isUsingTier: (tier)->
      this.selectedTier == tier
    rubricGradeParams: ()->
      metric = this
      tier = this.selectedTier
      {
        metric_name: metric.name,
        metric_description: metric.description,
        max_points: metric.max_points,
        order: metric.order,
        tier_name: tier.name,
        tier_description: tier.description,
        points: tier.points,
        submission_id: submission_id,
        metric_id: metric.id,
        tier_id: tier.id,
        comments: ""
      }

  $scope.addMetrics = (existingMetrics)->
    angular.forEach(existingMetrics, (metric, index)->
      metricObject = new MetricPrototype(metric)
      $scope.metrics.push metricObject
      $scope.pointsPossible += metricObject.max_points
    )

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
     metricName: ()->
       alert this.metric.name
     removeFromMetric: (index)->
       this.metric.tiers.splice(index,1)