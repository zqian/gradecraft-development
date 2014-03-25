@gradecraft = angular.module('gradecraft', ['restangular', 'ui.sortable'])

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
app.directive "smartFloat", ->
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
