<!-- TABLE OF CONTENTS -->
## Table of Contents

- [Table of Contents](#table-of-contents)
- [About The Project](#about-the-project)
  - [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Changelog](#changelog)
- [Usage](#usage)
- [Roadmap](#roadmap)
- [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project
Coming from IST Extens, transitioning to IST Administration has brought us a lot of new and exciting possibilities.
Having access to all of our data through EduCloud has given us the ability to control the flow of things much better.
In light of DNP (Digitala nationella prov) we saw the potential of the EduCloud API and that's when this project was born.


### Built With

* [Powershell](https://docs.microsoft.com/en-us/powershell/)
* [VSCode](https://code.visualstudio.com/)
* [EduCloud](https://api.ist.com/ss12000v2-api/)


<!-- GETTING STARTED -->
## Getting Started

First, we're happy that you are here! Hopefully you will find some use for this module in your organisation.
There are a few steps you will need to complete before you can use this module.
Please make sure you've followed each one.

### Prerequisites

* Powershell 5.1
* API key to EduCloud to get access to the API.

### Installation

1. Clone the repo or download it directly from here.
```sh
git clone https://github.com/VMO-IT-avdelningen/ISTAdminAPI.git
```
2. Upon first import of the module, you will only have access to the following cmdlets:
- `New-Secret`
- `Get-Secret`
- `Initialize-SettingsFile`

3. Start by creating a credential file: 
`New-Secret -Name <Name of the file> -Path <Path to store the secret> -Username <The API service account username>`
You will be prompted to enter the password for the service account.
Note that the credential file will only be readable by the account thats creates it, and on the very same machine. So if you are going to automate things with the module, be sure to generate the credential file with the appropriate service account.

4. Open an elevated powershell prompt. This is because when configuring the module the first time, a .checkfile containing the location of the settings file will be created under `$env:ProgramData`.
Run [`Initialize-SettingsFile`](/Docs/Initialize-SettingsFile.md) and provide it with your CustomerId eg. SE00100
A popup window will appear asking you to select a folder to store your settings. The settings will be stored in .CSV format.
Another popup window will appear asking you to locate your credential file. This will be the file that you previously created with the `New-Secret` Cmdlet.

5. Import the module again, this time with the `-Force` parameter to ensure the module loads your settings.

6. See each Cmdlet [help section](/Docs/) for further usage.

## Changelog

`ISTAdminAPI` is currently only maintained by one person. I will try to add as many features as possible.
- Version 0.0.1.2 - 2024-04-19
  - [x] Added documentation for all the public cmdlets. Find them under [/Docs](/Docs/)
  - [x] Rewritten a few steps when constructing the request url.
  - [x] Clean up of [Initialize-SettingsFile](/Docs/Initialize-SettingsFile.md)
  - [x] New cmdlet:
    - [x] [`Get-ISTGroup`](/Docs/Get-ISTGroup.md) - Retrieve your groups
    - [x] Parameters:
      - `[string[]]GroupType`
      - `[string[]]SchoolType`
      - `[guid[]]Parent`
      - `[guid]Id`
      - `[guid[]]LookUp`
      - `[switch]ExpandAssignmentRole`
      - `[string]StartDateOnOrBefore`
      - `[string]StartDateOnOrAfter`
      - `[string]EndDateOnOrBefore`
      - `[string]EndDateOnOrAfter`
- Version 0.0.1.1 - 2024-04-15
  - [x] Repository made public
  - [x] New cmdlet:
    - [x] [`Get-ISTOrganisation`](/Docs/Get-ISTOrganisation.md) - Retrieve your organisations
    - [x] Parameters:
      - `[string[]]OrgType`
      - `[string[]]SchoolType`
      - `[guid]Id`
      - `[guid[]]Parent`
      - `[guid[]]LookUp_Ids`
      - `[string[]]LookUp_SchoolUnitCodes`
      - `[string[]]LookUp_OrganisationCodes`
- Version 0.0.1.0 - 2024-04-02
  - [x] First commit.
  - [x] Available public cmdlets:
    - [x] [`Get-ISTPerson`](/Docs/Get-ISTPerson.md) - Retrieve users/persons from the EduCloud API.
    - [x] Parameters: 
      - `[string]NameContains`
      - `[string]CivicNo`
      - `[guid]Id`
      - `[string]RelationshipEntity`
      - `[guid]RelationshipOrganisation`
      - `[guid[]]LookUp`
      - `[string]LookUpType`
      - `[string]ExpandProperties`
      - `[string]StartDateOnOrBefore`
      - `[string]StartDateOnOrAfter`
      - `[string]EndDateOnOrBefore`
      - `[string]EndDateOnOrAfter`
    - [x] [`Get-ISTDuty`](/Docs/Get-ISTDuty.md) - Retrieve one or multiple duties connected to an organisation.
    - [x] Parameters: 
      - `[guid]Organisation`
      - `[string]DutyRole`
      - `[guid]PersonId`
      - `[guid]Id`
      - `[guid[]]LookUp`
      - `[switch]ExpandPerson`
      - `[string]StartDateOnOrBefore`
      - `[string]StartDateOnOrAfter`
      - `[string]EndDateOnOrBefore`
      - `[string]EndDateOnOrAfter`
<!-- USAGE EXAMPLES -->
## Usage
Take a look at the documentation under [/Docs](/Docs/). There are plenty of examples to help you get started.

You can also utilize the powershell help function like this: 
```powershell
Get-Help -Name Get-ISTOrganisation -Full
```

<!-- ROADMAP -->
## Roadmap

 - [ ] Adding compability for handling programmes
 - [ ] Adding compability for handling studyplans
 - [ ] Adding compability for handling syllabuses
 - [x] Adding compability for handling groups (2024-04-19 - v.0.0.1.2)


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
IST team for the very well documented API [EduCloud](https://api.ist.com/ss12000v2-api/)