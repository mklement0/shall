	# Since we rely on paths relative to the Makefile location, abort if make isn't being run from there.
$(if $(findstring /,$(MAKEFILE_LIST)),$(error Please only invoke this makefile from the directory it resides in))
	# Run all shell commands with bash.
SHELL := bash
	# Add the local npm packages' bin folder to the PATH, so that `make` can find them even when invoked directly (not via npm).
	# !! Note that this extended path only takes effect in (a) recipe commands that are (b) true shell commands (not optimized away) - when in doubt, simply append ';'
	# !! To also use the extended path in $(shell ...) function calls, use $(shell PATH="$(PATH)" ...),
export PATH := $(PWD)/node_modules/.bin:$(PATH)
	# Sanity check: git repo must exist.
$(if $(shell [[ -d .git ]] && echo ok),,$(error No git repo found in current dir. Please at least initialize one with 'git init'))
	# Sanity check: make sure dev dependencies (and npm) are installed - skip this check only for certain generic targets (':' is the pseudo target used by the `list` target's recipe.)
$(if $(or $(shell [[ '$(MAKECMDGOALS)' =~ list|: ]] && echo ok), $(shell [[ -d ./node_modules/semver ]] && echo 'ok')),,$(error Did you forget to run `npm install` after cloning the repo (Node.js must be installed)? At least one of the required dev dependencies not found))
	# Determine the editor to use for modal editing. Use the same as for git, if configured; otherwise $EDITOR, then fall back to vi (which may be vim).
EDITOR := $(shell git config --global --get core.editor || echo "$${EDITOR:-vi}")

	# Default target (by virtue of being the first non '.'-prefixed target in the file).
.PHONY: _no-target-specified
_no-target-specified:
	$(error Please specify the target to make - `make list` shows targets. Alternatively, use `npm test` to run the default tests; `npm run` shows all commands)

# Lists all targets defined in this makefile.
.PHONY: list
list:
	@$(MAKE) -pRrn -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

.PHONY: test
# To optionally skip tests in the context of target 'release', for instance, invoke with NOTEST=1; e.g.: make release NOTEST=1
# NOTE: The trailing ; is required to have `make` execute the command as a *shell* command and therefore pick up the PATH additions above.
test:
ifeq ($(NOTEST),1)
	@echo Note: Skipping tests, as requested. >&2
else
	@urchin ./test;
endif

# If VER is *not* specified: reports the current version number - both as defined by the latest git tag and by package.json
# If VER *is* specified: sets the version number in source files and package.json; increments from the latest git [version] tag
.PHONY: version
version: _need-clean-ws-or-no-untracked-files
ifndef VER
	@printf 'Current version:\n\tv%s (from package.json)\n\t%s (from git tag)\n' `json -f package.json version` `git describe --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo 'v0.0.0'`
	@printf 'Note:\tTo increment the version number or make a release, run:\n\t\tmake version VER=<new-version>\n\t\tmake release VER=<new-version>\n\twhere <new-version> is either an increment specifier (patch, minor, major,\n\tprepatch, preminor, premajor, prerelease), or an explicit <major>.<minor>.<patch> version number.\n'
else
	 @oldVer=`git tag | xargs semver | tail -n 1 | sed 's/^v//'`; oldVer=$${oldVer:-0.0.0}; \
	  newVer=`echo "$(VER)" | sed 's/^v//'`; \
	  if printf "$$newVer" | grep -q '^[0-9]'; then \
	    semver "$$newVer" >/dev/null || { echo 'Invalid semver version number specified: $(VER)' >&2; exit 2; }; \
	    semver -r "> $$oldVer" "$$newVer" >/dev/null || { echo "Invalid version number specified: $(VER) - must be HIGHER than $$oldVer." >&2; exit 2; } \
	  else \
	    newVer=`semver -i "$$newVer" "$$oldVer"` || { echo 'Invalid version-increment specifier: $(VER)' >&2; exit 2; } \
	  fi; \
	  printf "=== About to BUMP VERSION:\n\t$$oldVer -> **$$newVer**\n===\nProceed (y/N)?: " && read -re response && [[ "$$response" =~ [yY] ]] || { echo 'Aborted.' >&2; exit 2; };  \
	  replace --quiet --recursive --exclude='.git,node_modules,test,Makefile,CHANGELOG.md,README.md' "v$${oldVer//./\\.}" "v$${newVer}" . || exit; \
	  [[ `json -f package.json version` == $$newVer ]] || { npm version $$newVer --no-git-tag-version >/dev/null && printf $$'\e[0;33m%s\e[0m\n' 'package.json' || exit; }; \
	  fgrep -q "v$$newVer" CHANGELOG.md || { { sed -n '1,/^<!--/p' CHANGELOG.md && printf %s $$'\n* **v'"$$newVer"$$'** ('"`date +'%Y-%m-%d'`"$$'):\n  * ???\n' && sed -n '1,/^<!--/d; p' CHANGELOG.md; } > CHANGELOG.tmp.md && mv CHANGELOG.tmp.md CHANGELOG.md; }; \
	  git add --update . || exit; \
	  printf -- "-- Version bumped to v$$newVer in source files and package.json (only just-now updated files were printed above, if any).\n   Describe changes in CHANGELOG.md ('make release' will prompt for it).\n   To update the read-me file, run 'make update-readme' (also happens during 'make release').\n"
endif	

# make release VER=<newVerSpec> [NOTEST=1]
# Increments the version number, runs tests, then commits and tags, pushes to origin, prompts to publish to the npm-registry; NOTEST=1 skips tests.
.PHONY: release
release: _need-ver _need-origin _need-npm-credentials _need-master-branch version test
	@newVer=`json -f package.json version` || exit; \
	 echo '-- Opening changelog...'; \
	 $(EDITOR) CHANGELOG.md; \
	 { fgrep -q "v$$newVer" CHANGELOG.md && ! fgrep -q '???' CHANGELOG.md; } || { echo "ABORTED: No changelog entries provided for new version v$$newVer." >&2; exit 2; }; \
	 commitMsg="v$$newVer"$$'\n'"`sed -n '/\*\*'"v$$newVer"'\*\*/,/^\* /p' CHANGELOG.md | sed '1d;$$d'`"; \
	 $(MAKE) -f $(lastword $(MAKEFILE_LIST)) update-readme || exit; \
	 git add --update . || exit; \
	 echo '-- Committing...'; \
	 [[ -z $$(git status --porcelain || echo no) ]] && echo "-- (Nothing to commit.)" || { git commit -m "$$commitMsg" || exit; echo "-- v$$newVer committed."; }; \
	 git tag -a -m "$$commitMsg" "v$$newVer" || exit; \
	 echo "-- Tag v$$newVer created."; \
	 git push -u origin --tags master || exit; \
	 echo "-- v$$newVer pushed to origin."; \
	 if [[ `json -f package.json private` != 'true' ]]; then \
	 		printf "=== About to PUBLISH TO npm REGISTRY as:\n\t**`json -f package.json name`@$$newVer**\n===\nType 'publish' to proceed; anything else to abort: " && read -er response; \
	 		[[ "$$response" == 'publish' ]] || { echo 'Aborted.' >&2; exit 2; };  \
	 		npm publish || exit; \
	 		echo "-- Published to npm."; \
	 else \
	 		echo "-- (Package marked as private; not publishing to npm registry.)"; \
	 fi; \
	 echo "-- Done."

# Updates README.md as follows:
#  - Replaces the '## Usage' chapter with the command-line help output by this package's CLI, if applicable.
#  - Replaces the '### License' chapter with the contents of LICENSE.md
#  - Replaces the '### npm Dependencies' chapter with the current list of dependencies.
#  - Replaces the '## Changelog' chapter with the contents of CHANGELOG.md
# !! Disabled for now, because the links generated are absolute ones that, when invoked on npmjs.com, take one to *GitHub*
# # - Then uses `doctoc` to insert a TOC at the top.
# @doctoc README.md >/dev/null || { echo "Failed to update read-me TOC." >&2; exit 1; }; \
#  replace --count --quiet '^\*\*Table of Contents\*\*.*$$' '**Contents**' README.md | { fgrep -q ' (1)' || { echo "Failed to update heading of read-me TOC." >&2; exit 1; } }; \
.PHONY: update-readme
update-readme: _update-readme-usage _update-readme-license _update-readme-dependencies _update-readme-changelog
	@echo "-- README.md updated."

# --------- Aux. targets

# If applicable, replaces the usage read-me chapter with the current CLI help output, 
# enclosed in a fenced codeblock and preceded by '$ <cmd>'.
# Replacement is attempted if the project at hand has a (at least one) CLI, as defined in the 'bin' key in package.json.
# is an *object* that has (at least 1) property (rather than containing a string-scalar value that implies the package name as the CLI name).
#  - If 'bin' has *multiple* properties, the *1st* is the one whose usage info is to be used.
#    To change this, modify CLI_HELP_CMD in the shell command below.
#  - The CLI should be invoked with `-h` to retrieve usage information.
#    To change this, edit the value of CLI_HELP_ARGS below.
.PHONY: _update-readme-usage
# The arguments to pass to the CLI to have it output its help.
CLI_HELP_ARGS:= -h
# The exact, full text of the chapter heading to replace in README.md; watch for unintentional trailing whitespace. '#' must be represented as '\#'.
README_HEADING_USAGE := \#\# Usage
_update-readme-usage:
	@read -r cliName cliPath < <(json -f package.json bin | json -Ma key value | head -n 1) || exit 0; \
	 CLI_HELP_CMD=( "$$cliPath" $(CLI_HELP_ARGS) ); \
	 CLI_HELP_CMD_DISPLAY=( "$${CLI_HELP_CMD[@]}" ); CLI_HELP_CMD_DISPLAY[0]="$$cliName"; \
	 newText=$$'\n```\n$$ '"$${CLI_HELP_CMD_DISPLAY[@]}"$$'\n\n'"$$( "$${CLI_HELP_CMD[@]}" )"$$'\n```\n' || { echo "Failed to update read-me chapter: usage: invoking CLI help failed: $${CLI_HELP_CMD[@]}" >&2; exit 1; }; \
	 newText="$${newText//\$$/$$\$$}"; \
	 newText="$${newText//~/\~}"; \
	 replace --count --quiet --multiline=false '(^|\n)($(README_HEADING_USAGE)\n)[\s\S]*?(\n([ \t]*<!-- .*? -->\s*?\n)?#|$$)' '$$1$$2'"$$newText"'$$3' README.md | fgrep -q ' (1)' || { echo "Failed to update read-me chapter: usage." >&2; exit 1; }

#  - Replaces the '## License' chapter with the contents of LICENSE.md
.PHONY: _update-readme-license
_update-readme-license:
	@newText=$$'\n'"$$(< LICENSE.md)"$$'\n'; \
	 newText="$${newText//\$$/$$\$$}"; \
	 replace --count --quiet --multiline=false '(^|\n)(## License\n)[\s\S]*?(\n([ \t]*<!-- .*? -->\s*?\n)?#|$$)' '$$1$$2'"$$newText"'$$3' README.md | fgrep -q ' (1)' || { echo "Failed to update read-me chapter: license." >&2; exit 1; }


#  - Replaces the dependencies chapter with the current list of dependencies.
.PHONY: _update-readme-dependencies
# The exact, full text of the chapter heading to replace in README.md; watch for unintentional trailing whitespace. '#' must be represented as '\#'.
README_HEADING_DEPENDENCIES := \#\#\# npm Dependencies
_update-readme-dependencies:
	@newText=$$'\n'$$( \
	 keys=( dependencies peerDependencies devDependencies  optionalDependencies ); \
	 qualifiers=( ''     '(P)'            '(D)'            '(O)'); \
	 i=0; \
	 for key in "$${keys[@]}"; do \
	 json -f ./package.json $$key | json -ka | { \
	   while read -r pn; do \
	     hp=$$(json -f "./node_modules/$$pn/package.json" homepage); \
	     echo "* [$$pn$${qualifiers[i]:+ $${qualifiers[i]}}]($$hp)"; \
	   done \
	 }; \
	 (( ++i )); \
	 done)$$'\n'; \
	 [[ -n $$newText ]] || { echo "Failed to determine npm dependencies." >&2; exit 1; }; \
	 newText="$${newText//\$$/$$\$$}"; \
	 replace --count --quiet --multiline=false '(^|\n)($(README_HEADING_DEPENDENCIES)\n)[\s\S]*?(\n([ \t]*<!-- .*? -->\s*?\n)?#|$$)' '$$1$$2'"$$newText"'$$3' README.md | fgrep -q ' (1)' || { echo "Failed to update read-me chapter: npm dependencies." >&2; exit 1; }

#  - Replaces the changelog chapter with the contents of CHANGELOG.md
.PHONY: _update-readme-changelog
# The exact, full text of the chapter heading to replace in README.md; watch for unintentional trailing whitespace. '#' must be represented as '\#'.
README_HEADING_CHANGELOG := \#\# Changelog
_update-readme-changelog:
	@newText=$$'\n'"$$(tail -n +3 CHANGELOG.md)"$$'\n'; \
	 newText="$${newText//\$$/$$\$$}"; \
	 replace --count --quiet --multiline=false '(^|\n)($(README_HEADING_CHANGELOG)\n)[\s\S]*?(\n([ \t]*<!-- .*? -->\s*?\n)?#|$$)' '$$1$$2'"$$newText"'$$3' README.md | fgrep -q ' (1)' || { echo "Failed to update read-me chapter: changelog." >&2; exit 1; }


.PHONY: _need-master-branch
_need-master-branch:
	@[[ `git symbolic-ref --short HEAD` == 'master' ]] || { echo 'Please release from the master branch only.' >&2; exit 2; }

# Ensures that the git workspace is clean or contains no untracked files - any tracked files are implicitly added to the index.
.PHONY: _need-clean-ws-or-no-untracked-files
_need-clean-ws-or-no-untracked-files:
ifdef VER
	@git add --update . || exit
	@[[ -z $$(git status --porcelain | awk -F'\0' '$$2 != " " { print $$2 }') ]] || { echo "Workspace must either be clean or contain no untracked files; please add untracked files to the index first or delete them." >&2; exit 2; }
endif

.PHONY: _need-ver
_need-ver:
ifndef VER
	@echo "ERROR: Variable 'VER' must be defined. Use 'make version' for more information and to see the current version number." >&2; exit 1
endif

# Ensure that a remote git repo named 'origin' is defined.
.PHONY: _need-origin
_need-origin:
	@git remote | fgrep -qx 'origin' || { echo "ERROR: Remote git repo 'origin' must be defined." >&2; exit 2; }

# Unless the package is marked private, ensure that npm credentials have been saved.
.PHONY: _need-npm-credentials
_need-npm-credentials:
	@[[ `json -f package.json private` == 'true' ]] && exit 0; \
	 egrep -q '^//registry.npmjs.org/:_password' ~/.npmrc || { echo "ERROR: npm-registry credentials not found. Please log in with 'npm login' in order to enable publishing." >&2; exit 2; }; \

