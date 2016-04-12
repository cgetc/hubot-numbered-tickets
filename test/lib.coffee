chai = require 'chai'
NumberedTickets = require '../lib/numbered-tickets'

expect = chai.expect

class MockKVS
  _data = {}
  get: (key) ->
    _data[key]

  set: (key, value) ->
    _data[key] = value

auto_reset_interval = 3 * 360000

describe 'numbered tickets test', ->
  @timeout 0

  beforeEach ->
    @kvs = new MockKVS()
    @mediator = new NumberedTickets @kvs
    @mediator.once_call_count = 10

  it 'initialize', ->
    expect(@mediator.stat()).to.eql start: 0, end: 0, max: 0

  it 'request 1', ->
    {added, num} = @mediator.request("user1")
    expect(added).to.eql true
    expect(num).to.eql 1
    expect(@mediator.stat()).to.eql start: 1, end: 1, max: 1

  it 'not change if exists', ->
    {added, num} = @mediator.request("user1")
    expect(added).to.eql false
    expect(num).to.eql 1
    expect(@mediator.stat()).to.eql start: 1, end: 1, max: 1

  it 'fill once-call-count', ->
    [2..10].forEach (n)=>
      {added, num} = @mediator.request("user#{n}")
      expect(added).to.eql true
      expect(num).to.eql n
    expect(@mediator.stat()).to.eql start: 1, end: 10, max: 10

  it 'over once-call-count, only max +n', ->
    [11..12].forEach (n)=>
      {added, num} = @mediator.request("user#{n}")
      expect(added).to.eql true
      expect(num).to.eql n
    expect(@mediator.stat()).to.eql start: 1, end: 10, max: 12

  it 'call once-call-count, rooms are once-call-count and start +once-call-count', ->
    rooms = @mediator.call(auto_reset_interval)
    expect(rooms).eql [1..10].map (n) -> "user#{n}"
    expect(@mediator.stat()).to.eql start: 11, end: 12, max: 12

  it 'call empty, only start +left-rooms.', ->
    rooms = @mediator.call(auto_reset_interval)
    expect(rooms).eql [11..12].map (n) -> "user#{n}"
    expect(@mediator.stat()).to.eql start: 12, end: 12, max: 12

  it 'request +once-call-count, end and max +once-call-count', ->
    [13..22].forEach (n)=>
      {added, num} = @mediator.request("user#{n}")
      expect(added).to.eql true
      expect(num).to.eql n
    expect(@mediator.stat()).to.eql start: 13, end: 22, max: 22

  it 'then reset', ->
    rooms = @mediator.reset()
    expect(rooms).eql [13..22].map (n) => "user#{n}"
    expect(@mediator.stat()).to.eql start: 0, end: 0, max: 0

  it 'after reset, it works', ->
    {added, num} = @mediator.request("user1")
    expect(added).to.eql true
    expect(num).to.eql 1
    expect(@mediator.stat()).to.eql start: 1, end: 1, max: 1

  it 'then call and auto_reset', (done) ->
    rooms = @mediator.call(100)
    setTimeout =>
      expect(@mediator.stat()).to.eql start: 0, end: 0, max: 0
      done()
    , 100
