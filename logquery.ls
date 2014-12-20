require! 'fs'
require! 'read-each-line-sync'

eachlinecollection = (collection_name, processline) ->
  files = listcollectionfiles(collection_name)
  for file in files
    readEachLineSync file, processline

export allcollection = (collection_name, processjson) ->
  files = listcollectionfiles(collection_name)
  for file in files
    readEachLineSync file, (line) ->
      processjson JSON.parse line

export matchval = (query) ->
  return (json) ->
    for k,v of query
      if not json[k]? or json[k] != v
        return false
    return true

export haskeys = (...keys) ->
  return (json) ->
    for k in keys
      if not json[k]?
        return false
    return true

export alltrue = (...funclist) ->
  return (json) ->
    for func in funclist
      if not func(json)
        return false
    return true

export anytrue = (...funclist) ->
  if funclist.length == 0
    return (json) -> true
  return (json) ->
    for func in funclist
      if func(json)
        return true
    return false

export querycollection = (collection_name, filterfunc, processjson) ->
  files = listcollectionfiles(collection_name)
  for file in files
    readEachLineSync file, (line) ->
      json = JSON.parse line
      if filterfunc json
        processjson json

listcollectionfiles = (collection_name) ->
  output = []
  mongoprefix = 'mongohq_'
  if collection_name == 'fblogs'
    mongoprefix = 'mongolab_'
  logfiles = fs.readdirSync('.').sort().filter((x) -> x.indexOf(mongoprefix + collection_name) == 0)
  lognum = 1
  for i from 1 to Infinity
    prefix = mongoprefix + collection_name
    if i != 1
      prefix += i
    files = logfiles.filter((x) -> x.indexOf(prefix) == 0)
    if files.length == 0
      break
    lastfile = files[*-1]
    output.push lastfile
  return output