# Audio augmentation

(README.md)

*Audio augment* is an audio augment tool through speed, volume, reverb, noise based on kaldi and sox.

## Installation
- kaldi
- sox
- cd audio_augment
- cd tools; make KALDI=/your_kaldi_path

## Usage
- cd audio_augment
- vim run_aug.sh to change your input_path and out_path and save
- bash run_aug.sh, so easy!

## Workflow(run_aug.sh)
- Stage 1: Data Preparation contain data and text
- Stage 2: speed 0.9/1.1
- Stage 3: volume +-db
- Stage 4: reverberation(RIRS)
- Stage 5: MUSAN(noise/music/babble)
- Stage 6: combine above data and select a subset of the augmend data list about twice the origin data
- Stage 7: data and label generation

## generated Examples

- cd data/wav/train_aug listen a few enhanced audio example from aishell1 through speed/volume/RIRS/MUSAN.

### Reference
- MUSAN http://www.openslr.org/17/
- RIRS http://www.openslr.org/28/
- https://github.com/linan2/add_reverb2
