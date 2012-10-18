# serves up simple page (on 8080) that allows for executing "search" from web client and then sending results back
http = require 'http'
nowjs = require 'now'
fs = require 'fs'
AMQPConnection = (require '../../lib/AMQPConnection').AMQPConnection
Exchange = (require '../../lib/domain/Exchange').Exchange
MessageConfig = (require '../../lib/domain/MessageConfig').MessageConfig
Queue = (require '../../lib/domain/Queue').Queue

httpServer = http.createServer (req, res) -> 
    res.end(fs.readFileSync "#{__dirname}/test_amqp.html")
httpServer.listen 8080        
everyone = nowjs.initialize httpServer

# get connection and hold onto it, connection making is expensive
amqpConnection = new AMQPConnection()
amqpConnection.on 'ready', ->
    everyone.now.executeSearch = (msg) ->
        returnMessageQueueName = 'search-results-queue-' + Math.floor(Math.random() * 100000)
        callback = (q, msg, deliveryInfo) =>
            # initial request over, is async message back from Rabbit, ajax push via websockets/flash!
            this.now.notify msg.documents
            q.destroy();

        amqpConnection.createQueueOnDefaultExchange new Queue returnMessageQueueName, callback                         
        amqpConnection.publishMessageOnExchange new Exchange('document.search','topic'), 
            new MessageConfig msg,"message.text",{replyTo: returnMessageQueueName, contentType: 'text/plain'}
    console.log "Server Ready"
            