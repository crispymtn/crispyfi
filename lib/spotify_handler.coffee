class SpotifyHandler
  constructor: (options) ->
    @spotify = options.spotify
    @config = options.config

    @connect_timeout = null
    @connected = false

    # "playing" in this context means actually playing music or being currently paused (but NOT stopped).
    # This is an important distinction regarding the functionality of @spotify.player.resume().
    @playing = false
    # Whether we're SHUFFLING ERRYDAY or not.
    @shuffle = false
    # Current state
    @current_track = null
    @current_track_index = 0
    @current_track_name = null
    @current_track_artists = null
    @current_playlist = {
      name: null,
      playlist: null
    }

    @spotify.on
      ready: @spotify_connected.bind(@)
      logout: @spotify_disconnected.bind(@)
    @spotify.player.on
      endOfTrack: @skip.bind(this)

    # And off we got
    @connect()


  # Connects to Spotify.
  connect: ->
    @spotify.login @config.username, @config.password, false, false


  # Called after we have successfully connected to Spotify.
  # Clears the connect-timeout and grabs the default Playlist (or resumes playback if another playlist was set).
  spotify_connected: ->
    @connected = true
    clearTimeout @connect_timeout
    @connect_timeout = null
    if @current_playlist.name?
      @play()
    else
      @set_playlist 'default'
    return


  # Called after the handler has lost its connection to Spotify.
  # Attempts to re-connect every 2.5s.
  spotify_disconnected: ->
    @connected = false
    @connect_timeout = setTimeout (() => @connect), 2500
    return


  # Called after the current playlist has been updated.
  # Simply replaces the current playlist-instance with the new one and re-bind events.
  # Player-internal state (number of tracks in the playlist, current index, etc.) is updated on @get_next_track().
  update_playlist: (err, playlist, tracks, position) ->
    @current_playlist.playlist = playlist
    @current_playlist.playlist.on
      tracksAdded: @update_playlist.bind(this)
      tracksRemoved: @update_playlist.bind(this)
    return


  # Pauses playback at the current time. Can be resumed by calling @play().
  pause: ->
    @spotify.player.pause()
    return


  # Stops playback. This does not just pause, but returns to the start of the current track.
  # This state can not be changed by simply calling @spotify.player.resume(), because reasons.
  # Call @play() to start playing again.
  stop: ->
    @playing = false
    @spotify.player.stop()
    return


  # Plays the next track in the playlist
  skip: ->
    @play @get_next_track()
    return


  # Toggles shuffle on and off. MAGIC!
  toggle_shuffle: ->
    @shuffle = !@shuffle


  # Either starts playing the current track (or next one, if none is set) or immediately
  # plays the provided track or link.
  play: (track_or_link=null) ->
    # If a track is given, immediately switch to it
    if track_or_link?
      switch typeof track_or_link
        # We got a link from Slack
        when 'string'
          # Links from Slack are encased like this: <spotify:track:1kl0Vn0FO4bbdrTbHw4IaQ>
          # So we remove everything that is neither char, number or a colon.
          track_or_link = track_or_link.replace /[^0-9a-zA-Z:]/g, ''
          new_track = @spotify.createFromLink track_or_link
          # If the track was somehow invalid, don't do anything
          return if !new_track?
        # We also use this to internally trigger playback of already-loaded tracks
        when 'object'
          new_track = track_or_link
        # Other input is simply disregarded
        else
          return
    # If we are already playing, simply resume
    else if @playing
      return @spotify.player.resume()
    # Last resort: We are currently neither playing not have stopped a track. So we grab the next one.
    else if !new_track
      new_track = @get_next_track()

    # We need to check whether the track has already completely loaded.
    if new_track? && new_track.isLoaded
      @_play_callback new_track
    else if new_track?
      @spotify.waitForLoaded [new_track], (track) =>
        @_play_callback new_track
    return


  # Handles the actual playback once the track object has been loaded from Spotify
  _play_callback: (track) ->
    @current_track = track
    @current_track_name = @current_track.name
    @current_track_artists = @current_track.artists.map((artist) ->
      artist.name
    ).join ", "

    @spotify.player.play @current_track
    @playing = true
    return


  # Gets the next track from the playlist.
  get_next_track: ->
    if @shuffle
      @current_track_index = Math.floor(Math.random() * @current_playlist.playlist.numTracks)
    else
      @current_track_index = ++@current_track_index % @current_playlist.playlist.numTracks
    @current_playlist.playlist.getTrack(@current_track_index)


  # Changes the current playlist and starts playing.
  # Since the playlist might have loaded before we can attach our callback, the actual playlist-functionality
  # is extracted to _set_playlist_callback which we call either directly or delayed once it has loaded.
  set_playlist: (name = 'default') ->
    if @config.playlists[name]?
      playlist = @spotify.createFromLink @config.playlists[name]
      if playlist && playlist.isLoaded
        @_set_playlist_callback name, playlist
      else if playlist
        @spotify.waitForLoaded [playlist], (playlist) =>
          @_set_playlist_callback name, playlist
          return
    return


  # The actual handling of the new playlist once it has been loaded.
  _set_playlist_callback: (name, playlist) ->
    @current_playlist.name = name
    @current_playlist.playlist = playlist
    @current_playlist.playlist.on
      tracksAdded: @update_playlist.bind(this)
      tracksRemoved: @update_playlist.bind(this)
    @current_track_index = 0
    @play @current_playlist.playlist.getTrack @current_track_index
    return



# export things
module.exports = (options) ->
  return new SpotifyHandler(options)
