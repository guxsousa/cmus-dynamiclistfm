#!/bin/bash

#==============================================================================
#title           :add_songs.sh
#description     :This script adds files to a reference file.
#author          :Gus Sousa
#date            :2016.11.1
#version         :0.1
#usage		       :./add_songs.sh
#notes           :this scripts adds the current playing song into a txt
# 						    file, which will be then used by list_file.sh.
#==============================================================================

# ------------------------------------------------------------------------------
# Gradually build reference set list  ------------------------------------------
# ------------------------------------------------------------------------------

track=$(cmus-remote -C "format_print %{title}")
artist=$(cmus-remote -C "format_print %{artist}")
album=$(cmus-remote -C "format_print %{album}")
genre=$(cmus-remote -C "format_print %{genre}")

TITLE=`echo $track | tr -d -c '[:alnum:] '`
BAND=`echo $artist | tr -d -c '[:alnum:] '`
echo $BAND ";" $TITLE >> playlistbuiltup.txt

printf "\033c"
echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo ""
echo "$track"
echo by "$artist"
echo in "$album"
echo is "$genre"
echo ""
cat playlistbuiltup.txt
echo ""
echo "if ready, go ahead and use -->    ./list_file.sh playlistbuiltup.txt #_of_songs_wanted"
echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo ""
