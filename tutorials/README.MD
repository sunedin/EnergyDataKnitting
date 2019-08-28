Illustration of the working process

For such practice, people with three different roles will be involved:

    - Model developer: who develope the model, and provide a set of functions and procedures allowing the *interface developer* to access the the a) features and b) data of the model, or other service, in the format of API
    - Interface developer: who develop the common-purpose tools for facilitating co-run of models, though langugae API using the funcitons provided by the model developer
    - Model user: who co-run multiple models, in order to invesigate a particular reserach questions. Some beskope 
    

Essentially, the models need to provide feature that can access the data and also the data description, For a value of scalar or array, it would include:

    - name/label: to represent its physical meaning in the model
    - unit
    - format
    - default value
    - required or not
    - subclass that belongs to: subclass based on the data structure of the model, for example. the set of SETS, Parameters etc.

The schematic model-calling sequences through API can be illustrated as

End user who want to use multiple models

```puml
 digraph graphname {
       a [label="Prepare the input data for all model*"][shape=box];
       b [label = "run the first model with initial data"][shape=box]
       c [label = "second model with feedin data"]
       d [label = "first model with updated data "]
       a -> b -> c;
     c -> d;
     d -> c;
 }
```

Since the multiple models will run in sequences, the input of the models can be the combination of  1) exogenous input data and 2) dynamic feed from the model run in preceding steps

 - prepare the input data of  

use a example 

Implantation of the needs can be achieved by 

- automatic process enabled by coding through API

- manually check through documentation


---

API:

    a set of functions and procedures allowing the creation of applications that access the features or data of an operating system, application, or other service.


