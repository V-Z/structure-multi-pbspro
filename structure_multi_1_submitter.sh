#!/bin/bash

# Author: Vojtěch Zeisek, https://trapa.cz/
# License: GNU General Public License 3.0, https://www.gnu.org/licenses/gpl-3.0.html
# Homepage: https://github.com/V-Z/structure-multi-pbspro

# The script will use `qsub` to submit multiple jobs to calculate individual STRUCTURE runs.
# E.g. for K ranging from 1 to 10 and with 10 repetitions it will submit 100 jobs, which can be by cluster/grid computed in parallel.

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# Script working directory
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)" || { echo "Failed to determine script directory!" && exit 1; }

################################################################################
# Processing user input
################################################################################

# Variables used
STRUCTURE='' # '-s' Path to STRUCTURE binary
MAINPARAM='' # '-m' Path to STRUCTURE MAINPARAMS file
EXTRPARAM='' # '-e' Path to STRUCTURE EXTRAPARAMS file
INPUTFILE='' # '-i' Input data file
OUTNAME=''   # '-n' Output files base name
OUTDIR=''    # '-o' Output directory
KMIN=''      # '-f' Minimal K
KMAX=''      # '-k' Maximal K
KREP=''      # '-r' How many times run for each K
# Testing if provided values are numbers/character strings
NUMTEST='^[0-9]+$' # Testing if provided value is an integer
CHRTEST='^[a-zA-Z0-9._-]+$' # Testing if provided value is string containing only Latin characters, numbers, dots, underscores or dashes

# Parse initial arguments
while getopts "hvs:m:e:i:n:o:f:k:r:" INITARGS; do
	case "${INITARGS}" in
		h) # Help and exit
			echo "Usage options:"
			echo -e "\t-h\tPrint this help and exit."
			echo -e "\t-v\tPrint script version, author and license and exit."
			echo -e "\t-s\tPath to STRUCTURE binary. If not provided, it must be available in PATH."
			echo -e "\t-m\tPath to STRUCTURE MAINPARAMS file. Consult STRUCTURE manual <https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html> (required)."
			echo -e "\t-e\tPath to STRUCTURE EXTRAPARAMS file. Consult STRUCTURE manual <https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html> (required)."
			echo -e "\t-i\tInput data file. Consult STRUCTURE manual <https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html> (required)."
			echo -e "\t-n\tOutput files base name. If not provided, default is 'res'. It can contain only Latin characters, numbers, dots, underscores or dashes. The name for each output file will be as 'res.k.X.rep.Y.out', where 'X' is actual K and 'Y' is repetition."
			echo -e "\t-o\tOutput directory. Should be empty. If provided directory does not exist, it will be created (required)."
			echo -e "\t-f\tMinimal K. Default is 1."
			echo -e "\t-k\tMaximal K. Default is 10."
			echo -e "\t-r\tHow many times run for each K. Default is 10."
			echo
			exit
			;;
		v) # Print script version and exit
			echo "Version: 1.0"
			echo "Author: Vojtěch Zeisek, <https://trapa.cz/en>"
			echo "Homepage and documentation: <https://github.com/V-Z/structure-multi-pbspro>"
			echo "Discussion: <https://github.com/V-Z/structure-multi-pbspro/discussions>"
			echo "Issues: <https://github.com/V-Z/structure-multi-pbspro/issues>"
			echo "License: GNU GPLv3, <https://www.gnu.org/licenses/gpl-3.0.html>"
			echo "STRUCTURE homepage: <https://web.stanford.edu/group/pritchardlab/structure.html>"
			echo
			exit
			;;
		s) # Path to STRUCTURE binary
			if [ -x "${OPTARG}" ]; then
			STRUCTURE="${OPTARG}"
			echo "STRUCTURE binary: ${STRUCTURE}"
			echo
			else
				echo "Error! You did not provide correct path to STRUCTURE binary (-s) \"${OPTARG}\"!"
				echo
				exit 1
				fi
			;;
		m) # Path to STRUCTURE MAINPARAMS file
			if [ -r "${OPTARG}" ]; then
				MAINPARAM=$(realpath "${OPTARG}")
				echo "STRUCTURE MAINPARAMS file: ${MAINPARAM}"
				echo
				else
					echo "Error! You did not provide correct path to STRUCTURE MAINPARAMS file (-m) \"${OPTARG}\"!"
					echo
					exit 1
					fi
			;;
		e) # Path to STRUCTURE EXTRAPARAMS file
			if [ -r "${OPTARG}" ]; then
				EXTRPARAM=$(realpath "${OPTARG}")
				echo "STRUCTURE EXTRAPARAMS file: ${EXTRPARAM}"
				echo
				else
					echo "Error! You did not provide correct path to STRUCTURE EXTRAPARAMS file (-e) \"${OPTARG}\"!"
					echo
					exit 1
					fi
			;;
		i) # Input data file
			if [ -r "${OPTARG}" ]; then
				INPUTFILE=$(realpath "${OPTARG}")
				echo "Input data file: ${INPUTFILE}"
				echo
				else
					echo "Error! You did not provide correct path to input data file (-i) \"${OPTARG}\"!"
					echo
					exit 1
					fi
			;;
		n) # Output files base name
			if [[ ${OPTARG} =~ ${CHRTEST} ]]; then
			OUTNAME="${OPTARG}"
			echo "Output files base name: ${OUTNAME}"
			echo
			else
				echo "Error! You did not provide correct output files base name, e.g. 'res' (-n), \"${OPTARG}\"! It can contain only Latin characters, numbers, dots, underscores or dashes."
				echo
				exit 1
				fi
			;;
		o) # Output directory
			if [ -d "${OPTARG}" ]; then
				OUTDIR=$(realpath "${OPTARG}")
				echo "Output directory: ${OUTDIR}"
				echo
				else
					echo "Output directory ${OUTDIR} doesn't exist (-o) - creating 'structure_out'."
					OUTDIR='structure_out'
					mkdir "${OUTDIR}" || { echo "Error! Can't create ${OUTDIR}!"; echo; exit 1; }
					echo
					fi
			;;
		f) # Minimal K
			if [[ ${OPTARG} =~ ${NUMTEST} ]]; then
			KMIN="${OPTARG}"
			echo "Minimal K: ${KMIN}"
			echo
			else
				echo "Error! You did not provide correct minimal K (-f), e.g. 1, \"${OPTARG}\"!"
				echo
				exit 1
				fi
			;;
		k) # Maximal K
			if [[ ${OPTARG} =~ ${NUMTEST} ]]; then
			KMAX="${OPTARG}"
			echo "Maximal K: ${KMAX}"
			echo
			else
				echo "Error! You did not provide correct maximal K (-k), e.g. 10, \"${OPTARG}\"!"
				echo
				exit 1
				fi
			;;
		r) # How many times run for each K
			if [[ ${OPTARG} =~ ${NUMTEST} ]]; then
			KREP="${OPTARG}"
			echo "How many times run for each K: ${KREP}"
			echo
			else
				echo "Error! You did not provide correct number how many times to run for each K (-r), e.g. 10, \"${OPTARG}\"!"
				echo
				exit 1
				fi
			;;
		*)
			echo "Error! Unknown option!"
			echo "See usage options: \"$0 -h\""
			echo
			exit 1
			;;
		esac
	done

################################################################################
# Checking if all required parameters are provided
################################################################################

# Checking if all required parameters are provided
if [ -z "${STRUCTURE}" ]; then # Path to STRUCTURE binary
	command -v structure >/dev/null 2>&1 || {
		echo >&2 "Error! Path to STRUCTURE binary (-s) was not specified and command 'structure' was not found in PATH!"
		echo "See usage options: \"$0 -h\""
		echo
		exit 1
		}
	fi
if [ -z "${MAINPARAM}" ]; then # Path to STRUCTURE MAINPARAMS file
	echo "Error! Path to STRUCTURE MAINPARAMS file (-m) was not specified!"
	echo "See usage options: \"$0 -h\""
	echo
	exit 1
	fi
if [ -z "${EXTRPARAM}" ]; then # Path to STRUCTURE EXTRAPARAMS file
	echo "Error! Path to STRUCTURE EXTRAPARAMS file (-e) was not specified!"
	echo "See usage options: \"$0 -h\""
	echo
	exit 1
	fi
if [ -z "${INPUTFILE}" ]; then # Input data file
	echo "Error! Path to input data file (-i) was not specified!"
	echo "See usage options: \"$0 -h\""
	echo
	exit 1
	fi
if [ -z "${OUTNAME}" ]; then # Output files base name
	echo "Output files base name (-n) was not specified. Using default 'res'."
	OUTNAME='res'
	echo
	fi
if [ -z "${OUTDIR}" ]; then # Output directory
	echo "Error! Output directory (-o) was not specified!"
	echo "See usage options: \"$0 -h\""
	echo
	exit 1
	fi
if [ -z "${KMIN}" ]; then # Minimal K
	echo "Minimal K (-f) was not specified! Using default value 1."
	KMIN='1'
	echo
	fi
if [ -z "${KMAX}" ]; then # Maximal K
	echo "Maximal K (-k) was not specified! Using default value 10."
	KMAX='10'
	echo
	fi
if [ -z "${KREP}" ]; then # How many times run for each K
	echo "How many times run for each K (-r) was not specified! Using default value 10."
	KREP='10'
	echo
	fi
if [ "${KMIN}" -gt "${KMAX}" ]; then # Ensuring minimal K is smaller than maximal
	echo "User error! Minimal K is larger than maximal!"
	echo "See usage options: \"$0 -h\""
	echo
	exit 1
	fi

################################################################################
# End of processing of user input and checking if all required parameters are provided
################################################################################

# Information for user
echo "There will be in total $(((KMAX-KMIN+1)*KREP)) submitted jobs."
echo

################################################################################
# Jobs submission
# NOTE On another clusters than Czech MetaCentrum edit the 'qsub' command below to fit your needs
# See https://wiki.metacentrum.cz/wiki/About_scheduling_system
# NOTE Edit qsub parameters if you need more resources, use particular cluster, etc.
################################################################################

# Submit jobs within given range of Ks
for (( K="${KMIN}"; K<="${KMAX}"; K++ )); do
	echo "Submitting jobs for K ${K}."
	echo
	# Multiple jobs for particular K
	for (( R=1; R<="${KREP}"; R++ )); do
		echo "Submitting job for K ${K}, repetition ${R}."
		# Submission using PBS Pro
		# NOTE Edit following command on clusters/grids using different queuing system or if different parameters are needed
		qsub -l walltime=24:0:0 -l select=1:ncpus=1:mem=8gb:scratch_local=1gb -m abe -N STRUCTURE."${K}"."${R}" -v STRUCTURE="${STRUCTURE}",MAINPARAM="${MAINPARAM}",EXTRPARAM="${EXTRPARAM}",INPUTFILE="${INPUTFILE}",OUTNAME="${OUTNAME}",OUTDIR="${OUTDIR}",K="${K}",R="${R}" "${SCRIPTDIR}"/structure_multi_2_qsub_run.sh || { echo "Job submission failed!" && exit 1; }
		echo
		done
	done

echo "Done!"
echo

exit

