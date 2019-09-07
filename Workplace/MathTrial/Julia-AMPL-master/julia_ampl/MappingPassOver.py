#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by Dr. W SUN on 9/3/2019
import os
import numpy as np
import pandas as pd
from fuzzywuzzy import process

'''
commas make a significant difference in Julia array!!!

Creating simple arrays
Here's how to create a simple one-dimensional array:

julia> a = [1, 2, 3, 4, 5]
5-element Array{Int64,1}:
1
2
3
4
5    

Creating 2D arrays and matrices
If you leave out the commas when defining an array, you can create 2D arrays quickly. Here's a single row, multi-column array:

julia> [1 2 3 4]
1x4 Array{Int64,2}:
1  2  3  4

'''

os.chdir(os.path.dirname(__file__))  # switch to the folder where you script is stored


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

    :param a: the data array
    :param f: the list of labels depict the meaning of the data per columns in the model where it is originally from
    :param t: the list of labels indicates  the expected order of the data array
    :param c: the list of common name
    :return:  the converted data array
    """
    flag = False
    if isinstance(a, np.ndarray):
        if a.ndim == 1:
            flag = True
            a = [a.flatten()]

    '''
    https://stackoverflow.com/questions/50185926/valueerror-shape-of-passed-values-is-1-6-indices-imply-6-6
        You want [data] for pandas to understand they're rows.
    
    Simple illustration:
    
    a = [1, 2, 3]
    >>> pd.DataFrame(a)
       0
    0  1
    1  2
    2  3
    
    >>> pd.DataFrame([a])
       0  1  2
    0  1  2  3
    '''

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
    # G_JL   = Dict(1=>"coal",2=>"ocgt",3=>"ccgt",4=>"diesel",5=>"nuclear")
    # G_AMPL = Dict(1=>"Gcoal",2=>"Gocgt",3=>"Gccgt",4=>"Gnucl",5=>"Gdies")

    G_JL = ["coal", "ocgt", "ccgt", "diesel", "nuclear"]
    G_AMPL = ["Gcoal", "Gocgt", "Gccgt", "Gnucl", "Gdies"]

    common = ["Coal", "Ocgt", "Ccgt", "Diesel", "Nuclear"]

    print(CreatMap(G_JL, common))
    print(CreatMap(common, G_AMPL))
    ModelA = G_JL
    ModelB = G_AMPL

    # a = [1, 2, 3, 4, 5]  # need pass as [a]
    # a = [a]
    a = np.array([[1, 2, 3, 4, 5], [4, 5, 6, 7, 8], [7, 8, 9, 10, 11]])

    # [[1 2 3 5 4]] as numpy arrry
    # [1 2 3 5 4] as list
    print('Cross Mapping using common naming\n')
    print(CrossMapping(a, ModelA, ModelB, common))

    print('Cross Mapping without common naming\n')
    print(CrossMappingWTunif(a, G_JL, G_AMPL))

    pass
