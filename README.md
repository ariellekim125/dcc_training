# Arielle's DCC Training
## Moving files to/from DCC
Use `scp` to move a single file from my computer to the cluster. The general syntax is:
```sh
scp <localpath.file> ayk12@dcc-login.oit.duke.edu:<dccpath>
```
For example, to move `README.md` under my `dcc_training` directory:
```sh
scp README.md ayk12@dcc-login.oit.duke.edu:/hpc/group/bio1/arielle/dcc_training
```