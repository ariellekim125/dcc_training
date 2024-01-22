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
Note: you must be on the local computer you are moving the file from/to; **not from the DCC.**

You can also use the `scp` command to move a directory from the cluster to your local computer (pull). The general syntax is:
```sh
scp ayk12@dcc-login.oit.duke.edu:<dccpath.filename> <localpath>
```
For example, to move `data` from your DCC directory under your `dcc_training` in your local computer:
```sh
scp -r ayk12@dcc-login.oit.duke.edu:/hpc/group/bio1/arielle/dcc_training/data .
```
Note: Remember to add the `-r` flag when working with directories, the `.` also signifies the directory you are in.