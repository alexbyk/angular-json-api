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
    backend = $httpBackend
    backend.expectGET('/products?foo=foo&bar=bar').respond
      products: [
        { id: 'myid0', name: 'myname0' },
        { id: 'myid1', name: 'myname1' },
      ]

  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'shoul get items by query option', ->
    client.get type: 'products', query: foo: 'foo', bar: 'bar'
      .then (item) ->
        products = item
    backend.flush()
    expect(products.$isArray).toBe true
    expect(Array.isArray products).toBe true
    for product,ind in products
      expect(product.name).toBe "myname#{ind}"
      expect(product.$id).toBe "myid#{ind}"

  it 'shoul get items by type', ->
    client.get type: 'products', query: {foo: 'foo', bar: 'bar'}
      .then (item) ->
        products = item
    backend.flush()
    expect(products.$isArray).toBe true
    expect(Array.isArray products).toBe true
    for product,ind in products
      expect(product.name).toBe "myname#{ind}"
      expect(product.$id).toBe "myid#{ind}"

