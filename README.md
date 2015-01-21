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

* `play [Spotify URI]` - Starts/resumes playback if no URI is provided. If a URI is given, immediately switches to the linked track.
* `pause` - Pauses playback at the current time.
* `stop` - Stops playback and resets to the beginning of the current track.
* `skip` - Skips (or shuffles) to the next track in the playlist.
* `shuffle` - Toggles shuffle on or off.
* `vol [up|down|0..10]` Turns the volume either up/down one notch or directly to a step between 0 (mute) and 10 (full blast). Also goes to eleven.
* `list [command] [options]` - See playlists section below.
* `status` - Shows the currently playing song, playlist and whether you're shuffling or not.
* `help` - Shows a list of commands with a short explanation.

If you're using Slack integrations, simply create an outgoing webhook to `http://your-crispyfi-url/handle` that listens to the appropriate trigger words. See below for an example screenshot of our setup. To disable certain funtions, just remove the trigger word.

![Slack integration](http://i.imgur.com/Tye5R2W.png)

## Playlists
CrispyFi provides a command line-like interface to its internal playlist handling you can use to add, remove and rename lists. This data is persisted between sessions and will be available upon restart. On a fresh startup, CrispyFi attempts to load the last playlists you used or, failing that, will look for a playlist named "default". If neither of those work, it'll just pout a bit and not play anything. Using this interface is straight forward:

* `list add <name> <Spotify URI>` - Adds a list that can later be accessed under <name>.
* `list remove <name>` - Removes the specified list.
* `list rename <old name> <new name>` - Renames the specified list.
* `list <name>` - Selects the specified list and starts playback.

## Plugins
If CrispyFi doesn't do what you need, you can extend it. The plugin architecture is pretty minimal at this point, but at least there's a standardized interface. If none of the default trigger words matched, each plugin's `handle` method will be called until one is found that returns `true`. If a plugin returns `true`, the plugin chain is halted and the plugin's `status` attribute is checked for content. If it's not empty, its content will be replied to the Slack channel CrispyFi listens to. If it's empty, nothing further will happen (the plugin chain will *not* be traversed further, though).

Plugins live in `/plugins` and need a `name` attribute. A minimal example implementation is provided in `examples/my_first_plugin.coffee`.

## Getting your groove on(line)
Since your Pi will probably be behind a firewall/some sort of NAT or have a dynamic IP, you'll have difficulties tying Slack's webhooks to its IP address. We're currently using [ngrok](http://ngrok.com) to get around that, mainly because it's awesome and makes developing web services much easier. Also, using ngrok you avoid the hassle of updating some other service's configuration whenever your IP changes, instead you have to run a small binary all the time. YMMV, so use whatever you're comfortable with (but give ngrok a try).

## Used Software
CrispyFi builds upon [ApiServer](https://github.com/kilianc/node-apiserver) by killianc and includes a pre-compiled version of FrontierPsychiatrist's [node-spotify](https://github.com/FrontierPsychiatrist/node-spotify) since our Raspberry Pi stoically refused to compile the extension itself. The according license is redistributed as per the terms of the MIT License and can be found in the file `licenses/node-spotify` in the project's root directory. Also in use is simonlast's [node-persist](https://github.com/simonlast/node-persist) for persistent storage of playlist data.

We extend our everlasting gratitude to all of you!

## License
This software is released under the MIT license, which can be found under `licenses/crispyfi`.
