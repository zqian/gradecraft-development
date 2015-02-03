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