#!/bin/bash

# Author: Vojtěch Zeisek, https://trapa.cz/
# License: GNU General Public License 3.0, https://www.gnu.org/licenses/gpl-3.0.html
# Homepage: https://github.com/V-Z/structure-multi-pbspro

# 

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# 

echo "Running STRUCTURE with MAINPARAMS file ${MAINPARAM}, EXTRAPARAMS file ${EXTRPARAM} and input file ${INPUTFILE} for K ${K} and repetition ${R} at $(date)..."
echo
"${STRUCTURE}" -m "${MAINPARAM}" -e "${EXTRPARAM}" -K "${K}" -i "${INPUTFILE}" -o "${OUTNAME}.k.${K}.rep.${R}.out"
echo

exit

