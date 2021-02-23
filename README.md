STRUCTURE multi PBS Pro scripts
===============================

**Set of scripts to run [STRUCTURE](https://web.stanford.edu/group/pritchardlab/structure.html) in parallel** on computing grids like [MetaCentrum](https://www.metacentrum.cz/). Scripts are designed for grids and clusters using PBS Pro, but can be easily adopted for another queue system.

Version: alpha

**EARLY PHASE OF DEVELOPMENT**

# Author

Vojtěch Zeisek, <https://trapa.cz/>.

# Homepage and reporting issues

See <https://github.com/V-Z/structure-multi-pbspro>, ask about usage or so at <https://github.com/V-Z/structure-multi-pbspro/discussions> and report any issues or wishes using <https://github.com/V-Z/structure-multi-pbspro/issues>.

# License

GNU General Public License 3.0, see `LICENSE.md` and <https://www.gnu.org/licenses/gpl-3.0.html>.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# About STRUCTURE and its parallelization

x

# Requirements to use the scripts

The scripts are written for Linux servers. They might be running on another UNIX systems. Apart of BASH, the only requirement is STRUCTURE. It [is already installed on MetaCentrum](https://wiki.metacentrum.cz/wiki/Structure), so that user can simply load the module. If using own installation of STRUCTURE, either comment out or update respective line in script `structure_multi_2_qsub.sh`.

# Installation

x

# Adopting the scripts for another clusters and grids than Czech MetaCentrum

x

# Usage of the scripts

Prepare input file and MAINPARAMS and EXTRAPARAMS files according to [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html).

## Using structure_multi_1_submitter.sh

Script `structure_multi_1_submitter.sh` will use `qsub` to submit multiple jobs to calculate individual STRUCTURE runs. E.g. for K ranging from 1 to 10 and with 10 repetitions it will submit 100 jobs, which can be by cluster/grid computed in parallel.

* `-h` Print help.
* `-v` Print script version, author and license and exit.
* `-s` Path to STRUCTURE binary. If not provided, it must be available in `PATH` variable.
* `-m` Path to STRUCTURE MAINPARAMS file. Consult [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html) (required).
* `-e` Path to STRUCTURE EXTRAPARAMS file. Consult [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html) (required).
* `-i` Input data file. Consult [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html) (required).
* `-n` Output files base name. If not provided, default is `res`. It can contain only Latin characters, numbers, dots, underscores or dashes. The name for each output file will be as `res.k.X.rep.Y.out`, where `X` is actual K and `Y` is repetition.
* `-o` Output directory. Should be empty. If provided directory does not exist, it will be created (required).
* `-f` Minimal K. Default is 1.
* `-k` Maximal K. Default is 10.
* `-r` How many times run for each K. Default is 10.

