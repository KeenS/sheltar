# SHELTAR
A tarball based incremental backup tool written in B shell script.

## FEATURES

* Tarball based
* Easy to backup
* Easy to extract all/specific files
* Portable: written in B shell script
* Default to xz compress
* Lightweight and ready to use

## WHEN TO USE
In summary, use sheltar when you want to
* back up files to be extracted other platform
* migrate data across boxes
* synchronize files across boxes continuously
.


You may wonder "My OS(platform) has awsome backup tools. Why need another?"
Yes. I know and I'm using them too. However they tend to have their original
format which is not portable to another tools and they themselves aren't portable.
Then is your backup available when you lost your machine? Are you able to recover files
from a machine other than original machine? If you're afraid not, use Sheltar

Another situation is when you migrate (or synchronize) data across boxes.
I admit rsync is one option to do it and you may want to use it. Suppose your network is
unstable or slow. You'll catch up with migrating data via USB memory. Then, how?
Tarball is a platform dependent format
but the options of `tar` commands differ from platform to platform. Then use sheltar
or bother to consult `man` many times.


## USAGE


### Backup
#### STEP1
Prepare backup list and backup dir

```sh
$ ls *.sh > backup_list.txt
$ mkdir backup_dir
```

#### STEP2
Do it

```sh
$ path/to/sheltar backup backup_dir backup_list.txt
```

That's all

### Incremental Backup
The same as backing up

```sh
$ path/to/sheltar backup backup_dir backup_list.txt
```

### Restore

```sh
$ path/to/sheltar extract backup_dir
```

### Extract specified files

```sh
$ path/to/sheltar extract backup_dir file1 file2 ...
```

## LICENSE
BSD.
