Helper = require 'hubot-test-helper'
chai = require 'chai'
request = require 'request'

expect = chai.expect

helper = new Helper '../scripts/numbered-tickets-script.coffee'

process.env.ONCE_CALL_COUNT = 10

Array.prototype.last = () ->
  @[@.length - 1]

describe 'test hubot', ->

  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()
    @room.robot.server.close()

  it 'request', (done) ->
    @room.user.say("user1", '@hubot hey')
      .then =>
        expect(@room.messages).to.eql [
          ["user1", '@hubot hey']
          ["hubot", "登録されました。順番は1番目です。"]
        ]
        @room.user.say("user1", '@hubot hey')
      .then =>
        expect(@room.messages).to.eql [
          ["user1", '@hubot hey']
          ["hubot", "登録されました。順番は1番目です。"]
          ["user1", '@hubot hey']
          ["hubot", "すでに登録されています。順番は1番目です。"]
        ]
      .then ->
        done()

  it 'stat', (done) ->
    @timeout 0
    Promise.all [1..20].map (n) => @room.user.say("user#{n}", '@hubot hey')
      .then =>
        @room.user.say('user1', '@hubot stat')
      .then =>
        expect(@room.messages.last()).to.eql ['hubot', "次は1番〜10番\n最後尾は20番"]
        done()

  it 'call', (done) ->
    @room.user.say("user1", '@hubot hey')
      .then =>
        @room.robot.http("http://localhost:8080/call")
          .post() (error, response, body) =>
            expect(@room.messages.last()).to.eql ["hubot", '順番がきました。']
            done()

  it 'reset', (done) ->
    @room.user.say("user1", '@hubot hey')
      .then =>
        @room.robot.http("http://localhost:8080/reset")
          .post() (error, response, body) =>
            expect(@room.messages.last()).to.eql ["hubot", '本日の営業は終了しました。\nまたのご利用をお待ちしております。']
            done()
