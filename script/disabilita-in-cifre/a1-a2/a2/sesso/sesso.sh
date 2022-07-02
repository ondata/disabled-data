#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing

# cancella eventuali file vuoti
find  "$folder" -maxdepth 1  -iname "*.xls"  -type f -empty -delete

# i primi tre file
find "$folder" -maxdepth 1 -iname '*.xls' >"$folder"/tmp
#find "$folder" -maxdepth 1 -iname '*.xls' | head -n 1 >"$folder"/tmp

#in2csv -f xls -n g1V30927R09OH200000000_st.xls

if [ -f "$folder"/processing/out.jsonl ]; then
  rm "$folder"/processing/out.jsonl
fi

# per ogni file la lista dei fogli
while read line; do
  name="$(basename "$line" .xls)"
  echo "$name"
  in2csv -f xls -n "$line" | grep 'pagin' >"$folder"/tmp-fogli
  # per ogni foglio estrai dati
  while read foglio; do
    echo "$foglio"
    tavola=$(qsv excel -s "$foglio" "$line" | mlr --c2n --implicit-csv-header cut -f 1 then filter 'NR==1')
    pagina=$(qsv excel -s "$foglio" "$line" | mlr --c2n --implicit-csv-header cut -f 1 then filter 'NR==2')
    echo "$tavola"
    echo "$pagina"
    qsv excel -s "$foglio" "$line" | mlr --csv -N clean-whitespace then remove-empty-columns then skip-trivial-records then put 'if(is_empty($1)){$1="anno"}' then filter -S '$1=~"^(anno|[0-9]+)"' | mlr --c2j put '$file="'"$name"'";$tavola="'"$tavola"'";$pagina="'"$pagina"'"' >>"$folder"/processing/out.jsonl
  done <"$folder"/tmp-fogli
done <"$folder"/tmp


mlr --j2c unsparsify "$folder"/processing/out.jsonl>"$folder"/processing/out.csv

mlr -I --csv put '$regione=sub($tavola,"^(.+?)( - )(.+?) ([(].+)$","\3");$regione=sub($regione,"Regione *","");$tavola=sub($tavola,"^(.+?)( - )(.+?) ([(].+)$","\1");$pagina=sub($pagina,"^.+= ","");$pagina=sub($pagina,"\.","")' "$folder"/processing/out.csv

mv "$folder"/processing/out.csv "$folder"/../../../../../data/disabilita-in-cifre/processing/a1-a2/a2-sesso.csv
