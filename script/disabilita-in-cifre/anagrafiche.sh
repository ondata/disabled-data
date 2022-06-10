#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../data
mkdir -p "$folder"/tmp

# crea markdown dei file

 mlrgo --c2m put '$file="[".$file.".xls](rawdata/".$file.".xls?raw=true)"' "$folder"/../../data/disabilita-in-cifre/processing/anagrafica.csv >"$folder"/../../data/disabilita-in-cifre/anagrafica.md
