@gradecraft.service('MetricService', ()->
  this.tiers = []
  this.addTier = ()->
    this.tiers.push {}
)
