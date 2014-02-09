express = require 'express'
pg      = require 'pg'
app = express()

app.post '/message/create', (req, res) ->
  body = 'hello world'
  res.setHeader 'Content-Type', 'text/plain'
  res.setHeader 'Content-Length', body.length
  res.end body

app.listen 3000
