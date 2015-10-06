SCRIPTBOX
====
Flic Anderson 
1st July 2014

Aim: 
To hold scripts which will be useful for CMEP / RBGE work & manage these through Git version control associated with (currently private) GitHub repository @ https://github.com/FlicAnderson/Scriptbox

More Details: 
Containing scripts & documentation for Padme/R read/writes and eventually will contain analysis scripts.

Folder System:

- data_*/ folders:    
These contain scripts for dealing with data from various sources (such as GBIF, IUCN redlist, etc)    

- database_analysis:    
Analysis & summary stats for database output     

- database_connections:    
Connection scripts to databases such as Padme Arabia      

- database_export:    
Scripts dealing with exporting datasets such as ethnographic data or specimen data from databases such as Padme Arabia    

- database_importing:     
Functions & scripts for welding ethnographic annotations into Padme, checking & matching latin names against Padme's Latin Names tables, pulling in endemic annotations    

- database_output:    
Pulling data out of databases; datagrab scripts for specific queries or general regions or groups (herbarium = E, field observation counts, socotra specimens only, etc)    

- database_updating:   
Scripts for updating database directly: USE WITH CAUTION!!  Ideally, don't re-use these since they've been written often as one-time-only problem solvers & will screw up the database if they run at all now...  But allow tagging particular subsets such as expeditions, record fixes to the Socotra data etc   

- function_template:    
"function_format.R" contains the template layout for function scripts, including function title, date created/author details, aim of function, call info, code.  Follow this for all functions added to Scriptbox.

- general_utilities:    
Contain various snippets of old stuff & generally useful functions or scripts such as function padmeNameMatch.R which will check strings against Padme's Latin Names table & suggest fuzzy matches if it's not a direct match.  Also function getFamilies.R which pulls out & attaches families from Padme's Latin Names table to taxa   

- mapping:   
Scripts pertaining to mapping data & records; may include leaflet stuff, other mapping    

- script_template:     
"script_format.R" contains the template layout for script files, including project/title, date created/author details, aim of script, code.  Follow this for all files added to Scriptbox.

- web_reactiveApps:     
Things like Shiny apps; to continue & develop      

- web_xml-processing:   
Example xml-processing script, not fully developed or continued    