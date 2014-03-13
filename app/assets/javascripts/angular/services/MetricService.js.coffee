@gradecraft.service('MetricService', ()->
  this.tiers = []
  this.addTier = ()->
    tiers.push {}
)
