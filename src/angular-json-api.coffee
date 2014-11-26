'use strict'

objUtil = null
MSG_NOT_ARRAY = 'items must be an array and have $isArray attribute eq true'

angular
.module('json-api', ['object-util'])
.provider 'jsonApi', () ->
  idKey = null
  base  = null

  @idKey = (val) ->
    return idKey unless val?
    idKey = val
    @

  @base = (val) ->
    return base unless val?
    base = val
    @

  @$get = (jsonApiBuilder) ->
    opts = {}
    opts.idKey = idKey if idKey?
    opts.base  = base  if base?
    client = jsonApiBuilder.newClient(opts)

  return

.factory 'jsonApiBuilder', ($http, _ou) ->
  objUtil = _ou
  clientsBuilder = new JsonApiBuilder( idKey: 'id', http: $http, base: '/')


# # JsonApi - a jsonApi client
# A relaxed implementation of jsonapi standard for angular.js with right architecture
# and no ugly responses interceptors. Can process multiple api servers easily
#
# Provides services `jsonApi` - jsonApi Client, can be use by default and configured
# in `.configure` section, and `jsonApiBuilder` - builder for clients
#
# ### usage
#      angular.module('awesomeApp')
#      .controller 'MyCtrl', (jsonApi, $scope) ->
#
#        $scope.item = {}
#        # Short version ($scope.item will be replaced by reference,
#        # when request will be fullfilled, so no chain needed)
#        jsonApi.getIn(type: 'products', $scope.item)
#
#        # or by hand promise
#        jsonApi.get(type: 'products')
#          .then (item) ->
#            $scope.item = item
#
# ### configuration
# `jsonApi` accept configuration values in config section
# - `base` - a base for every requests, by default is '/'
# - `idKey` - name of *id* field , by default is `id`
# - `http` - `$http` service options, Experimental
#
#      angular.module('awesomeApp', ['json-api'])
#      .config (jsonApiProvider) ->
#        jsonApiProvider.base('/api/').idKey('_id')
#
#
# ### Building new clients
#
# So jsonApiBuider builds new clients, using `jsonApiBuilder.defaults` options. Providing
# options to the `newClient` method overrides defaults
#
#      client1 = jsonApi.newClient base: '/api1'
#      client2 = jsonApi.newClient base: '/api2', idKey: '_id'
#
#      # get from first api, change and put to second,
#      # 'id' will be converted automatically to `_id`
#      client1.get({type: 'products'})
#        .then (item) ->
#          item.name = "New"
#          client2.updateIn(item)
#
# Use it if you need more than 1 api backend in the single app
# `jsonApiBuilder.defaults`

# for extracting a data and finding a `type`, first exept these would be a data key
_RESERVED_ROOT = ['meta', 'links', 'linked']
# default reserved mapping. + clientsFactory.idKey, which is `id` by default
_RESERVED = type: '$type', href: '$href', links: '$links'

class JsonApiBase
  constructor: (opts = {}) -> angular.extend @, opts

# ## JsonApiItemsFactory Layer
#
# data manipulation layer, used as `client.itemsFactory` attribute
# attributes: `idKey`, by default `'id'`
#
# ### JsonApiItemsFactory attributes
# `@idKey` - a key for id, by default is `id`, but can be configured
# - every key will be recursively remapped using result of `reservedMap` function. So
#
# ### Items attributes:
# - `$pristineAttributes` - pristine attributes to check if data is pristine
# - `$type`, `$id`, `$href`, `$links` - describe and identify item
# - `$isArray` - true if object is an array of objects, false otherwise

class JsonApiItemsFactory extends JsonApiBase
  updatePristineAttributes: (item) -> item.$pristineAttributes = @getAttributes item
  getAttributes:            (item) -> objUtil.filterKeysNot item, /^\$/
  isUnchanged:              (item) ->
    angular.equals @getAttributes(item), item.$pristineAttributes

  toJson:(item) ->
    json = {}
    data = objUtil.mapKeys item, $id: @idKey
    json[item.$type] = @getAttributes(data)
    angular.toJson json

  reservedMap: () ->
    map = angular.copy _RESERVED
    map[@idKey] = '$id'
    map

  fromJson: (json) ->
    # try to find a type and data from json
    obj = angular.fromJson json
    type = key for key of obj when key not in _RESERVED_ROOT
    data = objUtil.mapKeys obj[type], @reservedMap()

    # fill root elements
    root = {}
    root[key] = obj[key] for key in _RESERVED_ROOT when obj[key]?
    root.linked = objUtil.mapKeys root.linked, @reservedMap() if root.linked

    @newItem {origin: obj, type: type, root: root}, data

  # #### new Item(attrs, data)
  # items can be itself an array or object depending on passed data, so
  newItem: (attrs = {}, data = {}) ->
    switch
      when Array.isArray data
        item = []
        angular.copy data, item
        item.$isArray = true
      else
        item = {}
        angular.copy data, item
        item.$isArray = false

    # `data` becomes a data of item
    # all attrs become *$keys* and will not be outputet via `toJson`, except $id
    item["$#{key}"] = val for key, val of attrs

    # set $type for each el if array
    el.$type = item.$type for el in item if item.$isArray

    @updatePristineAttributes(item)

    item

  # returns all linked, or by type, or by type when {id: id}
  getLinked: (item, type, id) ->
    switch
      when type?
        doc = item.$root?.linked?[type]
        return unless doc?

        switch
          when id
            return val for val in doc when val.$id == id
          else doc

      else item.$root?.linked

# ### JsonApi
# represents an api client object, which has other layers
# #### itemsFactory
# JsonApiItemsFactory object, delegates most methods to this atta
# #### base
# a base url to be added to every request
# #### http
# an http object, usually $http service

class JsonApi extends JsonApiItemsFactory
  # #### urlFor
  # Accepts parameters `url`, `type`, `id` or item, actually checking `$type`, `$id` and `$href`.
  # If the first arguments isn't an object, it will be a `type`, second will be an `id`
  #
  # If `$href` attribute is found, `base` doesn't matter and `href` will be returned as is
  #
  # Don't use `$` parameters without creating an item, it's only for confinience
  #
  #       client.base = '/api/'
  #       # '/api/products'
  #       url = client.urlFor(type: 'products')
  #       # '/api/products/22'
  #       url = client.urlFor(type: 'products', id: 22)
  #
  #       # '/api/products'
  #       url = client.urlFor('products')
  #       # '/api/products/22'
  #       url = client.urlFor('products', 22)
  #
  #       # '/api/products?cat=2'
  #       url = client.urlFor(type: 'products', query: cat: 2)
  #       # the same
  #       url = client.urlFor('products', {cat: 2})
  #
  #       # '/api/products?limit=2&skip=3'
  #       # if item has a $type
  #       url = client.urlFor(item, {limit: 2, skip: 3})
  #
  #       # '/api/products/33'
  #       item = client.newItem(type: "products", id: 33)
  #       url = client.urlFor(item)
  #
  #       # '/other'
  #       item = client.newItem(href: "/other")
  #       url = client.urlFor(item)
  #
  urlFor: ->
    return "#{@base}" unless arguments[0]

    switch
      when angular.isObject arguments[0]
        opts = arguments[0]
      else
        opts = type: arguments[0]

    # prevent an error
    # second argument could be id or query object
    # but shouldn't be an item. Someone can pass an item
    # using proxy or delegate and get a circular structure
    if type = arguments[1]?.$type
      throw new Error "unexpected second argument with $type #{type}"

    if arguments[1]
      switch
        when angular.isObject(arguments[1])
          opts.query = arguments[1]
        else opts.id = arguments[1]
      
    {url: url, id: id, type: type, query: query} = opts
    type ?= opts.$type
    id ?= opts.$id
    switch
      when url? then "#{@base}#{url}"
      when type? and id? then "#{@base}#{type}\/#{id}"
      when type?
        path = "#{@base}#{type}"
        path = "#{path}?" + objUtil.objectToQuery opts.query if opts.query
        path

  # #### Methods for updating by reference
  # this methods make call and replace an item by ref, so you can pass an object to the last argument and don't need
  # to chain for getting a result
  updateIn: (args...,item) ->
    updArgs = if args.length then args.push(item) && args else [item]
    @update.apply @, updArgs
    .then (resItem) -> objUtil.replace item, resItem

  createIn: (opts, item) -> (@create opts,item) .then (resItem) -> objUtil.replace item, resItem
  getIn: (args..., item) -> (@get.apply @, args) .then (resItem) -> objUtil.replace item, resItem

  # ### canLoadMore(`items`)
  # returns `false` if count was provided and `items.lenght` have reached that limit
  # otherwise returns `cont - items.length` if count was provided
  # if count wasn't provided, always returns true
  #
  # throws an error is `items.$isArray` isn't true
  canLoadMore: (items) ->
    throw new Error MSG_NOT_ARRAY unless items.$isArray
    count = items.$root?.meta?.count
    return true unless count?
    return 0 unless count
    return items.$root.meta.count - items.length

  # ### loadMore(`items`, `limit`)
  # loads more items by requesting url with /?skip=[items.length].
  # if `limit` is provided, also adds limit=`limit` to the request url
  #
  # also joins `$root.linked` section and replaces `$root.meta`
  #
  # `items` should be an array (has `$isArray` === true), throws an error
  # otherwise
  loadMore: (items, limit) ->
    throw new Error MSG_NOT_ARRAY unless items.$isArray

    opts = {}
    opts.limit = limit if limit?
    opts.skip = items.length

    @get(items, opts)
      .then (data) =>
        items.$root.meta = data.$root.meta
        items.push v for v in data

        extraLinked = @getLinked(data)

        if extraLinked
          items.$root.linked = {} if !@getLinked(items) and extraLinked
          for k of extraLinked
            @getLinked(items)[k] = [] unless @getLinked(items)[k]
            @getLinked(items)[k].push v for v in @getLinked(data, k)



  # like getIn, but arg is item only
  load: (item) ->
    @get item
    .then (resItem) -> objUtil.replace item, resItem

  # #### Requests methods
  # - update(item) - PUT
  # - delete(item) - DELETE
  # - create(options, data) - POST with optional data
  # - get(options) - GET with optional data
  #
  # #### update
  # accepts similar to `urlFor` parameters or an item
  #
  #     item = client.newItem(id: 'id', type: 'type')
  #     # will be saved to '/type/id'
  #     client.update(item)
  #
  #     # will be saved to '/other/my'
  #     client.update('other', 'my', item)
  #     client.update({type: 'other', id: 'my'}, item)

  update: (args..., item) ->
    urlArgs = if args.length then args else [item]
    url = @urlFor.apply(@, urlArgs)
    @http.put url, @toJson item
      .then (res) => @fromJson res.data

  delete: (item) ->
    @http.delete @urlFor(type: item.$type, id: item.$id)
    .then (res) -> true

  # `get` and `create` method use the same form as `urlFor`
  create: (opts, item={}) ->
    @http.post @urlFor(opts), @toJson item
    .then (res) => @fromJson res.data

  get: (args...) ->
    @http.get @urlFor.apply @, args
    .then (res) => @fromJson res.data


# create a new $http object with passed attributes
cloneHttp = (objF) ->
  f = new Function objF
  httpAttrs  = {}
  angular.copy objF, httpAttrs
  f[k] = v for own k,v of httpAttrs
  f

# ### JsonApiBuilder
# build new clients with `newClient` method. Contructor options became a `defaults` attributes
#
# builders's `defaults` attributes will be passed from every `newClient` method to the constructor, but may be overriden
# by passing arguments for `newClient`
# #### idKey
# A name of the id key. Fields with this name be determined recursively and converted to `$id` in item
# #### http
# options for extending $http instance
#
# #### base
# base url for every request
#      clientsBuilder = new JsonApiBuilder
#        idKey: idKey
#        http: $http
#        base: '/api/
#
#      client = clientsBuilder.newClient(idKey: 'overridesDefaults')

# #### newClient(options, baseClass)
# builds a new client using a `builder`'s `defaults` attribute
# - `options` can be provided to ovverride `defaults`

class JsonApiBuilder
  constructor: (opts = {}) ->
    @defaults = angular.extend {}, opts

  newClient: (opts = {}) ->
    opts              = angular.extend {}, @defaults, opts
    opts.http         = cloneHttp opts.http
    new JsonApi opts

