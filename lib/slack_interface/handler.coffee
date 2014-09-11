class SlackInterfaceHandler
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

            # console.info "Received command: #{@auth.command} with argument: #{@auth.argument}"

            reply_data = { ok: true }

            switch @auth.command
              when 'play' then @spotify.play @auth.argument
              when 'pause' then @spotify.pause()
              when 'stop' then @spotify.stop()
              when 'skip' then @spotify.skip()
              when 'reconnect' then @spotify.reconnect()

              when 'shuffle'
                @spotify.toggle_shuffle()
                reply_data['text'] = if @spotify.shuffle then "ERRYDAY I'M SHUFFLING." else "I am no longer shuffling. Thanks for ruining my fun."

              when 'vol'
                switch @auth.argument
                  when "up" then @volume.up()
                  when "down" then @volume.down()
                  else @volume.set @auth.argument

              when 'list'
                if @auth.argument?
                  @spotify.set_playlist @auth.argument
                else
                  str = 'Currently available playlists:'
                  for key of @spotify.config.playlists
                    str += "\n*#{key}*"
                  reply_data['text'] = str

              when 'status'
                shuffleword = if @spotify.shuffle then '' else ' not'
                reply_data['text'] = "You are currently letting your ears feast on the beautiful tunes titled *#{@spotify.current_track_name}* from *#{@spotify.current_track_artists}*.\nYour currently selected playlist, which you are#{shuffleword} shuffling through, is named *#{@spotify.current_playlist.name}*."

              when 'help'
                reply_data['text'] = "You seem lost. Maybe trying one of these commands will help you out:\n*play* [Spotify-URI] - Starts or resumes playback. If you provide a Spotify-URI it will be played immediately.\n*stop* - Stops playback.\n*pause* - Pauses playback (can be resumed using *play*).\n*skip*: Skips to the next track.\n*list* [listname] - Switches to the specified Spotify-Playlist. If no list name is provided, all available lists will be shown. Playlists need to be configured beforehand, please check the project's readme for details.\n*vol* [up|down|0-10] - Sets the output volume. Either goes up or down one notch or directly to a level ranging from 0 to 10 (inclusive). 0 is mute."


            response.serveJSON reply_data
            return
          return



module.exports = (auth, spotify, volume) ->
  handler = new SlackInterfaceHandler(auth, spotify, volume)
  return handler.endpoints

