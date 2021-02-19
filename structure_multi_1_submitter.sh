#!/bin/bash

# Author: Vojtěch Zeisek, https://trapa.cz/
# License: GNU General Public License 3.0, https://www.gnu.org/licenses/gpl-3.0.html

# 

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# 

STRUCTURE="" # Path to STRUCTURE binary
MAINPARAM="" # Path to STRUCTURE MAINPARAMS file
EXTRPARAM="" # Path to STRUCTURE EXTRAPARAMS file
INPUTFILE="" # Input data file
OUTNAME="" # Output files base name
OUTDIR="" # Output directory
KMIN="" # Minimal K
KMAX="" # Maximal K
KREP="" # How many times run for each K

# Submit jobs within given range of Ks
for (( K="${KMIN}"; K<="${KMAX}"; K++ )); do
	
	# Multiple jobs for particular K
	for (( R=1; R<="${KREP}"; R++ )); do
		
		qsub -l walltime=24:0:0 -l select=1:ncpus=1:mem=8gb:scratch_local=1gb -m abe -N STRUCTURE."${K}"."${R}" -v STRUCTURE="STRUCTURE",MAINPARAM="MAINPARAM",EXTRPARAM="EXTRPARAM",INPUTFILE="INPUTFILE",OUTNAME="OUTNAME",OUTDIR="OUTDIR",K="K",R="R" structure_multi_2_qsub.sh
		
		done
	
	done

exit

