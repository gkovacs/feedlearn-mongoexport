require! 'asyncblock'

{querycollection, allcollection, anytrue, alltrue, haskeys, matchval} = require './logquery'

users-who-did-posttest = ->
  output = []
  allcollection 'quiz', (data) ->
    if data.quiztype == 'posttest'
      output.push data.username
  return output

main = ->
  users = {}
  whitelist = {[k,true] for k in users-who-did-posttest()}
  #return
  allcollection 'logs', (data) ->
    #console.log <| data |> (.type)
    {type, username, format, qcontext} = data
    qcontext_format = {
      facebook: 'interactive'
      website: 'link'
      emailvisit: 'none'
    }[qcontext]
    #console.log qcontext
    #return
    if type == 'missingcookie'
      return
    if not whitelist[username]?
      return
    if not users[username]?
      users[username] = {
        interactive: {
          answered: 0
          feedinsert: 0
        }
        link: {
          answered: 0
          feedinsert: 0
        }
        none: {
          answered: 0
          feedinsert: 0
        }
      }
    if type == 'answered'
      users[username][format].answered += 1
    if type == 'feedinsert'
      users[username][format].feedinsert += 1
  console.log users

main()