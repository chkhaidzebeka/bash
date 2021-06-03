#!/bin/bash

curl -A 'GoogleBot' -s "https://vjs.zencdn.net/7.11.4/video-js.css" \
  | grep ',$\| {$/' \
  | sed 's/, /\n/g' \
  | sed 's/^. //g' \
  | sed 's/,$//g'


exit 0
