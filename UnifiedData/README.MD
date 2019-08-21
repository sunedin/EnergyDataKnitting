# Unified data 

General concept:

Most open energy data is published as CSV, despite they may be originally sourced from various format (Microsoft Excel, .DAT file, mat file, etc).

So there is a general need in modelling practice, to provide a model-independent paired-conversion tool to convert the various popular formats into/from CSV file and also creat an associated metadata .json file

The general concept can be envisaged with the following class of key functions.

## Key functions
- Resource
- Profile
- Validate
- Infer
- Foreign Keys

Such concept can be implemented with the [**Datapackage standard**.](https://frictionlessdata.io/)

## Example of the implementations in python
```python
# package = Package('datapackage.json')
# package.get_resource('resource').read()
# package.infer('Workplace/examples/datapackages/dispatch/data/*.csv')

```

## todo list
-[ ] test mat_to_csv.py using Newcastle model

## Matpower data
IEEE example data in matpower is a bit **hardcoded** in .m code file (including codes to load the data into workspace in matlab), rather than .mat data file

the procedures as:

1. export to csv ( this funcion is developed in Julia by GARCIA NAVA Rodrigo <Rodrigo.Garciana@ed.ac.uk>)

2. infer metadata

3. packed into datapackage

## Excel data
Process:
- export sheets into .csv files (if multiple tables exist in a single sheet, need to specify the range of the data for excel table)
- infer metadata
- adding foreign keys
- packaging up

```python
df = pd.read_excel('data/population.xlsx')
```
## Example
matpower case30 

## NetCdf

Python NetCDF
https://gist.github.com/jswhit/43dc116595ed66a92804

Python xarray
https://rabernat.github.io/research_computing/xarray.html

#####additional:
convert into various format, as: .nc; .jason; .mat; .yaml;


