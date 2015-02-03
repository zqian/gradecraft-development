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
  this.name = if attrs.name then attrs.name else ""
  this.rubricId = if attrs.rubric_id then attrs.rubric_id else $scope.rubricId
  this.max_points = if attrs.max_points then attrs.max_points else 0
  this.description = if attrs.description then attrs.description else ""

MetricPrototype.prototype =
  addTier: (attrs={})->
    self = this
    newTier = new TierPrototype(self, attrs)
    self.tiers.push newTier
    if self.rubricGradeTierId == newTier.id
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