#responsible for creating connections exchanges and queues
amqp = require 'amqp'

class AMQPFactory    
    @createConnection: (theUrl, callback) ->
        conn = amqp.createConnection {url: theUrl}
        conn.on 'ready', ->
            if callback? then callback(this)

    # Creates exchange
    @createExchange: (conn, aExchange, callback) ->
        conn.exchange aExchange.name, {type:aExchange.type, passive:false, durable:false}, callback

    # creates a queue on an existing exchange (passed in)
    # for now binds to all messages
    @createQueueOnExistingExchange: (e, aQueue) ->
        e.connection.queue aQueue.name, {durable:false}, (q) =>
            aQueue.extend(q)
            aQueue.bind e.name, '#'
            @queueSubscribe aQueue

    # Creates queue bound to the default exchange
    # different props for queue and no binding
    @createQueueOnDefaultExchange: (conn, aQueue) ->
        conn.queue aQueue.name, {durable:false, exclusive:true, autoDelete:true}, (q) =>
            aQueue.extend(q)
            @queueSubscribe aQueue

    # associates functionality with messages appearing in a queue
    @queueSubscribe: (aQueue) ->
        aQueue.subscribe {routingKeyInPayload:true}, (msg, headers, deliveryInfo) ->
            if aQueue.callback?
                aQueue.callback(aQueue, msg, deliveryInfo)
            else
                console.log "Exchange: #{aQueue.exchange.name}, Queue: #{aQueue.name}! #{msg.data.toString()}"      

exports.AMQPFactory = AMQPFactory