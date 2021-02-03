#!/bin/bash
#
# Script for performing basics checks against DNS records
#
# Read more about this script from the README.md
#
# Üllar Seerme

if [[ -n "$1" ]]; then
    # Constant. Location of the YAML file that contains all necessary input values
    declare -r INPUT=$1
else
    echo 'The first positional parameter is undefined. Exiting'
    exit 1
fi

if [[ -n "$2" ]]; then
    # Constant. Name of the zone being worked on
    declare -r ZONE=$2

    # Constant. Safe version of the 'ZONE' variable to be used in the final output as
    # the dots have been replaced with underscores
    declare -r ZONE_SAFE=${ZONE//\./_}
else
    echo 'The second positional parameter is undefined. Exiting'
    exit 2
fi

if [[ -n "$3" ]]; then
    # Constant. A value of either 'single' or 'multi' to define whether a single set
    # of endpoints or multiple set of endpoints are queried
    declare -r TYPE=$3
else
    echo 'The third positional parameter is undefined. Exiting'
    exit 3
fi

# Associative array for defining a global associative array. Otherwise the output
# of 'get_input_values' won't be able to be used
declare -A values

# Predefined global associative arrays to hold values for the records that are to
# be queried and the endpoints that are queried from
declare -A records
declare -A endpoints

# Integer for storing a combined value for values returned from 'set_status_code'
declare -i returned_values=0

get_input_values() {
    # $1 - Location of the input file to be used
    # $2 - Section to target from the input file
    # $3 - Sub-section to target from the input file

    # Grab block of text from the section to be targeted ($2) in
    # the input file ($1) until the next blank line
    out=$(sed -n "/${2}:/,/^$/p" "$1")

    # If the section to be targeted is equal to 'from' and the sub-section ($3)
    # value is not empty the block of text to be grabbed will span from the name
    # of the sub-section till the name of the next sub-section or till a blank line
    if [[ ("$2" = 'from') && (-n "$3") ]]; then
        out=$(sed -E -n "/  ${3}:$/,/(  [[:alnum:]]*:$|^$)/p" "$1" | head -n -1)
    fi

    # Whatever the grabbed block of text was remove first line, leading spaces, and
    # all possible single quotes
    out=$(echo "$out" | tail -n +2 | sed 's/ //' | tr -d "'")

    # Initialize counter variable for lines that do not contain key-value pairs
    counter=0

    # Go through every line in the variable 'out'
    while read -r line; do
        # A line containing a colon will be a key-value pair, which will then be
        # split into two variables with additional clean-up: 'key' and 'value'
        if [[ "$line" =~ ':' ]]; then
            key=$(echo "$line" | cut -d ':' -f1)
            value=$(echo "$line" | cut -d ':' -f2 | sed 's/ //')
        else
            # To make it easier on the end user we expect non-key-value pair lines
            # that we then turn into key-value pairs to reduce code further on dealing
            # with two types of data (i.e. associative and regular arrays)
            key="$counter"
            value="$line"
        fi

        # Add key-value pair to associative array
        values["$key"]="$value"

        # Increment counter variable by one
        ((counter++))
    done <<< "$out"
}

set_status_code() {
    # $1 - Name of the endpoint that was queried
    # $2 - Output of the response that was received
    # $3 - Answer section of the response that was received
    # $4 - IP address that is being searched for in the answer
    # $5 - Name of the record on which checks were performed

    # Clear the 'values' variable prior to starting to avoid issues where
    # the contents are not cleared and loops won't performed as expeccted
    unset values

    # Execute the 'get_input_values' function which instantiates the global
    # associative array 'values' variable and fills it with the possible
    # check values from the input file
    get_input_values "$INPUT" 'check'

    declare -A statuses

    # Go through 'values' variable and assign contents to newly created
    # 'statuses' associative array. This will be done later on as well as this
    # avoids issues with the 'values' variable not being accessible outside the
    # 'get_input_values' function and subsequent issue of not being able to return
    # it from that function
    for value in "${!values[@]}"; do
        statuses[$value]=${values[$value]}
    done

    # Integer representing overall boolean state of record that is being checked
    declare -i overall_value=0

    for status in "${!statuses[@]}"; do
        declare -i status_value=0

        # Set the status to 1 (i.e. 'false') if one of the statuses appears in the response ($2)
        if [[ "$2" =~ ${statuses[$status]} ]]; then
            status_value=1
        fi

        echo "response.${statuses[$status],,}.${1}.${5}_${ZONE_SAFE} ${status_value}"
    done

    # Set the status to 1 (i.e. 'false') if the response doesn't include 'NOERROR' and
    # the answer does not include the IP address being searched for
    if [[ ! ("$2" =~ 'NOERROR') && ! ("$3" =~ $4) ]]; then
        overall_value=1
    fi

    return "$overall_value"
}

# Execute the 'get_input_values' function which instantiates the global
# associative array 'values' variable and fills it with the names and
# expected values of what records are to be queried
get_input_values "$INPUT" 'what'

# See the explanation in 'set_status_code' function for the first 'for' loop
for value in "${!values[@]}"; do
    records[$value]=${values[$value]}
done

for record in "${!records[@]}"; do
    # Unset and re-declare 'values' and 'endpoints' to avoid possible pitfalls
    # with variables that contain values from previous function calls
    unset values
    unset endpoints
    declare -A values
    declare -A endpoints

    # Do not attempt to grab sub-sections for a given record in the input file
    # if the end user specified the string 'single' as the third parameter.
    # Executes the 'get_input_values' function which instantiates the global
    # associative array 'values' variable and fills it with the names and
    # IP addresses of the endpoints that are queried from
    if [[ "$TYPE" = 'single' ]]; then
        get_input_values "$INPUT" 'from'
    elif [[ "$TYPE" = 'multi' ]]; then
        get_input_values "$INPUT" 'from' "$record"
    fi

    # See the explanation in 'set_status_code' function for the first 'for' loop
    for value in "${!values[@]}"; do
        endpoints[$value]=${values[$value]}
    done

    # For every endpoint defined in the 'endpoints' variable
    for endpoint in "${!endpoints[@]}"; do
        # Execute 'dig' on the 'record' in a given 'ZONE' against the IP of an 'endpoint'
        response=$(dig "${record}.${ZONE}." @"${endpoints[$endpoint]}")

        # Grab just the answer section to check whether the correct IP was returned
        # for a given record and assign variables with just the target values
        answer=$(echo "$response" | grep -A 1 'ANSWER SECTION')
        target_value=${records[$record]}
        target_name=$record

        # Execute the 'set_status_code' function which outputs intermediary responses for
        # all the endpoints and returns an overall value for a given record
        set_status_code "$endpoint" "$response" "$answer" "$target_value" "$target_name"
        returned_values+=$?

        unset values
    done

    # If the sum of the return values from the 'set_status_code' function does not equal 0,
    # then the overall state of the record must be unhealthy (i.e a value of 1)
    if [[ $returned_values != 0 ]]; then
        returned_values=1
    fi

    echo "overall.${record}_${ZONE_SAFE} ${returned_values}"
done
