express = require 'express'
pg      = require 'pg'
request = require 'request'

{inspect} = require 'util'

app = express()

#app.use (req, res, next) ->
#  req.rawBody = '';
#  req.setEncoding('utf8');
#
#  req.on 'data', (chunk) ->
#    req.rawBody += chunk
#
#  req.on 'end', ->
#    next()

app.use(express.urlencoded())
app.use(express.json())

if not process.env.HOARDER_DB_USER?
  throw "HOARDER_DB_USER not defined in environment"
  process.exit(1)

if not process.env.HOARDER_DB_HOST?
  throw "HOARDER_DB_HOST not defined in environment"
  process.exit(1)

if not process.env.HOARDER_DB_DATABASE?
  throw "HOARDER_DB_DATABASE not defined in environment"
  process.exit(1)

if not process.env.HOARDER_PORT?
  throw "HOARDER_PORT not defined in environment"
  process.exit(1)

if not process.env.HOARDER_HUBOT_URL?
  throw "HOARDER_HUBOT_URL not defined in environment"
  process.exit(1)

client = new pg.Client("postgres://#{process.env.HOARDER_DB_USER}@#{process.env.HOARDER_DB_HOST}/#{process.env.HOARDER_DB_DATABASE}")

client.connect (connectErr) ->
  if connectErr
     console.error('Could not connect to postgres', connectErr)
     process.exit 1

  app.post '/message/create', (req, res) ->
    m = req.body
    console.error("body info: #{inspect m}")
    m.params or= {}
    createQuery = """
      insert into messages (message, message_type, nick, channel, network, profile, created, params)
      values ($1, $2, $3, $4, $5, $6, 'epoch'::timestamp + $7 * '1 millisecond'::interval, $8)
    """
    console.log("query: #{createQuery}")
    bindParams = [m.message, 'message', m.nick, m.channel, m.network, m.profile, m.time, JSON.stringify(m.params)]
    console.error("sql params: #{inspect bindParams}")

    client.query createQuery, bindParams, (queryErr, result) ->
      bodyData = {}
      if queryErr
        console.error("ERROR: #{inspect queryErr}")
        bodyData.success = false
        bodyData.reason = queryErr
      else
        console.log("Message saved!")
        bodyData.success = true

      res.json(bodyData)

  app.get "/health.json", (req, res) ->
    res.json {success: true}

  console.log("listening on #{process.env.HOARDER_PORT}...")


  app.listen process.env.HOARDER_PORT, ->
    # Send an "I'm up now" request to hubot
    request(
      {
        url: "#{process.env.HOARDER_HUBOT_URL}?b=up",
        method: "get"
      },
      (err, res) ->
        if err
          console.error("Could not hit hubot httpd")
        else
          if res.statusCode isnt 200
            console.error """
              Retrieve hubot httpd status code #{res.statusCode}.
              Body: #{res.body}
            """
      )
