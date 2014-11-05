'use strict'

describe 'JsonApiClient get array', ->

  # load the service's module
  beforeEach module 'json-api'

  client = {}
  backend = {}
  products = undefined

  beforeEach inject (_jsonApi_) ->
    client = _jsonApi_

  beforeEach inject ($httpBackend) ->
    product = {}
    backend = $httpBackend;
    backend.expectGET('/products').respond
      products: [ 
        { id: 'myid0', name: 'myname0' },
        { id: 'myid1', name: 'myname1' },
      ]


  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'shoul get items by url', ->
    client.get url: 'products'
      .then (item) ->
        products = item
    backend.flush()
    expect(products.$isArray).toBe true
    expect(Array.isArray products).toBe true
    for product,ind in products
      expect(product.name).toBe "myname#{ind}"
      expect(product.$id).toBe "myid#{ind}"

  it 'shoul get items by type', ->
    client.get type: 'products'
      .then (item) ->
        products = item
    backend.flush()
    expect(products.$isArray).toBe true
    expect(Array.isArray products).toBe true
    for product,ind in products
      expect(product.name).toBe "myname#{ind}"
      expect(product.$id).toBe "myid#{ind}"

