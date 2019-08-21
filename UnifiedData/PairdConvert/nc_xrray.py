#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by Dr. W SUN on 30/05/2019

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib as mpl
import os

import matplotlib.style  # https://matplotlib.org/users/dflt_style_changes.html

# print(plt.style.available)
mpl.style.use('classic')
# mpl.style.use('ggplot')
import xarray as xr
os.chdir(os.path.dirname(__file__))  # switch to the folder where you script is stored

data = np.random.rand(4, 3)
locs = ['IA', 'IL', 'IN']
times = pd.date_range('2000-01-01', periods=4)
foo = xr.DataArray(data, coords=[times, locs], dims=['time', 'space'])

xr.DataArray(data)
xr.DataArray(data, coords=[('time', times), ('space', locs)])
xr.DataArray(data, coords={'time': times, 'space': locs, 'const': 42,'ranking': ('space', [1, 2, 3])},dims=['time', 'space'])

temp = 15 + 8 * np.random.randn(2, 2, 3)
precip = 10 * np.random.rand(2, 2, 3)
lon = [[-99.83, -99.32], [-99.79, -99.23]]
lat = [[42.25, 42.21], [42.63, 42.59]]

# for real use cases, its good practice to supply array attributes such as
# units, but we won't bother here for the sake of brevity
ds = xr.Dataset({'temperature': (['x', 'y', 'time'],  temp), 'precipitation': (['x', 'y', 'time'], precip)},coords={'lon': (['x', 'y'], lon),'lat': (['x', 'y'], lat),'time': pd.date_range('2014-09-06', periods=3),'reference_time': pd.Timestamp('2014-09-05')})



if __name__ == '__main__':
    pass