import argparse, shlex, glob, math, os, random, sys, warnings, copy, imp, ast

def GetArgs():
    parser.add_argument("--speed-dir", type=int, dest = "speech_rate", default = '',
                        help="speed-perturbed scp data dir")
    parser.add_argument("--volume-dir", type=int, dest = "volume_rate", default = '',
                        help="volume-perturbed scp data dir")
    parser.add_argument("--rir-rate", type=int, dest = "rir_noise_rate", default = '',
                        help="rir-perturbed scp data dir")
    parser.add_argument("--noise-rate", type=int, dest = "noise_rate", default = '',
                        help="noise-perturbed scp data dir")
    parser.add_argument("--speed-rate", type=int, dest = "speech_rate", default = 1,
                        help="rate of speed-perturbed data")
    parser.add_argument("--volume-rate", type=int, dest = "volume_rate", default = 1,
                        help="rate of volume-perturbed data")
    parser.add_argument("--rir-rate", type=int, dest = "rir_noise_rate", default = 1,
                        help="rate of rir-perturbed data")
    parser.add_argument("--noise-rate", type=int, dest = "noise_rate", default = 1,
                        help="rate of rir-perturbed data")
    parser.add_argument('--output-dir', type=str, dest = "output_dir_string", default = 'data/train/wav', help='output augment data dir')

    print(' '.join(sys.argv))
    args = parser.parse_args()
    return args
def Main():
    args = GetArgs()
    speed_rate = args.speed-rate
    vol_rate = args.volume-rate
    rir_rate = args.rir-rate
    noise_rate = args.noise-rate
    speed_scp = args.speed-scp
    vol_scp = args.volume-scp
    rir_scp = args.rir-scp
    noise_scp = args.noise-scp
    output_dir = args.output-dir
    output_scp = open(os.path.join(output_dir,'wav.scp'),'wb+')
    if speed_scp != '':
    
        
        

if __name__ == '__main__':
    Main()

