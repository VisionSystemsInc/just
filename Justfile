#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then # If being sourced
  set -euE
fi

source "$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)/wrap"
cd "${JUST_CWD}"

# Plugins
source "${VSI_COMMON_DIR}/linux/docker_functions.bsh"
source "${VSI_COMMON_DIR}/linux/just_docker_functions.bsh"
source "${VSI_COMMON_DIR}/linux/just_git_functions.bsh"

# Main function
function caseify()
{
  local just_arg=$1
  shift 1
  case ${just_arg} in
    build) # Build Docker image
      if [ "$#" -gt "0" ]; then
        Docker-compose "${just_arg}" ${@+"${@}"}
        extra_args+=$#
      else
        (justify build_recipes)
        Docker-compose build
      fi
      ;;
    run_linux) # Run linux
      Just-docker-compose run linux ${@+"${@}"}
      extra_args+=$#
      ;;

    compile_linux) # Compile the linux binary
      Just-docker-compose run -w "${JUST_SOURCE_DIR_DOCKER}" linux pyinstaller just.spec
      ;;
    compile_windows) # Compiles the windows binary
      pipenv run pyinstaller just.spec
      ;;
    compile_macos) # Compiles the macos binary
      pipenv run pyinstaller just.spec
      ;;

    setup) # Run any special command to set up the environment for the first \
      # time after checking out the repo. Usually population of volumes/databases \
      # go here.
      (justify _sync)
      ;;
    sync) # Synchronize the many aspects of the project when new code changes \
          # are applied e.g. after "git checkout"
      (justify _sync)
      # Add any extra steps run when syncing when not installing
      ;;
    _sync)
      Docker-compose down
      (justify git_submodule-update) # For those users who don't remember!
      (justify build)
      (justify clean venv)
      ;;
    clean) # Remove all binary artifacts
      if [ -x "${JUST_CWD}/build" ]; then
        rm -r "${JUST_CWD}/build"
      fi
      if [ -x "${JUST_CWD}/dist" ]; then
        rm -r "${JUST_CWD}/dist"
      fi

      (justify clean venv)
      ;;
    clean_all) # Delete all local volumes
      (justify clean venv)
      ;;
    clean_venv) # Delete the virtual environment volume. The next container \
                # to use this volume will automatically copy the contents from \
                # the image.
      if docker volume inspect "${COMPOSE_PROJECT_NAME}_venv" &> /dev/null; then
        Docker volume rm "${COMPOSE_PROJECT_NAME}_venv"
      else
        echo "${COMPOSE_PROJECT_NAME}_venv already removed"
      fi
      ;;
    *)
      defaultify "${just_arg}" ${@+"${@}"}
      ;;
  esac
}

if ! command -v justify &> /dev/null; then caseify ${@+"${@}"};fi

