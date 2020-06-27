#!/bin/bash

# Copyright 2016  Johns Hopkins University (author: Daniel Povey)

# Apache 2.0

# This script does the standard 2-way speed perturbing of
# a data directory (it operates on the wav.scp).

. utils/parse_options.sh

if [ $# != 3 ]; then
  echo "Usage: perturb_data_dir_speed_2way.sh <srcdir> <destdir>"
  echo "Applies standard 2-way speed perturbation using factors of 0.9 and 1.1."
  echo "e.g.:"
  echo " $0 data/train data/train_sp"
  echo "Note: if <destdir>/feats.scp already exists, this will refuse to run."
  exit 1
fi

srcdir=$1
destdir=$2
outdir=$3
if [ ! -f $srcdir/wav.scp ]; then
  echo "$0: expected $srcdir/wav.scp to exist"
  exit 1
fi
if [ -f $destdir/feats.scp ]; then
  echo "$0: $destdir/feats.scp already exists: refusing to run this (please delete $destdir/feats.scp if you want this to run)"
  exit 1
fi

echo "$0: making sure the utt2dur file is present in ${srcdir}, because "
echo "... obtaining it after speed-perturbing would be very slow, and"
echo "... you might need it."
utils/data/get_utt2dur.sh ${srcdir}

utils/perturb_data_dir_speed_zy.sh 0.9 ${srcdir} ${destdir}0.9 ${outdir} || exit 1
utils/perturb_data_dir_speed_zy.sh 1.1 ${srcdir} ${destdir}1.1 ${outdir} || exit 1
utils/combine_data.sh $destdir ${destdir}0.9 ${destdir}1.1 || exit 1

rm -r ${destdir}0.9 ${destdir}1.1

echo "$0: generated 2-way speed-perturbed version of data in $srcdir, in $destdir"
#utils/validate_data_dir.sh --no-feats $destdir

