#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp

nome="DCCV_VIOL_CARAT"

mkdir -p "$folder"/../../../data/istat/"$nome"
mkdir -p "$folder"/../../../data/istat/"$nome"/raw
mkdir -p "$folder"/../../../data/istat/"$nome"/dict

df="78_1112"

# scarica dati
if [ -f "$folder"/../../../data/istat/"$nome"/raw/"$df".csv ]; then
  echo "File $df.csv already exists"
else
  curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "http://sdmx.istat.it/SDMXWS/rest/data/$df" >"$folder"/../../../data/istat/"$nome"/raw/"$df".csv
fi

# rimuovi colonne vuote
mlr --csv remove-empty-columns "$folder"/../../../data/istat/"$nome"/raw/"$df".csv >"$folder"/../../../data/istat/"$nome"/"$df".csv

# scarica schema dati
if [ -f "$folder"/../../../data/istat/"$nome"/raw/"$nome"-schema.xml ]; then
  echo "File already exists"
else
  curl -kL "http://sdmx.istat.it/SDMXWS/rest/datastructure/IT1/$nome/" >"$folder"/../../../data/istat/"$nome"/raw/"$nome"-schema.xml
fi

# estrai elenco dimensioni
<"$folder"/../../../data/istat/"$nome"/raw/"$nome"-schema.xml xq -r '."message:Structure"."message:Structures"."structure:DataStructures"."structure:DataStructure"."structure:DataStructureComponents"."structure:DimensionList"."structure:Dimension"[]' | jq -c '.|{id:."@id",URL:."structure:LocalRepresentation"."structure:Enumeration".Ref."@id"}'>"$folder"/tmp/"$nome"-dimensioni.jsonl

# scarica dizionari istat
while read line; do
  id=$(echo "$line" | jq -r '.id')
  URL=$(echo "$line" | jq -r '.URL')
  if [ -f "$folder"/../../../data/istat/"$nome"/dict/"$id".xml ]; then
    echo "File already exists"
  else
    curl -kL "http://sdmx.istat.it/SDMXWS/rest/codelist/IT1/$URL" >"$folder"/../../../data/istat/"$nome"/dict/"$id".xml
  fi
  <"$folder"/../../../data/istat/"$nome"/dict/"$id".xml xq -c '."message:Structure"."message:Structures"."structure:Codelists"."structure:Codelist"."structure:Code"[]'  | mlr --json unsparsify then reshape -r ":" -o i,v then cut -x -f "@urn" then put -S '$id=regextract($i,"[0-9]+");$k=sub($i,"^.+:","")' then cut -x -f i then reshape -s k,v then cut -x -f id then reshape -s lang,"#text" then label key then reorder -f key,en,it then unsparsify then filter -S -x '$it==""'>"$folder"/../../../data/istat/"$nome"/dict/"$id".jsonl
done <"$folder"/tmp/"$nome"-dimensioni.jsonl
