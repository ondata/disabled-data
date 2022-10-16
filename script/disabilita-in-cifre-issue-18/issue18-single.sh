#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

name="issue-18"
urlBase="https://disabilitaincifre.istat.it"

mkdir -p "$folder/../../data/$name/processing"

output="$folder/../../data/$name/processing"

mkdir -p "$folder"/../data
mkdir -p "$folder"/tmp

# svota cartella tmp
find "$folder"/tmp -iname "*" -type f -delete

find "$folder"/../data -iname "*.*" -type f -delete

# risorsa singola

if [ -f "$folder"/../data/risorse.jsonl ]; then
  rm "$folder"/../data/risorse.jsonl
fi

mlr --c2j filter '!is_empty($url)' "$folder"/risorse/anagrafica.csv | head -n 1000 | while read line; do
  echo "$line"
  # url pagina da scaricare
  URL=$(echo "$line" | jq -r '.url')
  # scarica pagina
  curl -kL "$URL" --compressed | iconv -f iso8859-1 -t UTF-8 >"$folder"/tmp/start.html
  # estrai nome dataset
  nomeDataset=$(scrape <"$folder"/tmp/start.html -e '//span[@class="nomeNodoRadice"]/text()' | awk '{$1=$1;print}')
  # url pagina con file xls
  paginaXLS=$(scrape <"$folder"/tmp/start.html -e '//a[img[contains(@src,"exce")]]/@href' | tr -d " \t\n\r")
  # scarica pagina con file xls
  curl -kL "$urlBase/$paginaXLS" --compressed | iconv -f iso8859-1 -t UTF-8 >"$folder"/tmp/paginaXLS.html
  # estrai url file xls
  fileXLS=$(scrape <"$folder"/tmp/paginaXLS.html -e '//a[img[contains(@src,"exce")]]/@href' | tr -d " \t\n\r")
  fileName=$(basename "$fileXLS")
  # scarica file xls
  cd "$folder"/../data
  if [ ! -f "$fileName" ]; then
    wget -c "$urlBase/$fileXLS"
  fi
  cd "$folder"

  echo '{"file":"'"$fileName"'","nomeDataset":"'"$nomeDataset"'"}' >>"$folder"/../data/risorse.jsonl
done
