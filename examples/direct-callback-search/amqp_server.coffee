# Creates a topic queue listening on an exchange and sets up a service call in response to
# messages appearing on the queue.  publishes the response onto replyTo sent with message
AMQPConnection = (require '../../lib/AMQPConnection').AMQPConnection
Exchange = (require '../../lib/domain/Exchange').Exchange
Queue = (require '../../lib/domain/Queue').Queue
AMQPConfig = (require '../../lib/AMQPConfig').AMQPConfig

config = new AMQPConfig(new Exchange 'document.search', 'topic')
config.addQueue new Queue 'search-datasetXYZ-queue', (q, msg, deliveryInfo) ->
    # executing search
    returnMessage = (require './SearchService').SearchService.search msg.data.toString()
    
    # wedging delay in to be able to watch rabbitmq activity on web console
    delayedCallback = (q, deliveryInfo, returnMessage) =>
        # publish to default exchange by publishing directly on connection
        q.connection.publish(deliveryInfo.replyTo, returnMessage)   
        console.log "done"

    console.log "timing...."
    setTimeout ( => delayedCallback q, deliveryInfo, returnMessage), 15000

amqpConnection = new AMQPConnection()
amqpConnection.on 'ready', ->  
    amqpConnection.createQueuesOnExchange config
    console.log "Server Ready"
    