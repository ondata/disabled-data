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

  # estrai long
  mlr --t2c -N --prepipe-gunzip nest --explode --values --across-fields -f 1 --nested-fs "," "$line" | \
  mlr --csv reshape -r '^.+ $' -o i,v then filter -S '$v!=~":"' then clean-whitespace >"$folder"/../../data/eurostat/raw/long/"$name".csv
done
