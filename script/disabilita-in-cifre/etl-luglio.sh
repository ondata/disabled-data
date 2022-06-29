#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../data
mkdir -p "$folder"/tmp

output="$folder/../../data/disabilita-in-cifre/processing"

if [ -f "$folder"/tmp/file.csv ]; then
  rm "$folder"/tmp/file.csv
fi

mlr --c2n cut -f file "$folder"/tmp/anagrafica-luglio.csv >"$folder"/tmp/anagrafica-luglio

# a partire dai file xls scaricati con dowload-nazionale.sh

while read line; do
  echo "$line"
  name="$line"
  # estrai il primo foglio
  qsv excel -s 0 "$folder"/../data/"$line".xls |
    # rimuovi colonne e righe vuote e rimuovi caratteri bianchi ridondanti
    mlr -N --csv remove-empty-columns then clean-whitespace then skip-trivial-records >"$folder"/tmp/"$name".csv
  # calcola il numero di colonne per file ogni file estratto
  colonne=$(mlr -N --c2x filter 'NR==1' "$folder"/tmp/"$name".csv | wc -l)
  # crea anagrafica delle colonne per file, in formato miller
  echo 'name='"$name".csv',colonne'="$colonne"'' >>"$folder"/tmp/file.csv
done <"$folder"/tmp/anagrafica-luglio

# converti anagrafica da formato miller a CSV
mlr -I --ocsv cat "$folder"/tmp/file.csv
mv "$folder"/tmp/file.csv "$output"/file.csv

if [ -f "$folder"/tmp/6.jsonl ]; then
  rm "$folder"/tmp/6.jsonl
fi

mlr --c2n filter '$colonne==6' then cut -f name "$output"/file.csv | while read line; do
  name="$(basename "$line" .csv)"
  mlr -N --c2j put '$file="'"$line"'"' "$folder"/tmp/"$line" >>"$folder"/tmp/6.jsonl
done

mlr --j2c cat then put '$file=sub($file,"\..+","")' "$folder"/tmp/6.jsonl >"$folder"/tmp/6.csv

mlrgo --csv filter -x 'is_empty($4)' then put 'if(is_empty($1)){$tipo=$2}' then fill-down -f tipo then put 'if(is_empty($1)){$1="scelta"}' "$folder"/tmp/6.csv >"$folder"/tmp/6.csv.tmp

mlrgo --csv filter '$tipo=~"^Limi"' then filter -x '$1=="Totale"' "$folder"/tmp/6.csv.tmp | tail -n +2 |  mlrgo --csv filter -x '$scelta=="scelta"' then uniq -a then sort -f file  then cut -x -r -f ".+_2$"  then rename -r "^g.+",file >"$output"/6-luglio.csv




# fai pulizia

find "$output"/ -iname "*.jsonl" -delete

# aggiungi dati anagrafici
mlrgo --csv join --ul -j file -f "$output"/6-luglio.csv then unsparsify "$folder"/tmp/anagrafica-luglio.csv >"$output"/tmp.csv
mv "$output"/tmp.csv "$output"/6-luglio.csv
