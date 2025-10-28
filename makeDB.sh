#install requirements
sudo apt install -y ncbi-blast+ vsearch coreutils grep tar gzip pigz bzip2 pbzip2 xz-utils unzip wget curl aria2 emboss jq || exit $?
#save date
export date=`TZ=JST-9 date +%Y.%m.%d`
export dateiso=`TZ=JST-9 date +%Y-%m-%d`
#set number of CPU cores
export NCPU=`grep -c processor /proc/cpuinfo` || exit $?
#configure maximum number of fileopens
ulimit -Sn `ulimit -Hn`
#make UCHIME DBs
sh uchimedb_mitochondrion.sh &
sh uchimedb_plastid.sh &
#fetch required files
sh fetchNCBIBLASTDB.sh &
wait
sh fetchNCBITAXDB.sh &
#dump acc_taxid
sh dumpacctaxid.sh &
#generate references
sh generate_references.sh &
wait
#make BLAST DBs and Taxonomy DBs
sh make_overall_class.sh || exit $?
sh make_animals_mt_genus.sh &
sh make_fungi_all_genus.sh &
sh make_plants_cp_genus.sh &
wait
sh make_animals_12S_genus.sh || exit $?
sh make_animals_16S_genus.sh || exit $?
sh make_animals_COX1_genus.sh || exit $?
sh make_animals_CytB_genus.sh || exit $?
sh make_animals_D-loop_genus.sh || exit $?
sh make_eukaryota_LSU_genus.sh || exit $?
sh make_eukaryota_SSU_genus.sh || exit $?
sh make_fungi_ITS_genus.sh || exit $?
sh make_plants_matK_genus.sh || exit $?
sh make_plants_rbcL_genus.sh || exit $?
sh make_plants_trnH-psbA_genus.sh || exit $?
sh make_prokaryota_16S_genus.sh || exit $?
#make archive files
sh compressBLASTDB.sh || exit $?
sh compressTAXDB.sh || exit $?
sh compressUCHIMEDB.sh || exit $?
#make scripts
for f in `ls uploadDB.sh installDB_*.sh installUCHIMEDB_*.sh | grep -oP '^[^\.]+'`
do perl -npe "s/YYYY\\.MM\\.DD/${date}/g;s/YYYY\\-MM\\-DD/${dateiso}/g" $f.sh > $f-0.9.${date}.sh
done
