# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_application"></a> [application](#input\_application)

Description: Unique identifier for the deployment

Type: `any`

### <a name="input_env"></a> [env](#input\_env)

Description: Environment acronym for deployment

Type: `any`

### <a name="input_location"></a> [location](#input\_location)

Description: Location for the deployment

Type: `any`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Default tags for the deployment

Type: `map(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_env_type"></a> [env\_type](#input\_env\_type)

Description: Environment grouping for shared hub (live/nonlive)

Type: `string`

Default: `"nonlive"`

### <a name="input_location_map"></a> [location\_map](#input\_location\_map)

Description: Azure location map used for naming abberviations

Type: `map(string)`

Default:

```json
{
  "Australia Central": "CAU",
  "Australia Central 2": "CAU2",
  "Australia East": "EAU",
  "Australia Southeast": "SEAU",
  "Brazil South": "SBR",
  "Canada Central": "CAC",
  "Canada East": "ECA",
  "Central India": "CIN",
  "Central US": "CUS",
  "East Asia": "EAA",
  "East US": "EUS",
  "East US 2": "EUS2",
  "France Central": "CFR",
  "France South": "SFR",
  "Germany North": "NGE",
  "Germany West Central": "WCGE",
  "Japan East": "EJA",
  "Japan West": "WJA",
  "Korea Central": "CKO",
  "Korea South": "SKO",
  "North Central US": "NCUS",
  "North Europe": "NEU",
  "South Africa North": "NSA",
  "South Africa West": "WSA",
  "South Central US": "SCUS",
  "South India": "SIN",
  "Southeast Asia": "SEA",
  "UAE Central": "CUA",
  "UAE North": "NUA",
  "UK South": "UKS",
  "UK West": "WUK",
  "West Central US": "WCUS",
  "West Europe": "WEU",
  "West India": "WIN",
  "West US": "WUS",
  "West US 2": "WUS2",
  "australiacentral": "CAU",
  "australiacentral2": "CAU2",
  "australiaeast": "EAU",
  "australiasoutheast": "SEAU",
  "brazilsouth": "SBR",
  "canadacentral": "CAC",
  "canadaeast": "ECA",
  "centralindia": "CIN",
  "centralus": "CUS",
  "eastasia": "EAA",
  "eastus": "EUS",
  "eastus2": "EUS2",
  "francecentral": "CFR",
  "francesouth": "SFR",
  "germanynorth": "NGE",
  "germanywestcentral": "WCGE",
  "japaneast": "EJA",
  "japanwest": "WJA",
  "koreacentral": "CKO",
  "koreasouth": "SKO",
  "northcentralus": "NCUS",
  "northeurope": "NEU",
  "southafricanorth": "NSA",
  "southafricawest": "WSA",
  "southcentralus": "SCUS",
  "southeastasia": "SEA",
  "southindia": "SIN",
  "uaecentral": "CUA",
  "uaenorth": "NUA",
  "uksouth": "UKS",
  "ukwest": "WUK",
  "westcentralus": "WCUS",
  "westeurope": "WEU",
  "westindia": "WIN",
  "westus": "WUS",
  "westus2": "WUS2"
}
```

## Outputs

The following outputs are exported:

### <a name="output_names"></a> [names](#output\_names)

Description: Return list of calculated standard names for the deployment.
