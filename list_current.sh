#!/bin/bash

#==============================================================================
#title           :list_current.sh
#description     :This script will generate the playlist
#                 based on current song.
#author          :Gus Sousa
#date            :2016.11.1
#version         :0.1
#usage		 :./list_current.sh n
#notes           :`n` is the size of the playlist.
#==============================================================================

limitList="$1"

# APIlastfm="YOURAPIKEYFROMLASTFM"
apifile="API_file"
read -d $'\x04' APIlastfm < "$apifile"
echo $APIlastfm


# ----------------------------------------------------------------------------
# Get cmus status information ------------------------------------------------
# ----------------------------------------------------------------------------

track=$(cmus-remote -C "format_print %{title}")
artist=$(cmus-remote -C "format_print %{artist}")
album=$(cmus-remote -C "format_print %{album}")
genre=$(cmus-remote -C "format_print %{genre}")

track=`echo $track | sed "s/([^)]*)//" | tr -d -c '[:alnum:] '`

printf "\033c"
echo "$track"
echo by "$artist"
echo in "$album"
echo is "$genre"
echo ""



# ----------------------------------------------------------------------------
# Find similar song in Last.Fm -----------------------------------------------
# ----------------------------------------------------------------------------

TITLE=${track}
ARTIST=${artist}
ARTIST_CONVERTED=`echo $ARTIST | tr " " "+"`
TITLE_CONVERTED=`echo $TITLE | tr " " "+"`

URL="http://ws.audioscrobbler.com/2.0/?method=track.getsimilar&artist=$ARTIST_CONVERTED&track=$TITLE_CONVERTED&api_key=$APIlastfm"

USER_AGENT="User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/\
537.36 (KHTML, like Gecko) Chrome/29.0.1535.3 Safari/537.36"

ANSWER=`curl -s $URL \
        -H 'Accept: text/html' \
        -H 'Accept: application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
        -H "$USER_AGENT"`
echo $ANSWER > tmpCurrent.xml;

if [ "$?" -ne "0" ]
then
 exit 1
fi

xml sel -T -t -m lfm/similartracks/track -s D:N:- "@id" -v \
  "concat(@id,'• ',artist/name,' ; ',name)" -n tmpCurrent.xml >> tmpCurrent.log




# -----------------------------------------------------------------------------
# Select and Create Songs File  -----------------------------------------------
# -----------------------------------------------------------------------------

declare -a mySimilar
declare -a mySimilarSong
declare -a mySimilarArtist
k=1
m=1

# detecet duplicates and remove them
awk '!a[$0]++' tmpCurrent.log > tmpdup.log


# read log file and convert to array
while read -r line
do
  name="$line"
	mySimilar[k]="$line"
	((k++))
done < tmpdup.log

set -f; IFS=
mySimilar=(${mySimilar[@]})

# re-Order the similar songs
size=${#mySimilar[*]}
max=$(( 10000 / size * size ))
for ((i=size-1; i>0; i--)); do
  while (( (rand=$RANDOM) >= max )); do :; done
  rand=$(( rand % (i+1) ))
  tmp=${mySimilar[i]}
  mySimilar[i]=${mySimilar[rand]}
  mySimilar[rand]=$tmp
done




# ----------------------------------------------------------------------------
# Mine the similar songs -----------------------------------------------------
# ----------------------------------------------------------------------------

for i in "${mySimilar[@]}"
do
	IFS=';' read -ra NAMES <<< "$i"    #Convert string to array
	mySimilarSong[m]=`echo ${NAMES[1]} | sed -e 's/^[ \t]//' | \
        tr -d -c '[:alnum:] '`
	mySimilarArtist[m]=`echo ${NAMES[0]} | sed -e 's/^[\• \t]*//' | \
        sed -e 's/[[:space:]]*$//' | tr -d -c '[:alnum:] '`
	((m++))
done

size=${#mySimilarSong[@]}
size=${#mySimilarArtist[@]}
echo $size songs

declare -a myExistingSimilar
x=1 # size limit of the reference list
y=1 # size limit of the playlist
no=0 # non-existing elements in the iteration
while [ $x -le $size ] && [ $y -le $limitList ]
do
  IFS_BAK=${IFS}
    IFS="
    "
  lblSong=${mySimilarSong[$x]}
  lblArtist=${mySimilarArtist[$x]}
  myarr=( $(grep -ni "$lblSong" ~/.cmus/lib.pl | grep -i "$lblArtist" | \
        grep -Eo '^[^:]+') )
  IFS=${IFS_BAK}

  if [ -z "$myarr" ]; then
      # echo '✗ no match'
      ((no++))
    else
      # echo '✓ found !'
      n=$RANDOM
      sel=$(( n %= ${#myarr[@]} ))
      myExistingSimilar[$y]=`sed "${myarr[$sel]}q;d" < ~/.cmus/lib.pl`
      ((y++))
    fi
  # echo ""
  ((x++))
done




# ----------------------------------------------------------------------------
# Display summary, remove auxiliar files and create playlist -----------------
# ----------------------------------------------------------------------------

set -f; IFS=
myExistingSimilar=(${myExistingSimilar[@]})

if [ ${#myExistingSimilar[@]} -gt $limitList ]; then
    echo "great news !"
		echo ${#myExistingSimilar[@]} found, $no not
else
		echo "but it seems there is not enough music like this in the library..."
		echo only ${#myExistingSimilar[@]} found, $no not
fi

cat /dev/null > ~/.cmus/playlist.pl

for i in "${myExistingSimilar[@]}"
do
   echo $i >> volatileCurrentSong.txt
   echo $i >> ~/.cmus/playlist.pl
done

echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo ""

rm tmpdup.log
rm tmpCurrent.xml
rm tmpCurrent.log
rm volatileCurrentSong.txt

cmus-remote -c ~/.cmus/playlist.pl
