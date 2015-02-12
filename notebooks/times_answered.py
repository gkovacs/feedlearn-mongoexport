#!/usr/bin/env python
# md5: fccedef67d66cb3d568272f3756034ff
# coding: utf-8

from logquery import allcollection
from jsobj import Object
import numpy

def users_who_did_posttest():
  output = []
  for data in allcollection('quiz'):
    if data['quiztype'] == 'posttest':
      output.append(data['username'])
  return output

def main():
  users = {}
  whitelist = {}
  for k in users_who_did_posttest():
    whitelist[k] = True
  for data in allcollection('logs'):
    data = Object(data)
    if 'username' not in data or 'type' not in data or 'format' not in data or 'qcontext' not in data:
      continue
    username = data['username']
    datatype = data['type']
    dataformat = data['format']
    qcontext = data['qcontext']
    qcontext_format = {
      'facebook': 'interactive',
      'website': 'link',
      'emailvisit': 'none',
    }[qcontext]
    if datatype == 'missingcookie':
      continue
    if username not in whitelist:
      continue
    if username not in users:
      users[username] = Object({
        'interactive': {
          'answered': 0,
          'feedinsert': 0,
        },
        'link': {
          'answered': 0,
          'feedinsert': 0,
        },
        'none': {
          'answered': 0,
          'feedinsert': 0,
        },
      })
    if datatype == 'answered':
      users[username][dataformat].answered += 1
    if datatype == 'feedinsert':
      users[username][dataformat].feedinsert += 1
  print users

main()

