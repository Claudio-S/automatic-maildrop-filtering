#!/bin/bash

STRUCTURE_FILE=$HOME/mailfilter/folder_structure

if [ $# -lt 1 ]
then
   echo "no Maildir given!"
   exit 1
fi

MAILDIR=$1

if [ ! -r "$STRUCTURE_FILE" ]
then
	echo "File $STRUCTURE_FILE not found or not readable!"
	exit 1
fi

while read folder
do
   test -d "$MAILDIR/$folder" || maildirmake "$MAILDIR/$folder"
done < "$STRUCTURE_FILE"

exit 0
