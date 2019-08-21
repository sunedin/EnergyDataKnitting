#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Created by Dr. W SUN on 28/06/2019

# We're using the `xarray` module to work with NetCDF files. We would also
# have the option of using the `netCDF4` library which provides a thin Python
# layer over the netCDF C library. Xarray can use `netCDF4` under the hood and
# builds some more complex features on top of it. The most prominent one would
# probably be pandas' style data access and pretty seamless integration with
# pandas in general.
import xarray as xr

# Since we will be using our list of timesteps in more than one place in the
# code, it makes sense to define it up front to avoid duplicating information.
timesteps = ["2010-01-01 01:00", "2010-01-01 02:00"]

# NetCDF files contain 'Variable's. These usually come in the form of 'data
# variables' and 'dimensions'. Data variables are usually the observations one
# is actually interested in, like the wind speed monitored at a certain
# observation station at a certain point in time at a certain height, or the
# surface roughness at a certain geolocation, or, in our case, the energy
# demand of a certain country at a certain point in time.
# Dimensions on the other hand are the values along which data variables are
# indexed. This means that a tuple with one value for each of a
# data variable's dimensions uniquely characterizes one value of said data
# variable. So the first example above would be three dimensional with the
# dimensions being the monitoring station, the height and the time.

# When using `xarray`, a netCDF variable is represented by a `DataArray` so we
# start by creating one which holds our demand values.
demand = xr.DataArray(
        # A variable not containing any data is pretty useless, so `data` is
        # the only (I think) required argument when creating a `DataArray`.
        # As you can see, we are providing our data as a two dimensional list.
        data=[[0.5, 2], [1.7, 2]],
        # You need to tell `xarray` how we want to name our dimensions. Not
        # doing so would mean that `xarray` will generate names for us which
        # makes it kinda hard to refer to the dimensions later on.
        # Note that the order is important here, starting with the name for
        # the outermost dimension and continuing inwards.
        dims=["country", "time"],
        # Supplying actual values for each dimension is done using the
        # `coords` keyword argument. There are multiple ways to specify those
        # values, but the line above exemplifies the one in which `coords` are
        # specified via a dictionary with dimension names as keys and the
        # dimension's values as, well, values.
        coords={"country": ["CH", "LI"], "time": timesteps},
        # NetCDF supports arbitrary metadata as key/value pairs on variables
        # (and globally for the whole file). This can be set by supplying a
        # dictionary to the `attrs` keyword argument. There's a rich set of
        # [conventions](http://cfconventions.org/) on how to convey certain
        # information via netCDF metadata. Below, I'm using the conventional
        # `"units"` attribute to specify the unit of measurement attached to
        # the variable at hand.
        attrs={"units": "MWh"})

# Since in addition to a demand, we also have a supply in our data, it makes
# sense to create a variable for that too.
supply = xr.DataArray(
        data=[[2, 1.5]],
        dims=["powerplant", "time"],
        coords={"powerplant": ["WPP1"], "time": timesteps},
        attrs={"unit": "MWh"})

# As I said in the beginning, a netCDF file contains multiple variables. When
# using `xarray`, a netCDF file is represented in memory using a `Dataset`.
# Accordingly, the line below creates a dataset holding our two variables
# `supply` and `demand`.
ds = xr.Dataset(data_vars={"demand": demand, "supply": supply})
# While the line above looks a bit unimpressive, there's actually quite a lot
# going on in the background. Only the data variables got specified, but
# `xarray` creates dimension variables for each of the dimensions attached to
# the data variables. If any of those dimensions have the same name, they are
# assumed to represent a single shared dimension and `xarray` tries to align
# all the data variables along this shared dimension. This means that the
# actual dimension variables created hold the union of the values of all
# equally named variable dimensions and variables missing values for certain
# dimension values are filled using a specified fill value.

# Note that you can also set metadata after creating a variable or a dataset.
# We didn't provide any description of what this dataset is about or what the
# values in the `country` dimension mean, so let's do that now.
ds['country'].attrs['description'] = "ISO 3166-1 alpha-2 country code"
ds.attrs['description'] = (
        "A toy example illustrating one way of storing an energy system in " +
        "a netCDF file.")

# Last but not least, let's write our dataset to an actual netCDF file. The
# file is named `"etdf.nc"`.
ds.to_netcdf("etdf.nc")
# That's it, we're done. NetCDF is a binary format, so you need other programs
# to actually view the data contained in it. Try using the `ncdump` utility
# (part of the netcdf-bin package on e.g. Ubuntu) to view the file we just
# created.


if __name__ == '__main__':
    pass