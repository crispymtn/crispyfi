class MyFirstPlugin
  constructor: () ->
    @name = 'My First Plugin'
    @response = null

  handle: (auth, spotify, volume) ->
    if auth.command == 'plugin'
      # This will be replied to the channel. If nothing is set, no reply will be sent.
      @response = "This is a reply from #{@name}."
      return true
    else
      return false

module.exports = () ->
  return new MyFirstPlugin()
