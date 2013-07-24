#!/bin/bash

# Snow Leopard Login Script MK I
# 
# Customize this script to the particular image.  Using OD groups to set simlinks may cause oddities depending on image version and group policy..

echo "login hook started for user $1"

# set path to the utilities used - might be unnecessary
# export PATH=/usr/local/bin:$PATH

# declare variables
user="$1"
work=/Volumes/Student_Work/$user
acro1=/tmp/$user/Acrobat/9.0_x86
acro2=/tmp/$user/Acrobat/9.0_ppc
caches=/tmp/$user/Caches
temp=/tmp/$user/test

# make student work folder and fix perms
chmod 777 /Volumes/Student_Work
if [ -d $work ];
then
    chown -R $user $work
    chmod 700 $work
else
    mkdir $work
    chown -R $user $work
    chmod 700 $work
fi
sleep 2
logger login: sleep 1 done

# serialize adobe products
if [ -f /usr/local/bin/aecs6_serial/AdobeSerialization ];
then
  /usr/local/bin/aecs6_serial/AdobeSerialization --tool=VolumeSerialize
  /usr/local/bin/cs6_serial/AdobeSerialization --tool=VolumeSerialize
  rm -r /usr/local/bin/aecs6_serial/
  rm -r /usr/local/bin/cs6_serial/
  logger login: adobe serialization complete
else
  logger login: no adobe serialization found
fi

# these users don't need simlinks
[[ $user == mfa ]] && exit 0
[[ $user == ce ]] && exit 0
[[ $user == podium ]] && exit 0
[[ $user == cac ]] && exit 0

# make destination dirs
mkdir -p $temp
sleep 2 # to let the network filesystem to catch up
logger login: sleep 2 done
mkdir -p $acro1
mkdir -p $acro2
mkdir -p $caches

# delete old symlinks, make acrobat destination, make new symlinks
su - $user -c "rm -r ~/Library/Application\ Support/Adobe/Acrobat/9.0_ppc; rm -r ~/Library/Application\ Support/Adobe/Acrobat/9.0_x86; rm -r ~/Library/Caches; mkdir -p ~/Library/Application\ Support/Adobe/Acrobat; ln -s $acro1 ~/Library/Application\ Support/Adobe/Acrobat/9.0_x86; ln -s $acro2 ~/Library/Application\ Support/Adobe/Acrobat/9.0_ppc; ln -s $caches ~/Library/Caches"
sleep 2
logger login: sleep 3 done

# set perms for simlinks
chown -R $user $acro1
chown -R $user $acro2
chown -R $user $caches
sleep 2
logger login: sleep 4 done
chmod 700 $acro1
chmod 700 $acro2
chmod 700 $caches

echo "ucs about to be removed"
# remove any .uc files from user's home drive
su - $user -c "rm -r ~/.uc*"
logger login: ucs removed

logger login: login hook has completed for $user

# questions:
# will an error on any of these commands cause the script to exit?
# are there any break points or exit conditions that should be added?
# are there specific printer related dirs that need perms rep to recover from a perms repair?
# set perms on Users/Shared for alexandria?
# if home directory file share is crawling i think the caches folder won't get mapped, any way to check for consistency?
