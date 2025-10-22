#!/bin/sh
# Set number of processor cores used for computation
export NCPU=`grep -c processor /proc/cpuinfo`
# Set PREFIX
if test -z $PREFIX; then
PREFIX=/usr/local || exit $?
fi
# Set PATH
export PATH=$PREFIX/bin:$PREFIX/share/claident/bin:$PATH
# Cluster sequences
for locus in matK rbcL
do vsearch --fasta_width 0 --notrunclabels --threads $NCPU --minseqlength 100 --wordlength 9 --id 0.9 --qmask none --strand both --cluster_fast uchimedb/$locus\_dereplicated.fasta --centroids references_plants_$locus.fasta
done
for locus in trnH-psbA
do vsearch --fasta_width 0 --notrunclabels --threads $NCPU --minseqlength 100 --wordlength 9 --id 0.7 --qmask none --strand both --cluster_fast uchimedb/$locus\_dereplicated.fasta --centroids references_plants_$locus.fasta
done
for locus in 12S COX1 CytB
do vsearch --fasta_width 0 --notrunclabels --threads $NCPU --minseqlength 100 --wordlength 9 --id 0.6 --qmask none --strand both --cluster_fast uchimedb/$locus\_dereplicated.fasta --centroids references_animals_$locus.fasta
done
for locus in 16S D-loop
do vsearch --fasta_width 0 --notrunclabels --threads $NCPU --minseqlength 100 --wordlength 9 --id 0.5 --qmask none --strand both --cluster_fast uchimedb/$locus\_dereplicated.fasta --centroids references_animals_$locus.fasta
done
# Download SILVA NR99
wget -c https://www.arb-silva.de/fileadmin/silva_databases/release_138.2/Exports/SILVA_138.2_LSURef_NR99_tax_silva.fasta.gz
wget -c https://www.arb-silva.de/fileadmin/silva_databases/release_138.2/Exports/SILVA_138.2_SSURef_NR99_tax_silva.fasta.gz
# GUNZIP
pigz -d SILVA_138.2_LSURef_NR99_tax_silva.fasta.gz
pigz -d SILVA_138.2_SSURef_NR99_tax_silva.fasta.gz
# Extract Eukaryota
clfilterseq --keyword=Eukaryota -n=$NCPU --minlen=100 SILVA_138.2_LSURef_NR99_tax_silva.fasta SILVA_138.2_LSURef_NR99_tax_silva_Eukaryota.fasta
clfilterseq --keyword=Eukaryota -n=$NCPU --minlen=100 SILVA_138.2_SSURef_NR99_tax_silva.fasta SILVA_138.2_SSURef_NR99_tax_silva_Eukaryota.fasta
# Cluster
for locus in LSU SSU
do vsearch --fasta_width 0 --notrunclabels --threads $NCPU --minseqlength 100 --wordlength 9 --id 0.7 --qmask none --strand both --cluster_fast SILVA_138.2_${locus}Ref_NR99_tax_silva_Eukaryota.fasta --centroids references_eukaryota_$locus.fasta
done
# Extract Prokaryota
clfilterseq --keyword="Bacteria|Archaea" -n=$NCPU --minlen=100 SILVA_138.2_SSURef_NR99_tax_silva.fasta SILVA_138.2_16SRef_NR99_tax_silva_Prokaryota.fasta
# Cluster
for locus in 16S
do vsearch --fasta_width 0 --notrunclabels --threads $NCPU --minseqlength 100 --wordlength 9 --id 0.7 --qmask none --strand both --cluster_fast SILVA_138.2_${locus}Ref_NR99_tax_silva_Prokaryota.fasta --centroids references_prokaryota_$locus.fasta
done
# Download Full UNITE+INSD dataset for Fungi from https://dx.doi.org/10.15156/BIO/3301227
# Cluster
vsearch --fasta_width 0 --notrunclabels --threads $NCPU --minseqlength 100 --wordlength 9 --id 0.5 --qmask none --strand both --cluster_fast UNITE_public_19.02.2025.fasta.gz --centroids references_fungi_ITS.fasta
