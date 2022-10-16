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

find "$folder"/../../data/eurostat/raw/long -maxdepth 1 -iname "spr_*.csv" | while read line; do
  head <"$line" -n 1 >>"$folder"/tmp.txt
done

tr <"$folder"/tmp.txt "," "\n" | sort | uniq | grep -vPi "^(sex|v|flag)$" >"$folder"/../../data/eurostat/dict.txt

baseDowloadURL="https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=dic%2Fen%2F"

cat "$folder"/../../data/eurostat/dict.txt | while read line; do
  echo "$line"
  cd "$folder"/../../data/eurostat/dict
  if [ ! -f "$line".dic ]; then
    #wget -O "$line".csv "$baseDowloadURL$line.csv"
    wget --output-document "$line.dic" "$baseDowloadURL$line.dic"
  fi
  echo "$baseDowloadURL$line.dic"
done


cd "$folder"

find "$folder"/../../data/eurostat/dict -maxdepth 1 -iname "*.dic" | while read file; do
  nomefile=$(basename "$file" .dic)
  if [ ! -f "$folder"/../../data/eurostat/dict/"$nomefile".jsonl ]; then
    # rm "$folder"/../../data/eurostat/dict/"$nomefile".jsonl
    cat "$file" | mlr --t2j -N label n,v | while read line; do
      #nome=$(echo "$line" | jq -r ".n")
      #valore=$(echo "$line" | jq -r ".v")
      #echo '{"'"$nome"'":[{"en":"'"$valore"'","it":null}]}' >>"$folder"/../../data/eurostat/dict/"$nomefile".jsonl
      mlrgo --t2j -N label key,en then put '$it=null' "$file" | jq -c '.[]' >"$folder"/../../data/eurostat/dict/"$nomefile".jsonl
    done
  fi
done

exit 0
