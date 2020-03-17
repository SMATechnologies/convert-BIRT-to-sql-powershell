# Convert BIRT to SQL with Powershell
This script reads through all the "BIRT" OpCon reports and and strips out the root SQL queries.  The query information can optionally be send to an OpCon job for immediate execution.

# Prerequisites
* OpCon Release 18.3
* PowerShell 5.1

# Instructions
This script should be run on the SAM OpCon server and has a number of parameters that match to the corresponding parameters when automating BIRT reports through the traditional method (see OpCon documentation for "BIRT Report Generator").

Parameters:
* <b>skddate</b> - Same as BIRT
* <b>histarc_skddate</b> - Same as BIRT
* <b>history_skddate</b> - Same as BIRT
* <b>audithst_sqldate</b> - Same as BIRT
* <b>machs_machid</b> - Same as BIRT
* <b>machgrps_machgrpid</b> - Same as BIRT
* <b>skdid</b> - Same as BIRT
* <b>deptid</b> - Same as BIRT
* <b>tagname</b> - Same as BIRT
* <b>birthpath</b> - Path to the BIRT report directory, default is: C:\Program Files\OpConxps\SAM\BIRT\ReportEngine\OpConXPS_Reports
* <b>o</b> - Same as BIRT
* <b>runas</b> - User permissions to simulate when building the query
* <b>opconmodule</b> - Path to the OpCon API module (available in the Innovation Lab <a href="https://github.com/SMATechnologies/opcon-rest-api-client-powershell">here</a>)
* <b>r</b> - Same as BIRT
* <b>report</b> - Name of report to run
* <b>msgin</b> - Path to MSGIN directory
* <b>extuser</b> - External event user (MSGIN only)
* <b>extpword</b> - External event password (MSGIN only)
* <b>email</b> - Email address to send the report results
* <b>run</b> - Yes/No whether to submit an OpCon event to run the report
* <b>url</b> - OpCon API url (instead of MSGIN)
* <b>token</b> - OpCon API token (instead of MSGIN)


# Disclaimer
No Support and No Warranty are provided by SMA Technologies for this project and related material. The use of this project's files is on your own risk.

SMA Technologies assumes no liability for damage caused by the usage of any of the files offered here via this Github repository.

# License
Copyright 2020 SMA Technologies

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Contributing
We love contributions, please read our [Contribution Guide](CONTRIBUTING.md) to get started!

# Code of Conduct
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code-of-conduct.md)
SMA Technologies has adopted the [Contributor Covenant](CODE_OF_CONDUCT.md) as its Code of Conduct, and we expect project participants to adhere to it. Please read the [full text](CODE_OF_CONDUCT.md) so that you can understand what actions will and will not be tolerated.
