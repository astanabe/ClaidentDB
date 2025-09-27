CURDIR=`pwd` || exit $?
NCPU=`grep -c processor /proc/cpuinfo` || exit $?
#install requirements
sudo apt install -y ncbi-blast+ vsearch coreutils tar gzip pigz bzip2 pbzip2 xz-utils unzip wget curl aria2 emboss || exit $?
#install claident
wget -nv -c -O Claident-0.9.2025.05.10.tar.gz https://github.com/astanabe/Claident/archive/refs/tags/v0.9.2025.05.10.tar.gz || exit $?
tar -xzf Claident-0.9.2025.05.10.tar.gz || exit $?
cd Claident-0.9.2025.05.10 || exit $?
export PREFIX=$CURDIR || exit $?
make -j$NCPU || exit $?
make install 2> /dev/null || sudo make install || exit $?
#fetch required files
sh fetchNCBITAXDB.sh || exit $?
sh fetchNCBIBLASTDB.sh || exit $?
#make BLAST DBs and Taxonomy DBs
sh make_overall_class.sh || exit $?
sh make_animals_mt_genus.sh &
sh make_eukaryota_LSU_genus.sh &
sh make_fungi_all_genus.sh &
sh make_plants_cp_genus.sh &
sh make_prokaryota_16S_genus.sh &
wait
sh make_animals_12S_genus.sh &
sh make_eukaryota_SSU_genus.sh &
sh make_fungi_ITS_genus.sh &
sh make_plants_matK_genus.sh &
wait
sh make_animals_16S_genus.sh &
sh make_animals_COX1_genus.sh &
sh make_animals_CytB_genus.sh &
sh make_animals_D-loop_genus.sh &
sh make_plants_rbcL_genus.sh &
sh make_plants_trnH-psbA_genus.sh &
wait
#make UCHIME DBs
sh uchimedb_mitochondrion.sh &
sh uchimedb_plastid.sh &
wait
#make archive files
sh compressBLASTDB.sh
sh compressTAXDB.sh
sh compressUCHIMEDB.sh
cd ..
