# J.U.S.T. - J.U.S.T. Uncomplicated Simple Tasking

It's like a make file, only simple and written in bash.

## just features

- Supports Windows 10 (using git MINGW64), macos (native bash 3.2) and Linux (bash)
  - Handles tty in windows
- Partial support for zsh.
- `new_just` - setup script to create a new just project
- Justfile - like a Makefile for just. Consists of a minimal number of lines of
`just` code, and a large case statement
- Tab completion for command name suggestions
- Targets and subtarget names
- Plugins with already common targets already setup
- Single bash variable file storing all of the environment variables used to customize the entire project, all from one place.
- Pre and post local environment file to customize the environment for the local computer without committing changes to repo
- Simple `wrap` command
    - Run any one command in the `just` environment without having to use `just`
    - Run interactively, with a custom PS1 string
- Generates help based off a simple comment string.
    - Can generate help for a wild card target using an array.
- Dryrun mode that just prints out many of the commands, rather than running them
- Run multiple targets at once
    - Support for pseudo-argument separator variable arguments

`just` `docker` features
- `Docker` wrapper to automatically add arguments to docker commands
- `Docker-compose` wrapper to automatically add arguments to docker-compose commands
    - Automatically add `--rm` flag so that containers aren't left behind
    - Pre-create a non-existing directory before docker does, so it is not owned by root
    - Adding docker-compose subcommand specific arguments
- `Just-docker-compose` wrapper that create an override docker-compose file on the fly to add features not in docker-compose
    - Everything in `Docker-compose`
    - Dynamically add additional volumes based off of env vars (`${PREFIX}_${SERVICE_NAME}_VOLUMES`)
    - Swapping environment variables names. `${PREFIX}_*` and `${PREFIX}_*_DOCKER` become `${PREFIX}_*_HOST` and `${PREFIX}_*`, respectively. This makes running the same script in and out of the container a lot easier. Can also keep the `${PREFIX}_*_DOCKER` version, if you want.
    - `${PREFIX}_.*_HOST` names and values are copied exactly as is. This simpilar to the swapping feature, this makes sure the variable has the exact same value in the container, rather than evaluating it inside the container where the result may be different
    - Auto determine docker-compose version
    - NFS solution that mounts an nfs root directory in the container to `${MOUNT_PREFIX}` and symlinks the correct locations during the entrypoint. (solves squash root issue)
    - Project name segregation based off of username. This ends up adding the username to the volume name so that multiple users can use their own environment on the same machine without interfering.
- A docker entrypoint to ease some of the more complicated features of `Docker-compose`/`Just-docker-compose`
    - Create a user with the correct UIDs, GIDs, name, home dirs, etc...
    - Set up symlinks to handle the squash root problem
- Designed to support both the traditional "run and throw away" approach to dockers, and long running interactive development containers.
- `DOCKER`, `DOCKER_COMPOSE`, `NVIDIA_DOCKER` names for replacing the docker executables
- docker "recipes" - Snippets of Dockerfile code uses often, centralized in one place.


## just plugins

- Supports addition help (JUST_HELP_FILES), targets (JUST_DEFAULTIFY_FUNCTIONS), and tab completion
- docker plugin
    - build recipes - Prep all recipes locally
    - log - Keep docker compose log running, even if all containers stop temporarily
- robodoc plugin
    - Make building robodoc documentation easy
- git plugin
    - git make-submodules-relative - Convert submodule paths from absolute (default on older versions of git) to relative paths.
    - git submodule-update - A safe version of `git submodule update` that intelligently updates all submodules that would not result in the lost of local changes.
