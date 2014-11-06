'use strict'

describe 'JsonApiClient get', ->

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
    backend = $httpBackend
    backend.expectGET('/products/myid').respond
      products:
        id: 'myid', name: 'myname'

  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'shoul get item by url', ->
    client.get url: 'products/myid'
      .then (item) ->
        product = item
    backend.flush()
    expect(product.name).toBe 'myname'
    expect(product.$type).toBe 'products'
    expect(product.$id).toBe 'myid'

  it 'shoul get item by type and id opts', ->
    client.get type: 'products', id: 'myid'
      .then (item) ->
        product = item
    backend.flush()
    expect(product.name).toBe 'myname'
    expect(product.$type).toBe 'products'
    expect(product.$id).toBe 'myid'

  it 'shoul get item by type,id', ->
    client.get 'products', 'myid'
      .then (item) ->
        product = item
    backend.flush()
    expect(product.name).toBe 'myname'
    expect(product.$type).toBe 'products'
    expect(product.$id).toBe 'myid'

  it 'shoul getIn item by type and id opts', ->
    ref = item = {}
    client.getIn {type: 'products', id: 'myid'}, item
    backend.flush()
    expect(item.name).toBe 'myname'
    expect(item.$id).toBe 'myid'
    expect(item).toBe ref
    
  it 'shoul getIn item by type, id', ->
    ref = item = {}
    client.getIn 'products', 'myid', item
    backend.flush()
    expect(item.name).toBe 'myname'
    expect(item.$id).toBe 'myid'
    expect(item).toBe ref
