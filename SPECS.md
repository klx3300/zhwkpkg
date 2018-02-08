## Specifications of zhwkpkg packages & servers



### zhwkpkg Installation Folder Structure

```text
+- installed-dir/
|-- scripts...
|-- serveraddr  #(configuration file)
|-- installpath #(configuration file)
```

`serveraddr` & `installpath` is a plain-text file include only one line.

`serveraddr` specified where should the manager to search for packages online. It will be described in detail later.

`installpath` is where the manager to search for already installed packages and install new packages into. It must point to a existing directory, such as `/home/hello/opt`.

There will not be any other files stored permanently in any other directories. That's saying, if you  have to copy the installed folder to other location, just simply set the `installpath` to the correct position, and this manager will work flawlessly.

(modulefiles need to be rebuilt since the path has changed. have builtin commands to do this, dont worry!)



### Package Format

A `package` is simply a tarball compressed using `bzip2` which contains the following content:

- Note: The tarball itself contains the top level folder. It will works as the package name.

```text
+- package-name/
| -- package contents...
| -- VERSION # version number.
| -- MODULEFILE # Environment Module file. will be copied to installpath/modulefiles/package-name/packagename-packageversion
| -- PREPARE # a bash script. will be executed before installation begins.
= -- CLEANUP # a bash script. will be executed after installation completes.
```

format specifications for each file:

`VERSION` should contains only one line, which is the version number of this package. this value will not be used for numerical comparation, since this manager allow multiple versions of one package.

`MODULEFILE` is the modulefile of this package, for easier switching between different versions packages. During the installation, it will be copied to `installpath/modulefiles/package-name` folder, as commented. The copy destination name is `pkgname-pkgversion`, and for better and easier packaging, the manager will do some replacing work here, that is: after the copy, the manager will alter every `#%INSTALL_FOLDER%#` string in the modulefile to the absolute path of installation folder *without the terminating slash, for clarification*. No escapes and exceptions here, anything matches will be replaced. BE AWARE.

`PREPARE` is a bash script that will be executed before the installation. the first parameter is the temporary folder path, and the second parameter is estimated installation folder.

`CLEANUP` is a bash script that will be executed after the installation. the first parameter is the installed folder path, for you to do some cleanups.

> Behaviors attempt to access root in these script files is *prohibited*. After all, you have to assume that the user did not have root access.

> Any non-zero return values of these scripts will cause the installation process be terminated immediately after clean-up the contents generated.

Dependencies and conflicts are currently not supported. Although I have planned to implementing them, there are better ways to achieve these goals.

> A better way: pack all your runtime dependencies into the package. Also convenient for environment modules loading, except little overhead in disk space usage.
>
> An even better way: check conflicts in environment modules modulefile. so instead of totally selects between two packages, the user can choose to activate this or that. MUCH NICER unless you aren't familiar with environment modules.



### Installation Process

This manager will go through the following steps when attempting to install a package:

1. Extract the package into some temp folder. usually `/tmp/zhwkpkg`. you may change that using environment variable `ZHWKPKG_TEMP_FOLDER`(option to not implement in some version).
2. Check if there is existing package with the same name and version number. If there is, a messeage will be printed and the process will terminated.
3. Execute the `PREPARE` script.
4. Copy ALL contents of the temporary folder into the `installpath` specified folder. the new folder is named as `pkgname-pkgversion`.
5. Copy the modulefile and do the string replace work.
6. Execute the `CLEANUP` script.
7. And that's done.



### Uninstallation Process

It's way too simple even doing this by your hand.

1. `rm` the corresponding modulefile.
2. `rm -rf` the package content folder.



### Package Distribution Server

It's actually a simple HTTP server that satisfying the following requirements:

1. When accessing `<the_url_given_in_serveraddr>/pkglist.lst`, it will return a plain text file that each line is a package name. Naming format doesn't matter, but you'd better keep it clear.
2. When accessing `<the_url_given>/<package_name>.tar.bz2`, it will return the package content.

As mentioned above, the tarball name itself doesn't matter at all. the package name and version installed into the system is defined by the folder name in the tarball and `VERSION` file inside it. But to make it easy-understanding, I recommend you to make the package names in your list be the actual `<package_name>-<package_version>`. *be reasonable*.

### Builtin Commands

`install` install a package *from the package distribution server specified in serveraddr file*.

`remove` uninstall an already installed package.

`deploy` install a package from file. You have to specify the package path.

`rebuild` rebuild all installed packages' modulefile from scratch. (from installation folder)

`package` -- for package authors. given a path to a folder, check whether it satisfy the package specification or not. If satisfied, compress it into a package, place in the current working directory(`pwd`). 

`unpackage` extract the package in place.

`list` list all installed packages and their versions.

`query` list all possible packages and their versions from the distribution server.

`get` download the specified package *from the package distribution server* and place it in the current working directory.

`modulepath` give the path of installed modulefiles. for `bashrc`.