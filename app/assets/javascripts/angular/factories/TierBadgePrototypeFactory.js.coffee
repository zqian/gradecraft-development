@gradecraft.factory 'TierBadgePrototype', ['$http', ($http) ->
  TierBadgePrototype = (tier, badge, attrs={create:false}) ->  
    @tier = tier
    @badge = badge
    if badge.name
      @name = badge.name
    @tier_id = tier.id
    @badge_id = badge.id
    @description = badge.description
    @point_total = badge.point_total
    @icon = badge.icon
    @multiple = badge.multiple
    @id = null
    if attrs.create
      @create()
 
  TierBadgePrototype.prototype =
    create: ()->
      self = this

      $http.post("/tier_badges", self.createParams()).success(
        (data,status)->
          self.id = data.existing_tier_badge.id
          self.tier.badges[self.badge_id] = self # add tier badge to tier
          delete self.tier.availableBadges[self.badge_id] # remove badge from available badges on tier
          #self.selectedBadge = "" # reset selected badge
      )
      .error((err)->
        alert("create failed!")
        return false
      )

    createParams: ()->
      tier_id: this.tier.id,
      badge_id: this.badge.id
 
  return TierBadgePrototype

]