@gradecraft.factory 'TierPrototype', ['$http', 'TierBadgePrototype', ($http, TierBadgePrototype) ->
  TierPrototype = (metric, attrs={})->
    this.id = attrs.id or null
    this.metric = metric
    this.badges = {}
    this.availableBadges = angular.copy($scope.courseBadges)
    this.selectedBadge = ""
    this.id = if attrs.id then attrs.id else null

    this.loadTierBadges(attrs["tier_badges"]) if attrs["tier_badges"] #add badges if passed on init
    this.metric_id = metric.id
    this.name = attrs.name or ""
    this.editingBadges = false
    this.points = attrs.points || 0
    this.fullCredit = attrs.full_credit or false
    this.noCredit = attrs.no_credit or false
    this.durable = attrs.durable or false
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
    alert: ()->
      alert("snakes!")        
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
    
    ##grade rubric ctrl
    # loadTierBadge: (tierBadge)->
    #   self = this
    #   courseBadge = self.availableBadges[tierBadge.badge_id]
    #   loadedBadge = new TierBadgePrototype(self, angular.copy(courseBadge))
    #   self.badges[courseBadge.id] = loadedBadge # add tier badge to tier
    #   delete self.availableBadges[courseBadge.id] # remove badge from available badges on tier

    ##rubric ctrl  
    loadTierBadge: (tierBadge)->
      self = this
      courseBadge = self.availableBadges[tierBadge.badge_id]
      loadedBadge = new TierBadgePrototype(self, angular.copy(courseBadge))
      loadedBadge.id = tierBadge.id
      self.badges[courseBadge.id] = loadedBadge # add tier badge to tier
      delete self.availableBadges[courseBadge.id] # remove badge from available badges on tier
      
    # Badges
    loadTierBadges: (tierBadges)->
      self = this
      angular.forEach(tierBadges, (tierBadge, index)->
        if (self.availableBadges[tierBadge.badge_id])
          self.loadTierBadge(tierBadge)
      )
    #rubric ctrl
    # Badges
    addBadge: (attrs={})->
      self = this
      newBadge = new TierBadgePrototype(self, attrs)
      this.badges.splice(-1, 0, newBadge)
    addBadges: (tiers)->
      self = this
      angular.forEach(badges, (badge,index)->
        self.loadBadge(badge)
      )

    selectBadge: ()->
      self = this
      newBadge = new TierBadgePrototype(self, angular.copy(self.selectedBadge), {create: true})

    deleteTierBadge: (badge)->
      self = this
      tierBadge = badge 

      if confirm("Are you sure you want to delete this badge from the tier?")
        $http.delete("/tier_badges/#{tierBadge.id}").success(
          (data,status)->
            self.availableBadges[tierBadge.badge.id] = angular.copy($scope.courseBadges[tierBadge.badge.id])
            delete self.badges[tierBadge.badge.id]
        )
        .error((err)->
          alert("delete failed!")
        )

    resetChanges: ()->
      this.hasChanges = false
    editBadges: ()->
      this.editingBadges = true
    closeBadges: ()->
      this.editingBadges = false
    params: ()->
      metric_id: this.metric_id,
      name: this.name,
      points: this.points,
      description: this.description
    create: ()->
      self = this
      Restangular.all('tiers').post(self.params())
        .then(
          (response)-> #success
            self.id = response.id
          (response)-> #error
        )

    modify: (form)->
      if form.$valid
        if this.isNew()
          this.create()
        else
          this.update()

    update: ()->
      if this.hasChanges
        self = this
        Restangular.one('tiers', self.id).customPUT(self.params())
          .then(
            ()-> #success
            ()-> #failure
          )
          self.resetChanges()

    metricName: ()->
      alert this.metric.name

    delete: (index)->
      self = this
      if this.isSaved()
        if confirm("Are you sure you want to delete this tier?")
          $http.delete("/tiers/#{self.id}").success(
            (data,status)->
              self.removeFromMetric(index)
              return true
          )
          .error((err)->
            alert("delete failed!")
            return false
          )
      else
        self.removeFromMetric(index)
    removeFromMetric: (index)->
      this.metric.tiers.splice(index,1)  
  return TierPrototype      
]