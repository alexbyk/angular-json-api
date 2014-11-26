'use strict'

describe 'JsonApiClient basics', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  client = {}
  beforeEach inject (_jsonApi_) ->
    client = _jsonApi_

  it 'should build new item', ->
    product = client.newItem type: 'products'
    expect(product.$type).toBe 'products'

  it 'should build json from item', ->
    product = client.newItem type: 'products'
    product.name = 'myname'
    jsonObj =  angular.fromJson client.toJson product
    expect(jsonObj).toEqual products: name: 'myname'

  it 'urlFor options', ->
    client.base = '/base/'
    expect(client.urlFor type: 'products', id: 'id').toBe '/base/products/id'
    expect(client.urlFor type: 'products').toBe '/base/products'
    expect(client.urlFor type: 'products', query: {param1: 'val1'})
      .toBe '/base/products?param1=val1'
    expect(client.urlFor url: 'my/url').toBe '/base/my/url'

  it 'urlFor item', ->
    client.base = '/base/'
    expect(client.urlFor $type: 'products', $id: 'id').toBe '/base/products/id'
    expect(client.urlFor $type: 'products').toBe '/base/products'

  it 'urlFor item($type?), query', ->
    client.base = '/'
    url = client.urlFor({$type: 'products'}, {limit: 10, skip: 20})
    expect(url).toContain '/products'
    expect(url).toContain 'limit=10'
    expect(url).toContain 'skip=20'

  it 'should throw an error if second argument is item with $type', ->
    msg = "unexpected second argument with $type BAD"
    expect(->client.urlFor({$type: 'products'}, {$type: 'BAD', limit: 10, skip: 20}))
      .toThrowError(msg)

  it 'urlFor type, query', ->
    client.base = '/'
    url = client.urlFor('products', {limit: 10, skip: 20})
    expect(url).toContain '/products'
    expect(url).toContain 'limit=10'
    expect(url).toContain 'skip=20'

  it 'urlFor args', ->
    client.base = '/base/'
    expect(client.urlFor 'products', 'id').toBe '/base/products/id'
    expect(client.urlFor 'products', {p1: 1, p2: 2}).toBe '/base/products?p1=1&p2=2'
    expect(client.urlFor 'products').toBe '/base/products'
