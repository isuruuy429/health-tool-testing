#!/bin/bash

source utils.sh

failed='"failed"'
success='"passed"'

tc192(){
    tcId="192"
    print_test_case_header $tcId "Verify if the tool can be pulled successfully"
    version_output=$(bal health --version 2>&1)

    # Check if the output includes 'unknown command 'health''
    if [[ $version_output == *"unknown command 'health'"* ]]; then
        echo "Unknown command 'health'. Pulling the tool..."

        pull_output=$(bal tool pull health 2>&1)
        if [[ $pull_output == *"pulled successfully."* ]]; then
            echo -e "The tool pull was successful.\n $tcId $success"
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
        else
            echo "Failed to pull the tool. Output: $pull_output"
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
        fi
    else
        echo "$version_output"
    fi
}

tc195(){
    tcId="195"
    print_test_case_header $tcId "Verify if the current version can be checked using a command."
    
    version_output=$(bal health --version 2>&1)
    pattern="Ballerina Health Tool [0-9]+(\.[0-9]+)*"

    if [[ $version_output =~ $pattern ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo "The string does NOT match the required format.\n" $version_output
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
}

tc194(){
    tcId="194"
    print_test_case_header $tcId "Verify if bal help opens."

    help_output=$(bal health fhir --help 2>&1)

    if [[ $help_output == *"COMMANDS"* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo $help_output
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
}

tc193(){
    tcId="193"
    print_test_case_header $tcId "Verify if the tool can be removed successfully."

    expected_output="tool 'health' successfully removed."
    remove_output=$(bal tool remove health 2>&1)

    if [[ $remove_output == "$expected_output" ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo $remove_output
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
}

test_cases=(tc192 tc195 tc194 tc193)
for test_case in "${test_cases[@]}"; do
    $test_case
    echo "$test_case completed."
    echo "----------------------------------------------------------------------------------------------"
done
