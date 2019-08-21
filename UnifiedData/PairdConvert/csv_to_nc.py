#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by Dr. W SUN on 30/05/2019

'''using pd read csv.file
using xarray to export to netcdf '''
import os
os.chdir(os.path.dirname(__file__))  # switch to the folder where you script is stored

import pandas as pd
from io import StringIO

s = StringIO('''             
    -32.0,-73.000000,0  
    -32.0,-72.999168,0  
    -32.0,-72.998337,0  
    -32.0,-72.997498,4  
    -32.0,-72.996666,0
    ''')
headings = ['lat', 'lon', 'hgt']
df = pd.read_csv(s, header=None, names=headings)
df.keys()
df = df.set_index(['lat', 'lon'])  # multiple-index: special feature different from DataPackage!!
df.to_xarray().to_netcdf('example.nc')

if __name__ == '__main__':
    pass
