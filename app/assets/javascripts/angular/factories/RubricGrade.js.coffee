@gradecraft.factory 'RubricGrade', ->
	class RubricGrade
		constructor: (attrs={})->
		  @id = attrs.id
		  @metric_id = attrs.metric_id
		  @tier_id = attrs.tier_id
		  @comments = attrs.comments
