# Creates a topic queue listening on an exchange and sets up a service call in response to
# messages appearing on the queue.  publishes the response onto replyTo sent with message
AMQPConnection = (require '../../lib/AMQPConnection').AMQPConnection
Exchange = (require '../../lib/domain/Exchange').Exchange
Queue = (require '../../lib/domain/Queue').Queue
AMQPConfig = (require '../../lib/AMQPConfig').AMQPConfig

config = new AMQPConfig(new Exchange 'TEST.topic', 'topic')
config.addQueue(new Queue 'a-topic-queue-1', (q, msg, deliveryInfo) ->
    returnMessage = (require './StringReversingService').StringReversingService.reverseString msg.data.toString()

    # publish to default exchange by publishing directly on connection
    q.connection.publish(deliveryInfo.replyTo, returnMessage))
 
amqpConnection = new AMQPConnection()
amqpConnection.on 'ready', ->  
    amqpConnection.createQueuesOnExchange config
    console.log "Server Ready"
    