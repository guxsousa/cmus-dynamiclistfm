#!/bin/bash

#==============================================================================
#title           :list_file.sh
#description     :This script will generate the playlist by reading a file.
#author          :Gus Sousa
#date            :2016.11.1
#version         :0.1
#usage		 :./list_file.sh playbase.txt n
#notes           :playbase is the file with reference songs, which are
#		  written using the format : 'artist ;songs'.
#		  `n` is the size of the playlist.
#==============================================================================

#set -x
#trap read debug

# ----------------------------------------------------------------------------
# Setup and input variables --------------------------------------------------
# ----------------------------------------------------------------------------

filename="$1"
declare -a myArray
declare -a theSongs
declare -a theArtists
k=1
m=1
> volatile.txt

# APIlastfm="YOURAPIKEYFROMLASTFM"
apifile="API_file"
read -d $'\x04' APIlastfm < "$apifile"
echo $APIlastfm




# ----------------------------------------------------------------------------
# Get cmus library information -----------------------------------------------
# ----------------------------------------------------------------------------

echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo ""

while read -r line
do
    name="$line"
		myArray[k]="$line"
		((k++))
done < "$filename"

for i in "${myArray[@]}"
do
	IFS=';' read -ra NAMES <<< "$i"    #Convert string to array
	theSongs[m]=${NAMES[1]}
	theArtists[m]=${NAMES[0]}
	((m++))
done

size=${#theSongs[@]}

printf "\033c"
echo Making the list with $size songs
echo ""

for (( c=1; c<=$size; c++ ))
do
	 echo ${theSongs[$c]} by ${theArtists[$c]}
done

echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo ""




# ----------------------------------------------------------------------------
# Find similar song in Last.Fm -----------------------------------------------
# ----------------------------------------------------------------------------

USER_AGENT="User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/\
537.36 (KHTML, like Gecko) Chrome/29.0.1535.3 Safari/537.36"

for (( c=1; c<=$size; c++ ))
do
   TITLE=${theSongs[$c]}
   ARTIST=${theArtists[$c]}
   ARTIST_CONVERTED=`echo $ARTIST | tr " " "+"`
   TITLE_CONVERTED=`echo $TITLE | tr " " "+"`

	 URL="http://ws.audioscrobbler.com/2.0/?method=track.getsimilar&artist=$ARTIST_CONVERTED&track=$TITLE_CONVERTED&api_key=$APIlastfm"
   ANSWER=`curl -s $URL \
					 -H 'Accept: text/html' \
					 -H 'Accept: application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
					 -H "$USER_AGENT"`
   echo $ANSWER > tmp.xml;

	 if [ "$?" -ne "0" ]
   then
   	exit 1
   fi

   xml sel -T -t -m lfm/similartracks/track -s D:N:- "@id" -v \
     "concat(@id,'• ',artist/name,' ; ',name)" -n tmp.xml >> tmp.log
done


# ------------------------------------------------------------------------------
# Select and Mine Songs File  --------------------------------------------------
# ------------------------------------------------------------------------------

declare -a mySimilar
declare -a mySimilarSong
declare -a mySimilarArtist
k=1
m=1

# detecet duplicates and remove them
awk '!a[$0]++' tmp.log > tmpdup.log

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
	mySimilarSong[m]=`echo ${NAMES[1]} | \
					sed -e 's/^[ \t]//' | \
					tr -d -c '[:alnum:] '`
	mySimilarArtist[m]=`echo ${NAMES[0]} | \
					sed -e 's/^[\• \t]*//' | \
					sed -e 's/[[:space:]]*$//' | \
					tr -d -c '[:alnum:] '`
	((m++))
done

size=${#mySimilarSong[@]}
size=${#mySimilarArtist[@]}
echo $size




# ----------------------------------------------------------------------------
# Find matches with local library (cmus/lib.pl) ------------------------------
# ----------------------------------------------------------------------------

declare -a myExistingSimilar
limitList="$2"
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
  ((x++))
done




# ----------------------------------------------------------------------------
# Display summary, remove auxiliar files and create playlist -----------------
# ----------------------------------------------------------------------------

cat /dev/null > ~/.cmus/playlist.pl
set -f; IFS=
myExistingSimilar=(${myExistingSimilar[@]})
echo  ${#myExistingSimilar[@]} found, $no not

for i in "${myExistingSimilar[@]}"
do
  echo $i >> volatile.txt
  echo $i >> ~/.cmus/playlist.pl
done

echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo ""

rm tmpdup.log
rm tmp.log
rm tmp.xml
rm volatile.txt
cat /dev/null > playlistprocess.txt
rm playlistprocess.txt

cmus-remote -c ~/.cmus/playlist.pl
