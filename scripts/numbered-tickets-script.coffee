# Description:
#   整理券を配布するボット
#
# Dependencies:
#   "hubot-redis-brain": "<module version>"
#
# Configuration:
#   AUTO_RESET_INTERVAL - 自動的に終了する時間(ミリ秒)
#   ONCE_CALL_COUNT - 一度に呼ぶ人数
#
# Commands:
#   hubot stat|now - 受付状態を確認
#   hubot .+ - 整理券を受け取る
#
# Notes:
#   / 管理画面
#   /call 登録された整理券の番号を呼ぶ
#   /reset 整理券情報をリセットする
#
# Author:
#   cgetc<cgetc502@gmail.com>

NumberedTickets = require '../lib/numbered-tickets'
AUTO_RESET_INTERVAL = parseInt(process.env.AUTO_RESET_INTERVAL) or 3 * 3600 * 1000

module.exports = (robot) ->
  _mediator = null

  robot.brain.on 'loaded', =>
    return if _mediator
    robot.brain.autoSave = false
    _mediator = new NumberedTickets robot.brain
    unless isNaN once_call_count = parseInt process.env.ONCE_CALL_COUNT
      _mediator.once_call_count = once_call_count
    console.log "#{robot.name} ready."

  robot.respond /(.+)$/, (res) =>
    if res.match[1].match /^(stat|now)$/i
      {start, end, max} = _mediator.stat()
      return res.send "次は#{start}番〜#{end}番\n最後尾は#{max}番"

    {added, num} = _mediator.request res.message.user.name
    if added
      res.send "登録されました。順番は#{num}番目です。"
    else
      res.send "すでに登録されています。順番は#{num}番目です。"

  robot.router.post '/call', (req, res) =>
    rooms = _mediator.call AUTO_RESET_INTERVAL
    for room in rooms
      robot.send room: room, "順番がきました。"

    res.redirect('/')

  robot.router.post '/reset', (req, res) =>
    rooms = _mediator.reset()
    for room in rooms
      robot.send room: room, "本日の営業は終了しました。\nまたのご利用をお待ちしております。"

    res.redirect('/')

  robot.router.get '/', (req, res) =>
    {start, end, max} = _mediator.stat()
    disabled = start > max? ' disabled': ''
    res.send """<DOCTYPE! html>
<html lang="ja">
<head>
  <meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
  <meta name="format-detection" content="telephone=no">
  <title>#{robot.name}</title>
  <style>
    form {
      margin: 10px 0;
      overflow: hidden;
    }
    form > button {
      display: block;
      border-radius: 10px;
    }
    .reset > button {
      float: right;
      font-size: 140%;
    }
    .more > button {
      width: 80%;
      padding: 1em;
      margin: auto;
      font-size: 160%;
    }
    p {
      text-align: center;
    }
  </style>
</head>
<body>
  <form method="POST" action="/reset" class="reset" onsubmit="return confirm('本当に終了しますか?');">
    <button type="submit">終了</button>
  </form>
  <h1>#{robot.name}</h1>
  <p>最後尾は#{max}番</p>
  <form method="POST" action="/call" class="more">
    <button type="submit"#{disabled}>
      <strong>#{start}番〜#{end}番を呼ぶ</strong>
    </button>
  </form>
</body>
</html>"""
