'use strict'

describe 'JsonApiClient loadMore', ->

  # load the service's module
  beforeEach module 'json-api'

  client = {}
  backend = {}
  products = undefined

  beforeEach inject (_jsonApi_) ->
    client = _jsonApi_
  
  it 'throw an error if items is not an array', ->
    msg = 'items must be an array and have $isArray attribute eq true'
    expect(-> client.canLoadMore({$type: 'foo', $isArray: false}, 3)).toThrowError(msg)


  it 'can load more if count was not provided', ->
    expect(client.canLoadMore($isArray: true)).toBe true

  it 'can load more', ->
    items = [{$id: 1}, {$id: 2}]
    items.$root = meta: count: 3
    items.$isArray = true
    expect(client.canLoadMore(items)).toBe 1

  it 'can load more', ->
    items = [{$id: 1}, {$id: 2}]
    items.$root = meta: count: 2
    items.$isArray = true
    expect(client.canLoadMore(items)).toBe 0

  it 'can load more', ->
    items = [{$id: 1}, {$id: 2}]
    items.$root = meta: count: 0
    items.$isArray = true
    expect(client.canLoadMore(items)).toBe 0
