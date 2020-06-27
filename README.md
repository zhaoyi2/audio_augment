
Audio augment through speech rate, volume, reverb, noise based on kaldi and sox

Install
  kaldi
  sox
  cd audio_augment
  cd tools; make KALDI=/your_kaldi_path
  
Usage
  $ cd audio_augment
  $ vim run_aug.sh to change your input_path and out_path and save
  $ bash run.sh, just fine!
  
Workflow(run_aug.sh)
  Stage 0: Data Preparation contain data and text
  Stage 1: speed 0.9/1.1
  Stage 2: volume +-db
  Stage 3: reverberation(RIRS)
  Stage 4: MUSAN(noise/music/babble)
  Stage 5: combine above data and select a subset of the augmend data list about twice the origin data
  Stage 6: data and label generation 

Example
  cd data/wav/train_aug listen a few enhanced audio example from aishell1 through speed/volume/RIRS/MUSAN 
  
Reference
  [1] MUSAN http://www.openslr.org/17/
  [2] RIRS http://www.openslr.org/28/



