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
    expect(client.urlFor url: 'my/url').toBe '/base/my/url'

  it 'urlFor item', ->
    client.base = '/base/'
    expect(client.urlFor $type: 'products', $id: 'id').toBe '/base/products/id'
    expect(client.urlFor $type: 'products').toBe '/base/products'
    expect(client.urlFor $href: '/external').toBe '/external'

  it 'urlFor args', ->
    client.base = '/base/'
    expect(client.urlFor 'products', 'id').toBe '/base/products/id'
    expect(client.urlFor 'products').toBe '/base/products'
