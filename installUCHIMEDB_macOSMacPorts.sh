if test -z $PREFIX; then
PREFIX=/usr/local || exit $?
fi
# dowload
aria2c -c https://github.com/astanabe/ClaidentDB/releases/download/v0.9.YYYY.MM.DD/downloadUCHIMEDB-0.9.YYYY.MM.DD.sh || exit $?
sh downloadUCHIMEDB-0.9.YYYY.MM.DD.sh || exit $?
# check and install UCHIME databases
if ! test -e .cdu; then
gsha256sum -c uchimedb-0.9.YYYY.MM.DD.tar.xz.sha256 || exit $?
gnutar -xJf uchimedb-0.9.YYYY.MM.DD.tar.xz || exit $?
mkdir -p $PREFIX/share/claident/uchimedb 2> /dev/null || sudo mkdir -p $PREFIX/share/claident/uchimedb || exit $?
for db in cdu12s cdu16s cducox1 cducytb cdudloop cdumatk cdurbcl cdutrnhpsba
do
$PREFIX/share/claident/bin/vsearch --dbmask none --makeudb_usearch $db.fasta --output $db.udb || exit $?
chmod 644 $db.fasta $db.udb || exit $?
mv -f $db.fasta $db.udb $PREFIX/share/claident/uchimedb/ 2> /dev/null || sudo mv -f $db.fasta $db.udb $PREFIX/share/claident/uchimedb/ || exit $?
done
rm -f uchimedb-0.9.YYYY.MM.DD.tar.xz.sha256 || exit $?
rm -f uchimedb-0.9.YYYY.MM.DD.tar.xz || exit $?
echo 'UCHIME databases were installed correctly!'
touch .cdu || exit $?
fi
echo 'You do not need to care about error messages.'
