#!/bin/sh
envFilename='./.env.production'
nextFolder='./standalone/.next/'

while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    if [ "${line:0:1}" = "#" ] || [ "${line}" = "" ]; then
        continue
    fi

    # Split the line into variable name and value
    configName="$(echo "$line" | cut -d'=' -f1)"
    configValue="$(echo "$line" | cut -d'=' -f2-)"

    # Get system env
    envValue=$(env | grep "^$configName=" | cut -d'=' -f2-)

    case "$configName" in
        NEXT_PUBLIC_*)
            if [ -n "$configValue" ] && [ -n "$envValue" ]; then
                echo "Replace: ${configValue} with ${envValue}"
                find "$nextFolder" -type d -name .git -prune -o -type f -print0 | xargs -0 sed -i "s|$configValue|$envValue|g"
            fi
        ;;
    esac
done <"$envFilename"

echo "Starting Nextjs"
exec "$@"
