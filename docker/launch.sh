#!/usr/bin/env bash

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# usage
function show_help() {
    echo "$1"
    cat <<_EOT_
Usage:
    $(basename "$0") [--DATA_DIR] [--RESULTS_DIR] [--IMG_NAME] [--CONTAINER_NAME] [-h|help]

Description:
    Launches the docker container with required binding.

Options:
    --DATA_DIR: Directory where the data is stored / will be created.
    --RESULTS_DIR: Directory where the results will be stored.
    --IMG_NAME: Docker image name.
    --CONTAINER_NAME: Name for docker container.

_EOT_
    exit 1
}

# CLI arguments.

IMG_NAME="nnabla/bert/per-training"
CONTAINER_NAME="BERT_pre_training_nnabla"

while :; do
    case $1 in
    -h | -\? | --help)
        show_help "Help" # Display a usage synopsis.
        exit
        ;;
    # --DATA_DIR) # Takes an option argument; ensure it has been specified.
    #     if [ "$2" ]; then
    #         DATA_DIR=$2
    #         shift
    #     else
    #         die 'ERROR: "--DATA_DIR" requires a non-empty option argument.'
    #     fi
    #     ;;
    # --DATA_DIR=?*)
    #     DATA_DIR=${1#*=} # Delete everything up to "=" and assign the remainder.
    #     ;;
    # --DATA_DIR=) # Handle the case of an empty --file=
    #     die 'ERROR: "--DATA_DIR" requires a non-empty option argument.'
    #     ;;

    # --RESULTS_DIR) # Takes an option argument; ensure it has been specified.
    #     if [ "$2" ]; then
    #         RESULTS_DIR=$2
    #         shift
    #     else
    #         die 'ERROR: "--RESULTS_DIR" requires a non-empty option argument.'
    #     fi
    #     ;;
    # --RESULTS_DIR=?*)
    #     RESULTS_DIR=${1#*=} # Delete everything up to "=" and assign the remainder.
    #     ;;
    # --RESULTS_DIR=) # Handle the case of an empty --file=
    #     die 'ERROR: "--RESULTS_DIR" requires a non-empty option argument.'
    #     ;;

    --IMG_NAME) # Takes an option argument; ensure it has been specified.
        if [ "$2" ]; then
            IMG_NAME=$2
            shift
        else
            die 'ERROR: "--IMG_NAME" requires a non-empty option argument.'
        fi
        ;;
    --IMG_NAME=?*)
        IMG_NAME=${1#*=} # Delete everything up to "=" and assign the remainder.
        ;;
    --IMG_NAME=) # Handle the case of an empty --file=
        die 'ERROR: "--IMG_NAME" requires a non-empty option argument.'
        ;;

    --CONTAINER_NAME) # Takes an option argument; ensure it has been specified.
        if [ "$2" ]; then
            CONTAINER_NAME=$2
            shift
        else
            die 'ERROR: "--CONTAINER_NAME" requires a non-empty option argument.'
        fi
        ;;
    --unified_io/sdk:0.0.1=?*)
        CONTAINER_NAME=${1#*=} # Delete everything up to "=" and assign the remainder.
        ;;
    --CONTAINER_NAME=) # Handle the case of an empty --file=
        die 'ERROR: "--CONTAINER_NAME" requires a non-empty option argument.'
        ;;

    --) # End of all options.
        shift
        break
        ;;
    -?*)
        printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
        ;;
    *) # Default case: No more options, so break out of the loop.
        break ;;
    esac

    shift
done


# function for running the image as non-root user
docker_run_user() {
    tempdir=$(mktemp -d)
    getent passwd >${tempdir}/passwd
    getent group >${tempdir}/group
    nvidia-docker run -v${HOME}:${HOME} -w$(pwd) --rm -u$(id -u):$(id -g) $(for i in $(id -G); do echo -n ' --group-add='$i; done) \
        -v ${tempdir}/passwd:/etc/passwd:ro \
        -v ${tempdir}/group:/etc/group:ro "$@"
}

echo "using $IMG_NAME for docker image."
echo "using $CONTAINER_NAME for docker container name."
# echo "using $DATA_DIR for /data."
# echo "using $RESULTS_DIR for /results."

# you can configure ipc and net flags as per your requirements.
docker_run_user --name $CONTAINER_NAME -it --rm \
    --gpus device=all \
    --net=host \
    --ipc=host \
    -v "$PWD":/workspace \
    "$IMG_NAME"
