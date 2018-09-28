********************************************************************************
*** Compiler script for rpca-imputation-tutorial.stmd

*** Stata markstat needs additional programs. A check is done as part of execution.


clear all
set more off


********************************************************************************
*** User-specific directory definitions

if (c(username) == "goshev") {
	local base_dir "~/Desktop/gitProjects/rpca_imputation_tutorial"
	local out_dir "`base_dir'/output"
}



********************************************************************************
*** Check for required software

*** check whether markstat is installed
capture which markstat
if _rc ~= 0 {
	noi di in y "Please, install markstat before proceeding." _n ///
	"To install markstat, use -ssc install markstat-."
	exit
}

*** check whether whereis is installed
capture which whereis
if _rc ~= 0 {
	noi di in y "Please, install whereis before proceeding." _n ///
	"To install whereis, use -ssc install whereis-."
	exit
}

*** check whether pandoc is installed/known to whereis
qui whereis pandoc
if "`r(pandoc)'" == "" {
	noi di in y "Please, install pandoc/configure whereis before proceeding." _n ///
	"See "`"{browse "http://data.princeton.edu/stata/markdown/gettingStarted":this page}"'" for instructions."
	exit
}


********************************************************************************
*** Utility function definitions

*** define a utility function for moving files
capture program drop mv
program define mv
	args source destination
	copy `source' `destination', replace
	erase `source'
end



********************************************************************************
*** Meat of the compile file

*** change to base directory
cd "`base_dir'"

*** compile the document
markstat using "rpca-imputation-tutorial.stmd", bundle



********************************************************************************
*** Cleaning up

*** stall to display page before moving it to a new location
sleep 1000

*** move compiled html and all graphs
local mvContentGraphs: dir . files "*.png"
local mvContentHtml: dir . files "*.html"
local mvContent "`mvContentGraphs' `mvContentHtml'"
foreach file of local mvContent {
	mv "`base_dir'/`file'" "`out_dir'/`file'" 
}

*** clean up base dir
local rmContent: dir . files "*"
foreach f of local rmContent {
	if regexm("`f'", "\.(gph)?(smcl)?$") {
		erase `f'
	}
}

	


