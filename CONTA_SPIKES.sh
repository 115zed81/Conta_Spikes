#!/bin/bash

#############################################################################################
#                                                                                           #
#                                  CONTA_SPIKES.sh                                          #
#                                         by                                                #
#                                Massimo Rizzi - 2018                                       #
#                                                                                           #
#                                                                                           #
# Questo script determina la distribuzione degli spikes estraendo la colonna <Time of Peak> #
# direttamente dal file di output di Clampfit, rimuovendo i decimali. I tempi nel file      #
# originale sono espressi in millisecondi.                                                  #
#                                                                                           #
# Lo script può essere utilizzato per la distribuzione oraria degli spikes contati da       #
# registrazioni EEG di qualunque durata. La durata minima di un intervallo di tempo può     #
# essere ridotta fino a 1 minuto, anche se di solito si utilizzano le ore. Nello script, i  #
# tempi devono essere espressi in millisecondi.                                             #
#                                                                                           #
# I file di Clampfit da utilizzare vengono messi nella directory DIR_INPUT, mentre i file   #
# elaborati (cioè le distribuzioni) vengono messi nella directory DIR_OUTPUT. I file sono   #
# in formato csv così da poterli aprire già incolonnati con excel per poi portarli su PRISM #
# direttamente con un copia/incolla.                                                        #
#                                                                                           #
# Lo script è impostato per essere eseguito in ambiente Windows utilizzando Cygwin (vedi    #
# README). Per l'utilizzo in ambiente Linux occorre modificare i path delle directory di    #                                                                        
# lavoro.                                                                                   #
#                                                                                           #
#############################################################################################


clear

cd /cygdrive/c/Users/mrizzi/Desktop/DIR_INPUT

find -name "* *" -type f -print0 |   while read -d $'\0' f; do mv -v "$f" "${f// /_}"; done      #toglie gli spazi nei nomi dei files sostituendoli con underscore, pipe trovata su internet

#find -name "* *" -type d -print0 |   while read -d $'\0' f; do mv -v "$f" "${f// /_}"; done     # NON IN USO - toglie gli spazi nei nomi delle directory sostituendoli con underscore, pipe trovata su internet

clear

echo;echo "########### SPACES IN FILE NAMES HAVE BEEN AUTOMATICALLY SUBSTITUTED WITH UNDERSCORES ###########";echo

cd /cygdrive/c/Users/mrizzi/Desktop

echo;echo;echo "FILES FOR SPIKES DISTRIBUTION:";echo

ls -1 DIR_INPUT         #l'opzione -1 (meno uno) forza ls a stampare a video uno sotto l'altro i nomi dei file, altrimenti vengono stampati sulla stessa linea

echo;echo "REMEMBER: to exit program any time press CTRL+c";echo

echo;echo;echo "ENTER TIME INTERVAL FOR SPIKES DISTRIBUTION (min):"

read minutes

let TIME_BIN=${minutes}*60000                     #la variabile TIME_BIN viene utilizzata per contare gli intervalli di distribuzione degli spikes (in millisecondi), 60000 sono i millisecondi in un minuto


ls DIR_INPUT > ls_Clampfit

while read line                            ### CICLO ASSOCIATO ALLA FASE DI PREPARAZIONE DEI FILE DI INPUT DAI FILE DI Clampfit - tutti i file devono essere nella directory DIR_INPUT ###
do


cut -f10 DIR_INPUT/${line}|grep "."|sed 1d|sed -r 's/.{4}$//'> DIR_INPUT/${line:0:${#line}-4}        #l'intera pipe estrae la colonna con i tempi dei picchi direttamente dal file di Clampfit, rimuovendo i decimali


cat DIR_INPUT/${line:0:${#line}-4} > TEST.txt      # il file TEST.txt è il file di lavoro, lasciato il nome usato durante i test



tail -n 1 TEST.txt>tempo_max     

read z<tempo_max            #legge l'ultimo valore per stabilire quanti contatori temporali devono essere inizializzati

rm tempo_max



let counter_max=(${z}/${TIME_BIN})    #calcola il numero di contatori temporali

for((i=1; i<=${counter_max}+1; i++))   #inizializza i contatori temporali a zero
do
let counter_${i}h=0
done


while read value
do


let c=${value}/${TIME_BIN}         #determina a quale intervallo temporale appartiene il valore letto

let ora=${c}+1

echo "file_in_lettura = "${line}"    tempo_del_picco_nel_file = "${value}"    intervallo_di_appartenenza = "${ora}



let counter_${ora}h+=1     #incrementa il contatore specifico in base al valore della variabile {ora}



done<TEST.txt


echo "File:,"${line}>DIR_OUTPUT/${line:0:${#line}-4}_spikes_distribution_every_${minutes}_min.csv        #inizializza il file di output in formato csv, leggibile da excel

echo>>DIR_OUTPUT/${line:0:${#line}-4}_spikes_distribution_every_${minutes}_min.csv

echo "Time interval:,"${minutes}" minutes">>DIR_OUTPUT/${line:0:${#line}-4}_spikes_distribution_every_${minutes}_min.csv

echo "Time,Num_Spikes">>DIR_OUTPUT/${line:0:${#line}-4}_spikes_distribution_every_${minutes}_min.csv                #intestazione colonne sul file csv


for((i=1; i<=${counter_max}+1; i++))        #stampa la distribuzione degli spikes con i tempi nella prima colonna e il numero di spikes nella seconda
do

let eventi=counter_${i}h

echo ${i}","${eventi}>>DIR_OUTPUT/${line:0:${#line}-4}_spikes_distribution_every_${minutes}_min.csv

done



done<ls_Clampfit


rm ls_Clampfit

rm TEST.txt

exit 0
