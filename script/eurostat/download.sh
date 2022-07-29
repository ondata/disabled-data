#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../data/eurostat/raw

# download
while read -r line; do
  wget -O "$folder"/../../data/eurostat/raw/"$line".tsv.gz "https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&downfile=data%2F$line.tsv.gz"
done <"$folder"/risorse/lista.txt

# extract data and reshape
find "$folder"/../../data/eurostat/raw -maxdepth 1 -iname "*tsv.gz" -type f -print0 | while IFS= read -r -d '' line; do
  name="$(basename "$line" .tsv.gz)"
  echo "$name"
  mlr --t2c -N --prepipe-gunzip nest --explode --values --across-fields -f 1 --nested-fs "," "$line" | \
  mlr --csv reshape -r '^.+ $' -o i,v then filter -S '$v!=~":"'>"$folder"/../../data/eurostat/raw/"$name".csv
done
