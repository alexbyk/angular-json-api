'use strict'

describe 'jsonApiBuilder basics', ->

  beforeEach module 'json-api'

  builder = null
  api = null
  beforeEach inject (_jsonApiBuilder_) ->
    builder = _jsonApiBuilder_
    api = builder.newClient()

  it 'should be defined', ->
    expect(!!api).toBe true

  it "builder should use defaults", ->
    builder.defaults.idKey = 'newIdKey'
    builder.defaults.base = 'newBase'
    builder.defaults.http.defaults.xsrfHeaderName = 'newName'
    api = builder.newClient()
    expect(api.idKey).toBe 'newIdKey'
    expect(api.base).toBe 'newBase'
    expect(api.http.defaults.xsrfHeaderName).toBe 'newName'

  it "new clients base must be configured separately", ->
    def = api.base
    api.base = '/new/'
    client1 = builder.newClient()
    expect(client1.base).not.toBe api.base
    expect(client1.base).toBe def

  it "new clients itemsFactory must be configures separately", ->
    api.base  = 'baseNew'
    api.idKey = 'keyNew'
    expect(builder.newClient().idKey).not.toBe api.idKey
    expect(builder.newClient().base).not.toBe api.base

  it "new clients http must be configures separately", ->
    def = api.http.defaults.xsrfHeaderName
    client1 = builder.newClient()
    client1.http.defaults.xsrfHeaderName = 'x1'
    expect(api.http.defaults.xsrfHeaderName).toBe def
    expect(api.http.defaults.xsrfHeaderName).not.toBe 'x1'
