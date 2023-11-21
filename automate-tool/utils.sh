#!/bin/bash

print_test_case_header() {
    local test_case_id="$1"
    local feature_description="$2"
    echo "----------------------------------------------------------------------------------------------"
    echo "🔍 Running Test Case: $test_case_id"
    echo "Feature: $feature_description"
}

#remove results.txt file if exists.
remove_file_if_exists() {
    local file=$1
    if [ -f "$file" ]; then
        rm "$file"
        echo "$file is removed."
    fi
}

# Function to execute test scripts
execute_test_suite() {
    local test_script=$1
    local test_description=$2
    
    echo "=============================================================================================="
    echo "🔍 $test_description"
    echo "=============================================================================================="
    source "$test_script"
}

publish_results(){  
    echo -e "Creating the test run in QASE\n"
    current_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local api_token=$1  # Get the API token from the first script argument
    
    response1=$(curl --location 'https://api.qase.io/v1/run/OHOC' \
    --header 'accept: application/json' \
    --header 'content-type: application/json' \
    --header "Token: $api_token" \
    --data "{
        \"title\": \"$current_timestamp\",
        \"include_all_cases\": false,
        \"is_autotest\": true,
        \"cases\": [192, 195, 194, 193, 204, 206, 207, 214, 217, 208, 210, 211, 213, 196, 197, 198, 199, 200, 202, 203]
    }")

    echo "response1 is $response1" 

    if [[ $(echo "$response1" | jq '.status') == true ]]; then
        run_id=$(echo "$response1" | jq '.result.id')
        echo "The operation was successful. Run ID: $run_id"
    else
        echo "The operation failed."
    fi

    echo -e "Publishing test results to QASE\n"
    local data_file="output.json" # This is the file with the JSON data

    curl --location "https://api.qase.io/v1/result/OHOC/$run_id/bulk" \
    --header "Token: $api_token" \
    --header 'accept: application/json' \
    --header 'content-type: application/json' \
    --data @"$data_file"
}
