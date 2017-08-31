#!/bin/bash
#PBS -l walltime=04:00:00
#PBS -lselect=1:ncpus=1:mem=70gb

module load intel-suite

echo "Indexing begun at..."
date


FILE1=Constant_Call50_fltrd.ld.gz
FILE2=Constant_Reads50_fltrd.ld.gz
FILE3=Constant_Call20_fltrd.ld.gz
FILE4=Constant_Reads20_fltrd.ld.gz
FILE5=Constant_Call10_fltrd.ld.gz
FILE6=Constant_Reads10_fltrd.ld.gz
FILE7=Constant_Call5_fltrd.ld.gz
FILE8=Constant_Reads5_fltrd.ld.gz
FILE9=Constant_Call2_fltrd.ld.gz
FILE10=Constant_Reads2_fltrd.ld.gz


cp $WORK/Constant/$FILE1 FullIndex.$PBS_ARRAY_INDEX.0.gz

PREV_STEP=0
STEP=1
for file in $FILE2 $FILE3 $FILE4 $FILE5 $FILE6 $FILE7 $FILE8 $FILE9 $FILE10
do

echo "Cross referencing with" $file
awk 'NR==FNR{a[$1,$2]=$7;next} ($1,$2) in a{print $1,$2,$3,a[$1,$2]}' <(gzip -dc FullIndex.$PBS_ARRAY_INDEX.$PREV_STEP.gz) <(gzip -dc $WORK/Constant/$file) | gzip > FullIndex.$PBS_ARRAY_INDEX.$STEP.gz    
TEMP_LEN=`zcat FullIndex.$PBS_ARRAY_INDEX.$STEP.gz | wc -l`
rm FullIndex.$PBS_ARRAY_INDEX.$PREV_STEP.gz
echo "New length:" $TEMP_LEN
PREV_STEP=$((PREV_STEP+1))
STEP=$((STEP+1))
done

echo "Reference file created"
LEN3=`zcat FullIndex.$PBS_ARRAY_INDEX.$PREV_STEP.gz | wc -l`
echo "Final number of sites:" $LEN3

if [ $PBS_ARRAY_INDEX = 1 ]; then
INDEX_FILE=$WORK/Constant/$FILE1
elif [ $PBS_ARRAY_INDEX = 2 ]; then
INDEX_FILE=$WORK/Constant/$FILE2
elif [ $PBS_ARRAY_INDEX = 3 ]; then
INDEX_FILE=$WORK/Constant/$FILE3
elif [ $PBS_ARRAY_INDEX = 4 ]; then
INDEX_FILE=$WORK/Constant/$FILE4
elif [ $PBS_ARRAY_INDEX = 5 ]; then
INDEX_FILE=$WORK/Constant/$FILE5
elif [ $PBS_ARRAY_INDEX = 6 ]; then
INDEX_FILE=$WORK/Constant/$FILE6
elif [ $PBS_ARRAY_INDEX = 7 ]; then
INDEX_FILE=$WORK/Constant/$FILE7
elif [ $PBS_ARRAY_INDEX = 8 ]; then
INDEX_FILE=$WORK/Constant/$FILE8
elif [ $PBS_ARRAY_INDEX = 9 ]; then
INDEX_FILE=$WORK/Constant/$FILE9
elif [ $PBS_ARRAY_INDEX = 10 ]; then
INDEX_FILE=$WORK/Constant/$FILE10
fi

echo "Indexing data file: " $INDEX_FILE
awk 'NR==FNR{a[$1,$2]=$7;next} ($1,$2) in a{print $1,$2,$3,$4,a[$1,$2]}' <(gzip -dc FullIndex.$PBS_ARRAY_INDEX.$PREV_STEP.gz ) <(gzip -dc $INDEX_FILE) > Idx.$PBS_ARRAY_INDEX
LEN3=`cat Idx.$PBS_ARRAY_INDEX | wc -l`
echo "Length of new data file" $LEN3

mv Idx.$PBS_ARRAY_INDEX $WORK/Constant
#~ echo "Adding column for standard bias calculation"
#~ awk 'NR>0{printf("%s %6.6f\n", $0, ($5-$4)/$4)}' Idx.$PBS_ARRAY_INDEX > Calc1.$PBS_ARRAY_INDEX
#~ rm Idx.$PBS_ARRAY_INDEX

#~ echo "Adding column for root mean square deviation calculation"
#~ awk 'NR>0{printf("%s %7.6f\n", $0, ($5-$4)^2)}' Calc1.$PBS_ARRAY_INDEX > $INDEX_FILE.idx
#~ LEN4=`cat $INDEX_FILE.idx | wc -l`
#~ LEN5=`zcat $INDEX_FILE.idx | wc -l`
#~ echo "Length of final file:" $LEN4
#~ rm Calc1.$PBS_ARRAY_INDEX

#~ echo "Full processing completed"

#~ SB=$(awk '{s+=$6}END{print s}' $INDEX_FILE.idx)
#~ SUM_RMSD=$(awk '{s+=$7}END{print s}' $INDEX_FILE.idx)
#~ RMSD=$(echo "scale=6;sqrt($SUM_RMSD/$LEN4)" | bc)

#~ echo "Standard Bias:" $SB
#~ echo "The sum of RMSD before scaled:" $SUM_RMSD
#~ echo "Len of final is" $LEN4
#~ echo "Zcat len:" $LEN5
#~ echo "Root Mean Square Deviation" $RMSD
