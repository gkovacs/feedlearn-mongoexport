require! {
  'express'
  'path'
  'body-parser'
  'async'
}

# mongo

mongo = require 'mongodb'
{MongoClient, Grid} = mongo

mongourls = JSON.parse fs.readFileSync('.mongourls.json', 'utf-8')
# we can get these urls via "heroku config" command
mongourl = mongourls.mongohq

if not mongourl?
  mongourl = 'mongodb://localhost:27017/default'

get-mongo-db = (callback) ->
  #MongoClient.connect mongourl, {
  #  auto_reconnect: true
  #  poolSize: 20
  #  socketOtions: {keepAlive: 1}
  #}, (err, db) ->
  MongoClient.connect mongourl, (err, db) ->
    if err
      console.log 'error getting mongodb'
    else
      callback db

get-grid = (callback) ->
  get-mongo-db (db) ->
    callback Grid(db), db

getvar = (varname, callback) ->
  get-grid (grid, db) ->
    key = 'gvr|' + varname
    #console.log 'key is: ' + key
    grid.get key, (err, res) ->
      #console.log 'res is: ' + res
      #console.log key
      #console.log res
      #console.log err
      if res?
        callback res.toString('utf-8')
      else
        callback null
      db.close()

getvardict = (varname, callback) ->
  getvar varname, (output) ->
    #console.log varname
    #console.log output
    if output?
      callback JSON.parse(output)
    else
      callback {}

get-conditions-collection = (callback) ->
  get-mongo-db (db) ->
    callback db.collection('conditions'), db

insert-if-not-present = (collection, body, callback) ->
  if not body._id?
    console.log 'need _id in item'
    callback() if callback?
    return
  key = body._id
  collection.findOne {_id: key}, (err, result) ->
    if not result?
      collection.insert body, (err2, result2) ->
        console.log err2
        console.log result2
        callback() if callback?
    callback() if callback?

/*
migrate_events = (conditions) ->
  tasks = []
  for let k,v of conditions
    tasks.push (callback) ->
      nv = parseInt v
      get-conditions-collection (collection) ->
        body = {_id: k, username: k, condition: nv}
        insert-if-not-present collection, body, ->
          callback(null, body)
  async.series tasks, (err, results) ->
    console.log err
    console.log results
*/

getconditions = (callback) ->
  get-conditions-collection (conditions) ->
    conditions.find().toArray (err, results) ->
      output = {}
      for {username, condition} in results
        output[username] = condition
      callback output

add-err-to-callback = (f) ->
  return (x, callback) ->
    f x, (results) ->
      callback(null, results)

async-map-noerr = (list, func, callback) ->
  async.map list, add-err-to-callback(func), (err, results) ->
    callback results

dict-to-keys = (dict) ->
  return [k for k,v of dict]

getuserlist = (callback) ->
  getconditions (conditions) ->
    users-array = dict-to-keys conditions
    callback users-array

getuserevents = (username, callback) ->
  getvardict ('evts|' + username), callback

getalluserevents = (callback) ->
  getuserlist (userlist) ->
    get-user-and-events = (username, callback) ->
      getuserevents username, (output) ->
        output.username = username
        callback(output)
    async-map-noerr userlist, get-user-and-events, callback

migrate_conditions = (conditions) ->
  tasks = []
  for let k,v of conditions
    tasks.push (callback) ->
      nv = parseInt v
      get-conditions-collection (collection) ->
        body = {_id: k, username: k, condition: nv}
        insert-if-not-present collection, body, ->
          callback(null, body)
  async.series tasks, (err, results) ->
    console.log err
    console.log results

get-events-collection = (callback) ->
  get-mongo-db (db) ->
    callback db.collection('events'), db

migrate_events = (eventlist) ->
  tasks = []
  for let userevents in eventlist
    tasks.push (callback) ->
      username = userevents.username
      userevents._id = username
      get-events-collection (collection, db) ->
        console.log userevents
        collection.insert userevents, {w:1}, (err0, s1, s2) ->
        #insert-if-not-present collection, userevents, ->
        #collection.save userevents, (err0, s1, s2) ->
          console.log 'err0'
          console.log err0
          console.log 's1'
          console.log s1
          console.log 's2'
          console.log s2
          callback(null, userevents)
          db.close()
  async.series tasks, (err, results) ->
    console.log err
    #console.log results


# perform migration

getalluserevents (userevents) ->
  #console.log JSON.stringify userevents
  migrate_events userevents

