<p align="center">
  <img src="figs/logo.png"  width="20%">
  <H2 align="center">CMus-dynamiclistfm</H2>
</p>

*Dynamic* list generator for [CMus](https://cmus.github.io/) (C\* Music Player) based on the [LastFm](https://www.last.fm/) database

---


### Aims
<!-- The aims of this mini-extension are: -->
+ to create a dynamic playlist, similar to the extension in [Amarok 1.2](https://amarok.kde.org/)
+ to maintain a low-level script able to work with CMus smoothly





### Features
1. it creates a playlist based on a list of songs, matching the result with a local library
2. it creates a playlist based on current song playing/queuing
3. it specifies the size of the playlist



### ToDo
- [x] Loop playlist songs
- [x] Get lastfm similartracks
- [x] Limit the method to retrieve xml data
- [x] Check existence in CMus library (*.lb)
- [x] Verify generation of playlists in CMus
- [x] fn() Selector: current song or playlist (and live re-make amarok)
- [x] playlist size
- [x] create playbase.txt or CMus/playlist.pl
- [ ] Add subset to playlist
- [ ] live-mode playlist generator
- [ ] use `jq` instead of `xml`


### Prerequisites :
- `cmus` - is a small ncurses based music player.  It supports various output methods by output-plugins. cmus has completely configurable keybindings and can be controlled from the outside via *cmus-remote*
- `curl` - is a tool to transfer data from or to a server, using one of the supported protocols (DICT, FILE, FTP, FTPS, GOPHER, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, TELNET and TFTP). The command is designed to work without user interaction.
- `tr` - is an UNIX utility for translating, or deleting, or squeezing repeated characters.
- `awk` - is a powerful method for processing or analysing text files—in particular, data files that are organised by lines (rows) and columns.
- `xml` - is a command lines utility to parse _xml_ files





### Installation and Use :

In any folder, download `cmus-dynamiclistfm` by cloning the project
```sh
git clone https://github.com/guxsousa/cmus-dynamiclistfm.git
```
or by getting a zip
```sh
wget https://github.com/guxsousa/cmus-dynamiclistfm/archive/master.zip
unzip cmus-dynamiclistfm-master.zip
```

Get inside the folder and check permissions to make the files executable
```sh
cd cmus-dynamiclistfm-master/
chmod 755 *.sh
cd ..
```

Get an API key from [LastFm](https://www.last.fm/api). Create a file called `API_file` and paste the key there.
```sh
touch API_file
vi API_file
<paste key here>
```
or just
```sh
YOURAPIKEYFROMLASTFM > API_file
```

So that the `API_file` content is:

    YOURAPIKEYFROMLASTFM




##### Files

`add_songs.sh` is used to add songs into an external file (*.txt), while a song is playing in CMus
```sh
./add_songs.sh
```

`list_file.sh` reads an external file and creates a playlist. This file can be the one created with `add_songs` or a file created manually.
```sh
./list_files.sh playlist.txt 21
```

`list_current.sh` creates a playlist based on the song played in CMus.
```sh
./list_current.sh 45
```





### CMus Shurcut Keys

<kbd>1</kbd> : tree

<kbd>2</kbd> : library

<kbd>3</kbd> : queue

<kbd>4</kbd> : **playlists**

<kbd>5</kbd> : directory

<kbd>6</kbd> : filters

<kbd>7</kbd> : Settings

<kbd>u</kbd> : refresh

<kbd>c</kbd> : continue

<kbd>r</kbd> : repeat

<kbd>s</kbd> : shuffle





### License

This software is licensed under the [MIT License](LICENSE).



### Authors

Gus Sousa -- [guxsousa](https://github.com/guxsousa)
