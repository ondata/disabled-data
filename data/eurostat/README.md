# Introduzione

Un'altra fonte di **Disabled data** è [Eurostat](https://ec.europa.eu/eurostat/web/main/home), e in particolare questi dataset:

- [hlth_de010](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_de010)
- [hlth_de020](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_de020)
- [hlth_dh010](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dh010)
- [hlth_dh020](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dh020)
- [hlth_dh030](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dh030)
- [hlth_dhc010](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dhc010)
- [hlth_dhc020](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dhc020)
- [hlth_dhc030](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dhc030)
- [hlth_dlm010](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dlm010)
- [hlth_dlm020](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dlm020)
- [hlth_dlm030](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dlm030)
- [hlth_dlm080](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dlm080)
- [hlth_dlm200](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dlm200)
- [hlth_dm010](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dm010)
- [hlth_dm020](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dm020)
- [hlth_dm040](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dm040)
- [hlth_dpe010](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dpe010)
- [hlth_dpe020](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dpe020)
- [hlth_dpe040](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dpe040)
- [hlth_dsi010](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dsi010)
- [hlth_dsi090](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=hlth_dsi090)

# Dati

Eurostat espone una [sezione di *download* in blocco](https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing) dei suoi dataset, strutturata così come descritto nella [guida](https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=BulkDownload_Guidelines.pdf).

Due i formati nativi: il `TSV` (*tab separated value*) e l'`SDMX` (*Statistical Data and Metadata eXchange*).

Abbiamo fatto uso del primo.

## TSV compressi (copia di quelli Eurostat)

I file `TSV` di Eurostat sono disponibili in formato compresso. Li abbiamo scaricati e resi disponibili nella cartella [`data/eurostat/raw`](raw).

Di base hanno questa struttura (testo da guida ufficiale):

- First line: header.
- Other lines: records with the sequence of values.
- First column — first line: sequence of codes separated by a comma followed by a
code separated by a back slash ‘\’.
The codes separated by a comma ‘,’ are the ‘names’ of the dimensions used for
identifying each (time) series.
For each of these codes there is  a file (with the same name plus  the extension
‘dic’) in the directory dic.
The  code  separated  by  a  back  slash  ‘\’  is  the  ‘name’  of  the  dimension  of  the
sequence of values, e.g. ‘time’ (if this is a time series) or ‘geo’ (in the case of a
geographical series).
- First column except the first line: sequence of codes separated by a comma ‘,’
that  represent  the  ‘names’  of  the  items  (or  instances  or  positions)  of  the
dimensions. The label/title of these codes can be found in the ‘dic’ file that has
the same name of the corresponding dimension.
- Other columns of the first line: sequence of codes corresponding to the items of
the dimension.
- All other columns but the first line: sequence of values.
Where available, flags are attached to values. The separator used between values
and flags is a blank. If there are no flags, the value is followed by a blank.
- The decimal symbol used in the files is the dot ‘.’.


È un `TSV`, in cui la prima colonna è `CSV`. Sotto un esempio:

| unit,hlth_pb,wstatus,sex,time\geo | BE  | BG  | CZ  | DK  | DE  | EE  | IE  | EL  | ES  | FR  | HR  | IT  | CY  | LV  | LT  | LU  | HU  | MT  | NL  | AT  | PL  | PT  | RO  | SI  | SK  | FI  | SE  | IS  | CH  | UK  | TR  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PC,PB1040,EMP,F,2011 | : u | : u | : u | : u | : u | : u | : u | : u | 51.1 u | : u | : u | : u | : u | : u | : u | : u | : u | : u | 15.3 u | : u | : u | : u | : u | : u | : u | : u | : u | : u | : u | 11.6  | 62.0  |
| PC,PB1040,EMP,M,2011 | 36.6 u | : u | : u | : u | : u | : u | : u | : u | 60.7 u | : u | : u | : u | : u | : u | : u | : u | : u | : u | 25.3 u | : u | : u | : u | : u | : u | : u | 30 u | : u | : u | 18.2 u | 15.7  | 63.4  |
| PC,PB1040,EMP,T,2011 | 32.4 u | : u | : u | : u | : u | : u | : u | : u | 55.5  | : u | : u | : u | : u | : u | : u | : u | : u | : u | 20 u | : u | : u | : u | : u | : u | : u | 19.9 u | 10.7 u | 38.4  | 9.6  | 13.3  | 62.9  |
| PC,PB1040,NEMP,F,2011 | : u | : u | 29.2 u | : u | : u | : u | 32.1  | : u | 33.2 u | : u | : u | 33.8  | : u | : u | : u | : u | 64.1 u | : u | 24.4 u | : u | 30 u | : u | 57.3 u | : u | : u | : u | : u | : u | 29.7 u | 37.2  | 64.1  |
| PC,PB1040,NEMP,M,2011 | 28.2 u | : u | 44.9 u | : u | : u | : u | 34.9  | : u | 40.3  | : u | : u | 46.5  | : u | : u | : u | : u | 44.4 u | : u | 39.6 u | : u | 31.5 u | : u | 62.1  | : u | : u | 21.4 u | : u | : u | : u | 33.6  | 57.8  |

In alcune celle ci sono dei flag (qui sopra ad esempio la `u`). Questo il significato:

- `b` = break in time series
- `c` = confidential
- `d` = definition differs, see metadata. The relevant explanations must be provided in the annex of the ESMS (metadata)
- `e` = estimated
- `f` = forecast
- `n` = not significant
- `p` = provisional
- `r` = revised
- `s` = Eurostat estimate
- `u` = low reliability
- `z` = not applicable

## CSV wide

A partire dal formato originale, sono stati derivati dei CSV:

- la prima colonna è stata esplosa nelle colonne da cui è costituita;
- sono stati rimossi gli spazi bianchi ridondanti (i nomi colonna ad esempio hanno uno spazio a fine cella, e `BE·` è stato trasformato in `BE`);
- il codice separato da `\`, che definisce le dimensioni delle sequenze di valori, è stato ridotto alla sola dimensione che rappresenta la colonna. Sopra ad esempio quindi da `time\geo` a `time`, perché in colonna ci sono le date, mentre la parte geografica e lungo le colonne;
- le celle che in origine hanno all'interno il carattere `:` sono quelle per cui "_no data available_". Sono state trasformate in null.

| unit | hlth_pb | wstatus | sex | time | BE | BG | CZ | DK | DE | EE | IE | EL | ES | FR | HR | IT | CY | LV | LT | LU | HU | MT | NL | AT | PL | PT | RO | SI | SK | FI | SE | IS | CH | UK | TR |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PC | PB1040 | EMP | F | 2011 |  |  |  |  |  |  |  |  | 51.1 u |  |  |  |  |  |  |  |  |  | 15.3 u |  |  |  |  |  |  |  |  |  |  | 11.6 | 62.0 |
| PC | PB1040 | EMP | M | 2011 | 36.6 u |  |  |  |  |  |  |  | 60.7 u |  |  |  |  |  |  |  |  |  | 25.3 u |  |  |  |  |  |  | 30 u |  |  | 18.2 u | 15.7 | 63.4 |
| PC | PB1040 | EMP | T | 2011 | 32.4 u |  |  |  |  |  |  |  | 55.5 |  |  |  |  |  |  |  |  |  | 20 u |  |  |  |  |  |  | 19.9 u | 10.7 u | 38.4 | 9.6 | 13.3 | 62.9 |
| PC | PB1040 | NEMP | F | 2011 |  |  | 29.2 u |  |  |  | 32.1 |  | 33.2 u |  |  | 33.8 |  |  |  |  | 64.1 u |  | 24.4 u |  | 30 u |  | 57.3 u |  |  |  |  |  | 29.7 u | 37.2 | 64.1 |
| PC | PB1040 | NEMP | M | 2011 | 28.2 u |  | 44.9 u |  |  |  | 34.9 |  | 40.3 |  |  | 46.5 |  |  |  |  | 44.4 u |  | 39.6 u |  | 31.5 u |  | 62.1 |  |  | 21.4 u |  |  |  | 33.6 | 57.8 |

Sono disponibili nella cartella [`data/eurostat/raw/wide`](raw/wide/)

## CSV long

È stata creata anche la versione *long* dei file grezzi originari:

- le dimensioni che erano in colonne, sono state riportate in formato *long*, con una colonna che contiene l'etichetta della dimensione (qui sotto `geo`) e une che contiene il valore (la `v`);
- il codice separato da `\`, che definisce le dimensioni delle sequenze di valori, è stato suddiviso in due parti. Qui ad esempio è `time\geo`, diviso in `time` e `geo`, e rispettivamente usati per dare i nomi alle colonne corrispondenti;
- le celle che in origine hanno all'interno il carattere `:` sono quelle per cui "_no data available_". Sono state trasformate in null;
- è stata aggiunta la colonna _flag_, per contenere quelli eventualmente presenti nei valori delle celle;
- sono stati rimossi i _flag_ dai  valori delle celle.

Sotto qualche righe di esempio di `hlth_de010` in versione _long_:

| unit | hlth_pb | wstatus | sex | time | geo | v | flag |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PC | PB1040 | EMP | F | 2011 | ES | 51.1 | u |
| PC | PB1040 | EMP | F | 2011 | NL | 15.3 | u |
| PC | PB1040 | EMP | F | 2011 | UK | 11.6 |  |
| PC | PB1040 | EMP | F | 2011 | TR | 62.0 |  |
| PC | PB1040 | EMP | M | 2011 | BE | 36.6 | u |


Sono disponibili nella cartella [`data/eurostat/raw/long`](raw/long/)
