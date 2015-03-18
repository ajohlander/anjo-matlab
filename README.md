anjo-matlab
====================
Set of tools for Matlab for use of Cluster data, mainly concerning CIS-HIA data with subspin resolution.

Author: Andreas Johlander  <br />
Swedish Institute of Space Physics, Uppsala

Installation
------------
Clone this directory by 
> git clone git://github.com/ajohlander/anjo-matlab.git

Make sure to add the path to Matlab so it can be used from anywhere. Add the following line to your [startup.m](http://se.mathworks.com/help/matlab/ref/startup.html?searchHighlight=startup.m "startup.m at Mathworks"):
>addpath /.../anjo-matlab

[irfu-matlab](https://github.com/irfu/irfu-matlab "IRFU's github") is required for these functions.

Compatibility
-------------------
Hopefully, everything is compatible with Matlab 2014b and later. Most functions are are compatible with 2014a as well. 

Usage
----------
Use the functions from any directory using:
>  anjo.function_name(...)

View help for the repo by typing in Matlab
> help anjo
or 
> doc anjo


Most "get functions" requires data to have been downloaded to a directory "~/Data/caalocal". Can use anjo.import_c_data to download data to this local directory.