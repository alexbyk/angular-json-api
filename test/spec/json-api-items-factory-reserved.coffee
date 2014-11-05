'use strict'

describe 'JsonApiItemsFactory idKey', ->

  # load the service's module
  beforeEach module 'json-api'

  api = {}
  beforeEach inject (_jsonApi_) ->
    api = _jsonApi_

  res =
    products: name: 'myname', _id: 'id', id: 'notId', other:
      _id: 'otherid', id: 'nototherid'

  it 'Check if object is build correct', ->
    factory = api
    factory.idKey = '_id'
    product = factory.fromJson res
    expect(product.$id).toBe 'id'
    expect(product.id).toBe 'notId'
    expect(product.other.$id).toBe 'otherid'
    expect(product.other.id).toBe 'nototherid'

