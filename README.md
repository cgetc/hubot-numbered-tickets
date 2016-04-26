# どういうボットか？

<iframe src="//www.slideshare.net/slideshow/embed_code/key/MIwea9pNRO6arp" width="595" height="485" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/cgetc/ss-61380264" title="整理券ボット" target="_blank">整理券ボット</a> </strong> from <strong><a href="//www.slideshare.net/cgetc" target="_blank">shigetoshi komatsu</a></strong> </div>

# Configuration
|環境変数|説明|
|:--:|:--:|
|HUBOT_SLACK_TOKEN|Slackのトークン|
|REDIS_URL|RedisのURL|
|AUTO_RESET_INTERVAL|自動的に終了する時間(ミリ秒)|
|ONCE_CALL_COUNT|一度に呼ぶ人数|

# Commands:
|入力|説明|
|:--:|:--:|
|hubot stat\|now|  受付状態を確認|
|hubot .+ |整理券を受け取る|

# Notes:
|パス|説明|
|:--:|:--:|
|/|管理画面
|/call|登録された整理券の番号を呼ぶ
|/reset|整理券情報をリセットする
