class AMQPConfig    
    constructor: (@exchange, @queues) ->   
         
    addQueue: (queue) ->
        @queues ?= []
        @queues.push queue
    
exports.AMQPConfig = AMQPConfig