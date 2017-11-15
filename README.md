# NTT Neural Machine Translation System for WAT 2017
## What is this?
These are scripts for re-building the same neural machine translation system as we submitted at WAT 2017.
Our systems achieved the best performance on ASPEC Ja-En, En-Ja, JIJI Ja-En and En-Ja among the participants w.r.t. BLEU scores.

For more details you can read the following paper:  
"NTT Neural Machine Translation Systems at WAT 2017", Makoto Morishita, Jun Suzuki, Masaaki Nagata, In Proceedings of the 4th Workshop on Asian Translation (WAT).

## How to use
First, you need to specify the path to the corpus (e.g. ASPEC) in `./scripts/preprocess.sh`.
We expect to use the raw (not tokenized) corpus here.
For the ASPEC, we only used the first 2.0M sentences for the submitted system.

Then, you can run the entire process by the following command:
```
$ ./process.sh
```

These scripts will download all the tools needed for the training, preprocess the corpus, train the model and evaluate it.
We expect to use the GPU No.0 to train the model.
If you need to change the GPU number or don't want to use a GPU, you can change it by specifying the GPU number in `./scripts/train_model.sh`
(specify `-1` for not using a GPU)

You can check the BLEU score by following command:
```
./tools/moses_scripts/multi-bleu.perl ./preproc/tok/test.ja < models/test.beam20
```
It should be around 40.00 if you trained the model correctly.

## Not included features
* Model ensembles
* Synthetic corpus generation

## Contact
Makoto Morishita  
morishita.makoto [] lab.ntt.co.jp
