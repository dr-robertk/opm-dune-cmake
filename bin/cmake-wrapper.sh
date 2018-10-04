#!/bin/bash

ORIG_FLAGS=( "$@" )
if test -z "$VANILLA_CMAKE"; then
    VANILLA_CMAKE="$(which cmake)"
fi
OPM_CMAKE_DIR="$(readlink -f $(dirname $(which $0))/..)"

# check if we're called with the --build flag. in this case, just use plain cmake
for FLAG in $ORIG_FLAGS; do
    if test "$FLAG" == "--build"; then
        exec $VANILLA_CMAKE "${ORIG_FLAGS[@]}"
    fi
done

# this is a function which is useful for debugging
function print_flags()
{
    for FLAG in "$@"; do
        echo -n "\"$FLAG\" "
    done
}


function get_source_dir()
{
    SOURCE_DIR=""
    for FLAG in "${ORIG_FLAGS[@]}"; do
        case "$FLAG" in
            -*)
                continue

                ;;

            *)
                if test -n "$SOURCE_DIR"; then
                    echo "Multiple source directories defined. Giving up!"
                    exit 1
                fi

                SOURCE_DIR="$FLAG"
                ;;
        esac
    done
}

function extract_module_name()
{
    MODULE_NAME=$(cat $SOURCE_DIR/dune.module | grep "Module" | sed "s/\s*Module\s*:\s*\([a-zA-Z0-9]*\)\s*/\1/")
    MODULE_VERSION=$(cat $SOURCE_DIR/dune.module | grep "Version" | sed "s/\s*Version\s*:\s*\([a-zA-Z0-9 ]*\)\s*/\1/")
}

function run_cmake_wrapper()
{
    BUILD_DIR="$(pwd)"
    FAKE_SOURCE_DIR="$BUILD_DIR/fake-src"

    rm -rf "$FAKE_SOURCE_DIR/"
    mkdir -p "$FAKE_SOURCE_DIR"

    echo "Real source dir: $SOURCE_DIR"
    echo "Fake source dir: $FAKE_SOURCE_DIR"

    # link everything in the real source directory to the fake one.
    ln -s "$SOURCE_DIR/"* "$FAKE_SOURCE_DIR/"
    for CUR_SRC_FILE in "$OPM_CMAKE_DIR/$MODULE_NAME-buildfiles/"*; do
        CUR_SRC_FILENAME="$(basename "$CUR_SRC_FILE")"
        rm -f "$FAKE_SOURCE_DIR/$CUR_SRC_FILENAME"
        ln -s "$CUR_SRC_FILE" "$FAKE_SOURCE_DIR/$CUR_SRC_FILENAME"
    done

    # create a "project-version.h" file in the fake source directory
    # as some opm modules seem to expect it
    cat > "$FAKE_SOURCE_DIR/project-version.h" <<EOF
#ifndef PROJECT_VERSION_H
#define PROJECT_VERSION_H

#define PROJECT_VERSION_NAME "${MODULE_VERSION}"
#define PROJECT_VERSION_HASH ""
#define PROJECT_VERSION "${MODULE_VERSION}"

#endif
EOF

    declare -a NEW_FLAGS
    NEW_FLAGS+=("-DCMAKE_MODULE_PATH=${FAKE_SOURCE_DIR}/cmake/modules")
    for FLAG in "${ORIG_FLAGS[@]}"; do
        case "$FLAG" in
            -DCMAKE_MODULE_PATH=*)
                # ignore module path arguments
                ;;

            -*)
                # copy all other flags
                NEW_FLAGS+=("${FLAG}")
                ;;

            *)
                # use the fake source directory instead of the real one
                NEW_FLAGS+=("${FAKE_SOURCE_DIR}")
                ;;

        esac
    done

    echo -n "running bare cmake:"
    echo -n "$VANILLA_CMAKE "
    print_flags "${NEW_FLAGS[@]}"
    echo

    exec $VANILLA_CMAKE "${NEW_FLAGS[@]}"
    exit 0
}

get_source_dir
extract_module_name
case "$MODULE_NAME" in
    "opm-common" | \
    "opm-grid" | \
    "opm-material" | \
    "ewoms" | \
    "chiwoms" | \
    "opm-simulators" | \
    "opm-upscaling")
        echo "Detected OPM module '$MODULE_NAME' in directory '$SOURCE_DIR'. Using wrapped cmake."

        run_cmake_wrapper
        ;;

    *)
        echo "Unrecognized module '$MODULE_NAME' in directory '$SOURCE_DIR'. Using vanilla cmake."

        exec "$VANILLA_CMAKE" "${ORIG_FLAGS[@]}"
        ;;
esac
