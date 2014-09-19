#!/bin/sh -e

# Convert a JSON string into ENV files.
#
# This script is useful to make values in JSON objects available as
# environment vars. Use in combination with `chpst -e` to load the
# directory of files into a script's environemnt.
#
# When the JSON object is converted, keys become the ENV file names.
# Nested JSON object keys are joined together with underscores.
# Non-alphanumeric characters in the keys are stripped from the file
# name. All file names are uppercase.
#
# Arrays will include a cooresponding "_NUM_" in the file name to
# indicate array position.
#
# The contents stored in each file is the raw JSON data witout
# enclosing quotes for string values.
#
# Example:
# {
#   "somekey": {
#     "nested": {
#       "anarray": [
#         "item1",
#         {
#           "item2": "value"
#         }
#       ]
#     }
#   }
# }
#
# SOMEKEY << {"somekey": {"nested": {"annarray": ["item1", {"item2": "value"}]}}}
# SOMEKEY_NESTED << {"annarray": ["item1", {"item2": "value"}]}
# SOMEKEY_NESTED_ANARAY << ["item1", {"item2": "value"}]
# SOMEKEY_NESTED_ANARRAY_0 << item1
# SOMEKEY_NESTED_ANARRAY_1 << {"item2": "value"}
# SOMEKEY_NESTED_ANARRAY_1_ITEM2 << value
#
#
# Usage:
#   json2env json_file output_path .key prefix_
#
# Note that jq requires special handling of object keys with hyphens.
# Quotes must be added after the period or jq will throw an error.
# Ex: json2env ."some-key"
#
# Defaults: runtime in /env/runtime.json


# Uncomment to output all commands to stdout for debugging
# set -x


# @param json     JSON string
# @param key      jq query string
# @param prefix   Optional env var prefix
# @param path     Optional ath to directory where ENV files will be exported
json2env() {
  local key; key="$1"
  local prefix; prefix="$2"
  local runtime; runtime=$(cat "/env/RUNTIME")
  local val
  local filename

  val=$(echo $runtime | jq -r -c "$key")

  filename="$prefix$key"
  # Remove '.' if first char
  filename=$(echo $filename | sed -e 's/^\.//')
  # Convert '.' '[' ']' to '_'
  filename=$(echo $filename | sed -e 's/\(\[\|\]\|\.\)/_/g')
  # Remove '-' chars
  filename=$(echo $filename | sed -e 's/[-"]//g')
  ## TODO: Joe, do we need different non-alpha here?
  ## Remove non alphanumeric, '_', or '-' chars
  ## filename=$(echo $filename | sed -e 's/[^[:alnum:]]//g')
  # Remove double underscores
  filename=$(echo $filename | sed -e 's/__/_/g')
  # Remove trailing underscores
  filename=$(echo $filename | sed -e 's/\(^_\|_$\)//g')
  # Convert to upper
  filename=$(echo $filename | tr "[:lower:]" "[:upper:]")

  # Write value to file
  echo $val > $filename

  # Return if val is empty
  [ -z "$val" ] && return 0

  local keys
  # Array
  if [ $(echo "$val" | head -c 1) = "[" ]; then
    keys=$(echo $runtime | jq -r -c "$key | keys[]")
    for k in $keys; do
      main "$key[$k]" $prefix
    done
  # Object
  elif [ $(echo "$val" | head -c 1) = "{" ]; then
    keys=$(echo $runtime | jq -r -c "$key | keys[]")
    for k in $keys; do
      main "$key.\"$k\"" $prefix
    done
  fi
}


# Main
# Only run the script if params are provided.
# Useful for sourcing the file for testing and access to functions.
if [ "$#" -gt 0 ]; then
  json2env "$@"
fi
