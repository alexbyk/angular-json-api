'use strict'

describe 'JsonApiClient create', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  client = {}
  backend = {}
  product = {}

  beforeEach inject (_jsonApi_) ->
    client = _jsonApi_

  beforeEach inject ($httpBackend) ->
    product = {}
    backend = $httpBackend;
    item = client.newItem {type: 'products'}, {name: 'myname'};
    json = client.toJson(item)
    backend.expectPOST('/products', json).respond
      products: 
        id: 'myid', name: 'myname', updated: 'foo'

  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'should create item', ->
    item = client.newItem type: 'products'
    item.name = 'myname'
    client.create({type: 'products'}, item)
      .then (item) ->
        product = item
    backend.flush()
    expect(product.$id).toBe 'myid'

  it 'should create an item and update it in Place', ->
    ref = item = client.newItem type: 'products'
    item.name = 'myname'
    client.createIn {type: 'products'}, item
    backend.flush()
    expect(item.$id).toBe 'myid'
    expect(item.updated).toBe 'foo'
    expect(item).toBe ref

