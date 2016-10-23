# Description:
#   A helpful simple bot for decide lunch or dinner.
#
# Configuration:
#   HUBOT_HOTPEPPER_API_KEY - Setting your HOTPEPPER API key
#   HUBOT_MOGUMOGU_CHANNEL - Setting your Slack channel
#   HUBOT_MOGUMOGU_LOCATION - Setting your location
#   HUBOT_MOGUMOGU_NOW_BUDGET - Setting your now budget(this budget is valid only when you requested)
#   HUBOT_MOGUMOGU_LUNCH_BUDGET - Setting your lunch budget
#   HUBOT_MOGUMOGU_DINNER_BUDGET - Setting your dinner budget
#                           (Please specify in the HOTPEPPER code)
#                         　  code : budget value
#                          　 B001 : ~2000YEN
#                           　B002 : 2001~3000YEN
#                       　    B003 : 3001~4000YEN
#                        　   B008 : 4001~5000YEN
#                         　  B004 : 5001~7000YEN
#                          　 B005 : 7001~10000YEN
#                          　 B006 : 10001YEN~
#
# Commands:
#   hubot hungry - Say lunch or dinner spot at around your location (Englist).
#   hubot angry  - Did you mean "hungry"? (; ･`ω･´)
#   hubot お腹減った - 昼食や夕食を食べるためのお店の情報を日本語で返します
#   hubot アングリー  - (; ･`ω･´)
#
# Author
#   @shinshin86

cronJob = require('cron').CronJob

config =
  api_key: process.env.HUBOT_HOTPEPPER_API_KEY
  channel: process.env.HUBOT_MOGUMOGU_CHANNEL
  addr: process.env.HUBOT_MOGUMOGU_LOCATION
  now_budget: process.env.HUBOT_MOGUMOGU_NOW_BUDGET
  lunch_budget: process.env.HUBOT_MOGUMOGU_LUNCH_BUDGET
  dinner_budget: process.env.HUBOT_MOGUMOGU_DINNER_BUDGET

module.exports = (robot) ->
  robot.hear /hungry/i, (msg) ->
    request = msg.http("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=#{config.api_key}&address=#{config.addr}&budget=#{config.now_budget}&english=1&format=json")
    .get()
    request (err, res, body) ->
        json = JSON.parse body
        num = Math.floor( Math.random() * 11 );
        shopName = json["results"]["shop"][num]["name"]
        shopUrl = json["results"]["shop"][num]["urls"]["pc"]
        msg.send "How about this?\n #{shopName} \n #{shopUrl}"

  robot.hear /angry/i, (msg) ->
    msg.send "Did you mean hungry? (; ･`ω･´)"

  robot.hear /お腹減った/i, (msg) ->
    request = msg.http("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=#{config.api_key}&address=#{config.addr}&budget=#{config.now_budget}&format=json")
    .get()
    request (err, res, body) ->
        json = JSON.parse body
        num = Math.floor( Math.random() * 11 );
        shopName = json["results"]["shop"][num]["name"]
        shopUrl = json["results"]["shop"][num]["urls"]["pc"]
        msg.send "こことかどう？\n#{shopName} \n #{shopUrl}"

  robot.hear /アングリー/i, (msg) ->
    msg.send "ハングリーの間違いじゃないの！? (; ･`ω･´)"

  # Send to the specified channel
  send = (channel, msg) ->
    robot.send {room: channel}, msg

  lunch_msg =  ->
    request = msg.http("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=#{config.api_key}&address=#{config.addr}&budget=#{config.lunch_budget}&lunch=1&format=json")
    .get()
    request (err, res, body) ->
        json = JSON.parse body
        num = Math.floor( Math.random() * 11 );
        shopName = json["results"]["shop"][num]["name"]
        shopUrl = json["results"]["shop"][num]["urls"]["pc"]
        msg = "もうすぐランチだよ！\n #{shopName} \n #{shopUrl}"

  dinner_msg =  ->
    request = msg.http("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=#{config.api_key}&address=#{config.addr}&budget=#{config.dinner_budget}&format=json")
    .get()
    request (err, res, body) ->
        json = JSON.parse body
        num = Math.floor( Math.random() * 11 );
        shopName = json["results"]["shop"][num]["name"]
        shopUrl = json["results"]["shop"][num]["urls"]["pc"]
        msg = "そろそろ帰る準備をしましょう！\n今夜は一杯飲んでいきますか？\n#{shopName} \n #{shopUrl}"

  # #your_channelと言う部屋に、平日の12:00時に実行
  # Send on weekdays 0:00 pm to the specified char room
  new cronJob('0 00 12 * * 1-5', () ->
    send config.channel, lunch_msg
  ).start()

  # cron ->  *(sec) *(min) *(hour) *(day) *(month) *(day of the week)
  # Send on weekdays 5:30 pm to the specified chat room.
  new cronJob('0 30 17 * * 1-5', () ->
    send config.channel, dinner_msg
  ).start()
