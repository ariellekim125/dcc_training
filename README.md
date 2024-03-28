# Arielle's DCC Training
## Moving files to/from DCC
### `scp` command to move files between computer/cluster
Use `scp` to move a single file from your local computer to the DCC (push). The general syntax is:
```sh
scp <localpath.file> ayk12@dcc-login.oit.duke.edu:<dccpath>
```
For example, to move `README.md` from your local computer under your `dcc_training` directory in the DCC:
```sh
scp README.md ayk12@dcc-login.oit.duke.edu:/hpc/group/bio1/arielle/dcc_training
```
Note: you must be on the local computer you are moving the file from/to; **not on the DCC.**

You can also use the `scp` command to move a directory from the cluster to your local computer (pull). The general syntax is:
```sh
scp ayk12@dcc-login.oit.duke.edu:<dccpath.filename> <localpath>
```
For example, to move `data` from your DCC directory under your `dcc_training` in your local computer:
```sh
scp -r ayk12@dcc-login.oit.duke.edu:/hpc/group/bio1/arielle/dcc_training/data .
```
Note: Remember to add the `-r` flag when working with directories, the `.` also signifies the directory you are in.
### Set up `Conda`
Use `conda create` command create an environment. The general syntax is:
```sh
conda create -n env_name
```
Note: -n flag specifies the name of the environment that you want to create.
For example, to create a new environment named `dcc_training`:
```sh
conda create -n dcc_training
```
Use `conda activate` to use the applications in your environment. The general syntax is:
```sh
conda activate env_name
```
For example, to activate the `dcc_training` environment:
```sh
conda activate dcc_training
```
Use `conda list --name` command to list installed packages. The general syntax is:
```sh
conda list --name env_name
```
For example, to list installed packages under the ```dcc_training``` environment:
```sh
conda list --name dcc_training
```
### Install `Mamba` (in the non-recommended way)
The command to install `mamba` with an existing `conda` install is:
```sh
conda install -n base --override-channels -c conda-forge mamba 'python_abi=*=*cp*'
```
Note: installing `mamba` into any other environment than base is not supported.

Check if `mamba` has been installed:

```sh
mamba -h
```
Note: this will pull up a help file if `mamba` has been successfully installed.
### Install `NanoPlot`
To install `nanoplot`, use this command:
```sh
mamba create -n nanoplot -c bioconda nanoplot
```
Note: the`-n` flag creates a new environment named nanoplot, `-c` flag tells `mamba` to look for `nanoplot` in a channel named `bioconda`.

Check if `nanoplot` has been installed:

```sh
NanoPlot -h
```

### Run `cat_reads.sh`
Use `sbatch` to run a script in batch mode:
```sh
sbatch <path.file>
```

`cat_reads.sh` is a script to merge the reads from each pool into a single file.
To run `cat_reads.sh`:
```sh
sbatch scripts/environmental_sequencing/ont_trial/cat_reads.sh
```
Note: make sure your directories match those of the script.

Check if your job is running:
```sh
sacct -j <jobID>
```
### Run `nanoplot_qc.sh`
`nanoplot_qc.sh` is a script to run a QC (quality control) report for each pool.
To run `nanoplot_qc.sh`:
```sh
sbatch scripts/environmental_sequencing/ont_trial/nanoplot_qc.sh
```
Note: if there are errors, check the output file and versions of `NanoPlot`:
```sh
Nanoplot -v
```
To move the `analyses/environmental_sequencing` directory from the DCC to your local computer:
First, make a new directory with the same name on your local computer:
```sh
mkdir analyses
```
Next, use `rsync` to move the directory `environmental_sequencing` onto your local computer:
``` sh
rsync -av ayk12@dcc-login.oit.duke.edu:/hpc/group/bio1/arielle/dcc_training/analyses/environmental_sequencing analyses
```
Note: open up the html files using file explorer to check QC report.
### Install `Demultiplex`
To install `demultiplex`, use this code:
```sh
mamba create -n demultiplex python
mamba activate demultiplex
pip install demultiplex
```
### Install `Cutadapt`
To install `cutadapt`, use this command:
```sh
mamba create -n cutadapt -c bioconda -c defaults -c conda-forge cutadapt=4.5
```
Note: `cutadapt` finds and removes unwanted sequences from the reads.
### Install `Kraken2`
To install `kraken2`, use this code:
```sh
mamba create -n kraken2 -c conda-forge -c bioconda kraken2 krakentools bracken
```
Note: `kraken` is a program for k-mer based taxonomic assignation of reads.
To create the path to where you want the `Greengenes` 16S database:
```sh
greengenes_db_path=/hpc/group/bio1/arielle/dcc_training/kraken2/greengenes/greengenes
```
Note: use `echo ${variablename}` to check what the variable stores.
To build the 16S database:
```sh
kraken2-build --db /hpc/group/bio1/arielle/dcc_training/kraken2/greengenes/greengenes --special greengenes
bracken-build -d /hpc/group/bio1/arielle/dcc_training/kraken2/greengenes/greengenes -t 8 -k 35 -l 1500
```
### Create `RStudio` project
To create a new `RStudio` project under `dcc_training`, create a new project in the `dcc_training` directory.
To ignore `RStudio` project file and history file, add to `.gitignore`.

### Run `sort_barcodes.R`
`sort_barcodes.R` is a script to prepare the barcode files for demultiplexing the ONT reads.
```R
Rscript scripts/environmental_sequencing/ont_trial/sort_barcodes.R
```
Note: ran this interactively in `RStudio`; transferred output to the DCC.

### Run `demultiplex_raw.sh`
`demultiplex_raw.sh` is a script to search for forward and reverse primers in each pool.
To run `demultiplex_raw.sh`:
```sh
sbatch scripts/environmental_sequencing/ont_trial/demultiplex_raw.sh
```
Note: had to install `python` version 3.9 to successfully run demultiplex
To concatenate the reads from the forward and reverse searches per sample:
```sh
for sample in $(cat misc_files/environmental_sequencing/ont_trial/pool1_samples.txt) ; do
 cat analyses/environmental_sequencing/ont_trial/demultiplex/reads/*${sample}_f.fastq \
  analyses/environmental_sequencing/ont_trial/demultiplex/reads/*${sample}_r.fastq > \
  analyses/environmental_sequencing/ont_trial/demultiplex/reads/${sample}_barcoded.fastq
done
for sample in $(cat misc_files/environmental_sequencing/ont_trial/pool2_samples.txt) ; do
 cat analyses/environmental_sequencing/ont_trial/demultiplex/reads/*${sample}_f.fastq \
  analyses/environmental_sequencing/ont_trial/demultiplex/reads/*${sample}_r.fastq > \
  analyses/environmental_sequencing/ont_trial/demultiplex/reads/${sample}_barcoded.fastq
done
```

###

