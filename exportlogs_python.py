#!/usr/bin/env python

import json
from subprocess import check_output, call
from os import path

datecmd = 'date'
if path.exists('/usr/local/bin/gdate'):
  datecmd = '/usr/local/bin/gdate'

outfileend = check_output(datecmd + ' --rfc-3339=seconds', shell=True).strip().replace(' ', '_') + '.json'

mongourls = json.load(open('.mongourls.json'))
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
      'fblogs2',
      'fblogs3',
      'fblogs4'
    ],
  }
]

def mkexport(outfilebase, uri, collection):
  outfile = '_'.join([outfilebase, collection, outfileend])
  login = json.loads(check_output("lsc parse_mongo_uri.ls '" + uri + "'", shell=True))
  host = login['hosts'][0] + ':' + str(login['ports'][0])
  db = login['database']
  user = login['username']
  passwd = login['password']
  call('mongoexport -h ' + host + ' -d ' + db + ' -u ' + user + ' -p ' + passwd + " -c " + collection + " -o '" + outfile + "'", shell=True)


for export_info in export_list:
  for collection in export_info['collections']:
    mkexport(export_info['outfilebase'], export_info['uri'], collection)

'''
outfilebase = 'mongoexport_logs'
collection = 'logs'
outfile = '_'.join([outfilebase, collection, outfileend])
login = json.load(open('mongologin.json'))
host = login['mongohost']
db = login['mongodb']
user = login['mongouser']
passwd = login['mongopassword']

call('mongoexport -h ' + host + ' -d ' + db + ' -u ' + user + ' -p ' + passwd + " -c " + collection + " -o '" + outfile + "'", shell=True)
'''
