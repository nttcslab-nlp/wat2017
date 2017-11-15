#!/bin/bash -x

CORES=`nproc`
WD=`pwd`
TD=$WD/tools

SRC=en
TRG=ja

TRAIN_SRC=$WD/preproc/bpe/train.$SRC
TRAIN_TRG=$WD/preproc/bpe/train.$TRG
DEV_SRC=$WD/preproc/bpe/dev.$SRC
DEV_TRG=$WD/preproc/bpe/dev.$TRG
TEST_SRC=$WD/preproc/bpe/test.$SRC
TEST_TRG=$WD/preproc/tok/test.$TRG  # This should not be sub-words

NMT_DIR=$TD/mlpnlp-nmt
MODEL_DIR=./models

GPU=0

mkdir ./data
python $NMT_DIR/count_freq.py 0 < $TRAIN_SRC | head -n 16000 > $WD/data/src.vocab
python $NMT_DIR/count_freq.py 0 < $TRAIN_TRG | head -n 16000 > $WD/data/trg.vocab

date
mkdir $MODEL_DIR
python3 -u $NMT_DIR/LSTMEncDecAttn.py \
			       --verbose 1 \
			       --gpu-enc $GPU \
			       --gpu-dec $GPU \
			       --train-test-mode train \
			       --embed-dim 512 \
			       --hidden-dim 512 \
			       --num-rnn-layers 2 \
			       --epoch 20 \
			       --batch-size 128 \
			       --output $MODEL_DIR/model \
			       --out-each 1 \
			       --enc-vocab-file $WD/data/src.vocab \
			       --dec-vocab-file $WD/data/trg.vocab \
			       --enc-data-file $TRAIN_SRC \
			       --dec-data-file $TRAIN_TRG \
			       --enc-devel-data-file $DEV_SRC \
			       --dec-devel-data-file $DEV_TRG \
			       --lrate 1.0 \
			       --optimizer SGD \
			       --gradient-clipping 5.0 \
			       --dropout-rate 0.3 \
			       --initializer-scale 0.1 \
			       --eval-accuracy 0 \
			       --use-encoder-bos-eos 0 \
			       --merge-encoder-fwbw 0 \
			       --attention-mode 1 \
			       --use-decoder-inputfeed 1 \
			       --lrate-decay-at 13 \
			       --lrate-no-decay-to 13 \
			       --lrate-decay 0.7 \
			       --shuffle-data-mode 1 \
			       --random-seed 12345 \
    | tee  ${MODEL_DIR}/train.log

export PYTHONIOENCODING=utf-8

for i in 1 5 10 20; do
    python3 -u $NMT_DIR/LSTMEncDecAttn.py \
				   --gpu-enc $GPU \
				   --gpu-dec $GPU \
				   --train-test-mode test \
				   --enc-data-file $TEST_SRC \
				   --setting $MODEL_DIR/model.setting \
				   --init-model $MODEL_DIR/model.epoch20 \
				   --max-length 107 \
				   --beam-size $i \
                   --length-normalized \
				   > $MODEL_DIR/test.beam$i
    sed -i -r 's/(@@ )|(@@ ?$)//g' $MODEL_DIR/test.beam$i
    cat $MODEL_DIR/test.beam$i | perl $TD/moses_scripts/multi-bleu.perl $TEST_TRG
done

date
