# Set number of processor cores used for computation
export NCPU=`grep -c processor /proc/cpuinfo`
# Get nt database files from NCBI
mkdir -p blastdb || exit $?
cd blastdb || exit $?
aria2c https://ftp.ncbi.nih.gov/blast/db/nt-nucl-metadata.json -o nt-nucl-metadata.before.json || exit $?
aria2c https://ftp.ncbi.nih.gov/blast/db/ -o index.html || exit $?
grep -o -P '"nt.\d+.tar.gz.md5"' index.html | sort -u | perl -npe 's/"//g;s/^/https:\/\/ftp.ncbi.nih.gov\/blast\/db\//' > md5list.txt || exit $?
aria2c -c -i md5list.txt -j 3 -x 1 || exit $?
rm md5list.txt || exit $?
grep -o -P '"nt.\d+.tar.gz"' index.html | sort -u | perl -npe 's/"//g;s/^/https:\/\/ftp.ncbi.nih.gov\/blast\/db\//' > targzlist.txt || exit $?
aria2c -c -i targzlist.txt -j 3 -x 1 || exit $?
rm targzlist.txt || exit $?
rm index.html || exit $?
# Check update during downloading
aria2c https://ftp.ncbi.nih.gov/blast/db/nt-nucl-metadata.json -o nt-nucl-metadata.after.json || exit $?
if test -n "`diff -u nt-nucl-metadata.before.json nt-nucl-metadata.after.json`"; then
if test -n "ls *.tar.gz 2> /dev/null"; then
chmod 644 *.tar.gz 2> /dev/null || sudo chmod 644 *.tar.gz 2> /dev/null
fi
rm -f *.md5 *.tar.gz nt-nucl-metadata.*.json || sudo rm -f *.md5 *.tar.gz nt-nucl-metadata.*.json
echo "NCBI nt has been updated! Please retry download."
exit 1
fi
# Get taxdb files from NCBI
aria2c -c https://ftp.ncbi.nih.gov/blast/db/taxdb.tar.gz.md5 || exit $?
aria2c -c https://ftp.ncbi.nih.gov/blast/db/taxdb.tar.gz || exit $?
# Check files
ls *.md5 | xargs -P $NCPU -I {} sh -c "md5sum -c {} || exit $?"
if test $? -ne 0; then
exit $?
fi
rm *.md5 || exit $?
# Extract files
ls *.tar.gz | xargs -P $NCPU -I {} sh -c "tar -xzf {} || exit $?"
if test $? -ne 0; then
exit $?
fi
# Delete files
chmod 644 *.tar.gz 2> /dev/null || sudo chmod 644 *.tar.gz 2> /dev/null
rm -f *.tar.gz || sudo rm -f *.tar.gz
cd .. || exit $?
