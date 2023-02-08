#!/bin/sh

printf "raw argument: %s\n" "$@"

##### STEP 1: prune arguments with no value

# We always need to produce the summary to parse the command outputs
CLEAN_ARGS="--summary"
for arg in $@
do
    if echo "$arg" | grep -Eq '\-\-.+'; then
        # The argument starts with '--', so check if it also has a value
        if echo "$arg" | grep -Eq '.+=\S+'; then
            # The argument also has a value, add it to the command line
            CLEAN_ARGS="$CLEAN_ARGS $arg"
        fi
        # If the argument has no value we discard it
    else
        # The argument doesn't start with -- (it's probably the Nyx command argument)
        # so add it to the command line as is
        CLEAN_ARGS="$CLEAN_ARGS $arg"
    fi
done

printf "clean arguments: %s\n" "$CLEAN_ARGS"

##### STEP 2: run Nyx
OUTPUT=$(/usr/bin/nyx $CLEAN_ARGS)

printf "Nyx output:\n"
printf "--------------------------------\n"
printf "%s\n" "$OUTPUT"
printf "--------------------------------\n"

# For each value from the output, discard everything before the '=' sign and set its corresponding output value
echo "branch=$(echo "$OUTPUT" | grep 'branch' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "bump=$(echo "$OUTPUT" | grep 'bump' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "coreVersion=$(echo "$OUTPUT" | grep 'core version' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "latestVersion=$(echo "$OUTPUT" | grep 'latest version' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "newRelease=$(echo "$OUTPUT" | grep 'new release' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "newVersion=$(echo "$OUTPUT" | grep 'new version' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "scheme=$(echo "$OUTPUT" | grep 'scheme' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "timestamp=$(echo "$OUTPUT" | grep 'timestamp' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "previousVersion=$(echo "$OUTPUT" | grep 'previous version' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "primeVersion=$(echo "$OUTPUT" | grep 'prime version' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
echo "version=$(echo "$OUTPUT" | grep 'current version' | sed 's/^.*\s*=\s*//')" >> $GITHUB_OUTPUT
