# simple service taking the place of something that might do real work on a queue
class StringReversingService
    @reverseString: (aString) ->
        aString.split('').reverse().join('')
        
exports.StringReversingService = StringReversingService