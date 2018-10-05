********************************************************************************
*** Compiler script for rpca-imputation-tutorial.stmd

*** Stata markstat needs additional programs. A check is done as part of execution.


clear all
set more off
snapshot erase _all

********************************************************************************
*** User-specific directory definitions

if (c(username) == "goshev") {
	local base_dir "~/Desktop/gitProjects/rpca_imputation_tutorial"
	local out_dir_html "`base_dir'/output/html"
	local out_dir_pdf "`base_dir'/output/pdf"
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

*** check for pdflatex
qui whereis pdflatex
if "`r(pdflatex)'" == "" {
	noi di in y "Please, install MikTex/configure whereis before proceeding." _n ///
	"See "`"{browse "http://data.princeton.edu/stata/markdown/gettingStarted":this page}"'" for instructions."
	exit
}


*** check for mathjax
qui whereis mathjax
if "`r(mathjax)'" == "" {
	noi di in y "Please, install mathjax/configure whereis before proceeding." _n ///
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

*** compile the document as html
markstat using "rpca-imputation-tutorial.stmd", mathjax

*** compile the document as pdf
markstat using "rpca-imputation-tutorial.stmd", pdf



********************************************************************************
*** Cleaning up

*** stall to display page before moving it to a new location
*sleep 5000

*** move compiled html and all graphs
local mvContentGraphs: dir . files "*.png"
local mvContentHtml: dir . files "*.html"
local mvContent "`mvContentGraphs' `mvContentHtml'"
foreach file of local mvContent {
	mv "`base_dir'/`file'" "`out_dir_html'/`file'" 
}

*** move pdf files
local mvContentPdf: dir . files "*.pdf"
foreach file of local mvContentPdf {
	mv "`base_dir'/`file'" "`out_dir_pdf'/`file'" 
}

*** clean up root dir
local rmContent: dir . files "*"
foreach f of local rmContent {
	if regexm("`f'", "\.(gph|smcl|dta|stptrace)?$") {
		erase `f'
	}
}
