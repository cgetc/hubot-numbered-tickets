responses = []
exists = (res) ->
  for v, n in responses
    if v.message.user.name == res.message.user.name
      return n
  return -1
KEY = 'user_list'
ONCE_CALL_COUNT = 10
module.exports = (robot) ->
  robot.respond /.*/, (res) ->
    n = exists(res)
    if n < 0
      responses.push(res)
      n = responses.length
      res.reply "登録されました。順番は#{n}番目です。"
    else
      res.reply "すでに登録されています。順番は#{n}番目です。"

  robot.router.get '/', (req, res) ->
    n = responses.length
    console.log robot
    res.send """<DOCTYPE! html>
<html lang="ja">
<head>
  <meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
  <meta name="format-detection" content="telephone=no">
  <title>#{robot.envelope.room}</title>
  <style>
  </style>
</head>
<body>
  <form method="POST" action="/reset" class="reset">
    <button type="submit">終了</button>
  </form>
  <form method="POST" action="/more" class="more">
    <button type="submit">
      ただいま#{n}人
      <br>
      <strong>呼ぶ</strong>
    </button>
  </form>
</body>
</html>"""

  robot.router.post '/more', (req, res) ->
    for user_res in responses.splice(0, Math.min(ONCE_CALL_COUNT, responses.length))
      user_res.reply "順番がきました。"
    res.redirect('/')

  robot.router.post '/reset', (req, res) ->
    for user_res in responses
      user_res.reply "終了しました。またのご利用をお待ちしております。"
    responses = []
    res.redirect('/')
