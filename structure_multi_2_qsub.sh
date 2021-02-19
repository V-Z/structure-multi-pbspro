#!/bin/bash

# Author: Vojtěch Zeisek, https://trapa.cz/
# License: GNU General Public License 3.0, https://www.gnu.org/licenses/gpl-3.0.html

# 

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# 

# qsub -l walltime=24:0:0 -l select=1:ncpus=1:mem=8gb:scratch_local=1gb -m abe -N STRUCTURE."${K}"."${R}" -v STRUCTURE="STRUCTURE",MAINPARAM="MAINPARAM",EXTRPARAM="EXTRPARAM",INPUTFILE="INPUTFILE",OUTNAME="OUTNAME",OUTDIR="OUTDIR",K="K",R="R" structure_multi_2_qsub.sh

# Clean-up of SCRATCH
trap 'clean_scratch' TERM EXIT
trap 'cp -ar $SCRATCH $DATADIR/ && clean_scratch' TERM

# Checking if all required variables are provided
if [ -z "${STRUCTURE}" ]; then
	echo "Error! Path to STRUCTURE binary not provided!"
	exit 1
	fi
if [ -z "${MAINPARAM}" ]; then
	echo "Error! Path to STRUCTURE MAINPARAMS file not provided!"
	exit 1
	fi
if [ -z "${EXTRPARAM}" ]; then
	echo "Error! Path to STRUCTURE EXTRAPARAMS file not provided!"
	exit 1
	fi
if [ -z "${INPUTFILE}" ]; then
	echo "Error! Path to input data file not provided!"
	exit 1
	fi
if [ -z "${OUTNAME}" ]; then
	echo "Error! Output files base name not provided!"
	exit 1
	fi
if [ -z "${OUTDIR}" ]; then
	echo "Error! Path to output directory not provided!"
	exit 1
	fi
if [ -z "${K}" ]; then
	echo "Error! K not provided!"
	exit 1
	fi
if [ -z "${R}" ]; then
	echo "Error! R not provided!"
	exit 1
	fi

# Required modules
echo "Loading modules"
module add structure-2.3.4 || exit 1
echo

# Change working directory
echo "Going to working directory ${SCRATCH}"
cd "${SCRATCH}"/ || exit 1
echo

# Copy data
echo "Copying..."
echo "STRUCTURE MAINPARAMS file - ${MAINPARAM}"
cp -a "${MAINPARAM}" "${SCRATCH}"/ || exit 1
echo "STRUCTURE EXTRAPARAMS file - ${EXTRPARAM}"
cp -a "${EXTRPARAM}" "${SCRATCH}"/ || exit 1
echo "Input data file - ${INPUTFILE}"
cp -a "${INPUTFILE}" "${SCRATCH}"/ || exit 1
echo

# Runing the task (HibPiper)
echo "Running STRUCTURE with MAINPARAMS file $(basename ${MAINPARAM}), EXTRAPARAMS file $(basename ${EXTRPARAM}) and input file $(basename ${INPUTFILE}) for K ${K} and repetition ${R} at $(date)..."
./structure_multi_3_run.sh  | tee .log
echo

# Removing unneeded files
echo "Removing temporal files"
rm "$(basename ${MAINPARAM})" "$(basename ${EXTRPARAM})" "$(basename ${INPUTFILE})"
echo

# Copy results back to storage
echo "Copying results to ${OUTDIR}"
cp -a "${SCRATCH}"/* "${DATADIR}"/ || export CLEAN_SCRATCH='false'
echo

exit

