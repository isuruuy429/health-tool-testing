#!/bin/bash
source utils.sh

file="results.txt"
jsonFile="output.json"

# Remove the results file before starting tests
remove_file_if_exists "$file"
remove_file_if_exists "$jsonFile"

## Execute tests related to the tool
execute_test_suite "tool-tests.sh" "Executing tool related tests"

## Install Bal health tool
echo "Pulling Ballerina Health Tool"
bal tool pull health

## Execute tests related to pacakge generation
execute_test_suite "package-tests.sh" "Executing package related tests"

## Execute tests related to template generation
execute_test_suite "template-tests.sh" "Executing template related tests"

## Remove Health tool
bal tool remove health 

## Create the test results file to the expected format. 
sed '$!s/$/,/' "$file" > temp_file && mv temp_file "$file"
echo -n '{"results": [' > output.json
cat "$file" >> output.json
echo ']}' >> output.json

## Publish test results to Qase
publish_results "$1"
