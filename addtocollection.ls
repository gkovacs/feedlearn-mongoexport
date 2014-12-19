#!/usr/bin/env lsc

root = exports ? this

require! {
  'fs'
  'async'
  'asyncblock'
}

mongo = require 'mongodb'
{MongoClient} = mongo

mongourls = JSON.parse fs.readFileSync('.mongourls.json', 'utf-8')
# we can get these urls via "heroku config" command

mongourl = mongourls.mongohq
if not mongourl?
  mongourl = 'mongodb://localhost:27017/default'

get-mongo-db = (callback) ->
  MongoClient.connect mongourl, (err, db) ->
    if err
      console.log 'error getting mongodb'
      console.log err
    else
      callback db

get-logs-fblogin-collection = (callback) ->
  get-mongo-db (db) ->
    callback db.collection('fblogin'), db

excludeid = (data) ->
  output = {[k,v] for k,v of data}
  if output['_id']?
    delete output['_id']
  return output

insert-data = (data, callback) ->
  get-logs-fblogin-collection (logs, db) ->
    #logs.save data, (err, results) ->
    #  console.log err
    #  console.log results
    #  callback() if callback?
    logs.findOne excludeid(data), (err, result) ->
      if not result?
        logs.save data, (err2, result2) ->
          console.log 'saving'
          console.log err2
          console.log result2
          callback() if callback?
          db.close()
      else
        callback() if callback?
        db.close()

main = ->
  jsonfiles = process.argv.filter((x) -> x.indexOf('.json') != -1)
  if jsonfiles.length == 0
    console.log 'need to specify a .json file'
    return
  data-to-insert = JSON.parse(fs.readFileSync(jsonfiles[0], 'utf-8'))
  if not Array.isArray(data-to-insert)
    console.log 'inputted json file needs to be an array'
    return
  asyncblock (flow) ->
    for let data in data-to-insert
      insert-data data, flow.add()
      flow.wait()
      console.log data
  /*
  tasks = []
  for let data in data-to-insert
    tasks.push (callback) ->
      console.log data
      setTimeout ->
        callback(null, null)
      , 1000
    #tasks.push (callback) ->
    #  insert-data data, ->
    #    callback(null, null)
  async.series tasks, (err, results) ->
    console.log 'all done'
    console.log err
    console.log results
  */

main()