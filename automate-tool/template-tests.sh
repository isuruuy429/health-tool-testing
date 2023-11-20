#!/bin/bash

failed='"failed"'
success='"passed"'

packageName="nzbase"
dependentPkg="healthcare/$packageName"
templateName="patient"
specPath="resources/nz-base/site/"
outputgenPath="outputgen"
orgname="healthcare"
version="2.0.0"
includedProfile="http://hl7.org.nz/fhir/StructureDefinition/NzMedicationRequest"
expectedDirname="medicationrequest"
includedProfile2="http://hl7.org.nz/fhir/StructureDefinition/NzPractitioner"

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
    publishPackage
    fhir_output=$(bal health fhir --mode template --dependent-package $dependentPkg $specPath 2>&1)

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [ -d "generated-template/$templateName" ]; then
            echo -e "The 'generated-template/$templateName' directory exists. \n" $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
        else
            echo -e "The directory 'generated-template/$templateName' does not exist.\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
        fi
        removeDir=$(rm -rf generated-template)
    fi
}

tc206(){
    tcId="206"
    fhir_output=$(bal health fhir -m template --dependent-package healthcare $specPath 2>&1)

    if [[ $fhir_output == *"Format of the dependent package is incorrect."* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo $tcId $failed"\n"$fhir_output
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

generateTemplate(){
    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg -o $outputgenPath --org-name $orgname --package-version $version $specPath 2>&1)
    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        echo "Templates generation is successful."
    else
        echo "Error occurred in template generation."
        echo $fhir_output
    fi
}

tc207(){
    tcId="207"
    if [ -d "$outputgenPath/$templateName" ]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else 
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

readFile() {
    local key="$1"
    local file_path="$outputgenPath/$templateName/Ballerina.toml"  

    readVal=$(grep "^$key\s*=\s*\"" "$file_path" | awk -F'"' '{print $2}')
    echo $readVal
}

tc214(){
    tcId="214"
    orgValue=$(readFile "org")

    if [[ $orgValue == $orgname ]]; then
        echo -e "The 'org' field contains '$orgValue'.\n" $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo "The 'org' value is not as expected. The actual org value is $orgValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi

}

tc217(){
    tcId=217
    versionValue=$(readFile "version")

    if [[ $versionValue == $version ]]; then
        echo -e "The 'version' is '$versionValue'.\n" $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo "The version is $versionValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

tc208(){
    tcId="208"
    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg --included-profile $includedProfile $specPath 2>&1)
    
    # Find directories inside the target directory, excluding subdirectories
    directories=$(find "generated-template" -mindepth 1 -maxdepth 1 -type d)
    count=$(echo "$directories" | wc -l | tr -d ' ')
    dirname=$(basename $directories)

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [[ $count == 1 ]]; then
            if [[ $dirname == $expectedDirname ]]; then
                echo $tcId $success
                echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
            else
                echo -e "The generated template is $dirname\n" $tcId $failed
                echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
            fi
        else
            echo -e "Actual count is $count\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
        fi
    else
        echo -e "Template generation failed\n"$tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
    rm -rf generated-template
}

tc210(){
    tcId="210"
    fhir_output=$(bal health fhir -m template --dependent-package $dependentPkg --included-profile $includedProfile --included-profile $includedProfile2 $specPath 2>&1)

    directories=$(find "generated-template" -mindepth 1 -maxdepth 1 -type d)
    count=$(echo "$directories" | wc -l | tr -d ' ')

    if [[ $fhir_output == *"Ballerina FHIR API templates generation completed successfully."* ]]; then
        if [[ $count == 2 ]]; then
            echo $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
        else
            echo -e "The count is $count\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
        fi
    else
        echo $fhir_output
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
    rm -rf generated-template


}

tc204
tc206
generateTemplate
tc207
tc214
tc217
tc208
tc210
