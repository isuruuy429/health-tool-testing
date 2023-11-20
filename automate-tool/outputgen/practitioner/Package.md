# Practitioner Template

## Template Overview

This template provides a boilerplate code for rapid implementation of FHIR APIs and creating, accessing and manipulating FHIR resources.

| Module/Element       | Version |
| -------------------- | ------- |
| FHIR version         | r4 |
| Implementation Guide | [http://hl7.org.nz/fhir](http://hl7.org.nz/fhir) |
| Profile URL          |[http://hl7.org.nz/fhir/StructureDefinition/NzPractitioner](http://hl7.org.nz/fhir/StructureDefinition/NzPractitioner)|

### Dependency List

- ballerinax/health.fhir.r4
- ballerinax/health.fhirr4
- healthcare/nzbase

This template includes a Ballerina service for Practitioner FHIR resource with following FHIR interactions.
- READ
- VREAD
- SEARCH
- CREATE
- UPDATE
- PATCH
- DELETE
- HISTORY-INSTANCE
- HISTORY-TYPE

## Prerequisites

Pull the template from central

    ` bal new -t healthcare/nzbase.practitioner PractitionerAPI `

## Run the template

- Run the Ballerina project created by the service template by executing bal run from the root.
- Once successfully executed, Listener will be started at port 9090. Then you need to invoke the service using the following curl command
    ` $ curl http://localhost:9090/fhir/r4/Practitioner `
- Now service will be invoked and returns an Operation Outcome, until the code template is implemented completely.

## Adding a Custom Profile/Combination of Profiles

- Add profile type to the aggregated resource type. Eg: `public type Practitioner r4:Practitioner|<Other_Practitioner_Profile>;`.
    - Add the new profile URL in `api_config.bal` file.
    - Add as a string inside the `profiles` array.
    - Eg: `profiles: ["http://hl7.org.nz/fhir/StructureDefinition/NzPractitioner", "new_profile_url"]`