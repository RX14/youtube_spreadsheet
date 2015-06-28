youtube_spreadsheet
===================
Downloads the audio from every youtube URL in a google docs spreadsheet.

Can be easily modified to download videos instead of audio by removing the `-x` flag in the `youtube-dl` invocation.
The download folder and filenames can also be easilly customised in the `youtube-dl` invocation.

Status is placed in the cells to the right of each URL, make sure to keep them empty.

Dependnencies
-------------
- Ruby (obviously)
- The stuff in the Gemfile (run `bundle`)
- [`youtube-dl`](https://github.com/rg3/youtube-dl/) command

Usage
-----
Run `./youtube_spreadsheet.rb` then follow the intructions.
