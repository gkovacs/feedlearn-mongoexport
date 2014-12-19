#!/usr/bin/env lsc

root = exports ? this

require! {
  'fs'
  'mongo-uri'
}
{run, exec} = require 'execSync'

datecmd = 'date'
if fs.existsSync('/usr/local/bin/gdate')
  datecmd = '/usr/local/bin/gdate'

outfileend = exec(datecmd + ' --rfc-3339=seconds').stdout.trim().split(' ').join('_') + '.json'

mongourls = JSON.parse fs.readFileSync('.mongourls.json', 'utf-8')
# we can get these urls via "heroku config" command
mongohq = mongourls['mongohq']
mongolab = mongourls['mongolab']

export_list = [
  {
    'outfilebase': 'mongohq',
    'uri': mongohq,
    'collections': ['logs', 'emaillogs', 'vars', 'events', 'conditions', 'fs.chunks', 'fs.files'],
  },
  {
    'outfilebase': 'mongolab',
    'uri': mongolab,
    'collections': [
      #'fblogs',
      #'fblogs2',
      #'fblogs3',
      'fblogs4',
      'fblogs5'
    ],
  }
]

mkexport = (outfilebase, uri, collection) ->
  outfile = [outfilebase, collection, outfileend].join('_')
  #login = json.loads(check_output("lsc parse_mongo_uri.ls '" + uri + "'", shell=True))
  login = mongo-uri.parse uri
  host = login['hosts'][0] + ':' + login['ports'][0]
  db = login['database']
  user = login['username']
  passwd = login['password']
  run('mongoexport -h ' + host + ' -d ' + db + ' -u ' + user + ' -p ' + passwd + " -c " + collection + " -o '" + outfile + "'")


for export_info in export_list
  for collection in export_info['collections']
    mkexport(export_info['outfilebase'], export_info['uri'], collection)
