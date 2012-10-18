Exchange = (require '../../lib/domain/Exchange').Exchange
Queue = (require '../../lib/domain/Queue').Queue
AMQPConnection = (require '../../lib/AMQPConnection').AMQPConnection
AMQPConfig = (require '../../lib/AMQPConfig').AMQPConfig

# build configuration for this Exchange and its bound queues
config = new AMQPConfig(new Exchange 'TEST.fanout', 'fanout')
config.addQueue(new Queue 'a-topic-queue-1')
config.addQueue(new Queue 'a-topic-queue-2', (q, msg, deliveryInfo) ->
    console.log "Callback on queue #{q.name} from exchange #{q.exchange.name}! Message : #{msg.data.toString()}")

# establish connection and create exchanges/queues
amqpConnection = new AMQPConnection()
amqpConnection.on 'ready', ->
    amqpConnection.createQueuesOnExchange(config)
    console.log "Server Ready"
    