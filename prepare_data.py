# coding=utf-8
import os
import glob
import sys

if __name__ == '__main__':
    aug_ori = sys.argv[1] 
    aug_new = sys.argv[2]
    #write wav list
    wav_scp = open(aug_ori,'r')
    new_scp = open(aug_new,'wb+')
    lines = wav_scp.readlines()
    print(len(lines))
    i = 0
    for line in lines:
        key = line.strip().split(' ')[0]
        command = line[len(key):].strip()
        new_scp.write(command+'\n')
    new_scp.close()

