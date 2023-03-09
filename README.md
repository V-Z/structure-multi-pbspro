STRUCTURE multi PBS Pro scripts
===============================

**Set of scripts to run [STRUCTURE](https://web.stanford.edu/group/pritchardlab/structure.html) in parallel** on computing grids like [MetaCentrum](https://www.metacentrum.cz/). Scripts are designed for grids and clusters using PBS Pro, but can be easily adopted for another queue system.

Version: 1.3

# Author

Vojtěch Zeisek, <https://trapa.cz/>.

# Homepage and reporting issues

See <https://github.com/V-Z/structure-multi-pbspro>, ask about usage or so at <https://github.com/V-Z/structure-multi-pbspro/discussions> and report any issues or wishes using <https://github.com/V-Z/structure-multi-pbspro/issues>.

# License

GNU General Public License 3.0, see `LICENSE.md` and <https://www.gnu.org/licenses/gpl-3.0.html>.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# About STRUCTURE and its parallelization

STRUCTURE itself process single file in time. It has simple Java GUI available to create batch task and run on desktop, or also possibly on MetaCentrum. Other option is [ParallelStructure R package](https://r-forge.r-project.org/projects/parallstructure/) (see my older [example](https://trapa.cz/en/structure-r-linux) and [slides](https://trapa.cz/sites/default/files/r_mol_data_phylogen_2020.pdf) --- chapter *Structure* from slide 204), but it has problems with some input file formats. It runs on single computer, using multiple cores.

Provided scripts distribute individual runs of STRUCTURE among multiple nodes (computers, servers) in computing cluster/grid, which speeds up everything a lot. STRUCTURE must be rune repeatedly for different K, and also for each K repeatedly. Here, `structure_multi_1_submitter.sh` will submit each single run as individual computing job. As soon as `structure_multi_1_submitter.sh` is done, the computing jobs are submitted to the queue and user can monitor their progress by commands like `qstat` (depending on scheduling system of the computing grid/cluster), and see if something already appeared in the output directory.

# Requirements to use the scripts

The scripts are written for Linux servers. They might be running on another UNIX systems. Apart of BASH, the only requirement is [STRUCTURE](https://web.stanford.edu/group/pritchardlab/structure.html). It [is already installed on MetaCentrum](https://wiki.metacentrum.cz/wiki/Structure), so that user can simply load the module. If using own installation of STRUCTURE, either comment out or update respective line in script `structure_multi_2_qsub.sh`. If you are unsure how to work in Linux command line on computing cluster, consult e.g. [my slides](https://soubory.trapa.cz/linuxcourse/linux_bash_metacentrum_course.pdf) or [MetaCentrum wiki](https://wiki.metacentrum.cz/).

# Installation

Either download and decompress [latest release](https://github.com/V-Z/structure-multi-pbspro/releases) or clone the Git repository:

```shell
git clone https://github.com/V-Z/structure-multi-pbspro.git
cd structure-multi-pbspro/
./structure_multi_1_submitter.sh -h
./structure_multi_1_submitter.sh -v
```

Consider copying of both scripts `structure_multi_1_submitter.sh` and `structure_multi_2_qsub_run.sh` into some folder dedicated to store scripts and software like `~/bin/` to have them available in PATH.

# Usage of the scripts

Prepare input file and MAINPARAMS and EXTRAPARAMS files according to [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html). The scripts need them as input. They then overwrite the K stated in MAINPARAMS to get the range of Ks, and name outputs according to K and repetition.

Script `structure_multi_1_submitter.sh` will use `qsub` to submit multiple jobs to calculate individual STRUCTURE runs. E.g. for K ranging from 1 to 10 and with 10 repetitions it will submit 100 jobs, which can be by cluster/grid computed in parallel (queueing system will decide according to cluster load).

* `-h` --- Print help and exit.
* `-v` --- Print script version, author and license and exit.
* `-s` --- Path to STRUCTURE binary. If not provided, it must be available in `PATH` variable.
* `-m` --- Path to STRUCTURE MAINPARAMS file. Consult [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html) (required).
* `-e` --- Path to STRUCTURE EXTRAPARAMS file. Consult [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html) (required).
* `-i` --- Input data file. Consult [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html) (required).
* `-n` --- Output files base name. If not provided, default is `res`. It can contain only Latin characters, numbers, dots, underscores or dashes. The name for each output file will be as `res.k.X.rep.Y.out`, where `X` is actual K and `Y` is repetition.
* `-o` --- Output directory. Should be empty. If provided directory does not exist, it will be created (required).
* `-f` --- Minimal K. Default is 1.
* `-k` --- Maximal K. Default is 10.
* `-r` --- How many times run for each K. Default is 10.
* `-w` --- Walltime (maximal running time) in hours for individual job to finish. Default is 24. See documentation of your cluster/grid scheduling system (e.g. [MetaCentrum](https://wiki.metacentrum.cz/wiki/About_scheduling_system)).

If `-s` is not specified (and `structure_multi_1_submitter.sh` doesn't find it in PATH), then `structure_multi_2_qsub_run.sh` will load module `structure-2.3.4` and use it.

Script `structure_multi_1_submitter.sh` will pass needed variables --- i.e. input files, output name and directory, path to STRUCTURE binary (if needed) and particular K and repetition --- to `structure_multi_2_qsub_run.sh` which will do the calculation. The latter script uses variables passed via `qsub` from script `structure_multi_1_submitter.sh` and calculates single run of STRUCTURE. As all the jobs are submitted in single step, the cluster queueing system can highly parallelize all calculations (if the cluster has enough performance, all jobs can dun in parallel).

## Usage example

If there is no need to edit the scripts (see following chapter), typical usage is like this:

```shell
# Submit the job
./structure_multi_1_submitter.sh -m mainparams.txt -e extraparams.txt -i input.str -n myanalysis -o str_outdir -f 1 -k 10 -r 10
# Monitor if jobs are running
# Different command might be needed on computing grids/clusters using different scheduling system
qstat -w -n -1 -u "${USER}" -x
```

If jobs are correctly submitted, but there are no `*_f` output files in the output directory (`str_outdir` in the above example), check output logs as there is probably something wrong with your input data. If so, consult [STRUCTURE manual](https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/html/structure.html). If input files were prepared on Windows, ensure they have correct EOL, e.g. using `dos2unix`.

Normally, there is **no need to manually run** `structure_multi_2_qsub_run.sh` --- it is used by `structure_multi_1_submitter.sh`. It is possible to use `structure_multi_2_qsub_run.sh` for single run (see comments in it what to edit in such case).

## Test data

Reduced microsatellite (SSRs) dataset of *Nuphar lutea* from Czech rivers (65 individuals, 5 loci, 13 populations) from 3 disconnected river basins (Elbe, Morava, Oder). Input file `nuphar_in.str`, STRUCTURE MAINPARAMS file `nuphar_mainparams.txt` and STRUCTURE EXTRAPARAMS file `nuphar_extraparams.txt`.

```shell
# Clone the git repository
git clone https://github.com/V-Z/structure-multi-pbspro.git
# Go to the directory
cd structure-multi-pbspro/
# See content
ls
# See help
./structure_multi_1_submitter.sh -h
# Submit the jobs
./structure_multi_1_submitter.sh -m nuphar_mainparams.txt -e nuphar_extraparams.txt -i nuphar_in.str -n Nuphar -o nuphar_str_out -f 1 -k 15 -r 10 -w 1
# Monitor how the jobs are running...
qstat -w -n -1 -u "${USER}" -x
# From time to time see results in the output directory...
ls -lh nuphar_out/
```

# Adopting the scripts for another clusters and grids than Czech MetaCentrum

Edits **might be** required on clusters/grids using **different scheduling system than PBS Pro**. Of course, improvements are welcomed, but *edit the code only if you know what you are doing*. ;-)

If your cluster/grid is using different scheduling system than [PBS on MetaCentrum](https://wiki.metacentrum.cz/wiki/About_scheduling_system), edit in last section of `structure_multi_1_submitter.sh` the `qsub` line. Also, if you need to submit the job to particular queue, change time to run, needed memory or so (e.g. for larger data), edit required resources on that `qsub` line.

If your cluster/grid is using different method to cleanup of temporal (scratch) directories [than MetaCentrum](https://wiki.metacentrum.cz/wiki/Trap_command_usage), edit or remove `trap` commands in `structure_multi_2_qsub_run.sh`. If your cluster/grid is using different method to manage application modules [than MetaCentrum](https://wiki.metacentrum.cz/wiki/Structure), edit or remove the block with `module add` command in `structure_multi_2_qsub_run.sh`. If your cluster/grid is using different name of variable pointing to temporal working directory than `SCRATCH` on [MetaCentrum](https://wiki.metacentrum.cz/wiki/Beginners_guide), replace all occurrences of `SCRATCH` by the correct variable name in `structure_multi_2_qsub_run.sh`.

Of course, improvements, generalizations for easier work on another clusters/grids are welcomed. :-)

# Postprocessing of the results

For next step collect all `res.k.X.rep.Y.out_f` files in the output directory. Select the best K using e.g. Structure_sum R script (see my older [example](https://trapa.cz/en/structure-r-linux) and [slides](https://trapa.cz/sites/default/files/r_mol_data_phylogen_2020.pdf) --- chapter *Structure* from slide 204) or [Structure Harvester](https://taylor0.biology.ucla.edu/structureHarvester/). Structure_sum was originally written by [Dorothee Ehrich](https://en.uit.no/ansatte/person?p_document_id=41186) and [updated for modern R by Marek Šlenker](https://github.com/MarekSlenker/structureSum). Align and reorder the results with [CLUMPP](https://web.stanford.edu/group/rosenberglab/clumpp.html) and draw final plots by e.g. [distruct](https://web.stanford.edu/group/rosenberglab/distruct.html). See also my older [complete example](https://trapa.cz/en/structure-r-linux).

