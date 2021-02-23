#!/bin/bash

# Author: Vojtěch Zeisek, https://trapa.cz/
# License: GNU General Public License 3.0, https://www.gnu.org/licenses/gpl-3.0.html
# Homepage: https://github.com/V-Z/structure-multi-pbspro

# 

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# qsub -l walltime=24:0:0 -l select=1:ncpus=1:mem=8gb:scratch_local=1gb -m abe -N STRUCTURE."${K}"."${R}" -v STRUCTURE="STRUCTURE",MAINPARAM="MAINPARAM",EXTRPARAM="EXTRPARAM",INPUTFILE="INPUTFILE",OUTNAME="OUTNAME",OUTDIR="OUTDIR",K="K",R="R",SCRIPTDIR="SCRIPTDIR" "${SCRIPTDIR}"/structure_multi_2_qsub_run.sh

################################################################################
# If using this script standalone (not via structure_multi_1_submitter.sh), either export the
# needed variables in shell, or uncomment the below section and declare all needed variables here
################################################################################

# ### Variables used
# STRUCTURE='' # Path to STRUCTURE binary 
# MAINPARAM='' # Path to STRUCTURE MAINPARAMS file
# EXTRPARAM='' # Path to STRUCTURE EXTRAPARAMS file
# INPUTFILE='' # Input data file
# OUTNAME=''   # Output files base name
# OUTDIR=''    # Output directory
# K=''         # K of actual run
# R=''         # Actual repetition
# SCRIPTDIR='' # Directory where the structure_multi_*.sh scripts are located

################################################################################
# Checking if all required variables are passed via qsub from structure_multi_1_submitter.sh
################################################################################

# Checking if all required variables are provided
# Structure binary (variable STRUCTURE) is checked later, together with possible loading of STRUCTURE module
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
if [ -z "${SCRIPTDIR}" ]; then
	echo "Error! Directory where the structure_multi_*.sh scripts are located not available!"
	exit 1
	fi

################################################################################
# Cleanup of temporal (scratch) directory where the calculation was done
# See https://wiki.metacentrum.cz/wiki/Trap_command_usage
# NOTE On another clusters than Czech MetaCentrum edit or remove the 'trap' commands below
################################################################################

# Clean-up of SCRATCH
trap 'clean_scratch' TERM EXIT
trap 'cp -ar "${SCRATCH}" "${OUTDIR}"/ && clean_scratch' TERM

################################################################################
# Loading of STRUCTURE application module
# See https://wiki.metacentrum.cz/wiki/Structure
# NOTE On another clusters than Czech MetaCentrum edit or remove the 'module' command below
################################################################################

# If custom STRUCTURE binary is not provided, load its module
if [ -z "${STRUCTURE}" ]; then
	echo "Custom path to STRUCTURE binary not provided"
	echo "Loading module"
	# NOTE Edit following command on clusters/grids using different loading of application modules
	module add structure-2.3.4 || exit 1
	STRUCTURE="$(which structure)" || exit 1
	echo
	fi

################################################################################
# 
# See https://wiki.metacentrum.cz/wiki/Beginners_guide#Run_batch_jobs
# NOTE 
################################################################################

# Change working directory
echo "Going to working directory ${SCRATCH}"
cd "${SCRATCH}"/ || exit 1
echo

# Copy data
echo "Copying..."
echo "STRUCTURE MAINPARAMS file - ${MAINPARAM}"
cp "${MAINPARAM}" "${SCRATCH}"/ || exit 1
echo "STRUCTURE EXTRAPARAMS file - ${EXTRPARAM}"
cp "${EXTRPARAM}" "${SCRATCH}"/ || exit 1
echo "Input data file - ${INPUTFILE}"
cp "${INPUTFILE}" "${SCRATCH}"/ || exit 1
echo

# Runing the STRUCTURE
echo "Running STRUCTURE with MAINPARAMS file ${MAINPARAM}, EXTRAPARAMS file ${EXTRPARAM} and input file ${INPUTFILE} for K ${K} and repetition ${R} at $(date)..."
echo
"${STRUCTURE}" -m "${MAINPARAM}" -e "${EXTRPARAM}" -K "${K}" -i "${INPUTFILE}" -o "${OUTNAME}.k.${K}.rep.${R}.out" | tee "${OUTNAME}.k.${K}.rep.${R}.log"
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

