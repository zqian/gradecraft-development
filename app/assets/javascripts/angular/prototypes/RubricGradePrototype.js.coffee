  # Rubric Grades
RubricGradePrototype = (attrs={})->
  this.id = attrs.id
  this.metric_id = attrs.metric_id
  this.tier_id = attrs.tier_id
	this.comments = attrs.comments

RubricGradePrototype.prototype = {}