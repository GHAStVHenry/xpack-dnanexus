#!/bin/bash
#
# Copyright 2021, Seqera Labs, S.L. All Rights Reserved.
#
set -o pipefail

on_exit() {
  ret=$?
  # upload log file
  dx upload $LOG_NAME --path $DX_LOG --wait --brief --no-progress --parents || true
  # backup cache
  echo "=== Execution complete — uploading Nextflow cache metadata files"
  dx rm -r "$DX_PROJECT_CONTEXT_ID:/.nextflow/cache/$NXF_UUID/*" 2>&1 >/dev/null || true
  dx upload ".nextflow/cache/$NXF_UUID" --path "$DX_PROJECT_CONTEXT_ID:/.nextflow/cache/$NXF_UUID" --no-progress --brief --wait -p -r || true
  # done
  exit $ret
}

dx_path() {
  local str=${1#"dx://"}
  local tmp=$(mktemp -t nf-XXXXXXXXXX)
  case $str in
    project-*)
      dx download $str -o $tmp --no-progress --recursive -f
      echo file://$tmp
      ;;
    container-*)
      dx download $str -o $tmp --no-progress --recursive -f
      echo file://$tmp
      ;;
    *)
      echo "Invalid $2 path: $1"
      return 1
      ;;
  esac
}

# Main entry point for this app.
main() {
    [[ $debug ]] && set -x && env | grep -v license | sort
    [[ $debug ]] && export NXF_DEBUG=2

    LOG_NAME="nextflow-$(date +"%y%m%d-%H%M%S").log"
    DX_WORK=${work_dir:-$DX_WORKSPACE_ID:/scratch/}
    DX_LOG=${log_file:-$DX_PROJECT_CONTEXT_ID:$LOG_NAME}

    export NXF_WORK=dx://$DX_WORK
    export NXF_HOME=/opt/nextflow
    export NXF_UUID=${resume_id:-$(uuidgen)}
    export NXF_XPACK_LICENSE=$(dx_path $license 'license file')
    export NXF_IGNORE_RESUME_HISTORY=true
    export NXF_ANSI_LOG=false
    export NXF_EXECUTOR=dnanexus
    export NXF_PLUGINS_DEFAULT=xpack-dnanexus@1.0.0-beta.5
    export NXF_DOCKER_LEGACY=true
    export NXF_DOCKER_CREDS_FILE=$docker_creds_file
    [[ $scm_file ]] && export NXF_SCM_FILE=$(dx_path $scm_file 'Nextflow CSM file')
    trap on_exit EXIT

    echo "============================================================="
    echo "=== NF work-dir : ${DX_WORK}"
    echo "=== NF Resume ID: ${NXF_UUID}"
    echo "=== NF log file : ${DX_LOG}"
    echo "=== NF cache    : $DX_PROJECT_CONTEXT_ID:/.nextflow/cache/$NXF_UUID"
    echo "============================================================="

    # restore cache
    local ret
    mkdir -p .nextflow/cache/$NXF_UUID
    ret=$(dx download "$DX_PROJECT_CONTEXT_ID:/.nextflow/cache/$NXF_UUID/*" -o ".nextflow/cache/$NXF_UUID" --no-progress -r -f 2>&1) || {
      if [[ $ret == *"The specified folder could not be found"* ]]; then
        echo "No previous execution cache was found"
      else
        echo $ret >&2
        exit 1
      fi
    }

    # prevent glob expansion
    set -f
    # launch nextflow
    nextflow -trace nextflow.plugin \
          $opts \
          -log $LOG_NAME \
          run $pipeline_url \
          -resume $NXF_UUID \
          $args
    # restore glob expansion
    set +f
}

nf_task_exit() {
  ret=$?
  if [ -f .command.log ]; then
    dx upload .command.log --path "${cmd_log_file}" --brief --wait --no-progress || true
  else
    >&2 echo "Missing Nextflow .command.log file"
  fi
  # mark the job as successful in any case, real task
  # error code is managed by nextflow via .exitcode file
  dx-jobutil-add-output exit_code "0" --class=int
}

nf_task_entry() {
  # enable debugging mode
  [[ $NXF_DEBUG ]] && set -x
  # capture the exit code
  trap nf_task_exit EXIT
  # run the task
  dx cat "${cmd_launcher_file}" > .command.run
  bash .command.run > >(tee .command.log) 2>&1 || true
}

