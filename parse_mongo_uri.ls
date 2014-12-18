require! 'mongo-uri'

console.log JSON.stringify mongo-uri.parse process.argv[2]
