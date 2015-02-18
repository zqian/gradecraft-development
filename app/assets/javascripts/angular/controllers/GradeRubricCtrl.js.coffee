@gradecraft.controller 'GradeRubricCtrl', ['$scope', 'Restangular', '$http', ($scope, Restangular, $http) -> 

  $scope.metrics = []
  $scope.courseBadges = {}
  $scope.rubricGrades = {} # index in hash with metric_id as key
  $scope.gsiGradeStatuses = ["In Progress", "Graded"]
  $scope.professorGradeStatuses = ["In Progress", "Graded", "Released"]

  $scope.pointsPossible = 0
  $scope.pointsGiven = 0

  $scope.init = (rubricId, metrics, assignmentId, studentId, rubricGrades, gradeStatus, courseBadges, releaseNecessary)->
    $scope.rubricId = rubricId
    $scope.assignmentId = assignmentId
    $scope.studentId = studentId
    if gradeStatus
      $scope.gradeStatus = gradeStatus
    else
      $scope.gradeStatus = ""

    # use 'Graded' for all assignments for which release is necessary, bypass ui
    $scope.releaseNecessary = releaseNecessary
    if not $scope.releaseNecessary
      $scope.gradeStatus = "Graded"

    $scope.addRubricGrades(rubricGrades)
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


  $scope.selectedTierIds = []
  # count how many tiers have been selected in the UI
  $scope.selectedTierIds = ()->
    tierIds = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        tierIds.push metric.selectedTier.id
    )
    $scope.selectedTierIds = tierIds
    tierIds

  $scope.allMetricIds = []
  # ids of all the metrics in the rubric
  $scope.allMetricIds = ()->
    metricIds = []
    angular.forEach($scope.metrics, (metric, index)->
      metricIds.push metric.id
    )
    $scope.allMetricIds = metricIds
    metricIds

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
    metrics 

  $scope.selectedMetrics = ()->
    metrics = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        metrics.push metric
    )
    $scope.selectedMetrics = metrics
    metrics 

  $scope.gradedMetricsParams = ()->
    params = []
    angular.forEach($scope.gradedMetrics(), (metric, index)->
      # get params just from the metric object
      metricParams = $scope.metricOnlyParams(metric,index)

      # add params from the tier if a tier has been selected
      if metric.selectedTier
        jQuery.extend(metricParams, $scope.gradedTierParams(metric))

      # create params for the rubric grade regardless
      params.push metricParams
    )
    params

  # params for just the metric
  $scope.metricOnlyParams = (metric,index)->
    {
      metric_name: metric.name,
      metric_description: metric.description,
      max_points: metric.max_points,
      order: index,
      metric_id: metric.id,
      comments: metric.comments
    }

  # additional tier params if a tier is selected
  $scope.gradedTierParams = (metric) ->
    {
      tier_name: metric.selectedTier.name,
      tier_description: metric.selectedTier.description,
      points: metric.selectedTier.points,
      tier_id: metric.selectedTier.id
    }

  $scope.tierBadgesParams = ()->
    params = []
    # alert("# of graded metrics:" + $scope.gradedMetrics.length)
    angular.forEach($scope.gradedMetrics(), (metric, index)->
      # alert(metric.name)
      # grab the selected tier for the active metric
      tier = metric.selectedTier
      angular.forEach(tier.badges, (badge, index)->
        params.push {
          name: badge.name,
          tier_id: tier.id,
          metric_id: tier.metric_id,
          badge_id: badge.badge.id,
          description: badge.description,
          point_total: badge.point_total,
          icon: badge.icon,
          multiple: badge.multiple
        }
      )
    )
    return params

  $scope.gradedRubricParams = ()->
    {
      points_given: $scope.pointsGiven(),
      rubric_id: $scope.rubricId,
      student_id: $scope.studentId,
      points_possible: $scope.pointsPossible,
      rubric_grades: $scope.gradedMetricsParams(),
      tier_badges: $scope.tierBadgesParams(),
      tier_ids: $scope.selectedTierIds(),
      metric_ids: $scope.allMetricIds(),
      grade_status: $scope.gradeStatus
    }

  $scope.submitGrade = ()->
    self = this
    if confirm "Are you sure you want to submit the grade for this assignment?"
      # alert(self.gradedRubricParams().tier_badges.length)
      $http.put("/assignments/#{$scope.assignmentId}/grade/submit_rubric", self.gradedRubricParams()).success(
        window.location = "/assignments/#{$scope.assignmentId}"
      )
      .error(
      )

  # Rubric Grades
  RubricGradePrototype = (attrs={})->
    this.id = attrs.id
    this.metric_id = attrs.metric_id
    this.tier_id = attrs.tier_id
    this.comments = attrs.comments

  RubricGradePrototype.prototype = {}

  $scope.addRubricGrades = (rubricGrades)->
    angular.forEach(rubricGrades, (rg, index)->
      rubricGrade = new RubricGradePrototype(rg)
      $scope.rubricGrades[rg.metric_id] = rubricGrade
    )

  # Badge Section
  CourseBadgePrototype = (attrs={})->
    this.id = attrs.id
    this.name = attrs.name
    this.description = attrs.description
    this.point_total = attrs.point_total
    this.icon = attrs.icon
    this.multiple = attrs.multiple

  CourseBadgePrototype.prototype = {}

  $scope.addCourseBadges = (courseBadges)->
    angular.forEach(courseBadges, (badge, index)->
      courseBadge = new CourseBadgePrototype(badge)
      $scope.courseBadges[badge.id] = courseBadge
    )

  MetricBadgePrototype = (metric, badge, attrs={})->
    this.metric = metric
    this.badge = badge
    this.create()
    this.name = badge.name
    this.metric_id = metric.id
    this.badge_id = badge.id
    this.description = badge.description
    this.point_total = badge.point_total
    this.icon = badge.icon
    this.multiple = badge.multiple

  MetricBadgePrototype.prototype =
    create: ()->
      self = this

      $http.post("/metric_badges", self.createParams()).success(
        (data,status)->
          self.id = data.existing_metric_badge.id
      )
      .error((err)->
        alert("create failed!")
        return false
      )

    createParams: ()->
      metric_id: this.metric.id,
      badge_id: this.badge.id

  TierBadgePrototype = (tier, badge, attrs={})->
    this.tier = tier
    this.badge = badge
    this.name = badge.name
    this.tier_id = tier.id
    this.badge_id = badge.id
    this.description = badge.description
    this.point_total = badge.point_total
    this.icon = badge.icon
    this.multiple = badge.multiple

  MetricPrototype = (attrs={})->
    this.tiers = []
    this.selectedTier = null
    this.hasChanges = false
    this.id = if attrs.id then attrs.id else null
    this.rubricGrade = $scope.rubricGrades[this.id]

    if this.rubricGrade
      this.rubricGradeTierId = this.rubricGrade.tier_id
    else
      this.rubricGradeTierId = null

    if this.rubricGrade
      this.comments = this.rubricGrade.comments
    else
      this.comments = ""

    this.addTiers(attrs["tiers"]) if attrs["tiers"] #add tiers if passed on init
    # alert(this.selectedTier.id)
    this.name = if attrs.name then attrs.name else ""
    this.rubricId = if attrs.rubric_id then attrs.rubric_id else $scope.rubricId
    this.max_points = if attrs.max_points then attrs.max_points else 0
    this.description = if attrs.description then attrs.description else ""
  MetricPrototype.prototype =
    addTier: (attrs={})->
      self = this
      newTier = new TierPrototype(self, attrs)
      self.tiers.push newTier
      if self.rubricGradeTierId and self.rubricGradeTierId == newTier.id
        # alert(self.rubricGradeTierId)
        # alert(newTier.id)
        self.selectedTier = newTier
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
        comments: metric.comments
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
    this.badges = {}
    this.availableBadges = angular.copy($scope.courseBadges)
    this.loadTierBadges(attrs["tier_badges"]) if attrs["tier_badges"] #add badges if passed on init
    this.points = attrs.points || 0
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
     loadTierBadge: (tierBadge)->
       self = this
       courseBadge = self.availableBadges[tierBadge.badge_id]
       loadedBadge = new TierBadgePrototype(self, angular.copy(courseBadge))
       self.badges[courseBadge.id] = loadedBadge # add tier badge to tier
       delete self.availableBadges[courseBadge.id] # remove badge from available badges on tier
      
     # Badges
     loadTierBadges: (tierBadges)->
       self = this
       angular.forEach(tierBadges, (tierBadge, index)->
         if (self.availableBadges[tierBadge.badge_id])
           self.loadTierBadge(tierBadge)
       )

  ]
