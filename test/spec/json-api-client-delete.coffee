'use strict'

describe 'JsonApiClient update', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  client = {}
  backend = {}

  beforeEach inject (_jsonApi_) ->
    client = _jsonApi_

  beforeEach inject ($httpBackend) ->
    backend = $httpBackend;
    backend.expectDELETE('/products/myid').respond(204, '')
      
  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()

  it 'shoul delete item', ->
    item = client.newItem type: 'products', id: 'myid'
    result = undefined
    client.delete item
      .then (res) ->
        result = res
    backend.flush()
    expect(result).toBe true

