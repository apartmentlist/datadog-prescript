#!/usr/bin/env bash

# main
# ===============================================

function main {
  topic 'Datadog Prerun:'
  set_variables
  if [[ $DYNO_TYPE == 'release' ]]; then
    echo 'Dyno type is release, not running this' | indent
    export DISABLE_DATADOG_AGENT=true
    return 0
  fi
  echo "Datadog config path: ${DATADOG_CONF}" | indent
  set_tags
  modify_config
}

# ===============================================

function set_variables {
  if [[ -z $DATADOG_CONF ]]; then
    APT_DIR="$HOME/.apt"
    DD_CONF_DIR="$APT_DIR/etc/datadog-agent"
    DATADOG_CONF="$DD_CONF_DIR/datadog.yaml"
  fi
  YAML_INDENT='  '
  if [[ -n $DYNO ]]; then
    DYNO_TYPE=${DYNO%%.*}
  fi
  if [[ -z $AL_SERVICE ]]; then
    if [[ -n $DD_AL_SERVICE ]]; then
      AL_SERVICE=$DD_AL_SERVICE
    else
      AL_SERVICE='unknown'
    fi
  fi

  if [[ -n $DD_AL_PROCMAP ]] && [[ -n $DYNO_TYPE ]]; then
    jtc_exec=$(command -v jtc)
    if [[ -z $jtc_exec ]]; then
      jtc_exec="/app/bin/jtc"
    fi
    if [[ -x "$jtc_exec" ]]; then
      procmap_type=$(<<<$DD_AL_PROCMAP $jtc_exec -w"[$DYNO_TYPE][0]" -qq)
      procmap_subtype=$(<<<$DD_AL_PROCMAP $jtc_exec -w"[$DYNO_TYPE][1]" -qq)
    fi
  fi

  if [[ -z $AL_PROC_TYPE ]]; then
    if [[ -n $procmap_type ]]; then
      AL_PROC_TYPE=$procmap_type
    elif [[ -n $DD_AL_PROC_TYPE ]]; then
      AL_PROC_TYPE=$DD_AL_PROC_TYPE
    elif [[ -n $DYNO ]]; then
      AL_PROC_TYPE=$DYNO_TYPE
    else
      AL_PROC_TYPE='unknown'
    fi
  fi
  if [[ -z $AL_PROC_SUBTYPE ]]; then
    if [[ -n $procmap_subtype ]]; then
      AL_PROC_SUBTYPE=$procmap_subtype
    elif [[ -n $DD_AL_PROC_SUBTYPE ]]; then
      AL_PROC_SUBTYPE=$DD_AL_PROC_SUBTYPE
    else
      AL_PROC_SUBTYPE='unknown'
    fi
  fi
}

function set_tags {
  TAGS="${YAML_INDENT}- al_service:${AL_SERVICE}\n${YAML_INDENT}- al_proc_type:${AL_PROC_TYPE}\n${YAML_INDENT}- al_proc_subtype:${AL_PROC_SUBTYPE}"
  echo "Extra tags are: \"${TAGS}\"" | indent
}

function modify_config {
  # The following is based on Datadog's buildpack.
  # See https://github.com/DataDog/heroku-buildpack-datadog/blob/a9efed3f683f906e0fb62b3650f3f2214006075e/extra/datadog.sh#L58-L62
  sed -i "s/^\(## @param tags\)/$TAGS\n\1/" $DATADOG_CONF
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
