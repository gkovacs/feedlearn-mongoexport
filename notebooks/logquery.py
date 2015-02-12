#!/usr/bin/env python
# md5: 9fa9d47bbd8d773d8f577eda78425fb8
# coding: utf-8

import os
import itertools
import json

def allcollection(collection_name):
  files = listcollectionfiles(collection_name)
  for filename in files:
    for line in open(filename):
      yield json.loads(line)

def listcollectionfiles(collection_name):
  output = []
  mongoprefix = 'mongohq_'
  if collection_name == 'fblogs':
    mongoprefix = 'mongolab_'
  logfiles = sorted(os.listdir('..'))
  logfiles = [x for x in logfiles if x.startswith(mongoprefix + collection_name)]
  for i in itertools.count(1):
    prefix = mongoprefix + collection_name
    if i > 1:
      prefix += str(i)
    files = [x for x in logfiles if x.startswith(prefix)]
    if len(files) == 0:
      break
    lastfile = files[-1]
    output.append('../' + lastfile)
  return output

