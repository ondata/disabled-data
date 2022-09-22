#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../data/eurostat/dict
mkdir -p "$folder"/../../data/eurostat/raw
mkdir -p "$folder"/../../data/eurostat/raw/wide
mkdir -p "$folder"/../../data/eurostat/raw/long

if [ -f "$folder"/tmp.txt ]; then
  rm "$folder"/tmp.txt
fi

find "$folder"/../../data/eurostat/raw/long -maxdepth 1 -iname "*.csv" | while read line; do
  head <"$line" -n 1 >>"$folder"/tmp.txt
done

tr <"$folder"/tmp.txt "," "\n" | sort | uniq | grep -vPi "^(sex|v|flag)$" >"$folder"/../../data/eurostat/dict.txt

baseDowloadURL="https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=dic%2Fen%2F"

cat "$folder"/../../data/eurostat/dict.txt | while read line; do
  echo "$line"
  cd "$folder"/../../data/eurostat/dict
  wget --output-document "$line.dic" "$baseDowloadURL$line.dic"
  echo "$baseDowloadURL$line.dic"
done

cd "$folder"
