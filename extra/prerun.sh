#!/usr/bin/env bash

set -e
set -o pipefail

# main
# ===============================================

function main {
  topic 'Datadog Prerun:'
  set_variables
  echo "Datadog config path: ${DATADOG_CONF}" | indent
  set_tags
  modify_conifg
}

# ===============================================

function set_variables {
  if [ -z $DATADOG_CONF ]; then
    APT_DIR="$HOME/.apt"
    DD_CONF_DIR="$APT_DIR/etc/datadog-agent"
    DATADOG_CONF="$DD_CONF_DIR/datadog.yaml"
  fi
  YAML_INDENT='  '
  if [[ -z $AL_SERVICE ]]; then
    AL_SERVICE="unknown"
  fi
  if [[ -z $AL_PROC_TYPE ]] && [[ -n $DYNO ]]; then
    AL_PROC_TYPE=${DYNO%%.*}
  fi
  if [[ -z $AL_PROC_TYPE ]]; then
    AL_PROC_TYPE="unknown"
  fi
  if [[ -z $AL_PROC_SUBTYPE ]]; then
    AL_PROC_SUBTYPE="unknown"
  fi
}

function set_tags {
  TAGS="${YAML_INDENT}- al_service:$AL_SERVICE\n${YAML_INDENT}- al_proc_type:$AL_PROC_TYPE\n${YAML_INDENT}- al_proc_subtype:$AL_PROC_SUBTYPE"
  echo "Extra tags are: \"${TAGS}\"" | indent
}

function modify_conifg {
  case $(uname) in
    Darwin) SED_PROG="gsed";;
    *)      SED_PROG="sed";;
  esac

  # The following is based on Datadog's buildpack.
  # See https://github.com/DataDog/heroku-buildpack-datadog/blob/a9efed3f683f906e0fb62b3650f3f2214006075e/extra/datadog.sh#L58-L62
  $SED_PROG -i "s/^\(## @param tags\)/$TAGS\n\1/" $DATADOG_CONF
}

# utils
# ===============================================

function topic {
  echo "--> $*"
}

function indent {
  c='s/^/      /'
  case $(uname) in
    Darwin) sed -l "$c";;
    *)      sed -u "$c";;
  esac
}

# ===============================================

main