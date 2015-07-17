angular-json-api
================

## Deprecated
This lib isn't longer maintained and doesn't reflect current v1.0 jsonApi. Don't use it. Maybe I'll continue develope it in the future, I don't know

## Installation

```bower install --save angular-json-api```

## Usage

```coffee
 angular.module('awesomeApp')
 .controller 'MyCtrl', (jsonApi, $scope) ->

   $scope.item = {}
   # Short version ($scope.item will be replaced by reference,
   # when request will be fullfilled, so no chain needed)
   jsonApi.getIn(type: 'products', $scope.item)

   # or by hand promise
   jsonApi.get(type: 'products')
     .then (item) ->
       $scope.item = item
```


Angular json-api implementation

See docs [here](http://alexbyk.github.io/angular-json-api/angular-json-api.html)
