#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../../data/eurostat/raw
#touch "$folder"/../../data/eurostat/raw/keep.txt


while read -r line; do
  wget -O "$folder"/../../data/eurostat/raw/"$line".tsv.gz "https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&downfile=data%2F$line.tsv.gz"
done <"$folder"/risorse/lista.txt
