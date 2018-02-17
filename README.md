# J.U.S.T. - J.U.S.T. Useful Simple Tasking

`just`, and its associated Justfile, is a harness written in bash designed to make developing/running code easier.

## System Requirements

- Linux (bash with partial support for zsh)
- macOS (native bash 3.2)
- Windows 10 (using git MINGW64)
  - Handles tty in Windows

## just Basics

- `./new_just` - setup script to create a new just project
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
  - Run multiple targets at once
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
    - Dynamically add additional volumes based off of env vars (`${PREFIX}_${SERVICE_NAME}_VOLUMES`)
      - Special processing for volumes with a source on an NFS filesystem.
        - The NFS root directory is mounted into the container under `${MOUNT_PREFIX}` and the destination is symlinked to the correct location in the entrypoint
      - Solves squash root issue
    - Container segregation based on project name and username
      - Creates a custom project name so that multiple users on the same machine can start their own containers based on the same image without interfering
    - Auto determine docker-compose version
- A docker entrypoint to ease some of the more complicated features of `Docker-compose`/`Just-docker-compose`
    - Create a user with the same UIDs, GIDs, name, home dir, etc... as the host
      - Avoids permission issues when creating files in a volume and facilitates running GUIs
    - Set up symlinks to the NFS volumes
- Designed to support both the traditional "run and discard" approach to dockers, and long running interactive development containers.
- `DOCKER`, `DOCKER_COMPOSE`, `NVIDIA_DOCKER` environment variables for specifying the docker executables
- docker "recipes"
  - Frequently used snippets of Dockerfile code, which can be referenced with multi-staged docker builds

