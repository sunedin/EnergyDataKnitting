# General interfacing API for multi-model approach
This work is to use general model interfacing to integrating different math model together. Several basic integrating functions has been implement, include:

- callModel()
- readData()
- getParameter()
- getVariables()
- getConstraints()
- getValue()
- setValue()
- solve()

These functions are demonstrated using Investment-Operational Problem with the investment model coded in Julia (JuMP) and the operational model coded in AMPL.

With the help of the integrating interfacing,  **the original csv-file-based data exchange between AMPL and Julia is replaced with a robust AMPL python API**.

### Translate data between models

Inputs:
-------
1. text file contain the names of items in data A:
    > for example: [ExhangeInfo_Julia.txt](ExhangeInfo_Julia.txt)
2. text file contain the names of items in data B
    > [ExhangeInfo_AMPL.txt](ExhangeInfo_AMPL.txt)
3. text file contain the common names
    > [ExhangeInfo_common.txt](ExhangeInfo_common.txt)

Function:
---------
```javascript
CrossMapping(a, f, t, c):
    """
    translate data a from ModelA to ModelB
    :param a: the data array
    :param f: the list of labels depict the meaning of the data per columns in the model where it is originally from
    :param t: the list of labels depict the expected order of the data array
    :param c: the list of common name
    :return:  the converted data array
    """
 ```

## To runing the multi-model with intefacing API:
[MainWithInterface.jl](main_py.jl)
> cd ./Workplace/MathTrial/Julia-AMPL-master/julia_ampl
>
> Julia MainWithInterface.jl

##  Dependency
**for julia**

- julia == 1.0.5
- jump == 0.18

**for python:**

- fuzzymuzzy
-  amplpy


## Note:
the challenge I found in writing API functions is
1) the risk the data format mapping between two side going wrong.
2) the python-to-julia is not robust as the other way around.
;to call Julia from python but found the python-package Julia is quite buggy.
 
