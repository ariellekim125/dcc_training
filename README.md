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
### Set up Conda
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