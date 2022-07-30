#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# lista markdown

mlr --nidx put '$1="- [".$1."]"."(https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=".$1.")"' "$folder"/risorse/lista.txt >"$folder"/risorse/lista_ul.md
