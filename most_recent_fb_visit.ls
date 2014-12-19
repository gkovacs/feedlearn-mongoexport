require! 'asyncblock'
require! 'fs'
line-reader = require 'line-reader'
#LineByLineReader = require 'line-by-line'
#byline = require 'byline'

eachlineinfile = (file, processline, callback) ->
  line-reader.each-line file, (line, last) ->
    processline line
    if last
      callback()

eachlinefblog = (processline, callback) ->
  asyncblock (flow) ->
    #files = ['mongolab_fblogs_2014-12-17_12:14:22-08:00.json']
    files = listfblogfiles()
    for file in files
      eachlineinfile file, processline, flow.add()
    flow.wait()
    callback()

listfblogfiles = ->
  output = []
  logfiles = fs.readdirSync('.').sort().filter((x) -> x.indexOf('mongolab_fblogs') == 0)
  lognum = 1
  for i from 1 to Infinity
    prefix = 'mongolab_fblogs'
    if i != 1
      prefix += i
    files = logfiles.filter((x) -> x.indexOf(prefix) == 0)
    if files.length == 0
      break
    lastfile = files[*-1]
    output.push lastfile
  return output

main = ->
  #console.log listfblogfiles()
  #return
  asyncblock (flow) ->
    users = {}
    eachlinefblog (line) ->
      try
        data = JSON.parse line
      catch
        console.log 'parse error on: ' + line
        return
      {type, username, time} = data
      #console.log username
      if not time? or not isFinite(time)
        return
      if type == 'fbvisit' or type == 'fbstillopen'
        if not users[username]?
          users[username] = time
          #console.log username
        else
          users[username] = Math.max(users[username], time)
    , flow.add()
    flow.wait()
    #console.log users
    console.log 'users:'
    console.log users
    for k,v of users
      console.log k, new Date(parseInt(v))

main()