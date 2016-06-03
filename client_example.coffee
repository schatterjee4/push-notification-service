amqp = require 'amqp-as-promised'
genrun = require 'q-genrun'

conf =
  connection:
    url: process.env.RABBITMQ_URL or "amqp://localhost:5672//?heartbeat=10"
  logLevel: 'warn'

amqpc = amqp(conf)

if not module.parent then genrun ->

  # launch this as
  # coffee client_example.coffee [gcm|apn] [devicetoken] [textmessage]

  try
    type = process.argv[2]
    token = process.argv[3]
    message = process.argv[4]

    note =
      alert: message
      tokens: [token] if token
      type: type

    console.log 'Sending notification', note

    response = yield amqpc.rpc('myexchange', 'push-notification-service', note)
    console.log response

  catch error
    console.log error

  yield amqpc.shutdown()
