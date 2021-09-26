# Future goals
This repository has the following goals:

* Provide easy-to-use code to reduce time & effort in setting up and performing common experiments
* Provide robust code to reduce the risk of destructive mistakes during characterization
* Use modular code design to reduce/eliminate time wasted re-programming when setups are reconfigured

# Download & Use

To use this code, simply click the "Code" drop-down menu at the top-right of this page and select "Download ZIP". After extracting the archive, simply open the repository folder in MATLAB and ensure all subdirectories are added to MATLAB's path. You should then be able to run any of the ready-to-use experiment scripts in the main directory of the repository.

# Modular design principles
To allow reconfiguration of the optical and electrical instruments used in various setups, this repository will be comprised mainly of the following parts:

* Generic functions for each experiment 'type' (e.g. measure a single wavelength as a function of tuning)
* Interfaces to provide a common way to initiate the functions common to each 'type' of equipment
* Low-level implementations of equipment interfaces for each specific piece of equipment supported by the repository

By structuring the code in this manner, the only additional code that must be written to support additional equipment is the implementation of the equipment interface for each piece of equipment.

# Available experiments
At this time, only the following experiments are supported:
* Perform a single transmission spectrum measurement
* Measure transmission at a single wavelength as a function of heating
* Measure transmission spectra as a function of heating

# Equipment
## Available optical equipment 
* Agilent 8164B (CSPTF)
## Available electrical equipment
* Keithley 2400
## TODO equipment to add:
* Basement setup laser
* Basement setup power meter
* TE heater/cooler driver
