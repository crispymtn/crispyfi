class SlackInterfaceRequestHandler
  constructor: (auth, spotify, volume) ->
    @auth = auth
    @spotify = spotify
    @volume = volume

    @endpoints =
      handle:
        post: (request, response) =>
          request.resume()
          request.once "end", =>
            return if !@auth.validate(request, response)

            reply_data = { ok: true }

            switch @auth.command
              when 'play' then @spotify.play @auth.args[0]
              when 'pause' then @spotify.pause()
              when 'stop' then @spotify.stop()
              when 'skip' then @spotify.skip()
              when 'reconnect' then @spotify.reconnect()

              when 'shuffle'
                @spotify.toggle_shuffle()
                reply_data['text'] = if @spotify.shuffle then "ERRYDAY I'M SHUFFLING." else "I am no longer shuffling. Thanks for ruining my fun."

              when 'vol'
                switch @auth.args[0]
                  when "up" then @volume.up()
                  when "down" then @volume.down()
                  else @volume.set @auth.args[0]

              when 'list'
                if @auth.args[0]?
                  switch @auth.args[0]
                    when 'add' then status = @spotify.add_playlist @auth.args[1], @auth.args[2]
                    when 'remove' then status = @spotify.remove_playlist @auth.args[1]
                    when 'rename' then status = @spotify.rename_playlist @auth.args[1], @auth.args[2]
                    else status = @spotify.set_playlist @auth.args[0]
                  if status
                    reply_data['text'] = 'Ok.'
                  else
                    reply_data['text'] = "I don't understand. Please consult the manual or cry for help."
                else
                  str = 'Currently available playlists:'
                  for key of @spotify.playlists
                    str += "\n*#{key}* (#{@spotify.playlists[key]})"
                  reply_data['text'] = str


              when 'status'
                shuffleword = if @spotify.shuffle then '' else ' not'
                reply_data['text'] = "You are currently letting your ears feast on the beautiful tunes titled *#{@spotify.state.track.name}* from *#{@spotify.state.track.artists}*.\nYour currently selected playlist, which you are#{shuffleword} shuffling through, is named *#{@spotify.state.playlist.name}*."

              when 'help'
                reply_data['text'] = "You seem lost. Maybe trying one of these commands will help you out:\n*play* [Spotify-URI] - Starts or resumes playback. If you provide a Spotify-URI it will be played immediately.\n*stop* - Stops playback.\n*pause* - Pauses playback (can be resumed using *play*).\n*skip*: Skips to the next track.\n*list* [listname] - Switches to the specified Spotify-Playlist. If no list name is provided, all available lists will be shown. Playlists need to be configured beforehand, please check the project's readme for details.\n*vol* [up|down|0-10] - Sets the output volume. Either goes up or down one notch or directly to a level ranging from 0 to 10 (inclusive). 0 is mute."


            response.serveJSON reply_data
            return
          return



module.exports = (auth, spotify, volume) ->
  handler = new SlackInterfaceRequestHandler(auth, spotify, volume)
  return handler.endpoints

