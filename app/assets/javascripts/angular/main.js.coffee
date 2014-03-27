@gradecraft = angular.module('gradecraft', ['restangular', 'ui.sortable', 'ng-rails-csrf'])

INTEGER_REGEXP = /^\-?\d+$/
@gradecraft.directive "integer", ->
  require: "ngModel"
  link: (scope, elm, attrs, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      if INTEGER_REGEXP.test(viewValue)
        # it is valid
        ctrl.$setValidity "integer", true
        viewValue
      else
        # it is invalid, return undefined (no model update)
        ctrl.$setValidity "integer", false
        'undefined'

    return

FLOAT_REGEXP = /^\-?\d+((\.|\,)\d+)?$/
@gradecraft.directive "smartFloat", ->
  require: "ngModel"
  link: (scope, elm, attrs, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      if FLOAT_REGEXP.test(viewValue)
        ctrl.$setValidity "float", true
        parseFloat viewValue.replace(",", ".")
      else
        ctrl.$setValidity "float", false
        `undefined`

    return

@gradecraft.directive "ngMax", ->
  require: "ngModel"
  link: (scope, elm, attr, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      value = viewValue
      #alert("value:" + value)
      max = scope.$eval(attr.ngMax)
      #alert("max:" + max)
      if value and value != "" and value > max
        ctrl.$setValidity "ngMax", false
        'undefined'
      else
        ctrl.$setValidity "ngMax", true
        value

    return

# @gradecraft.directive "ngMin", ->
#   restrict: "A"
#   require: "ngModel"
#   link: (scope, elem, attr, ctrl) ->
#     scope.$watch attr.ngMin, ->
#       ctrl.$setViewValue ctrl.$viewValue
#       return
# 
#     minValidator = (value) ->
#       min = scope.$eval(attr.ngMin) or 0
#       if value and value != "" and value < min
#         ctrl.$setValidity "ngMin", false
#         'undefined'
#       else
#         ctrl.$setValidity "ngMin", true
#         value
# 
#     ctrl.$parsers.push minValidator
#     ctrl.$formatters.push minValidator
#     return
# 
# @gradecraft.directive "ngMax", ->
#   restrict: "A"
#   require: "ngModel"
#   link: (scope, elem, attr, ctrl) ->
#     scope.$watch attr.ngMax, ->
#       ctrl.$setViewValue ctrl.$viewValue
#       return
# 
#     maxValidator = (value) ->
#       max = scope.$eval(attr.ngMax) or Infinity
#       if value and value != "" and value > max
#         ctrl.$setValidity "ngMax", false
#         'undefined'
#       else
#         ctrl.$setValidity "ngMax", true
#         value
# 
#     ctrl.$parsers.push maxValidator
#     ctrl.$formatters.push maxValidator
#     return
