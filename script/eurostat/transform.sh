#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../data/eurostat/raw
mkdir -p "$folder"/../../data/eurostat/raw/wide
mkdir -p "$folder"/../../data/eurostat/raw/long

# extract data and reshape
find "$folder"/../../data/eurostat/raw -maxdepth 1 -iname "*tsv.gz" -type f -print0 | while IFS= read -r -d '' line; do
  name="$(basename "$line" .tsv.gz)"
  echo "$name"

  # estrai wide
  mlr --t2c -N --prepipe-gunzip nest --explode --values --across-fields -f 1 --nested-fs "," then clean-whitespace "$line" >"$folder"/../../data/eurostat/raw/wide/"$name".csv

  # estrai nome campo con lo slash e le due parti da cui è composto
  campo_raw=$(mlr --csv head then cut -r -f '\' "$folder"/../../data/eurostat/raw/wide/"$name".csv | head -n 1)
  campo=$(echo "$campo_raw" | sed -r 's/\\/,/g')
  campo_left=$(echo "$campo" | cut -d ',' -f 1)
  campo_right=$(echo "$campo" | cut -d ',' -f 2)

  mlr -I --csv rename -r '".+[\].+",'"$campo_left"'' then put -S 'for (k in $*) {$[k] = gsub($[k], ".*:.*", "")}' "$folder"/../../data/eurostat/raw/wide/"$name".csv

  # estrai long
  mlr --t2c -N --prepipe-gunzip nest --explode --values --across-fields -f 1 --nested-fs "," "$line" | \
  mlr --csv reshape -r '^.+ $' -o i,v then filter -S '$v!=~":"' then put -S '$flag=regextract_or_else($v,"[a-z]+","");$v=gsub($v,"[a-z]+","")' then clean-whitespace then rename i,"$campo_right" then rename "$campo_raw","$campo_left" >"$folder"/../../data/eurostat/raw/long/"$name".csv
done
