'use strict'

describe 'JsonApiItemsFactory basics', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  factory = {}
  beforeEach inject (_jsonApi_) ->
    factory = _jsonApi_

  it 'should be defined', ->
    expect(!!factory).toBe true

  it 'should be defined with empty {}', ->
    expect(!!factory.fromJson data: {}).toBe true

  it '$type must be found from non reserved worlds', ->

    expect(factory.fromJson(
      meta: 'meta', links: 'links', linked: 'linked'
      products: 'products'
    ).$type).toBe 'products'

  res =
    links: 'top.links'
    meta: 'top.meta'
    products:
      name: 'myname'
      id: 'id'
      another:
        id: 'aid', links: 'alinks', sizes: [1,2], type: 'another'
      href: 'myhref'
      links: 'links'
    linked : 'top.linked'

  product = {}
  beforeEach ->
    product = factory.fromJson res

  it 'Check if object is build correct', ->
    expect(product.name).toBe 'myname'
    expect(product.$id).toBe 'id'
    expect(product.$isArray).toBe false
    expect(product.$type).toBe 'products'
    expect(product.$links).toBe 'links'
    expect(product.$href).toBe 'myhref'
    expect(product.another.$id).toBe 'aid'
    expect(product.another.sizes).toEqual [1,2]
    expect(product.another.$type).toBe 'another'
    expect(product.another.$links).toBe 'alinks'
    expect(product.$root.links).toBe 'top.links'
    expect(product.$root.linked).toBe 'top.linked'
    expect(product.$root.meta).toBe 'top.meta'

  it 'getAttributes should return attributes without $hiddens', ->
    attrs =
      name: 'myname', another: sizes: [1,2]
    expect(factory.getAttributes(product)).toEqual attrs
    #expect(product.$pristineAttributes).toEqual attrs

  it 'Check isUnchanged', ->
    expect(factory.isUnchanged(product)).toBe true
    #expect(product.$isUnchanged()).toBe true

  it 'Change attributes, isUnchanged must be falsy', ->
    product.another = 'bar'
    expect(factory.getAttributes(product)).not.toEqual product.$pristineAttributes
    expect(factory.isUnchanged(product)).toBe false

  it 'Update pristineAttributes', ->
    product.foo = 'bar'
    expect(factory.isUnchanged(product)).toBe false
    factory.updatePristineAttributes(product)
    expect(factory.getAttributes(product)).toEqual product.$pristineAttributes
    expect(factory.isUnchanged(product)).toBe true

    product.bar = 'baz'
    expect(factory.isUnchanged(product)).toBe false
    factory.updatePristineAttributes(product)
    expect(factory.isUnchanged(product)).toBe true
    expect(factory.getAttributes(product)).toEqual product.$pristineAttributes

  it 'newItem', ->
    item = factory.newItem({type: 'mytype'}, {foo: 'foo'})
    expect(item.$type).toBe 'mytype'
    expect(item.foo).toBe 'foo'

  it 'toJson', ->
    obj = products:
      name: 'myname', id: 'id',
      another: sizes: [1,2], id: 'aid'
    
    expect(angular.fromJson factory.toJson product).toEqual obj

  it 'toJson idKey', ->
    obj = products:
      name: 'myname', _id: 'id',
      another: sizes: [1,2], _id: 'aid'
    
    factory.idKey = '_id'
    expect(angular.fromJson factory.toJson product).toEqual obj
