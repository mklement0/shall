## Changelog

Versioning complies with [semantic versioning (semver)](http://semver.org/).

<!-- NOTE: An entry template is automatically added each time `make version` is called. Fill in changes afterwards. -->

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
