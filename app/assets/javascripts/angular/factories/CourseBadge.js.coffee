@gradecraft.factory 'CourseBadge', ->
  class CourseBadge
	  constructor: (attrs={}) ->
	  	@id = attrs.id
	  	@name = attrs.name
	  	@description = attrs.description
	  	@point_total = attrs.point_total
	  	@icon = attrs.icon
	  	@multiple = attrs.multiple
