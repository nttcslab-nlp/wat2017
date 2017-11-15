#!/bin/bash -x

CORES=`nproc`
WD=`pwd`
TD=$WD/tools

SRC=en
TRG=ja

TRAIN_SRC=/path/to/aspec/train.en
TRAIN_TRG=/path/to/aspec/train.ja
DEV_SRC=/path/to/aspec/dev.en
DEV_TRG=/path/to/aspec/dev.ja
TEST_SRC=/path/to/aspec/test.en
TEST_TRG=/path/to/aspec/test.ja

KYTEA_DIR=$TD/kytea
MOSES_DIR=$TD/moses_scripts
BPE_DIR=$TD/subword-nmt

# Raw
mkdir -p $WD/preproc/raw
ln -s $TRAIN_SRC $WD/preproc/raw/train.$SRC
ln -s $TRAIN_TRG $WD/preproc/raw/train.$TRG
ln -s $DEV_SRC $WD/preproc/raw/dev.$SRC
ln -s $DEV_TRG $WD/preproc/raw/dev.$TRG
ln -s $TEST_SRC $WD/preproc/raw/test.$SRC
ln -s $TEST_TRG $WD/preproc/raw/test.$TRG

# Tokenize
mkdir -p $WD/preproc/tok
# English
for FILE in $WD/preproc/raw/{train,dev,test}.$SRC; do
    BASE=`basename $FILE`
    $MOSES_DIR/tokenizer.perl < $FILE > $WD/preproc/tok/$BASE &
done
# Japanese
for FILE in $WD/preproc/raw/{train,dev,test}.$TRG; do
    BASE=`basename $FILE`
    $KYTEA_DIR/src/bin/kytea -model $KYTEA_DIR/data/model.bin -notags < $FILE > $WD/preproc/tok/$BASE &
done

wait

# Cleaning
mkdir -p $WD/preproc/clean
$MOSES_DIR/clean-corpus-n.perl -ratio 9 $WD/preproc/tok/train $SRC $TRG $WD/preproc/clean/train 1 60
ln -s $WD/preproc/tok/dev.$SRC $WD/preproc/clean
ln -s $WD/preproc/tok/dev.$TRG $WD/preproc/clean
ln -s $WD/preproc/tok/test.$SRC $WD/preproc/clean
ln -s $WD/preproc/tok/test.$TRG $WD/preproc/clean

# BPE
mkdir -p $WD/preproc/bpe/vocab
cat $WD/preproc/clean/train.{$SRC,$TRG} | $BPE_DIR/learn_bpe.py -s 16000 >  $WD/preproc/bpe/vocab/codes

for FILE in $WD/preproc/clean/*; do
    BASE=`basename $FILE`
    $BPE_DIR/apply_bpe.py -c $WD/preproc/bpe/vocab/codes < $FILE > $WD/preproc/bpe/$BASE &
done

wait
