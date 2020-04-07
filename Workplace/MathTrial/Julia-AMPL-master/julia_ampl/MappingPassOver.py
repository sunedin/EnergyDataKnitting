#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by Dr. W SUN on 9/3/2019
import os
import numpy as np
import pandas as pd
from fuzzywuzzy import process

os.chdir(os.path.dirname(__file__))  # switch to the folder where you script is store

ModelAfile = 'ExhangeInfo_Julia.txt'
ModelBfile = 'ExhangeInfo_AMPL.txt'
Commonfile = 'ExhangeInfo_common.txt'


def read_text(id_file):
    with open(id_file) as f:
        data = f.read().split(',')
    return data


if any([ModelAfile, ModelBfile, Commonfile]):
    ModelA = read_text(ModelAfile)
    ModelB = read_text(ModelBfile)
    Common = read_text(Commonfile)


def CreatMap(f, t):
    # mapping by labels would be provided by the modeller developer as inputs.
    # however, it is simulated by generating mapping using fuzzywuzzy package
    maping = {}
    for i in f:
        highest = process.extractOne(i, t, score_cutoff=50)
        maping[i] = highest[0]
    return maping


def CrossMapping(a, f, t, c):
    """
    translate data a from ModelA to ModelB
    :param a: the data array
    :param f: the list of labels depict the meaning of the data per columns in the model where it is originally from
    :param t: the list of labels depict the expected order of the data array
    :param c: the list of common name
    :return:  the converted data array
    """
    flag = False
    if isinstance(a, np.ndarray):
        if a.ndim == 1:
            flag = True
            a = [a.flatten()]

    df = pd.DataFrame(data=a, columns=f).rename(columns=CreatMap(f, c)).rename(columns=CreatMap(c, t))[t]
    if flag:
        return df.values.flatten()  # devised for the 1d array exchange between julia and python
    else:
        return df.values


def CrossMappingWTunif(a, f, t):
    df = pd.DataFrame(data=a, columns=f).rename(columns=CreatMap(f, t))[t]
    return df.values


if __name__ == '__main__':
    ##########################################################################
    # example
    ##########################################################################

    a = np.array([[1, 2, 3, 4, 5], [4, 5, 6, 7, 8], [7, 8, 9, 10, 11]])

    print('Cross Mapping using common naming\n')
    print(CrossMapping(a, ModelA, ModelB, Common))

    print('Cross Mapping without common naming\n')
    print(CrossMappingWTunif(a, ModelA, ModelB))
