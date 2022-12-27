[![npm version](https://img.shields.io/npm/v/shall.svg)](https://npmjs.com/package/shall) [![license](https://img.shields.io/npm/l/shall.svg)](https://github.com/mklement0/shall/blob/master/LICENSE.md)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Contents**

- [shall &mdash; introduction](#shall-&mdash-introduction)
- [Examples](#examples)
- [Installation](#installation)
  - [Installation from the npm registry](#installation-from-the-npm-registry)
  - [Manual installation](#manual-installation)
- [Usage](#usage)
- [License](#license)
  - [Acknowledgements](#acknowledgements)
  - [npm dependencies](#npm-dependencies)
- [Changelog](#changelog)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# shall &mdash; introduction

`shall` is a Unix CLI and REPL for invoking shell scripts or commands with
multiple POSIX-like shells for portability testing.

**`shall`** (for ***sh***ell with ***all*** (POSIX-like) shells) offers a
convenient way of running a given shell script or shell command with a default
set or specifiable set of POSIX-like shells, so as to facilitate testing of
portable (POSIX-compliant, cross-shell) shell code.

By default, the following shells are targeted, if installed: **sh, dash, bash, zsh, ksh**

Additionally, you can use `shall`:

* as a REPL, with `-i`.
* in a script's shebang line.

Each shell's execution is automatically timed to allow performance comparisons.

The syntax is modeled on that of the underlying shells.

See the examples below, concise [usage information](#usage) further below,
or read the [manual](doc/shall.md).

# Examples

```sh

# Echo the name of each executing shell; sample output included.
$ shall -c 'echo "Hello from $0."'
```
![Hello example - sample output](doc/images/example-output-hello.png)


```sh

# Pass a script to all shells via stdin, plus an argument on the command line.
echo 'echo "Passed to $0: $1"' | shall -s one

# Execute script 'foo-script' with argument 'bar' in all shells.
shall foo-script bar

# Print the type of the 'which' command in Bash and Zsh.
shall -w bash,zsh -c 'type which'

# Enter a REPL that evaluates commands in both Bash and Dash.
SHELLS=bash,dash shall -i

```

# Installation

**Supported platforms**

* When installing from the [**npm registry**](https://www.npmjs.com): all **Unix-like** platforms supported by [Node.js](http://nodejs.org/) with [**Bash**](http://www.gnu.org/software/bash/) installed.
* When installing **manually**: any **Unix-like** platform with **Bash** installed.

## Installation from the npm registry

<sup>Note: Even if you don't use Node.js, its package manager, `npm`, works across platforms and is easy to install; try [`curl -L http://git.io/n-install | bash`](https://github.com/mklement0/n-install)</sup>

With [Node.js](http://nodejs.org/) or [io.js](https://iojs.org/) installed, install [the package](https://www.npmjs.com/package/shall) as follows:

    [sudo] npm install shall -g

**Note**:

* Whether you need `sudo` depends on how you installed Node.js / io.js and whether you've [changed permissions later](https://docs.npmjs.com/getting-started/fixing-npm-permissions); if you get an `EACCES` error, try again with `sudo`.
* The `-g` ensures [_global_ installation](https://docs.npmjs.com/getting-started/installing-npm-packages-globally) and is needed to put `shall` in your system's `$PATH`.

## Manual installation

* Download [the CLI](https://raw.githubusercontent.com/mklement0/shall/stable/bin/shall) as `shall`.
* Make it executable with `chmod +x shall`.
* Move it or symlink it to a folder in your `$PATH`, such as `/usr/local/bin` (OSX) or `/usr/bin` (Linux).

# Usage

Find concise usage information below; for complete documentation, read the [manual online](doc/shall.md), or, once installed, run `man shall` (`shall --man` if installed manually).

<!-- DO NOT EDIT THE FENCED CODE BLOCK and RETAIN THIS COMMENT: The fenced code block below is updated by `make update-readme/release` with CLI usage information. -->

```nohighlight
$ shall --help


Cross-POSIX-compatible-shell testing:

Run a script file:

    shall [-w <shellA>,...] [-q|-Q] [-p <opts>]     <script> [<arg>...]

Execute a command string:

    shall [-w <shellA>,...] [-q|-Q] [-p <opts>]  -c <cmd>    [<arg0> <arg>...]

Execute commands specified via stdin:

    shall [-w <shellA>,...] [-q|-Q] [-p <opts>] [-s           <arg>...]

Start a REPL (run commands interactively):

    shall [-w <shellA>,...]  -i

Default shells targeted are sh, and, if installed, dash, bash, zsh, ksh.  
Override with -w or environment variable SHELLS, using a comma-separated  
list without spaces; e.g., -w bash,ksh,zsh or SHELLS=bash,ksh,zsh.

-q, -Q quiets stdout, stdout + stderr from the script / commands invoked.  
-p passes options through to the target shells.

Standard options: --help, --man, --version, --home
```

<!-- DO NOT EDIT THE NEXT CHAPTER and RETAIN THIS COMMENT: The next chapter is updated by `make update-readme/release` with the contents of 'LICENSE.md'. ALSO, LEAVE AT LEAST 1 BLANK LINE AFTER THIS COMMENT. -->

# License

Copyright (c) 2014-2015 Michael Klement, released under the [MIT license](https://spdx.org/licenses/MIT#licenseText).

## Acknowledgements

This project gratefully depends on the following open-source components, according to the terms of their respective licenses.

[npm](https://www.npmjs.com/) dependencies below have optional suffixes denoting the type of dependency; the absence of a suffix denotes a required run-time dependency: `(D)` denotes a development-time-only dependency, `(O)` an optional dependency, and `(P)` a peer dependency.

<!-- DO NOT EDIT THE NEXT CHAPTER and RETAIN THIS COMMENT: The next chapter is updated by `make update-readme/release` with the dependencies from 'package.json'. ALSO, LEAVE AT LEAST 1 BLANK LINE AFTER THIS COMMENT. -->

## npm dependencies

* [doctoc (D)](https://github.com/thlorenz/doctoc)
* [json (D)](https://github.com/trentm/json)
* [marked-man (D)](https://github.com/kapouer/marked-man#readme)
* [replace (D)](https://github.com/harthur/replace)
* [semver (D)](https://github.com/isaacs/node-semver)
* [urchin (D)](https://git.sdf.org/tlevine/urchin)

<!-- DO NOT EDIT THE NEXT CHAPTER and RETAIN THIS COMMENT: The next chapter is updated by `make update-readme/release` with the contents of 'CHANGELOG.md'. ALSO, LEAVE AT LEAST 1 BLANK LINE AFTER THIS COMMENT. -->

# Changelog

Versioning complies with [semantic versioning (semver)](http://semver.org/).

<!-- NOTE: An entry template is automatically added each time `make version` is called. Fill in changes afterwards. -->

* **[v0.2.8](https://github.com/mklement0/shall/compare/v0.2.7...v0.2.8)** (2015-10-23):
  * [doc] `README.md` examples still contained obsolete `-l` switch.
  * [dev] Improved robustness of internal `rreadlink()` function.

* **[v0.2.7](https://github.com/mklement0/shall/compare/v0.2.6...v0.2.7)** (2015-09-20):
  * [dev] Confusing changelog typos fixed.
  * [dev] Removed post-install command that verifies presence of Bash, because
    `npm` always _prints_ the command during installation, which can be confusing.  

* **[v0.2.6](https://github.com/mklement0/shall/compare/v0.2.5...v0.2.6)** (2015-09-19):
  * [doc] `shall` now has a man page (if manually installed, use `shall --man`);
          `shall -h` now just prints concise usage information.

* **[v0.2.5](https://github.com/mklement0/shall/compare/v0.2.4...v0.2.5)** (2015-09-15):
  * [dev] Makefile improvements; various other behind-the-scenes tweaks.

* **[v0.2.4](https://github.com/mklement0/shall/compare/v0.2.3...v0.2.4)** (2015-07-08):
  * [fix] Pass-through option-arguments with embedded spaces are now handled correctly; process substitution replaced with alternative so as to improve FreeBSD compatibility.
  * [doc] Read-me improved, notably: manual-installation instructions added, TOC added.

* **[v0.2.3](https://github.com/mklement0/shall/compare/v0.2.2...v0.2.3)** (2015-06-26):
  * [doc] Read-me: npm badge changed to [shields.io](http://shields.io); license badge added; typo fixed.
  * [dev] To-do added; Makefile updated.

* **v0.2.2** (2015-05-31):
  * [doc] [npm registry badge](https://badge.fury.io) added

* **v0.2.1** (2015-05-27):
  * [fix] Options passed through with -p are no longer ignored on Linux.
  * [fix] Removed extraneous status output.

* **v0.2.0** (2015-05-24):
  * [new] New -p option allows passing additional options through to the shells invoked; e.g.: -p '-e'
  * [deprecated] -l option for specifying shells to target renamed to -w to avoid confusion with shells' native -l version (login shells); -l will continue to work. 
  * [robustness] Exit codes relating to shall's *own* failures changed to: 126 (incorrect arguments) and 127 (unexpected failure), chosen so as to avoid clashes with exit codes produced during normal operation and termination by signal.

* **v0.1.7** (2015-02-11):
  * [doc] improved description in package.json

* **v0.1.6** (2015-02-11):
  * [fix] When using the default target shells, only those actually installed should be targeted.

* **v0.1.5** (2015-02-11):
  * [install] warning added, if bash not found
  * [dev] bash-presence test improved
  * [dev] Makefile improvements

* **v0.1.4** (2015-02-11):
  * [dev] testing no longer requires the CLI to be in the path
  * [dev] bash-presence test added
  * [dev] Makefile improvements
  * [doc] read-me improvements (examples)

* **v0.1.3** (2015-01-28):
  * [doc] read-me typo corrected
  * [dev] Makefile improvements

* **v0.1.2** (2015-01-27):
  * [fix] -q option no longer masks failures
  * [doc] CLI help and read-me updates
  * [dev] Urchin-based tests added

* **v0.1.1** (2014-12-23):
  * [doc] read-me and CLI help fixes

* **v0.1.0** (2014-12-23):
  * Initial release
