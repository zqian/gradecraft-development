# @gradecraft.factory 'TierBadgePrototype', ->
#   TierBadgePrototype = (tier, badge, attrs={create:false}) ->  
#     @tier = tier
#     @badge = badge
#     if badge.name
#       @name = badge.name
#     @tier_id = tier.id
#     @badge_id = badge.id
#     @description = badge.description
#     @point_total = badge.point_total
#     @icon = badge.icon
#     @multiple = badge.multiple
#     @id = null
#     if attrs.create
#       @create()
 
#   TierBadgePrototype.prototype =
#     create: ()->
#       self = this

#       $http.post("/tier_badges", self.createParams()).success(
#         (data,status)->
#           self.id = data.existing_tier_badge.id
#       )
#       .error((err)->
#         alert("create failed!")
#         return false
#       )

#     createParams: ()->
#       tier_id: this.tier.id,
#       badge_id: this.badge.id
 
#   return TierBadgePrototype