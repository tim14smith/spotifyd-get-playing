# spotifyd-get-playing

A tiny shell script to get the currently playing track from [spotifyd](https://github.com/Spotifyd/spotifyd).

There are likely other/better scripts out there for this, I didn't bother searching.

## Dependencies

`sqlite3` CLI on the path.

Expected to be called by spotifyd events but you could manually call it if you want...it's just a script.

## Usage

Supply the path to this script when running `spotifyd`, e.g., 

```sh
spotifyd --on-song-change-hook /path/to/spotifyd-get-playing.sh
```

When spotifyd is running the file `$HOME/.spotifyd-playing` should contain a play/pause symbol and the currently playing track name.

## Configuration (optional)

Set environment variables to configure the sqlite3 database file name (default is `$HOME/.spotifyd.db`) or the currently playing song file name (default is `$HOME/.spotifyd-playing`).

```sh
export SPOTIFYD_DB=/path/to/.my-custom-spotifyd.db
export SPOTIFYD_PLAYING_FILE=/path/to/.my-custom-spotifyd-playing-file
```

## License

MIT license. See [LICENSE](LICENSE)
