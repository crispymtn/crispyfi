<p align="center">
  <img src="http://res.cloudinary.com/hlwjgyj8f/image/upload/v1410430228/h71mqvptn5t1yc9pdjuf.png" alt="CrispyFi" />
</p>
<hr />
*CrispyFi* is a local pseudo-bot for [Slack](http://slack.com) that controls what the people in your office have to listen to. It's comprised of a small Node.js-based server that interfaces with Spotify and is controlled by chat commands in your Slack chatroom of choice. It's designed to run on a Raspberry Pi connected to your sound system, but should work on any system that supports [node-spotify](http://node-spotify.com) and volume control using `amixer` (not required, though). Sound is streamed to your device's default audio output and thus can work with the integrated audio jack, HDMI output or additional sound boards like the HiFiBerry.

## Local pseudo-bot?
In contrast to many existing Slack integrations, you're supposed to run CrispyFi locally in your office where it can access your sound hardware. Also, it's not really an IRC-style bot since it doesn't connect to your chat rooms itself, but rather listens to simple HTTP requests and replies accordingly. If you issue these commands from Slack, you'll even get comments back.

## Requirements
There are three main prerequisites for CrispyFi to do his job:

* Node.js installed on your Raspberry. [This link](http://joshondesign.com/2013/10/23/noderpi) should get you there in a few minutes.
* A Spotify account. CrispyFi doesn't care for your MP3s.
* A Spotify API-Key. You need to apply for one, which you can do [here](https://devaccount.spotify.com/my-account/keys/).

## Installation
1. Once you have everything you need, clone this repo into a directory of your choice.
2. Copy your `spotify_appkey.key` into the installation directory.
3. Edit `config.json` according to your needs. Most of it is self-explanatory, but we'll go into details later on.
4. `npm install`
5. `npm start` or `node index`, whatever works for you.

That's it, your personal CrispyFi instance is now ready to serve requests. There's some additional steps you might want to take, though, (e.g. integrating it with Slack), so read on!

## Configuration
All the important bits are controlled by `config.json` in the project's root path. Below is a code example with comments which *you need to remove* when you copy/pase it, since comments are not allowed in JSON files.

```
{
  "spotify": {
    "username": "Spotify Username",
    "password": "Spotify Password",

    // Playlists need to be pre-configured for use here.
    // Create playlists using the Spotify app, then right-click
    // them and copy their URIs. The names in here don't have to
    // match the actual Playlist's name but are used as arguments,
    // so you might want to keep them short and simple.
    // A playlist named "default" is required!
    "playlists": {
      "default": "spotify:user:crispymtn:playlist:1xUTFaq10nzODhwkwLMo2l",
      "metal": "spotify:user:crispymtn:playlist:6IkIC1Rq6bMkhsO0sj9GGs",
      "hiphop": "spotify:user:crispymtn:playlist:71SBbMfSyMHRAIxl8fKEbI"
    }
  },
  "auth": {
  	// Slack generates one token per integration, so you can just put them
  	// all in here. We don't check the token per integraion, but rather
  	// just whether it's included in this list.
    "tokens": [
      "slack-token-one",
      "slack-token-two"
    ]
  },
}
```

## How does it work?
By default, CrispyFi listens on port 8000 and provides a single HTTP endpoint. To issue orders to it, you have to POST to the endpoint and provide an authentication token as well as a command. The format of this is a bit non-standard (i.e. no token in the header) since we built it to be mainly used in combination with Slack's outgoing webhooks. You should probably create an outgoing webhook first and familiarize yourself with the semantics, but the short version is you need a POST body with the following fields:

```
token=<your auth thoken>
text=<trigger_word> <argument>
```

Currently the following trigger words are available:

* `play [Spotify URI]` - Starts/resumes playback if no URI is provided. If a URI is given, immedtiately switches to the linked track.
* `pause` - Pauses playback at the current time.
* `stop` - Stops playback and resets to the beginning of the current track.
* `skip` - Skips (or shuffles) to the next track in the playlist.
* `shuffle` - Toggles shuffle on or off.
* `vol [up|down|0..10]` Turns the volume either up/down one notch or directly to a step between 0 (mute) and 10 (full blast). Also goes to eleven.
* `list [list name]` - When provided with an argument, switches to this playlist. Otherwise, shows all available playlists.
* `status` - Shows the currently playing song, playlist and whether you're shuffling or not.
* `help` - Shows a list of commands with a short explaantion.

If you're using Slack integrations, simply create an outgoing webhook to `http://your-crispyfi-url/handle` that listens to the appropriate trigger words. See below for an example screenshot of our setup. To disable certain funtions, just remove the trigger word.

![Slack integration](http://i.imgur.com/Tye5R2W.png)

## Getting your groove on(line)
Since your Pi will probably be behind a firewall/some sort of NAT or have a dynamic IP, you'll have difficulties tying Slack's webhooks to its IP address. We're currently using [ngrok](http://ngrok.com) to get around that, mainly because it's awesome and makes developing web services much easier. Also, using ngrok you avoid the hassle of updating some other service's configuration whenever your IP changes, instead you have to run a small binary all the time. YMMV, so use whatever you're comfortable with (but give ngrok a try).

## Used Software
CrispyFi builds upon [ApiServer](https://github.com/kilianc/node-apiserver) by killianc and includes a pre-compiled version of FrontierPsychiatrist's [node-spotify](https://github.com/FrontierPsychiatrist/node-spotify) since our Raspberry Pi stoically refused to compile the extension itself. The according license is redistributed as per the terms of the MIT License and can be found in the file `licenses/node-spotify` in the project's root directory.

We extend our everlasting gratitude to both of you!

## License
This software is released under the MIT license, which can be found under `licenses/crispyfi`.
