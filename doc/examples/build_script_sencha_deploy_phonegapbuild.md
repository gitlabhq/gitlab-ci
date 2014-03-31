script-build-sencha-deploy-phonegapbuild
=================================

Build an app with Sencha Cmd and deploy to PhoneGap Build.

This is a build script originally written for Gitlab CI but should be fine for whatever CI server you're using.

The script does the following:

- compile the app with sencha cmd ("app build package")
- push the "build" subdirectory to PhoneGap Build using REST APIs

If you just need the first or second part you can comment out in the script the section you don't need, it should be pretty straightforward.

HOWTO
-----

- (one-time) configure the script editing it and filling in the "### Config ###' section
- chdir to your sencha app root
- execute the script

Dependancies
------------

- JSON.sh from https://github.com/dominictarr/JSON.sh
- XMLLint from http://xmlsoft.org/xmllint.html (or libxml2-utils on Debian-based distros)

License
-------

This script is licensed under MIT Expat, i.e. you can do anything including commercial purposes, just don't blame it on me if anything goes wrong! :)

Bash
--------

```bash
#!/bin/bash

# 8p8@Mobimentum 2013-09-04 Build a Sencha app and publish repo to user PhoneGapBuild

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

### Config ###

# PhoneGap Build basic auth (include ":" at the end with no password)
PGB_AUTH_USER="youruser@yourdomain.com:"

# PhoneGap Build auth token 
PGB_AUTH_TOKEN=""

# JSON.sh, cfr. https://github.com/dominictarr/JSON.sh
JSON_SH="$(dirname $0)/JSON.sh"

# XMLLint is in package libxml2-utils (Debian)
XMLLINT="$(which xmllint)"

# Sencha CMD
SENCHA_CMD="/opt/sencha-cmd"

### Script ###

# Compile
$SENCHA_CMD app build package
status=$?

# Add config.xml and zip content
app=$(grep -P '^\s*app.name=' .sencha/app/sencha.cfg | awk -F'=' '{print $2}')
cp config.xml "build/package/$app/"
cd "build/package/$app"
zip -r "${app}.zip" *

# Check if app is already uploaded to PG:B
# cfr. https://build.phonegap.com/docs/read_api
app_pkg="$($XMLLINT --xpath "/*[local-name()='widget']/@id" config.xml | sed 's/\(^ id=\"\|\"$\)//g')"
app_id=$(curl -u "$PGB_AUTH_USER" "https://build.phonegap.com/api/v1/apps?auth_token=$PGB_AUTH_TOKEN" \
	| $JSON_SH -b | grep -E '\["apps",([0-9]+),"(package|id)"\]' \
	| grep -A 1 "$app_pkg" | tail -n 1 | awk -F'\t' '{print $2}')

# Upload app
# cfr. https://build.phonegap.com/docs/write_api
if [[ ! -z "$app_id" ]]
then
	# App already uploaded
	curl -u "$PGB_AUTH_USER" -X PUT -F "file=@${app}.zip" \
		"https://build.phonegap.com/api/v1/apps/$app_id?auth_token=$PGB_AUTH_TOKEN"
else
	# New app
	# Upload to PG:B
	curl -u "$PGB_AUTH_USER" -F "file=@${app}.zip" -F "data={\"title\":\"$app\",\"create_method\":\"file\"}" \
		"https://build.phonegap.com/api/v1/apps?auth_token=$PGB_AUTH_TOKEN"
fi

# TODO: improve status detection
exit $status
```

JSON
--------

```bash
#!/usr/bin/env bash

throw () {
  echo "$*" >&2
  exit 1
}

BRIEF=0
LEAFONLY=0
PRUNE=0

usage() {
  echo
  echo "Usage: JSON.sh [-b] [-l] [-p] [-h]"
  echo
  echo "-p - Prune empty. Exclude fields with empty values."
  echo "-l - Leaf only. Only show leaf nodes, which stops data duplication."
  echo "-b - Brief. Combines 'Leaf only' and 'Prune empty' options."
  echo "-h - This help text."
  echo
}

parse_options() {
  set -- "$@"
  local ARGN=$#
  while [ $ARGN -ne 0 ]
  do
    case $1 in
      -h) usage
          exit 0
      ;;
      -b) BRIEF=1
          LEAFONLY=1
          PRUNE=1
      ;;
      -l) LEAFONLY=1
      ;;
      -p) PRUNE=1
      ;;
      ?*) echo "ERROR: Unknown option."
          usage
          exit 0
      ;;
    esac
    shift 1
    ARGN=$((ARGN-1))
  done
}

awk_egrep () {
  local pattern_string=$1

  gawk '{
    while ($0) {
      start=match($0, pattern);
      token=substr($0, start, RLENGTH);
      print token;
      $0=substr($0, start+RLENGTH);
    }
  }' pattern=$pattern_string
}

tokenize () {
  local GREP
  local ESCAPE
  local CHAR

  if echo "test string" | egrep -ao --color=never "test" &>/dev/null
  then
    GREP='egrep -ao --color=never'
  else
    GREP='egrep -ao'
  fi

  if echo "test string" | egrep -o "test" &>/dev/null
  then
    ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\]'
  else
    GREP=awk_egrep
    ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\\\]'
  fi

  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD='null|false|true'
  local SPACE='[[:space:]]+'

  $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
}

parse_array () {
  local index=0
  local ary=''
  read -r token
  case "$token" in
    ']') ;;
    *)
      while :
      do
        parse_value "$1" "$index"
        index=$((index+1))
        ary="$ary""$value" 
        read -r token
        case "$token" in
          ']') break ;;
          ',') ary="$ary," ;;
          *) throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=`printf '[%s]' "$ary"` || value=
  :
}

parse_object () {
  local key
  local obj=''
  read -r token
  case "$token" in
    '}') ;;
    *)
      while :
      do
        case "$token" in
          '"'*'"') key=$token ;;
          *) throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac
        read -r token
        case "$token" in
          ':') ;;
          *) throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac
        read -r token
        parse_value "$1" "$key"
        obj="$obj$key:$value"        
        read -r token
        case "$token" in
          '}') break ;;
          ',') obj="$obj," ;;
          *) throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
    ;;
  esac
  [ "$BRIEF" -eq 0 ] && value=`printf '{%s}' "$obj"` || value=
  :
}

parse_value () {
  local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0
  case "$token" in
    '{') parse_object "$jpath" ;;
    '[') parse_array  "$jpath" ;;
    # At this point, the only valid single-character tokens are digits.
    ''|[!0-9]) throw "EXPECTED value GOT ${token:-EOF}" ;;
    *) value=$token
       isleaf=1
       [ "$value" = '""' ] && isempty=1
       ;;
  esac
  [ "$value" = '' ] && return
  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 1 ] && [ "$isempty" -eq 0 ] && print=1
  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && \
    [ $PRUNE -eq 1 ] && [ $isempty -eq 0 ] && print=1
  [ "$print" -eq 1 ] && printf "[%s]\t%s\n" "$jpath" "$value"
  :
}

parse () {
  read -r token
  parse_value
  read -r token
  case "$token" in
    '') ;;
    *) throw "EXPECTED EOF GOT $token" ;;
  esac
}

parse_options "$@"

if ([ "$0" = "$BASH_SOURCE" ] || ! [ -n "$BASH_SOURCE" ]);
then
  tokenize | parse
fi
```
