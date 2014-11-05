'use strict'

describe 'JsonApiItemsFactory arrays', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  factory = {}
  beforeEach inject (_jsonApi_) ->
    factory = _jsonApi_

  res =
    links: 'top.links'
    meta: 'top.meta'
    products: [
      name: 'myname0'
      id: 'myid0'
      anotherMany: [{id: 'id', name: 'name'}]
      another:
        id: "anotherid", name: 'another', type: 'another'
        many : [1, 2]
    ,
      name: 'myname1'
      id: 'myid1'
      anotherMany: [{id: 'id', name: 'name'}]
      another:
        id: "anotherid", name: 'another', type: 'another'
        many : [1, 2]
    ]
    linked : 'top.linked'


  it 'Check if arrays from json work', ->
    products = factory.fromJson angular.toJson res
    expect(Array.isArray products).toBe true
    expect(products.$isArray).toBe true
    for i in [0..1]
      expect(products[i].anotherMany[0].$id).toBe 'id'
      expect(Array.isArray products[i].anotherMany).toBe true
      expect(products[i].name).toBe "myname#{i}"

      expect(products[i].$id).toBe "myid#{i}"
      expect(products[i].$type).toBe "products"

      expect(products[i].another.$id).toBe "anotherid"
      expect(products[i].another.$type).toBe "another"
      expect(products[i].another.name).toBe "another"
      expect(products[i].another.many).toEqual [1,2]

  it 'Check if arrays returned from Json', ->
    products = factory.fromJson angular.toJson res
    obj = (angular.fromJson factory.toJson products).products
    expect(Array.isArray obj).toBe true
    expect(Array.isArray obj[0].anotherMany).toBe true
    expect(Array.isArray obj[0].another.many).toBe true
    

