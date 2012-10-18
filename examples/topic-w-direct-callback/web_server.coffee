# serves up simple page (on 8080) that allows for publishing messages from web client
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
    everyone.now.sendMessage = (msg) ->
        returnMessageQueueName = 'arandomqueuename'
        callback = (q, msg, deliveryInfo) =>
            # initial request over, is async message back from Rabbit, ajax push!
            this.now.notify msg.data.toString()
            q.destroy();

        amqpConnection.createQueueOnDefaultExchange new Queue returnMessageQueueName, callback                         
        amqpConnection.publishMessageOnExchange new Exchange('TEST.topic','topic'), 
            new MessageConfig msg,"message.text",{replyTo: returnMessageQueueName, contentType: 'text/plain'}
    console.log "Server Ready"
            