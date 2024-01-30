#!/usr/bin/env bash

# Use this script to:
#  - export a secure note
#  - sort it A-Z
#  - update the note with the sorted version
# There isn't a lot of error checking, so be careful
# Note use of gsed (GNU sed) -- which is not the BSD sed that Apple ships with OS/X
#

NOTE_TITLE=${1}
VAULT="set_github_secrets"

if [ -z ${NOTE_TITLE} ]; then
    cat <<-EOT
Note name a is required argument

Usage:

  $0 foo-bar -- sorts the note named "foo-bar" in the vault ${VAULT}

EOT
    exit 1
fi

TMP_FILE_1=$(mktemp)
TMP_FILE_2=$(mktemp)
# op read --out-file ${TMP_FILE_1} --force "op://${VAULT}/${NOTE_TITLE}" > /dev/null
op read --out-file ${TMP_FILE_1} --force "op://${VAULT}/${NOTE_TITLE}/notesPlain" > /dev/null
if [ ! -f ${TMP_FILE_1} ]; then
    echo "There was a fatal problem, the file \"${TMP_FILE_1}\" was not created!"
    exit 1
fi

sort ${TMP_FILE_1} --output ${TMP_FILE_2}

# remove blank lnes -- note: Gnu sed, not Mac OS sed
gsed -i '/^$/d' ${TMP_FILE_2}

printf "\nOriginal note:\n"
cat ${TMP_FILE_1}

printf "\n\nSorted note:\n"
cat ${TMP_FILE_2}
printf "\n"

read -p "Press Y to replace Original with Sorted in ${VAULT}/${NOTE_TITLE} .  Are you sure?  " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # op supports a --dry-run flag
    op item edit ${NOTE_TITLE} --vault ${VAULT} notesPlain="$(cat ${TMP_FILE_2})"
fi