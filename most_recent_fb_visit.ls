require! 'asyncblock'

{querycollection, allcollection, anytrue, alltrue, haskeys, matchval} = require './logquery'

main = ->
  #console.log listfblogfiles()
  #return
  users = {}
  querycollection 'fblogs', haskeys('type', 'username', 'time'), (data) ->
    {type, username, time} = data
    if not isFinite(time)
      return
    if type == 'fbvisit' or type == 'fbstillopen'
      if not users[username]?
        users[username] = time
        #console.log username
      else
        users[username] = Math.max(users[username], time)
  #console.log users
  console.log 'users:'
  console.log users
  for k,v of users
    console.log k, new Date(parseInt(v))

main()