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
    backend = $httpBackend;
    backend.expectGET('/products/myid').respond
      products: 
        id: 'myid', name: 'myname'

  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  # todo load by href
  it 'shoul get item by type and id', ->
    product = $type: 'products', $id: 'myid'
    client.load product 
    backend.flush()
    expect(product.name).toBe 'myname'
    expect(product.$type).toBe 'products'
    expect(product.$id).toBe 'myid'
