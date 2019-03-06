# J.U.S.T. - J.U.S.T. Useful Simple Tasking

|Linux|Windows|macos|
|--|--|--|
|[![CircleCI](https://circleci.com/gh/VisionSystemsInc/just.svg?style=shield)](https://circleci.com/gh/VisionSystemsInc/just)|[![Build status](https://ci.appveyor.com/api/projects/status/qapo0xmd67xskhm9/branch/master?svg=true)](https://ci.appveyor.com/project/andyneff/just/branch/master)|[![Build Status](https://travis-ci.org/VisionSystemsInc/just.svg?branch=master)](https://travis-ci.org/VisionSystemsInc/just)|


`just`, and its associated Justfile, is a harness written in bash designed to
make developing/running code easier.

- `just` is a collection of scripts created that easily run any number of "targets". Imagine a directory of scripts; this directory will be replaced by a single `Justfile` similar to a Makefile (minus dependencies and timestamps), but in the language of bash instead of make.
- There is an emphasis on features that assist in running docker-compose to handle corner cases that can't be solved blindly in the sandbox provided by docker. E.g.:
  - matching host user and group ids
  - using nfs mounts with squash root.
- There are two ways to use `just`
  - The easiest way to interface with `just` is to add vsi_common as a submodule to your project. This exposes all the internals for code development
  - You can also download the `just` executable in the Releases section, and put the executable in your system path.
- To get `juste` (The executable version of `just`)
   1. Download the latest just from the [release page](https://github.com/VisionSystemsInc/just/releases)
   2. Put the just exectuable in your path and add execute permissions

   - Example (you will need to update version number):

    ```
    cd /usr/local/bin
    sudo curl -LO https://github.com/VisionSystemsInc/just/releases/download/0.0.12/juste
    chmod 755 /usr/local/bin/juste
    ```

    When using `juste`, replace any `just` command in the documentation with `juste`

- To run the new just wizard to add `just` to your project, `cd` into your project directory and run:

    ```
    just --new
    ```

## System Requirements

- Linux (bash with partial support for zsh)
- macOS (native bash 3.2)
- Windows 10 (using git MINGW64 included in git)
  - Handles tty in Windows by using powershell

## just Basics

- `just --new` - setup script to create a new just project
- `source setup.env` - activate a `just` project
- `just` does not have to be run from the root of the source directory; like `git`, it will search parent directories for the Justfile
- `just help` lists the available targets in the project
- `just` supports tab completion for target and subtarget suggestions
- Plugins available with common targets already set up

## just Project organization
- Justfile - like a Makefile for just
  - Consists of a minimal number of lines of `just` code, and a large case statement listing target and subtarget names
- setup.env - activate the `just` project
- wrap - run a `just` target without activating the `just` project
  - Run interactively, with a custom PS1 string
- _projectname_.env - a bash configuration file stores all of the environment variables used to customize the entire project
  - User-configurable pre- and post-environment files can be used to customize the environment without committing these changes to repo
- .justplugins - lists plugins that are enabled for the project

## just Internals

- Identifies targets and subtargets from the Justfile and exposes these for `bash` tab completion
  - Run a chain of multiple targets in one command
    - Support for pseudo-argument separator variable arguments
- Generates help based off simple comment strings in the Justfile
  - Can generate help for a wild card target using an array

### just Plugins

- Supports additional help (JUST_HELP_FILES), targets (JUST_DEFAULTIFY_FUNCTIONS), and tab completion
- docker plugin
    - `build recipes` - prep all recipes locally; useful for multi-stage builds
    - `log` - keep docker-compose log running, even if all containers stop temporarily
- robodoc plugin
    - Make building robodoc documentation easy
- git plugin
    - `git make-submodules-relative` - convert submodule paths from absolute (default on older versions of `git` and [accidentally](http://git.661346.n2.nabble.com/Submodule-s-git-file-contains-absolute-path-when-created-using-git-clone-recursive-td7655372.html) v2.7 and v2.8) to relative paths.
    - `git submodule-update` - a safe version of `git submodule update` which is careful to only update submodules that would not result in the loss (de-referencing) of local changes.

### just's Docker features
- `just --dryrun/-n` - prints out the intervening docker/compose commands, rather than running them
- `Docker` wrapper to automatically add arguments to docker commands
- `Docker-compose` wrapper to automatically add arguments to docker-compose commands
    - Automatically add `--rm` flag so that containers aren't left behind
    - Pre-create a non-existing directory before docker does, so it is not owned by root
    - Adding docker-compose subcommand specific arguments
- `Just-docker-compose` wrapper that creates an override docker-compose yaml file on the fly to assist in setting up the container
    - Wraps `Docker-compose`
    - Swapping environment variables names. `${PREFIX}_*` and `${PREFIX}_*_DOCKER` become `${PREFIX}_*_HOST` and `${PREFIX}_*` in the container, respectively. This makes running the same script in and out of the container a lot easier
      - Can keep the `${PREFIX}_*_DOCKER` version, if you want.
    - `${PREFIX}_.*_HOST` names and values are copied exactly as is. This makes sure the variable has the exact same value in the container as on the host, rather than evaluating it inside the container where the result may be different
    - Dynamically add additional volumes based off of env vars (`${PREFIX}_VOLUMES`, `${PREFIX}_${SERVICE_NAME}_VOLUMES`, `${PREFIX}_VOLUME_{NUMBER}`, and `${PREFIX}_${SERVICE_NAME}_VOLUME_{NUMBER}`)
      - Special processing for volumes with a source on an NFS filesystem.
        - The NFS root directory is mounted into the container under `${MOUNT_PREFIX}` and the destination is symlinked to the correct location in the entrypoint
      - Solves squash root issue
    - Container segregation based on project name and username
      - Creates a custom project name so that multiple users on the same machine can start their own containers based on the same image without interfering
    - Auto determine docker-compose version
- A docker entrypoint to ease some of the more complicated features of `Docker-compose`/`Just-docker-compose`
    - Create a user with the same UIDs, GIDs, name, home dir, etc... as the host
    - `Just-docker-compose` only: Avoids permission issues when creating files in a volume and facilitates running GUIs
    - `Just-docker-compose` only: Set up symlinks to the NFS volumes
    - `Just-docker-compose` only: Replaces environment variables containing `^//` and `://` with single `/` versions. This is handle the Git for Windows workarounds that require `//` to prevent path translation. On rare occations, the `//` cause problem for software inside the docker and this feature corrects this
      - The variable `JUST_NO_PATH_CONV` can be set to a regex pattern for variable names that are not to have the correction applied
- Designed to support both the traditional "run and discard" approach to dockers, and long running interactive development containers.
- `DOCKER`, `DOCKER_COMPOSE`, `NVIDIA_DOCKER` environment variables for specifying the docker executables
- docker "recipes"
  - Frequently used snippets of Dockerfile code, which can be referenced with multi-staged docker builds

## Alpine support

Alpine support is experimental and buggy, to say the least. You at least need to have `bash` installed in order for just to work in alpine. You currently requires `ncurses` to be installed for some of the more advanced features

## Cygwin support

`just` and `juste` do not currently work in cygwin, as the cygwin requires different line endings than git for windows, and this is not compatible with the current `.gitattributes` and the way `makeself` is called. [Further development would be needed to add cygwin support](https://stackoverflow.com/q/37805181/4166604).

## Compiling juste

1. Setup environment: `. setup.env`
1. Build the docker image: `just build`
2. Compile `juste`: `just compile make`
3. A new `juste` is in: `./dist/juste`
4. Run tests: `just test`
