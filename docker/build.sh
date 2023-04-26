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
    $(basename "$0") [--IMG_NAME] [-h]

Description:
    builds docker image from Dockerfile.

Options:
    --IMG_NAME: Name for docker image.

_EOT_
    exit 1
}

# CLI arguments.
IMG_NAME=my_image

while :; do
    case $1 in
    -h | -\? | --help)
        show_help "Help" # Display a usage synopsis.
        exit
        ;;
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

echo "using $IMG_NAME for the docker image name."
docker build  -t $IMG_NAME \
    -f ./docker/Dockerfile ./docker
