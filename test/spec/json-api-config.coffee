'use strict'


describe 'jsonApi config', ->
  provider = null
  beforeEach module 'json-api', (jsonApiProvider) ->
    provider =  jsonApiProvider
    return

  it 'defaults', inject (jsonApi) ->
    expect(jsonApi.idKey).toBe 'id'
    expect(jsonApi.base).toBe '/'

  it 'idKey', inject () ->
    expect(provider.idKey(0)).toBe provider
    expect(provider.idKey()).toBe 0
    inject (jsonApi) ->
      expect(jsonApi.idKey).toBe 0

  it 'base', inject () ->
    expect(provider.base(0)).toBe provider
    expect(provider.base()).toBe 0
    inject (jsonApi) ->
      expect(jsonApi.base).toBe 0
