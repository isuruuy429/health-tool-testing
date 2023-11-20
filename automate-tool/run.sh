#!/bin/bash

failed='"failed"'
packageName="nzbase" 
success='"passed"'
specPath="resources/nz-base/site/"


# Check the version of the tool.
version_output=$(bal health --version 2>&1)

# Check if the output includes 'unknown command 'health''
if [[ $version_output == *"unknown command 'health'"* ]]; then
    echo "Unknown command 'health'. Pulling the tool..."

    pull_output=$(bal tool pull health 2>&1)
    if [[ $pull_output == *"pulled successfully."* ]]; then
        echo -e "The tool pull was successful.\n 192 $success"
        echo '{"status": '$success',"case_id": 192}' >> results.json
       source run1.sh
    else
        echo "Failed to pull the tool. Output: $pull_output"
    fi
else
    echo "Tool version:"
    echo "$version_output"
fi

fhir_output=$(bal tool remove health 2>&1)
echo $fhir_output
