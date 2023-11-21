#!/bin/bash

source utils.sh

failed='"failed"'
success='"passed"'

packageName="nzbase"
dependentPkg="healthcare/$packageName"
templateName="patient"
specPath="resources/nz-base/site/"
outputgenPath="outputgen"
orgname="healthcare"
version="2.0.0"
profile1="http://hl7.org.nz/fhir/StructureDefinition/NzMedicationRequest"
expectedDirname="medicationrequest"
profile2="http://hl7.org.nz/fhir/StructureDefinition/NzPractitioner"

publishPackage(){
    expected_output="Creating bala
target/bala/healthcare-$packageName-any-1.0.0.bala"

    expectedBalPushOutput="Successfully pushed target/bala/healthcare-$packageName-any-1.0.0.bala to 'local' repository."

    fhir_output=$(bal health fhir --mode package --package-name $packageName $specPath 2>&1)
    if [[ $fhir_output == *"Ballerina FHIR package generation completed successfully."* ]]; then
        echo "Ballerina package generation is successful"
        cd generated-package/$packageName
        balpackOutput=$(bal pack)

        if echo "$balpackOutput" | grep -Fq "$expected_output"; then
            echo "The bal pack is successful"
            balPushOutput=$(bal push --repository local)
            if echo "$balPushOutput" | grep -Fq "$expectedBalPushOutput"; then
                echo "The bal push is successful"
            else
                echo "An error occurred while pushing to the repository."
            fi
        else
            echo "An error occurred while building the Ballerina package."
        fi    
    else
        echo $fhir_output
        echo "An error occurred while Ballerina package generation"
    fi
    cd ../..
    rm -rf generated-package
}

tc204() {
    tcId="204"
    print_test_case_header $tcId "Verify if a template can be generated given the mandatory parameters only"
    publishPackage
    fhir_output=$(bal health fhir --mode template --dependent-package $dependentPkg $specPath 2>&1)

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [ -d "generated-template/$templateName" ]; then
            echo $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
        else
            echo -e "The directory 'generated-template/$templateName' does not exist.\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
        fi
        removeDir=$(rm -rf generated-template)
    fi

}

tc206(){
    tcId="206"
    print_test_case_header $tcId "Verify if it provides an error message if specific format for the --dependent-package is not given."
    fhir_output=$(bal health fhir -m template --dependent-package healthcare $specPath 2>&1)

    if [[ $fhir_output == *"Format of the dependent package is incorrect."* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo $tcId $failed"\n"$fhir_output
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc207(){
    tcId="207"
    print_test_case_header $tcId "Verify if a template can be generated given the specified output folder."
    if [ -d "$outputgenPath/$templateName" ]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else 
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc214(){
    tcId="214"
    print_test_case_header $tcId "Verify if the organization name in the templates can be custommized by the --org-name parameter."

    orgValue=$(readFile "org")
    echo "orgvalue" $orgValue

    if [[ $orgValue == $orgname ]]; then
        echo -e "The 'org' field contains '$orgValue'.\n" $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo -e "The 'org' value is not as expected. The actual org value is $orgValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi

}

tc217(){
    tcId=217
    print_test_case_header $tcId "Verify if templates can be customized with the package-version"

    versionValue=$(readFile "version")

    if [[ $versionValue == $version ]]; then
        echo -e "The 'version' is '$versionValue'.\n" $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
    else
        echo "The version is $versionValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
    rm -rf $outputgenPath

}

tc208(){
    tcId="208"
    print_test_case_header $tcId "Verify if only the given template can be generated using included-profile option."

    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg --included-profile $profile1 $specPath 2>&1)
    
    # Find directories inside the target directory, excluding subdirectories
    directories=$(find "generated-template" -mindepth 1 -maxdepth 1 -type d)
    count=$(echo "$directories" | wc -l | tr -d ' ')
    dirname=$(basename $directories)

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [[ $count == 1 ]]; then
            if [[ $dirname == $expectedDirname ]]; then
                echo $tcId $success
                echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
            else
                echo -e "The generated template is $dirname\n" $tcId $failed
                echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
            fi
        else
            echo -e "Actual count is $count\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
        fi
    else
        echo -e "Template generation failed\n"$tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
    rm -rf generated-template

}

tc210(){
    tcId="210"
    print_test_case_header $tcId "Verify --included-profile option can be used multiple times."

    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg --included-profile $profile1 --included-profile $profile2 $specPath 2>&1)

    directories=$(find "generated-template" -mindepth 1 -maxdepth 1 -type d)
    count=$(echo "$directories" | wc -l | tr -d ' ')

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [[ $count == 2 ]]; then
            echo $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
        else
            echo -e "The count is $count\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
        fi
    else
        echo $fhir_output
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
    rm -rf generated-template

}

tc211(){
    tcId="211"
    print_test_case_header $tcId "Verify if the given template can be excluded from using excluded-profile option."

    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg --excluded-profile $profile1 $specPath 2>&1)
    
    # Find directories inside the target directory, excluding subdirectories
    directories=$(find "generated-template" -mindepth 1 -maxdepth 1 -type d)
    count=$(echo "$directories" | wc -l | tr -d ' ')

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [[ $count == 9 ]]; then
            echo $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
        else
            echo -e "Actual count is $count\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
        fi
    else
        echo -e "Template generation failed\n"$tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
    rm -rf generated-template
}

tc213(){
    tcId="213"
    print_test_case_header $tcId "Verify --excluded-profile option can be used multiple times."

    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg --excluded-profile $profile1 --excluded-profile $profile2 $specPath 2>&1)
    
    # Find directories inside the target directory, excluding subdirectories
    directories=$(find "generated-template" -mindepth 1 -maxdepth 1 -type d)
    count=$(echo "$directories" | wc -l | tr -d ' ')

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [[ $count == 8 ]]; then
            echo $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.txt
        else
            echo -e "Actual count is $count\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
        fi
    else
        echo -e "Template generation failed\n"$tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.txt
    fi
    rm -rf generated-template
}

generateTemplate() {
    echo "Generating template with -o, --org-name and --package-version"
    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg -o $outputgenPath --org-name $orgname --package-version $version $specPath 2>&1)
    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        echo "Templates generation is successful."
    else
        echo "Error occurred in template generation."
        echo $fhir_output
    fi
}

# This function reads the Ballerina.toml file
readFile() {
    local key="$1"
    local file_path="$outputgenPath/$templateName/Ballerina.toml"  

    readVal=$(grep "^$key\s*=\s*\"" "$file_path" | awk -F'"' '{print $2}')
    echo $readVal
}

test_cases=(tc204 tc206 generateTemplate tc207 tc214 tc217 tc208 tc210 tc211 tc213)
for test_case in "${test_cases[@]}"; do
    $test_case
    echo "$test_case completed."
    echo "----------------------------------------------------------------------------------------------"
done
