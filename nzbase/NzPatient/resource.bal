// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com).
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerinax/health.fhir.r4;
import healthcare/nzbasegen as nz;

isolated function getPatient() returns nz:NzPatient {

    //Define NzAddress1
    nz:NzAddress address1 = {
        id: "29A",
        use: "billing",
        'type: "both",
        text: "137 Nowhere Street, Erewhon 9132",
        line: ["137 Nowhere Street"],
        city: "Erewhon",
        district: "Madison",
        postalCode: "9132",
        country: "nz",
        extension: [
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/suburb",
                valueString: "Rototuna"
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/building-name",
                valueString: "Rove"
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/domicile-code",
                valueCodeableConcept: {
                    coding: [
                        {
                            system: "https://standards.digital.health.nz/ns/domicile-code",
                            code: "D",
                            display: "Domicile"
                        }
                    ]
                }
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/nz-geocode",
                extension: [
                    {
                        url: "latitude",
                        valueDecimal: 123.456
                    },
                    {
                        url: "longitude",
                        valueDecimal: 123.456
                    }
                ]
            }

        ]

    };
    //Define NzAddress2
    nz:NzAddress address2 = {
        id: "39A",
        use: "billing",
        'type: "both",
        text: "39A Nowhere Street, Erewhon 9132",
        line: ["39A Nowhere Street"],
        city: "Erewhon",
        district: "Madison",
        postalCode: "9132",
        country: "nz",
        extension: [
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/suburb",
                valueString: "Rototuna"
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/building-name",
                valueString: "Rove"
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/domicile-code",
                valueCodeableConcept: {
                    coding: [
                        {
                            system: "https://standards.digital.health.nz/ns/domicile-code",
                            code: "D",
                            display: "Domicile"
                        }
                    ]
                }
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/nz-geocode",
                extension: [
                    {
                        url: "latitude",
                        valueDecimal: 133.456
                    },
                    {
                        url: "longitude",
                        valueDecimal: 43.456
                    }
                ]
            }

        ]
    };

    //Define NzContactPoint extension
    nz:ContactpointPurpose cp = {
        url: "http://hl7.org.nz/fhir/StructureDefinition/contactpoint-purpose",
        valueCodeableConcept: {
            coding: [
                {
                    system: "http://hl7.org/fhir/contact-point-use",
                    code: "home",
                    display: "Home"
                }
            ]
        }
    };

    // Convert the NzContactPoint extension to r4:CodeableConceptExtension[]
    r4:CodeableConceptExtension[] ex = [
        <r4:CodeableConceptExtension>cp
    ];

    //Define NzContactPoint
    nz:NzContactPoint telecom = {
        id: "518117",
        system: "phone",
        extension: ex,
        value: "518117",
        use: "home",
        rank: 1,
        period: {
            'start: "1991-10-23"
        }
    };

    // Define Patient 
    nz:NzPatient patient = {
        id: "12345",
        gender: "male",
        address: [address1, address2],
        name: [
            {
                use: "official",
                family: "Smith",
                given: ["John", "Edward"]
            }
        ],
        telecom: [telecom],
        extension: [
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/nz-ethnicity",
                valueCodeableConcept: {
                    coding: [
                        {
                            system: "https://standards.digital.health.nz/ns/ethnic-group-level-4-code",
                            code: "11111",
                            display: "New Zealand European"
                        }
                    ]
                }
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/nz-ethnicity",
                valueCodeableConcept: {
                    coding: [
                        {
                            system: "https://standards.digital.health.nz/ns/ethnic-group-level-4-code",
                            code: "11444",
                            display: "Sinhalese"
                        }
                    ]
                }
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/dhb",
                valueCodeableConcept: {
                    coding: [
                        {
                            system: "https://standards.digital.health.nz/ns/dhb-code",
                            code: "G00011-K",
                            display: "Auckland District Health Board"
                        }
                    ]
                }
            },
            {
                url: "http://hl7.org.nz/fhir/StructureDefinition/nz-iwi",
                valueCodeableConcept: {
                    coding: [
                        {
                            system: "https://standards.digital.health.nz/ns/iwi-cod",
                            code: "0104",
                            display: "Ngāpuhi"
                        }
                    ]
                }
            }

        ],
        identifier: [
            {
                id: "89620",
                use: "usual",
                system: "https://standards.digital.health.nz/ns/nhi-id",
                value: "89620"
            }
        ],
        active: true,
        photo: [
            {
                contentType: "image/jpeg",
                language: "en",
                title: "Patient's photo"
            }
        ]
    };
    return patient;
};
