MetricPrototype = ()->
MetricPrototype.prototype =
  tiers: []
  addTier: ()->
    this.tiers.push {}
