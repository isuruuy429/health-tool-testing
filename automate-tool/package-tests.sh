#!/bin/bash

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
    fhir_output=$(bal health fhir --mode package --package-name $packageName $specPath 2>&1)

    if [[ $fhir_output == *"Ballerina FHIR package generation completed successfully."* ]]; then
        if [ -d "generated-package/$packageName" ]; then
            echo -e "The 'generated-package/$packageName' directory exists. \n" $tcId $success
            echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
        else
            echo -e "The directory 'generated-package/$packageName' does not exist.\n" $tcId $failed
            echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
        fi
        removeDir=$(rm -rf generated-package)
    fi
}

tc197(){
    tcId="197"
    fhir_output=$(bal health fhir --package-name $packageName $specPath 2>&1)

    if [[ $fhir_output == *"Invalid mode received for FHIR tool command."* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

tc198(){
    tcId="198"
    fhir_output=$(bal health fhir --mode package $specPath 2>&1)

    if [[ $fhir_output == *"Package name [--package-name] is required for package generation"* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

generatePacakge(){
    fhir_output=$(bal health fhir --mode package --package-name $packageName -o $outputgenPath --org-name $orgname --package-version $version $specPath 2>&1)
    if [[ $fhir_output == *"Ballerina FHIR package generation completed successfully."* ]]; then
        echo $fhir_output
    else
        echo "Error occurred in package generation."
    fi
}

tc199(){
    tcId="199"
    if [ -d "$outputgenPath/$packageName" ]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else 
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

readFile() {
    local key="$1"
    local file_path="$outputgenPath/$packageName/Ballerina.toml"  

    readVal=$(grep "^$key\s*=\s*\"" "$file_path" | awk -F'"' '{print $2}')
    echo $readVal
}

tc200(){
    tcId=200
    orgValue=$(readFile "org")

    if [[ $orgValue == $orgname ]]; then
        echo -e "The 'org' field contains '$orgValue'.\n" $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo "The 'org' value is not as expected. The actual org value is $orgValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

tc202(){
    tcId=201
    versionValue=$(readFile "version")

    if [[ $versionValue == $version ]]; then
        echo -e "The 'version' is '$versionValue'.\n" $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo "The version is $versionValue'.\n" echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}

tc203(){
    tcId="203"
    fhir_output=$(bal health fhir --mode package --package-name $packageName $invalidSpecpath 2>&1)

    if [[ $fhir_output == *"No resources found in the IG"* ]]; then
        echo $tcId $success
        echo '{"status": '$success',"case_id": '$tcId'}' >> results.json
    else
        echo $tcId $failed
        echo '{"status": '$failed',"case_id": '$tcId'}' >> results.json
    fi
}


tc197
tc198
generatePacakge
tc199
tc200
tc202
tc203