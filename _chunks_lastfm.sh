#!/bin/bash

# NOTE: For Live-playlist
# export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
# state=$(cmus-remote -C status | sed -n 1p | cut -d " " -f2)




# ------------------------------------------------------------------------------
# Get API from external file --------------------------------------------------
# ------------------------------------------------------------------------------

# APIlastfm="YOURAPIKEYFROMLASTFM"
apifile="API_file"
read -d $'\x04' APIlastfm < "$apifile"
echo $APIlastfm



# ------------------------------------------------------------------------------
# Get songs in queue -----------------------------------------------------------
# ------------------------------------------------------------------------------

 cmus-remote -C ":vol +10%"
 cmus-remote -C ":vol -10%"
 cmus-remote -C "save -q -" # from queue
 cmus-remote -C "save -p -" # from playlist
 cmus-remote -C "save -q -" | sed "s/^/add -q /" # preapend arg


 echo $(cmus-remote -C "save -q -" > tmp.txt)


# ------------------------------------------------------------------------------
# Get cmus status information --------------------------------------------------
# ------------------------------------------------------------------------------
# NOTE: For Live-playlist
# export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

state=$(cmus-remote -C status | sed -n 1p | cut -d " " -f2)

track=$(cmus-remote -C "format_print %{title}")
artist=$(cmus-remote -C "format_print %{artist}")
album=$(cmus-remote -C "format_print %{album}")
genre=$(cmus-remote -C "format_print %{genre}")

TITLE=`echo $track | tr -d -c '[:alnum:] '`
echo "$track"
echo by "$artist"
echo in "$album"
echo is "$genre"
echo ""
