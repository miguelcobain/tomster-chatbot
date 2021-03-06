# Description:
#   Use hubots redis brain to store useful information
#
# Author:
#   locks
#
# Commands:
#   hubot learn "<key name>" means <value> - Get Hubot to memorize something new
#   hubot relearn "<key name>" means <value> - Overwrite something that Hubot learned before
#   hubot learned - Check all the things Hubot as learned so far

module.exports = (robot) ->
  redisUrl = process.env.REDISCLOUD_URL
  thoughts = null

  actuallyLearnMethod = (res, key, value) ->
    thoughts[key] = value
    robot.brain.emit 'save'
    res.reply "gotcha, *'#{key}'* means '#{value}'"

  learnMethod = (res) ->
    [_, key, value] = res.match
    if thoughts[key]
      res.reply "I've already learnt that \" #{key} \" means #{thoughts[key]}"
    else
      actuallyLearnMethod(res, key, value)

  relearnMethod = (res) ->
    [_, key, value] = res.match
    actuallyLearnMethod(res, key, value)

  robot.respond /learn "([^"]+)" (.+)$/i, (res)-> learnMethod(res)

  robot.respond /relearn "([^"]+)" (.+)$/i, (res)-> relearnMethod(res)

  rememberMethod = (res) ->
    [_, match] = res.match
    if `match in thoughts`
      res.send thoughts[match]
    else
      res.send "sorry, I don't know this :("

  robot.respond /.*remember "([^"]+)".*/, rememberMethod

  robot.respond /learned/, (res) ->
    res.reply "check out my brain at http://rampant-stove.surge.sh/"

  robot.brain.on 'loaded', ->
    thoughts = robot.brain.data.thoughts
    thoughts ?= {}
