class PluginHandler
  constructor: () ->
    # Plugin cache
    @plugins = []

  # Adds all plugins to the cache
  load_plugins: () ->
    # Reset the plugin cache
    @plugins = []
    console.log "Loading Plugins..."
    root_dir = require('path').dirname require.main.filename
    require("fs").readdirSync("#{root_dir}/plugins").forEach (file) =>
      plugin = require("#{root_dir}/plugins/" + file)()
      @plugins.push plugin
      console.log " -- #{plugin.name}"
    console.log "...done."
    return

  handle: (auth, spotify, volume) ->
    state = false
    for plugin in @plugins
      if plugin.handle(auth, spotify, volume)
        return plugin.response

module.exports = () ->
  if !@handler?
    @handler = new PluginHandler()
    @handler.load_plugins()
  return @handler
