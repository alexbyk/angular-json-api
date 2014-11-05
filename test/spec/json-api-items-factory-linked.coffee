'use strict'

describe 'JsonApiItemsFactory arrays', ->

  # load the service's module
  beforeEach module 'json-api'

  # instantiate service
  factory = {}
  beforeEach inject (_jsonApi_) ->
    factory = _jsonApi_
    factory.idKey = '_id'

  images = [
      {_id: 'imgId1', src: 'imgSrc1' }
      {_id: 'imgId2', src: 'imgSrc2' }
  ]
  $images = [
      {$id: 'imgId1', src: 'imgSrc1' }
      {$id: 'imgId2', src: 'imgSrc2' }
  ]
  res =
    products: name: 'myname', _id: 'myid'
    linked: images: images

  it 'nulls linked', ->
    expect(!factory.getLinked({}, 'images')).toBe true
    expect(!factory.getLinked({$linked: {}} , 'images')).toBe true
    expect(!factory.getLinked({$linked: {images: {}}} , 'images')).toBe true
    expect(!factory.getLinked({}, 'images', 'badid')).toBe true
    expect(!factory.getLinked({$linked: {}} , 'images', 'badid')).toBe true
    expect(!factory.getLinked({$linked: {images: {}}} , 'images', 'badid')).toBe true

  it 'linked without type returns all linked section', ->
    products = factory.fromJson angular.toJson res
    expect(factory.getLinked(products)).toEqual images: $images

  it 'linked with type return all linked by type', ->
    products = factory.fromJson angular.toJson res
    expect(factory.getLinked(products, 'images')).toEqual $images

  it 'linked with type and id return specified linked object', ->
    products = factory.fromJson angular.toJson res
    expect(factory.getLinked(products, 'images', 'imgId1')).toEqual $images[0]
  
    
