

FOLDER="maqao"
MAQAO=/home/sbstndbs/Downloads/maqao.intel64.2.15.0/maqao.intel64
OPTION="lprof"
MPI=""




cd $FOLDER
echo "MAQAO LPROF ..."
$MAQAO $OPTION $MPI ../lbm

echo "MAQAO CQA ...

$MAQAO cqa ../lbm fct-loops=main




