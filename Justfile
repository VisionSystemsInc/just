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
        if [ "${VSI_OS}" == "windows" ]; then
          Docker-compose build
        else
          Docker-compose build linux wine musl
        fi
      fi
      ;;
    build_darling) # Build darling environment
      (
        # darling uses a very old version of openssl (instead of libcrypto,
        # which is the library macOS uses), which prevents pip from establishing
        # a secure connection. so just download these packages myself
        mkdir -p build/macos
        pushd build/macos
        curl -LO https://files.pythonhosted.org/packages/3c/86/909a8c35c5471919b3854c01f43843d9b5aed0e9948b63e560010f7f3429/PyInstaller-3.3.1.tar.gz
        curl -LO https://files.pythonhosted.org/packages/ff/f4/385715ccc461885f3cedf57a41ae3c12b5fec3f35cce4c8706b1a112a133/setuptools-40.0.0-py2.py3-none-any.whl
        curl -LO https://files.pythonhosted.org/packages/7e/9b/f99171190f04cd23768547dd34533b4016bd582842f53cd9fe9585a74c74/pefile-2017.11.5.tar.gz
        curl -LO https://files.pythonhosted.org/packages/fd/89/58e160e4c3a010dd85dab1a43d20d4728be759fbffc1fc78356b344ffe98/macholib-1.9-py2.py3-none-any.whl
        curl -LO https://files.pythonhosted.org/packages/c8/a1/bb0ab17df7e6cbc6d1555dd1c6fdaa09e90842f0f683507042b9dae83e2d/dis3-0.1.2.tar.gz
        curl -LO https://files.pythonhosted.org/packages/00/2b/8d082ddfed935f3608cc61140df6dcbf0edea1bc3ab52fb6c29ae3e81e85/future-0.16.0.tar.gz
        curl -LO https://files.pythonhosted.org/packages/fe/fd/f63226be4aeebcac65d5f7e882bd00c8465ce883c1a4d16b18bd4ae9086e/altgraph-0.15-py2.py3-none-any.whl

        unzip -o altgraph-*.whl
        unzip -o macholib-*.whl
        unzip -o setuptools-*.whl

        tar xvf dis3-*.tar.gz
        cp -r dis3-*/dis3.py dis3-*/dis3.egg-info ./
        rm -r dis3-*/

        tar xvf future-*.tar.gz
        cp -r future-*/src/* ./
        rm -r future-*/ __init__.py*

        tar xvf pefile-*.tar.gz
        cp -r pefile-*/{pe*.py,ordlookup,pefile.egg-info} ./
        rm -r pefile-*/

        tar xvf PyInstaller-*.tar.gz
        cp -r PyInstaller-*/PyInstaller* ./
        rm -r PyInstaller-*/

        rm *.whl *.tar.gz

        . "${VSI_COMMON_DIR}/linux/uwecho.bsh"

        popd
        uwecho '#!/usr/bin/env python
                import sys, os
                sys.path.append(os.path.dirname(__file__))
                # EASY-INSTALL-ENTRY-SCRIPT: "PyInstaller==3.3.1","console_scripts","pyinstaller"
                __requires__ = "PyInstaller==3.3.1"
                import re
                import sys
                from pkg_resources import load_entry_point

                if __name__ == "__main__":
                    sys.argv[0] = re.sub(r"(-script\.pyw?|\.exe)?$", "", sys.argv[0])
                    sys.exit(
                        load_entry_point("PyInstaller==3.3.1", "console_scripts", "pyinstaller")()
                    )' > build/macos/pyinstaller
        chmod 755 build/macos/pyinstaller

      )
      ;;
    run_linux) # Run linux
      Just-docker-compose run linux ${@+"${@}"}
      extra_args+=$#
      ;;
    run_windows) # Run linux
      Just-docker-compose run windows ${@+"${@}"}
      extra_args+=$#
      ;;
    run_wine) # Run wine in console
      Just-docker-compose run wine ${@+"${@}"}
      extra_args+=$#
      ;;
    run_wine-gui) # Run wine with GUI console
      Just-docker-compose run wine_gui ${@+"${@}"} &
      extra_args+=$#
      ;;
    run_musl) # Compile the linux musl binary
      Just-docker-compose run musl ${@+"${@}"}
      extra_args+=$#
      ;;
    debug_wine) # Debug wine
      Just-docker-compose run --entrypoint= wine_gui bash
      ;;

    compile_linux) # Compile the linux binary
      Just-docker-compose run linux
      ;;
    compile_musl) # Compile the linux musl binary
      Just-docker-compose run musl sh -c "
        cd /src;
        pipenv run pyinstaller --workpath=./build/just-musl just.spec"
      ;;
    compile_windows) # Compiles the windows binary
      # pipenv run pyinstaller just.spec
      Just-docker-compose run windows
      ;;
    compile_wine) # Compile the windows binary using wine
      Just-docker-compose run wine wine64 pyinstaller --workpath build/wine just.spec
      ;;
    compile_macos) # Compiles the macos binary
      pipenv run pyinstaller just.spec
      ;;
    compile_darling) # Compiles the macos binary using darling
      darling shell ./build/macos/pyinstaller --workpath ./build/macos just.spec
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
      (justify clean all)
      ;;
    clean) # Remove all binary artifacts
      if [ -x "${JUST_CWD}/build" ]; then
        rm -r "${JUST_CWD}/build"
      fi
      if [ -x "${JUST_CWD}/dist" ]; then
        rm -r "${JUST_CWD}/dist"
      fi

      (justify clean all)
      ;;
    clean_all) # Delete all local volumes
      (justify clean venv wine)
      ;;
    clean_wine) # Delete wine home directory
      if docker volume inspect "${COMPOSE_PROJECT_NAME}_wine_home" &> /dev/null; then
        Docker volume rm "${COMPOSE_PROJECT_NAME}_wine_home"
      else
        echo "${COMPOSE_PROJECT_NAME}_wine_home already removed"
      fi
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
    upload_release) # Upload a new release to github - $1 - release name
      ${DRYRUN} hub release create -a "${JUST_CWD}/dist/just-Darwin-x86_64" \
                         -a "${JUST_CWD}/dist/just-Linux-x86_64" \
                         -a "${JUST_CWD}/dist/just-Windows-x86_64.exe" \
                         "${1}"
      extra_args+=1
      ;;
    *)
      defaultify "${just_arg}" ${@+"${@}"}
      ;;
  esac
}

if ! command -v justify &> /dev/null; then caseify ${@+"${@}"};fi

