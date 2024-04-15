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

First, I'm glad you're here. Hopefully you will find this module to some use for your organisation.
There are a few steps you will need to complete before you can use this module.
Please make sure you've followed each one.

### Prerequisites

* Powershell 5.1
* API key to EduCloud to get access to the API.

### Installation

1. Clone the repo
```sh
git clone https://github.com/th3d00rw4y/ISTAdminAPI.git
```
2. Upon first import of the module, you will only have access to the following Cmdlets:
`New-Secret`, `Get-Secret`, `Initialize-SettingsFile`

3. Start by creating a credential file: `New-Secret -Name <Name of the file> -Path <Path to store the secret> -Username <The API service account username>`
You will be prompted to enter the password for the service account.
Note that the credential file will only be useable by the account thats creates it, and on the very same machine.

4. Run `Initialize-SettingsFile` and provide it with your CustomerId eg. SE00100
A popup window will appear asking you to select a folder to store your settings. The settings will be stored in .CSV format.
Another popup window will appear asking you to locate your credential file. This will be the file that you previously created with the `New-Secret` Cmdlet.

5. Import the module again, this time with the -Force parameter to ensure the module loads your settings.

6. See each Cmdlet help section for further usage.

## Changelog

`ISTAdminAPI` is currently only maintained by me. I will try to add as many features as possible.
- Version 0.0.1.1 - 2024.04-15
  - [x] Repository made public
  - [ ] New cmdlets:
    - [x] `Get-ISTOrganisation` - Retrieve your organisations
    - [x] Parameters:
      - `[string[]]`OrgType
      - `[string[]]`SchoolType
      - `[guid]`Id
      - `[switch]`Parent
  - [x] `Get-ISTStudentGroup` - Retrieve your student groups.
    - [x] Parameters:
      - `[string]`Id
      - `[string]`GroupType
      - `[string]`Parent
      - `[string]`SchoolType
- Version 0.0.1.0 - 2024.04.02
  - [x] First commit.
  - [x] Available but not finished public cmdlets:
    - [x] `Get-ISTPerson` - Retrieve users/persons from the EduCloud API.
    - [x] Parameters: 
      - `[string]`NameContains
      - `[string]`CivicNo
      - `[guid]`Id
      - `[string]`RelationshipEntity
      - `[guid]`RelationshipOrganisation
      - `[guid[]]`LookUp
      - `[string]`LookUpType
      - `[string]`ExpandProperties
      - `[string]`StartDateOnOrBefore
      - `[string]`StartDateOnOrAfter
      - `[string]`EndDateOnOrBefore
      - `[string]`EndDateOnOrAfter
    - [x] `Get-ISTDuty` - Retrieve one or multiple duties connected to an organisation.
    - [x] Parameters: 
      - `[guid]`Organisation
      - `[string]`DutyRole
      - `[guid]`PersonId
      - `[guid]`Id
      - `[guid[]]`LookUp
      - `[switch]`ExpandPerson
      - `[string]`StartDateOnOrBefore
      - `[string]`StartDateOnOrAfter
      - `[string]`EndDateOnOrBefore
      - `[string]`EndDateOnOrAfter
  - [x] Currently under construction:
    - [x] `Get-ISTSchoolUnit`
<!-- USAGE EXAMPLES -->
## Usage

Get-Help `Function-Name` -Full


<!-- ROADMAP -->
## Roadmap

 - [x] Adding compability for handling programmes

 - [x] Adding compability for handling studyplans

 - [x] Adding compability for handling syllabuses


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
IST team for the very well documented API [EduCloud](https://api.ist.com/ss12000v2-api/)