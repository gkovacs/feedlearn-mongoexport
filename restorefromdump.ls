#!/usr/bin/env lsc

# assumes you have already started a monogd server as follows:
# mkdir mongodbstore
# mongod --dbpath mongodbstore

require! 'fs'
{run} = require 'execSync'

listmostrecentdump = ->
  dumpdirs = fs.readdirSync('.').sort().filter((x) -> x.indexOf('dump_') == 0)
  return dumpdirs[*-1]

main = ->
  dumpdir = listmostrecentdump()
  for dbpath in fs.readdirSync(dumpdir)
    console.log dumpdir + '/' + dbpath
    run "mongorestore --db default '#{dumpdir}/#{dbpath}'"

main()
