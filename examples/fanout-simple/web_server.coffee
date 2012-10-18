# serves up simple page (on 8080) that allows for publishing messages from web client
http = require 'http'
nowjs = require 'now'
fs = require 'fs'
AMQPConnection = (require '../../lib/AMQPConnection').AMQPConnection
Exchange = (require '../../lib/domain/Exchange').Exchange
MessageConfig = (require '../../lib/domain/MessageConfig').MessageConfig

httpServer = http.createServer (req, res) -> res.end(fs.readFileSync "#{__dirname}/test_amqp.html")
httpServer.listen 8080        
everyone = nowjs.initialize httpServer

# establish connection and create exchanges/queues
amqpConnection = new AMQPConnection()
amqpConnection.on 'ready', ->
    everyone.now.sendMessage = (msg) -> 
        amqpConnection.publishMessageOnExchange new Exchange('TEST.fanout','fanout'), 
            new MessageConfig msg,"message.text",{contentType: 'text/plain'}
    console.log "Server Ready"
