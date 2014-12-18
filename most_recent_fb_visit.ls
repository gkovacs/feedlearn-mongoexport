require! 'fs'

users = {}

fileconts = fs.readFileSync process.argv[2], 'utf-8'
for line in fileconts.split('\n')
  try
    data = JSON.parse line
  catch
    continue
  {type, username, time} = data
  if not time? or not isFinite(time)
    continue
  if type == 'fbvisit' or type == 'fbstillopen'
    if users[username]?
      users[username] = time
    else
      users[username] = Math.max(users[username], time)

#console.log users
for k,v of users
  console.log k, new Date(parseInt(v))
