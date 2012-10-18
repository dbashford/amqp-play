# integration point with Rabbit
# holds connection for long term interaction with Rabbit queue
AMQPFactory = (require './AMQPFactory').AMQPFactory
EventEmitter = require('events').EventEmitter;

class AMQPConnection extends EventEmitter
    
    constructor: (@url) ->
        @url ?= "amqp://guest:guest@localhost:5672"
        @conn = AMQPFactory.createConnection @url
        
        # when connection is ready, indicate that OUR connection is ready
        @conn.on 'ready', =>
            this.emit 'ready'
                
    # convienence method for a single queue on an exchange
    createAQueueOnExchange: (config) ->
        @createQueuesOnExchange config

    # creates an exchange and binds queues to it
    createQueuesOnExchange: (config) ->
        AMQPFactory.createExchange @conn, config.exchange, (e) ->
            for queue in config.queues
                AMQPFactory.createQueueOnExistingExchange e, queue     

    # binds queue to default exchange
    createQueueOnDefaultExchange: (queue) ->
        AMQPFactory.createQueueOnDefaultExchange @conn, queue

    publishMessageOnExchange: (exchange, msg) ->
        AMQPFactory.createExchange @conn, exchange, (e) ->
            e.publish(msg.routingKey, msg.msg, msg.options);       

exports.AMQPConnection = AMQPConnection