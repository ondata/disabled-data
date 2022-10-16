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

mkdir -p "$folder"/../data/csv
mkdir -p "$folder"/tmp

# a partire da tutti gli xls scaricati
find "$folder"/../data -maxdepth 1 -iname "*.xls" -type f | head -n 300 | while read line; do
  echo "$line"
  # estrai nome file
  fileName=$(basename "$line" .xls)
  # leggi i metadati sui fogli xls, per capire se sono a pagina singola o a più pagine
  qsv excel --metadata "$line" >"$folder"/tmp/"$fileName"_metadata.csv

  # se contengono il foglio "Tavola" sono a pagina singola
  if grep -q ',Tavola,' "$folder"/tmp/"$fileName"_metadata.csv; then
    echo "$line"
    if [ -f "$folder"/tmp/"$fileName".jsonl ]; then
      rm "$folder"/tmp/"$fileName".jsonl
    fi
    # estrai elenco nomi fogli (in questo caso è solo 1, "Tavola")
    mlr --c2n cut -f sheet_name "$folder"/tmp/"$fileName"_metadata.csv | grep -P 'Tavola' | while read foglio; do
      echo "$foglio"
      # converti XLS in CSV e poi in JSONL
      qsv excel -s "$foglio" "$line" | mlr --csv -N remove-empty-columns then clean-whitespace then skip-trivial-records then filter '!is_empty($4)' | sed -r 's@(\./)@ @g' | mlrgo --icsv --ojsonl --ragged label anno then put '$file="'"$fileName"'";$foglio="'"$foglio"'"' >>"$folder"/tmp/"$fileName".jsonl
    done
  else
    # se invece non contengono il foglio "Tavola" sono a più pagine
    echo "$line"
    if [ -f "$folder"/tmp/"$fileName".jsonl ]; then
      rm "$folder"/tmp/"$fileName".jsonl
    fi
    # estrai elenco nomi fogli (in questo caso sono più di 1)
    mlr --c2n cut -f sheet_name "$folder"/tmp/"$fileName"_metadata.csv | grep -P 'pagina' | while read foglio; do
      echo "$foglio"
      # estra la descrizione del foglio, che poi verrà suddivisa su più campi
      info=$(qsv excel -s "$foglio" "$line" | mlr --c2n -N filter -S '$1=~"Pagina"' then clean-whitespace)
      qsv excel -s "$foglio" "$line" | mlr --csv -N remove-empty-columns then clean-whitespace then skip-trivial-records then filter '!is_empty($4)' | sed -r 's@(\./)@ @g' | mlrgo --icsv --ojsonl --ragged label anno then put '$file="'"$fileName"'";$foglio="'"$foglio"'";$info="'"$info"'"' then clean-whitespace >>"$folder"/tmp/"$fileName".jsonl
    done
  fi
done


# a partire da tutti i file jsonl estratti
find "$folder"/tmp -maxdepth 1 -iname "*.jsonl" -type f | while read line; do
  echo "$line"
  fileName=$(basename "$line" .jsonl)
  # se c'è la colonna che contiene le info del foglio, suddividila in più campi
  if grep -q '"info"' "$line"; then
    mlrgo --j2c unsparsify then put '$info=sub($info,"^Pag.+va a: *","");$uno=gsub((regextract($info,"^.+?\.")),"\.","");$due=gsub((regextract($info,"\..+$")),"\.","")' then clean-whitespace then nest --explode --pairs --across-fields -f uno --nested-ps " = " then nest --explode --pairs --across-fields -f due --nested-ps " = " then cut -x -f info then sort -t foglio "$line"  >"$folder"/../../data/"$name"/processing/"$fileName".csv
  else
    mlrgo --j2c unsparsify then clean-whitespace "$line" >"$folder"/../../data/"$name"/processing/"$fileName".csv
  fi
done
