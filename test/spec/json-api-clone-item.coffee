'use strict'

describe 'JsonApiItemsFactory cloneItem', ->

  # load the service's module
  beforeEach module 'json-api'

  api = {}
  beforeEach inject (_jsonApi_) ->
    api = _jsonApi_

  it 'clone simple obj', ->
    orig = [{$foo: 1}, {bar: 2}]
    orig.$isArray = true
    orig.$type = 'products'
    clone = api.cloneItem(orig)
    expect(clone).toEqual orig
    expect(clone).not.toBe orig
    expect(clone.$isArray).toBe true
    expect(clone.$type).toBe 'products'

  it 'clone simple obj with $isArray = false', ->
    orig = {foo: 1, $isArray: false, $bar: {$foo : 2}}
    clone = api.cloneItem(orig)
    expect(clone).toEqual orig
    expect(clone).not.toBe orig

  it 'clone simple obj', ->
    orig = {foo: 1, $bar: {$foo : 2}}
    clone = api.cloneItem(orig)
    expect(clone).toEqual orig
    expect(clone).not.toBe orig

  it 'clone simple array', ->
    orig = [{foo: 1, bar: {foo : 2}}, {}]
    clone = api.cloneItem(orig)
    expect(clone).toEqual orig
    expect(clone).not.toBe orig

  it 'clone undef', ->
    expect(api.cloneItem(null)).not.toBeDefined

  it 'clone string', ->
    expect(api.cloneItem(22)).toBe 22
