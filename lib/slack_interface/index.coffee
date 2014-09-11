module.exports = () ->
  Config = require '../../config.json'
  os = require 'os'
  path = require 'path'

  # Path to Spotify's AppKey
  root_dir = path.dirname require.main.filename
  appkey_path = path.resolve root_dir, 'spotify_appkey.key'

  # libspotify-bindings for node
  if os.arch() == 'arm'
    Spotify = require "../spotify/pi/spotify"
  else
    Spotify = require "../spotify/mac/spotify"

  # Request authentication.
  # I'd love to use a "proper" ApiServer-middleware, but we need the request's body to do this, which
  # requires us to resume() the request and wait for a callback, which is impractical in a middleware.
  AuthHandler = require('../auth_handler')(Config.auth);
  VolumeHandler = require('../volume_handler')();
  SpotifyHandler = require('../spotify_handler')({
    spotify: Spotify({ appkeyFile: appkey_path  })
    config: Config.spotify
  })

  return require('./handler')(AuthHandler, SpotifyHandler, VolumeHandler)
