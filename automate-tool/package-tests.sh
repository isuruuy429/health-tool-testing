#!/bin/bash

source utils.sh

failed='"failed"'
packageName="nzbase" 
success='"passed"'
specPath="resources/nz-base/site/"
outputgenPath="outputgen"
orgname="xyz"
version="2.0.0"
invalidSpecpath="resources/"

tc196() {
    tcId="196"
    print_test_case_header $tcId "Verify if a package can be generated when only the mandatory parameters are given."

    fhir_output=$(bal health fhir --mode package --package-name $packageName $specPath 2>&1)

    if [[ $fhir_output == *"Ballerina FHIR package generation completed successfully."* ]]; then
        if [ -d "generated-package/$packageName" ]; then
            echo $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
        else
            echo -e "The directory 'generated-package/$packageName' does not exist.\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
        fi
        removeDir=$(rm -rf generated-package)
    fi

}

tc197(){
    tcId="197"
    print_test_case_header $tcId "Verify if it provides a meaningful error message when the mandatory parameter -m (mode) is missing."

    fhir_output=$(bal health fhir --package-name $packageName $specPath 2>&1)

    if [[ $fhir_output == *"Invalid mode received for FHIR tool command."* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc198(){
    tcId="198"
    print_test_case_header $tcId "Verify if it provides a meaningful error message when the package-name is missing."

    fhir_output=$(bal health fhir --mode package $specPath 2>&1)

    if [[ $fhir_output == *"Package name [--package-name] is required for package generation"* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc199(){
    tcId="199"
    print_test_case_header $tcId "Verify if package can be generated to a specified output directory by specifying -o option."

    if [ -d "$outputgenPath/$packageName" ]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else 
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc200(){
    tcId=200
    print_test_case_header $tcId "Verify if the package can be generated defining the organization by providing the --org-name parameter."

    orgValue=$(readFile "org")

    if [[ $orgValue == $orgname ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo "The 'org' value is not as expected. The actual org value is $orgValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc202(){
    tcId="202"
    print_test_case_header $tcId "Verify if the package can be generated with the specified version --package-version."

    versionValue=$(readFile "version")

    if [[ $versionValue == $version ]]; then
        echo -e "The 'version' is '$versionValue'.\n" $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo "The version is $versionValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc203(){
    tcId="203"
    print_test_case_header $tcId "Verify if it provides a meaningful error message when an invalid path is provided that does not contain the Structure definitions."

    fhir_output=$(bal health fhir --mode package --package-name $packageName $invalidSpecpath 2>&1)

    if [[ $fhir_output == *"No resources found in the IG"* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

generatePackage() {
    echo "Generating package with -o, --org-name, --package-version"
    fhir_output=$(bal health fhir --mode package --package-name $packageName -o $outputgenPath --org-name $orgname --package-version $version $specPath 2>&1)
    if [[ $fhir_output == *"Ballerina FHIR package generation completed successfully."* ]]; then
        echo "Ballerina FHIR package is generated successfully."
    else
        echo "Error occurred in package generation."
    fi
}

# This function reads the Ballerina.toml file
readFile() {
    local key="$1"
    local file_path="$outputgenPath/$packageName/Ballerina.toml"  

    readVal=$(grep "^$key\s*=\s*\"" "$file_path" | awk -F'"' '{print $2}')
    echo $readVal
}

test_cases=(tc196 tc197 tc198 generatePackage tc199 tc200 tc202 tc203)

# Loop through the array and execute each test case function
for test_case in "${test_cases[@]}"; do
    $test_case
    echo "$test_case completed."
    echo "----------------------------------------------------------------------------------------------"
done
