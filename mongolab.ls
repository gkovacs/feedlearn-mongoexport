#!/usr/bin/env lsc

root = exports ? this

require! {
  'fs'
  'mongo-uri'
}
{spawn} = require 'child_process'

mongourls = JSON.parse fs.readFileSync('.mongourls.json', 'utf-8')
# we can get these urls via "heroku config" command
#mongohq = mongourls['mongohq']
mongolab = mongourls['mongolab']

login = mongo-uri.parse mongolab

host = login['hosts'][0] + ':' + login['ports'][0]
db = login['database']
user = login['username']
passwd = login['password']

spawn 'mongo', ['--username', user, '--password', passwd, host + '/' + db], {stdio: [0,1,2]}
