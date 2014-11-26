'use strict'

describe 'JsonApiClient loadMore', ->

  # load the service's module
  beforeEach module 'json-api'

  client = {}
  backend = {}
  products = undefined

  beforeEach inject (_jsonApi_) ->
    client = _jsonApi_

  afterEach inject ($httpBackend) ->
    $httpBackend.verifyNoOutstandingExpectation()
  
  it 'throw an error if items is not an array', ->
    msg = 'items must be an array and have $isArray attribute eq true'
    expect(-> client.loadMore({$type: 'foo', $isArray: false}, 3)).toThrowError(msg)

  describe 'loadMore', ->
    beforeEach inject ($httpBackend) ->
      product = {}
      backend = $httpBackend
      backend.expectGET('/products').respond
        products: [
          { id: 'myid0', name: 'myname0' },
          { id: 'myid1', name: 'myname1' },
        ]
        linked: {images: [{_id: 1, src: '1.src'}]}

      client.get type: 'products'
        .then (item) ->
          products = item
      backend.flush()

    it 'should load more without limit', ->
      backend.expectGET('/products?skip=2').respond
        meta: count: 10
        products: [
          { id: 'myid2', name: 'myname0' },
        ]

      client.loadMore(products)
      backend.flush()

      expect(products.length).toBe 3
      expect(products.$root.meta.count).toBe 10

    it 'should load more with limit', ->
      backend.expectGET('/products?limit=3&skip=2').respond
        meta: count: 10
        products: [
          { id: 'myid2', name: 'myname0' },
          { id: 'myid3', name: 'myname3' },
          { id: 'myid4', name: 'myname4' },
        ]

      client.loadMore(products, 3)
      backend.flush()

      expect(products.length).toBe 5
      expect(products.$root.meta.count).toBe 10

    it 'should load more with extra parameters', ->
      backend.expectGET('/products?limit=3&category=mycat&skip=44').respond
        meta: count: 10
        products: [
          { id: 'myid2', name: 'myname0' },
          { id: 'myid3', name: 'myname3' },
          { id: 'myid4', name: 'myname4' },
        ]

      client.loadMore(products, {limit: 3, category: 'mycat', skip: 44})
      backend.flush()

      expect(products.length).toBe 5
      expect(products.$root.meta.count).toBe 10

    it 'should not spoil passed parameters object', ->
      opts = {category: 'mycat'}
      backend.expectGET('/products?category=mycat&skip=2').respond
        meta: count: 10
        products: [
          { id: 'myid2', name: 'myname2' },
        ]

      client.loadMore(products, opts)
      backend.flush()

      expect(opts).toEqual category: 'mycat'

      # second time
      backend.expectGET('/products?category=mycat2&skip=3').respond
        meta: count: 10
        products: [
          { id: 'myid3', name: 'myname3' },
        ]
      opts.category = 'mycat2'
      client.loadMore(products, opts)
      backend.flush()

      expect(opts).toEqual category: 'mycat2'
      expect(products.length).toBe 4


    it 'should load more and join getLinked', ->
      backend.expectGET('/products?limit=3&skip=2').respond
        products: [
          { id: 'myid2', name: 'myname0' },
          { id: 'myid3', name: 'myname3' },
          { id: 'myid4', name: 'myname4' },
        ]
        linked: {
          images: [{id: 2, src: '2.src'}]
          foo: [{id: 2, src: '2.foo'}]
        }

      client.loadMore(products, 3)
      backend.flush()

      expect(client.getLinked(products, 'images', 2).src).toBe '2.src'
      expect(client.getLinked(products, 'foo', 2).src).toBe '2.foo'

  describe 'loadMore when target han no linked section', ->
    beforeEach inject ($httpBackend) ->
      product = {}
      backend = $httpBackend
      backend.expectGET('/products').respond
        products: [
          { id: 'myid0', name: 'myname0' },
          { id: 'myid1', name: 'myname1' },
        ]

      client.get type: 'products'
        .then (item) ->
          products = item
      backend.flush()

    it 'should load more and add getLinked', ->
      backend.expectGET('/products?limit=3&skip=2').respond
        products: [
          { id: 'myid2', name: 'myname0' },
          { id: 'myid3', name: 'myname3' },
          { id: 'myid4', name: 'myname4' },
        ]
        linked: {images: [{id: 2, src: '2.src'}]}

      client.loadMore(products, 3)
      backend.flush()

      expect(client.getLinked(products, 'images', 2).src).toBe '2.src'
