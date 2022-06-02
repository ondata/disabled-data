#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../data
mkdir -p "$folder"/tmp

# svota cartella tmp
find "$folder"/tmp -iname "*" -type f -delete

find "$folder"/../data -iname "*.*" -type f -delete

# scarica pagina elenco anni
curl -kL 'https://disabilitaincifre.istat.it/dawinciMD.jsp?a1=u2i4a94&a2=_-&n=$$$3$$$$$$$&o=&p=0&sp=null&l=0&exp=0' --compressed >"$folder"/tmp/anni.html

# estrai URL delle pagine degli anni della sola sezione "Amministrativa"
scrape <"$folder"/tmp/anni.html -be 'ul:nth-child(1) .nomeNodo a' | xq -c '.html.body.a[]' >"$folder"/tmp/anni-amministrativa.jsonl

# aggiungi etichette
mlr -I --json label href,title,text "$folder"/tmp/anni-amministrativa.jsonl

# per ogni URL estratto sopra, per ogni anno scarica pagina
cat "$folder"/tmp/anni-amministrativa.jsonl | while read -r line; do
  URL=$(echo "$line" | jq -r '.href')
  anno=$(echo "$line" | jq -r '.title')
  echo "https://disabilitaincifre.istat.it/$URL" >>"$folder"/tmp/URL
  # apri pagina anno e scaricala
  curl -kL "https://disabilitaincifre.istat.it/$URL" --compressed >"$folder"/tmp/"$anno".html
  # estrai i link della sezione Nazionale
  scrape <"$folder"/tmp/"$anno".html -be '.last .last:nth-child(1) a' | xq -c '.html.body.a[]' >"$folder"/tmp/"$anno"-amministrativa.jsonl
  mlr -I --json label href,title,text "$folder"/tmp/"$anno"-amministrativa.jsonl

  # scarica pagina delle ultime due sezioni gerarchiche (di solito provinciale e regionale)
  cat "$folder"/tmp/"$anno"-amministrativa.jsonl | tail -n 2 | while read -r line; do
    URL=$(echo "$line" | jq -r '.href')
    territorio=$(echo "$line" | jq -r '.title')
    echo "$territorio"
    echo "https://disabilitaincifre.istat.it/$URL" >>"$folder"/tmp/URL
    curl -kL "https://disabilitaincifre.istat.it/$URL" --compressed >"$folder"/tmp/"$anno"-"$territorio".html
    scrape <"$folder"/tmp/"$anno"-"$territorio".html -be '.linkWhite' | xq -c '.html.body.a' >"$folder"/tmp/"$anno"-"$territorio".jsonl
    mlr -I --json label href,title,text "$folder"/tmp/"$anno"-"$territorio".jsonl
    URLlista=$(jq <"$folder"/tmp/"$anno"-"$territorio".jsonl -r '.href')
    echo "https://disabilitaincifre.istat.it/$URL" >>"$folder"/tmp/URL
    curl -kL "https://disabilitaincifre.istat.it/$URLlista" --compressed >"$folder"/tmp/"$anno"-"$territorio"-lista.html
    scrape <"$folder"/tmp/"$anno"-"$territorio"-lista.html -be '.tabImageTavXl a' | xq -c '.html.body.a[]' >"$folder"/tmp/"$anno"-"$territorio"-lista.jsonl
    mlr -I --json label href,title,text "$folder"/tmp/"$anno"-"$territorio"-lista.jsonl
    cat "$folder"/tmp/"$anno"-"$territorio"-lista.jsonl | tail -n 1 | while read -r line; do
      URL=$(echo "$line" | jq -r '.href')
      echo "https://disabilitaincifre.istat.it/$URL" >>"$folder"/tmp/URL
      curl -kL "https://disabilitaincifre.istat.it/$URL" --compressed | iconv -f ISO-8859-1 -t utf-8 >"$folder"/tmp/"$anno"-"$territorio"-xls.html
      scrape <"$folder"/tmp/"$anno"-"$territorio"-xls.html -be '.hrefDownXL a' | xq -c '.html.body.a|{href:."@href",title:."@title",text:."#text"}' >"$folder"/tmp/"$anno"-"$territorio"-xls.jsonl
      titolo=$(scrape <"$folder"/tmp/"$anno"-"$territorio"-xls.html -be '.titTavDownXL' | xq -r '.html.body.div."#text"')
      jq <"$folder"/tmp/"$anno"-"$territorio"-xls.jsonl -c '.|= .+ {titolo:"'"$titolo"'",anno:"'"$anno"'",territorio:"'"$territorio"'"}' >"$folder"/tmp/tmp.jsonl
      mv "$folder"/tmp/tmp.jsonl "$folder"/tmp/"$anno"-"$territorio"-xls.jsonl
      cat "$folder"/tmp/"$anno"-"$territorio"-xls.jsonl >>"$folder"/tmp/anagrafica.jsonl
      URLdownload=$(jq <"$folder"/tmp/"$anno"-"$territorio"-xls.jsonl -r '.href')
      cd "$folder"/../data
      echo "https://disabilitaincifre.istat.it/$URLdownload" >>"$folder"/tmp/URL
      wget "https://disabilitaincifre.istat.it/$URLdownload"
    done
  done

done

# crea anagrafica file in CSV
mlr --j2c cat then cut -x -f text,title then label file,descrizione then put '$file=gsub($file,"(excel/|\.xls)","");$descrizione=gsub($descrizione,"Tavola: ","")' "$folder"/tmp/anagrafica.jsonl >"$folder"/tmp/anagrafica.csv
