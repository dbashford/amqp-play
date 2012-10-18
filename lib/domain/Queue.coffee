class Queue 
    constructor: (@name, @callback) ->
        
    # exposes node-amqp queue through convenience queue
    extend : (q) ->
        this[name] = method for name, method of q        

exports.Queue = Queue