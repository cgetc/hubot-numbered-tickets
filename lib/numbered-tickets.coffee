LIST_KEY = 'rooms'
CUR_KEY = 'cursor'
INCR_KEY = 'counter'

module.exports = class NumberedTickets
  _kvs = null
  @once_call_count = 10
  _autoReset = null
  _rooms =  []
  _start =  0
  _max = 0

  constructor: (kvs) ->
    @once_call_count = 10
    _kvs = kvs
    _autoReset = null
    _rooms = _kvs.get(LIST_KEY) or []
    _start = _kvs.get(CUR_KEY) or 1
    _max = _kvs.get(INCR_KEY) or 0

  stat: ->
    start: Math.min _start, _rooms.length
    end: Math.min _start + @once_call_count - 1, _rooms.length
    max: _rooms.length

  request: (room) ->
    n = _rooms.indexOf(room)
    if n < 0
      _rooms.push room
      _kvs.set LIST_KEY, _rooms
      return added: true, num: _rooms.length
    else
      return added: false, num: n + 1

  call: (auto_reset_interval) ->
    clearTimeout _autoReset
    _autoReset = setTimeout resetData, auto_reset_interval

    rooms = _rooms.slice _start - 1, _start + @once_call_count - 1
    _start += Math.min @once_call_count, rooms.length
    _kvs.set CUR_KEY, _start
    rooms

  reset: () ->
    clearTimeout _autoReset
    rooms = _rooms.slice _start - 1
    resetData()
    rooms

  resetData = ->
    _rooms = []
    _start = 0
    _max = 0
    _kvs.set LIST_KEY, _rooms
    _kvs.set CUR_KEY, _start
