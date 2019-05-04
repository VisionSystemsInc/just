#!/usr/bin/env false bash

function caseify()
{
  local cmd="${1}"
  shift 1
  case "${cmd}" in
    makeself)
      cd /src
      mkdir -p /src/dist
      /makeself/makeself.sh --tar-extra "--exclude=.git --exclude=docs ../.juste_wrapper" --noprogress --nomd5 --nocrc --nox11 --keep-umask --header /makeself/makeself-header_just.sh vsi_common/ /src/dist/juste juste_label ./.juste_wrapper
      ;;
    *)
      exec "${@}"
      ;;
  esac
}