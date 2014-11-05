'use strict'

describe 'jsonApi basics', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  api = {}
  beforeEach inject (_jsonApi_) ->
    api = _jsonApi_

  it 'should be defined', ->
    expect(!!api).toBe true


  it "client methods", ->
    for meth in ['newItem', 'update', 'create', 'get', 'updateIn', 'createIn']
      expect(!!api[meth]).toBe true

  it "itemsFactory methods", ->
    for meth in ['updatePristineAttributes', 'getAttributes', 'isUnchanged', 'getLinked']
      expect(!!api[meth]).toBe true

  it "defaults itemsFactory.idKey, base", ->
    expect(api.base).toBe '/'
    expect(api.idKey).toBe 'id'
    expect(api.http.defaults.xsrfHeaderName).toBe 'X-XSRF-TOKEN'
    expect(api.http.defaults.xsrfCookieName).toBe 'XSRF-TOKEN'
