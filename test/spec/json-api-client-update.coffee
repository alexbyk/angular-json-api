'use strict'

describe 'JsonApiClient update', ->

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
    backend.expectPUT('/products/myid', json).respond
      products: 
        id: 'myid', name: 'myname', updated: 'foo'

  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'shoul post item', ->
    item = client.newItem {type: 'products', id: 'myid'}
    item.name = 'myname'
    client.update item
      .then (item) ->
        product = item
    backend.flush()
    expect(product.$id).toBe 'myid'
    expect(product.updated).toBe 'foo'

  it 'shoul post item and update local value by ref', ->
    ref = product = client.newItem {type: 'products', id: 'myid'}
    product.name = 'myname'
    client.updateIn product
    backend.flush()

    expect(product.updated).toBe 'foo'
    expect(product).toBe ref

