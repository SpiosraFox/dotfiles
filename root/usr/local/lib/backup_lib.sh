#!/bin/sh
# Shared backup script functions.

datetime()
{
    # Print the current datetime in UTC and adhering to ISO 8601.

    printf '%s' "$(date --utc '+%Y-%m-%dT%H:%MZ')"
}

print_error()
{
    # Parameters.
    #   $1: Message to print.

    printf '[%s]: %s\n' "$(datetime)" "${1}" 1>&2
}

print_message()
{
    # Parameters.
    #   $1: Message to print.

    printf '[%s]: %s\n' "$(datetime)" "${1}"
}
