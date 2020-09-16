#!/bin/bash

FILTER_DIR="$HOME/mailfilter"
STRUCTURE_FILE="$FILTER_DIR/folder_structure"

if [ $# -lt 2 ]; then
  echo "no new directory or maildir given!"
  exit 1
fi

if [ ! -r "$STRUCTURE_FILE" ]; then
  echo "File $STRUCTURE_FILE not found or not readable!"
  exit 1
fi

if ! grep -Eq "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$" <<< "$1"; then
  echo "The email is not well formatted. Please make sure that you hand over a valid email address."
  exit 1
fi

existing_structure=$(cat "$STRUCTURE_FILE")

# parse part before the @ of the mail address and split it at the dots
IFS='@' read -r -a new_structures <<<"$(sed -r 's/(^|\.)(\w)/.\U\2/g' <<<"$1")"
IFS='.' read -r -a new_structures <<<"${new_structures[0]}"
IFS=' '

# reverse the order of the segments to create the folder structure (amazon.shopping -> shopping.amazon)
new_structures_len=${#new_structures[@]}
for ((idx = 0; idx < new_structures_len / 2; idx++)); do
  first_element="${new_structures[idx]}"
  new_structures[idx]="${new_structures[$new_structures_len - idx - 1]}"
  new_structures[$new_structures_len - idx - 1]="$first_element"
done

# create the folder structure
for((i=0;i<"$new_structures_len";i++)); do
  new_folder=""
  for ((j = 0; j <= i; j++)); do
    if [ -n "${new_structures[j]// /}" ]; then
      new_folder="$new_folder.${new_structures[j]}"
    fi
  done
  if [ -n "${new_folder// /}" ]; then
    # append the new folder to the structure file if not already there - will be resorted anyways later
    if ! grep -qi "^$new_folder$" <<< "$existing_structure"; then
      existing_structure="$existing_structure
$new_folder"
    fi
  fi
done

# Load the chosen folder from the existing structure to avoid upper-/lowercase issues
# This is the maildir that maildrop will deliver the mail to!
grep -i "^$new_folder$" <<< "$existing_structure";

# synchronize new structure to the existing cache file
echo "$existing_structure" | sort -f >"$STRUCTURE_FILE"

# Let the folder check script create the new folder structure
"$FILTER_DIR"/scripts/check_folder_structure.sh "$2"
