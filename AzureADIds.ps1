
#param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'
#param AppConfigReaderGroupId string = '$(AppConfigReaderGroupId)'
#param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
#param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

Get-AzADServicePrincipal -DisplayNameStartsWith biztalkbill-AzureAppConfigurationTalk
$AzureDevOpsServiceConnectionId = (Get-AzADServicePrincipal -DisplayNameStartsWith biztalkbill-AzureAppConfigurationTalk).Id
Write-Host "##vso[task.setvariable variable=AzureDevOpsServiceConnectionId;]$AzureDevOpsServiceConnectionId"

Get-AzADGroup -DisplayName AppConfigTalkAppConfigAdministrators
$AppConfigAdministratorsGroupId = (Get-AzADGroup -DisplayName AppConfigTalkAppConfigAdministrators).Id
Write-Host "##vso[task.setvariable variable=AppConfigAdministratorsGroupId;]$AppConfigAdministratorsGroupId"

Get-AzADGroup -DisplayName AppConfigTalkAppConfigReader
$AppConfigReaderGroupId = (Get-AzADGroup -DisplayName AppConfigTalkAppConfigReader).Id
Write-Host "##vso[task.setvariable variable=AppConfigReaderGroupId;]$AppConfigReaderGroupId"

Get-AzADGroup -DisplayName AppConfigTalkKeyVaultAdministrators
$KeyVaultAdministratorsGroupId = (Get-AzADGroup -DisplayName AppConfigTalkKeyVaultAdministrators).Id
Write-Host "##vso[task.setvariable variable=KeyVaultAdministratorsGroupId;]$KeyVaultAdministratorsGroupId"

Get-AzADGroup -DisplayName AppConfigTalkKeyVaultReader
$KeyVaultReaderGroupId = (Get-AzADGroup -DisplayName AppConfigTalkKeyVaultReader).Id
Write-Host "##vso[task.setvariable variable=KeyVaultReaderGroupId;]$KeyVaultReaderGroupId"