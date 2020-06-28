#!/bin/bash

# Copyright 2020 Zhao Yi
#需要建立路径，存放下载的数据
. ./cmd.sh
. ./path.sh
set -e
cmd=run.pl
#input data
data=data
NOISE_DIR=../kaldi-master/egs/sre16/v2/noise
audio_dir=../speech/aishell/train/
out_data=data/wav/train_aug
tmp_dir=data/train
logdir=log
nj=10
stage=-1

#prepare data
if [ $stage -le 0 ]; then
  echo "$0: preparing data"
  find $audio_dir -iname "*.wav" > $tmp_dir/wav.list
  sed -e 's/\.wav//' $tmp_dir/wav.list | awk -F '/' '{print $NF}' > $tmp_dir/utt.list
  sed -e 's/\.wav//' $tmp_dir/wav.list | awk -F '/' '{i=NF-1;printf("%s %s\n",$NF,$i)}' > $tmp_dir/utt2spk
  paste -d' ' $tmp_dir/utt.list $tmp_dir/wav.list > $tmp_dir/wav.scp
  utils/utt2spk_to_spk2utt.pl $data/train/utt2spk > $data/train/spk2utt
fi

#speed-perturbation
if [ $stage -le 1 ]; then
  echo "$0: preparing directory for speed-perturbed data"
  utils/data/perturb_data_dir_speed_zy.sh $data/train $data/train_speed $out_data/train_speed
fi

# do volume-perturbation 
if [ $stage -le 2 ]; then
  echo "$0: preparing directory for volume-perturbed data"
  utils/data/perturb_data_dir_volume_zy.sh $data/train  $data/train_volume  $out_data/train_volume
  
  awk '{printf("%s_vol %s\n",$1,$NF)}' $data/train/utt2spk  > $data/train_volume/utt2spk
  awk '{printf("%s_vol %s\n",$1,$NF)}' $data/train/utt2dur  > $data/train_volume/utt2dur
  cat $data/train/utt2spk | awk -v p=_vol '{printf("%s %s%s\n", $1, $1, p);}' > $data/train_volume/utt_map
  utils/apply_map.pl -f 1 $data/train_volume/utt_map <$data/train_volume/wav.scp > $data/train_volume/wav.scp_new
  rm $data/train_volume/wav.scp
  mv $data/train_volume/wav.scp_new $data/train_volume/wav.scp
  utils/apply_map.pl -f 1 $data/train_volume/utt_map <$data/train/text > $data/train_volume/text
  utils/utt2spk_to_spk2utt.pl $data/train_volume/utt2spk > $data/train_volume/spk2utt
fi
#RIRS 
if [ $stage -le 3 ]; then
  echo "$0: preparing directory for RIRS-perturbed data"
  #frame_shift=0.01
  #awk -v frame_shift=$frame_shift '{print $1, $2*frame_shift;}' $aug_data/utt2num_frames > $aug_data/reco2dur

  #if [ ! -d "RIRS_NOISES" ]; then
    # Download the package that includes the real RIRs, simulated RIRs, isotropic noises and point-source noises
    #wget --no-check-certificate http://www.openslr.org/resources/28/rirs_noises.zip
    #unzip rirs_noises.zip
  #fi

  # Make a version with reverberated speech
  rvb_opts=()
  rvb_opts+=(--rir-set-parameters "0.5, RIRS_NOISES/simulated_rirs/smallroom/rir_list")
  rvb_opts+=(--rir-set-parameters "0.5, RIRS_NOISES/simulated_rirs/mediumroom/rir_list")

  # Make a reverberated version of the SWBD+SRE list.  Note that we don't add any
  # additive noise here.
  python steps/data/reverberate_data_dir_zy.py \
    "${rvb_opts[@]}" \
    --speech-rvb-probability 1 \
    --pointsource-noise-addition-probability 0 \
    --isotropic-noise-addition-probability 0 \
    --num-replications 1 \
    --source-sampling-rate 16000 \
    --out_dir $out_data/train_reverb \
    $data/train $data/train_reverb
  #cp $aug_data/vad.scp $data/train_reverb/
  utils/copy_data_dir.sh --utt-suffix "-reverb" $data/train_reverb $data/train_reverb.new
  rm -rf $data/train_reverb
  mv $data/train_reverb.new $data/train_reverb
fi
#MUSAN
if [ $stage -le 4 ]; then
  echo "$0: preparing directory for MUSAN-perturbed data"
  # Prepare the MUSAN corpus, which consists of music, speech, and noise
  # suitable for augmentation.
  local/make_musan.sh $NOISE_DIR/musan $data

  # Get the duration of the MUSAN recordings.  This will be used by the
  # script augment_data_dir.py.
  for name in speech noise music; do
    utils/data/get_utt2dur.sh $data/musan_${name}
    mv $data/musan_${name}/utt2dur $data/musan_${name}/reco2dur
  #augment data  
  python steps/data/augment.py --utt-suffix "noise" --fg-interval 1 --fg-snrs "15:10:5:0" --fg-noise-dir "$data/musan_noise" --out_dir  "$out_data/train_noise" $data/train $data/train_noise
  # Augment with musan_music
  python steps/data/augment.py --utt-suffix "music" --bg-snrs "15:10:8:5" --num-bg-noises "1" --bg-noise-dir "$data/musan_music" --out_dir  "$out_data/train_music" $data/train $data/train_music
  # Augment with musan_speech
  python steps/data/augment.py --utt-suffix "babble" --bg-snrs "20:17:15:13" --num-bg-noises "3:4:5:6:7" --bg-noise-dir "$data/musan_speech" --out_dir  "$out_data/train_babble" $data/train $data/train_babble
fi
#combine data
if [ $stage -le 5 ]; then
  echo "$0: combine augment data and random select a subset about twice the origin data"
  # Combine reverb, noise, music, and babble into one directory.
  utils/combine_data.sh $data/train_aug $data/train_reverb $data/train_noise $data/train_music $data/train_babble $data/train_speed $data/train_volume
  utils/subset_data_dir.sh $data/train_aug 240000 $data/train_aug_24k
  utils/fix_data_dir.sh $data/train_aug_24k
fi
  
if [ $stage -le 6 ]; then
  echo "$0: convert the subset to audio file and save the audio and text to dest dir"
  cat $data/train_aug_24k/wav.scp | awk '{printf("%s  \n", $1);}' > $data/train_aug_24k/utt_map  
  utils/apply_map.pl -f 1 $data/train_aug_24k/utt_map <$data/train_aug_24k/wav.scp > $data/train_aug_24k/wav.scp_new
  cp $data/train_aug_24k/text $data/wav/train_aug/text

  split_command=""
  for n in $(seq $nj); do
    split_command="$split_command $logdir/command.$n.sh"
  done

  utils/split_scp.pl $data/train_aug_24k/wav.scp_new $split_command || exit 1;

  $cmd JOB=1:$nj $logdir/add_noise.JOB.log \
    bash $logdir/command.JOB.sh || exit 1;

  echo "Sucessed corrupting the wave files."
fi
  
