'use strict'

describe 'JsonApiClient update', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  client = {}
  backend = {}
  product = {}
  item = null

  beforeEach inject (_jsonApi_) ->
    client = _jsonApi_

  beforeEach inject ($httpBackend) ->
    product = {}
    backend = $httpBackend
    item = client.newItem {type: 'products'}, {id: 'myid', name: 'myname'}
    json = client.toJson(item)
    backend.expectPUT('/aliasType/aliasId', json).respond
      products:
        id: 'myid', name: 'myname', updated: 'foo'

  beforeEach ->
    item = client.newItem {type: 'products', id: 'myid'}

  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'shoul put item with "type", "id" syntax', ->
    item.$href = "/foo"
    item.name = 'myname'
    client.update 'aliasType', 'aliasId', item
      .then (item) ->
        product = item
    backend.flush()
    expect(product.$id).toBe 'myid'
    expect(product.updated).toBe 'foo'

  it 'shoul put item with {type: "type", id: "id"} syntax', ->
    item.$href = "/foo"
    item.name = 'myname'
    client.update type: 'aliasType', id: 'aliasId', item
      .then (item) ->
        product = item
    backend.flush()
    expect(product.$id).toBe 'myid'
    expect(product.updated).toBe 'foo'

  it 'shoul put item and update local value by ref with "type", "id" syntax', ->
    ref = item
    item.name = 'myname'
    client.updateIn 'aliasType', 'aliasId', item
    backend.flush()

    expect(item.updated).toBe 'foo'
    expect(item).toBe ref

  it 'shoul put item and update local value by ref with {type: "type", id: "id"} syntax', ->
    ref = item
    item.name = 'myname'
    client.updateIn type: 'aliasType', id: 'aliasId', item
    backend.flush()

    expect(item.updated).toBe 'foo'
    expect(item).toBe ref

