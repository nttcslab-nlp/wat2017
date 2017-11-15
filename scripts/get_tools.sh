#!/bin/sh

CORES=`nproc`
WD=`pwd`

TD=$WD/tools

# KyTea
if [[ ! -e $TD/kytea/src/bin/kytea ]]; then
    git clone https://github.com/neubig/kytea.git $TD/kytea
    
    cd $TD/kytea
    autoreconf -i
    ./configure
    make -j $CORES 
fi

# Moses scripts
if [[ ! -e $TD/moses_scripts/tokenizer.perl ]]; then
    mkdir -p $TD/moses_scripts
    wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/tokenizer/tokenizer.perl -P $TD/moses_scripts
fi
if [[ ! -e $TD/moses_scripts/clean-corpus-n.perl ]]; then
    mkdir -p $TD/moses_scripts
    wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/training/clean-corpus-n.perl -P $TD/moses_scripts
fi
if [[ ! -e $TD/moses_scripts/multi-bleu.perl ]]; then
    mkdir -p $TD/moses_scripts
    wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/generic/multi-bleu.perl -P $TD/moses_scripts
fi
if [[ ! -e $TD/share/nonbreaking_prefixes/nonbreaking_prefix.en ]]; then
    mkdir -p $TD/share/nonbreaking_prefixes
    wget https://raw.githubusercontent.com/moses-smt/mosesdecoder/master/scripts/share/nonbreaking_prefixes/nonbreaking_prefix.en -P $TD/share/nonbreaking_prefixes
fi
chmod +x $TD/moses_scripts/*.perl

# BPE
if [[ ! -e $TD/subword-nmt ]]; then
    git clone https://github.com/rsennrich/subword-nmt.git $TD/subword-nmt
fi    

# NMT codes
pip install cupy chainer bottleneck
if [[ ! -e $TD/mlpnlp-nmt ]]; then
    git clone https://github.com/mlpnlp/mlpnlp-nmt.git $TD/mlpnlp-nmt
fi    


