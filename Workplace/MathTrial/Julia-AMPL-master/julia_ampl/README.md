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

To test them:
 
1. install amplpy using ‘pip install amplpy’ command.(https://pypi.org/project/amplpy/ ). 

2. run the script called ‘main_py.jl’.
 
 Note:
the challenge I found in writing API functions is 
1) the risk the data format mapping between two side going wrong.
 2) the python-to-julia is not robust as the other way around.
;to call Julia from python but found the python-package Julia is quite buggy.
 
