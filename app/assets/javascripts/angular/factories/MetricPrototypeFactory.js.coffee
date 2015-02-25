@gradecraft.factory 'MetricPrototype', ['$http', 'Restangular', 'TierPrototype', 'MetricBadgePrototype', ($http, Restangular, TierPrototype, MetricBadgePrototype) ->
  class MetricPrototype
    constructor: (attrs={}, $scope)->
      @$scope = $scope
      @tiers = []
      @badges = {}
      # @availableBadges = angular.copy($scope.courseBadges)
      # @selectedBadge = ""
      @id = if attrs.id then attrs.id else null
      @fullCreditTier = null
      @addTiers(attrs["tiers"]) if attrs["tiers"] #add tiers if passed on init
      # @loadMetricBadges(attrs["metric_badges"]) if attrs["metric_badges"] #add badges if passed on init
      @name = if attrs.name then attrs.name else ""
      @rubricId = if attrs.rubric_id then attrs.rubric_id else @$scope.rubricId
      if @id
        @max_points = if attrs.max_points then attrs.max_points else 0
      else
        @max_points = if attrs.max_points then attrs.max_points else null

      @description = if attrs.description then attrs.description else ""
      @hasChanges = false

      ## graderubric
      @selectedTier = null
      
      if $scope.rubricGrades
        @rubricGrade = $scope.rubricGrades[@id]

      if @rubricGrade
        @rubricGradeTierId = @rubricGrade.tier_id
      else
        @rubricGradeTierId = null

      if @rubricGrade
        @comments = @rubricGrade.comments
      else
        @comments = ""

      # alert(@selectedTier.id)
      # would this always have an id?
      #@max_points = if attrs.max_points then attrs.max_points else 0
    alert: ()->
      alert("snakes!")    
    addTier: (attrs={})->
      self = this
      newTier = new TierPrototype(self, attrs, self.$scope)
      self.tiers.push newTier
      if self.rubricGradeTierId and self.rubricGradeTierId == newTier.id
        # alert(self.rubricGradeTierId)
        # alert(newTier.id)
        self.selectedTier = newTier
    #what is different here? // from GradeRubric
      # addTier: (attrs={})->
      #   self = this
      #   newTier = new TierPrototype(self, attrs, $scope)
      #   @tiers.splice(-1, 0, newTier)    
      # loadTier: (attrs={})->
      #   self = this
      #   newTier = new TierPrototype(self, attrs, $scope)
      #   @tiers.push newTier
      # addTiers: (tiers)->
      #   self = this
      #   angular.forEach(tiers, (tier,index)->
      #     self.loadTier(tier)
      #   )

    addTiers: (tiers)->
      self = this
      angular.forEach(tiers, (tier,index)->
        self.addTier(tier)
      )
    resourceUrl: ()->
      "/metrics/#{self.id}"
    order: ()->
      self = this
      jQuery.inArray(this, self.$scope.metrics)

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
      @order()
    createRubricGrade: ()->
      self = this
      $http.post("/rubric_grades.json", self.rubricGradeParams()).success(
      )
      .error(
      )
    gradeWithTier: (tier)->
      if @isUsingTier(tier)
        @selectedTier = null
      else
        @selectedTier = tier
    isUsingTier: (tier)->
      @selectedTier == tier
    rubricGradeParams: ()->
      metric = this
      tier = @selectedTier
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
            self.availableBadges[metricBadge.badge.id] = angular.copy(self.$scope.courseBadges[metricBadge.badge.id])
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
      @id is null
    isSaved: ()->
      @id != null
    change: ()->
      self = this
      if @fullCreditTier
        @updateFullCreditTier()
      if @isSaved()
        self.hasChanges = true
    updateFullCreditTier: ()->
      @tiers[0].points = @max_points
    resetChanges: ()->
      @hasChanges = false
    params: ()->
      self = this
      {
        name: self.name,
        max_points: self.max_points,
        order: self.order(),
        description: self.description,
        rubric_id: self.rubricId
      }
    destroy: ()->

    remove:(index)->
      self = this
      self.$scope.metrics.splice(index,1)
    create: ()->
      self = this
      Restangular.all('metrics').post(@params())
        .then (response)->
          metric = response.existing_metric
          self.id = metric.id
          self.$scope.countSavedMetric()
          self.addTiers(metric.tiers)

    modify: (form)->
      if form.$valid
        if @isNew()
          @create()
        else
          @update()

    update: ()->
      self = this
      if @hasChanges
        Restangular.one('metrics', self.id).customPUT(self.params())
          .then(
            ()-> , #success
            ()-> # failure
          )
          self.resetChanges()

    delete: (index)->
      self = this
      if @isSaved()
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
]  