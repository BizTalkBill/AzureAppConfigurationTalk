param BaseName string = 'AppConfigTalk'
param BaseShortName string = 'act'
param EnvironmentName string = 'Demo'
param EnvironmentShortName string = 'Demo'
param AppLocation string = resourceGroup().location
//tags
param LocationTag string = resourceGroup().location
param OwnerTag string = 'MVP'
param OrganisationTag string = 'AppConfigTalk'
param EnvironmentTag string = 'Demo'
param ApplicationTag string = 'AppConfigTalk'
// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'
param AppConfigReaderGroupId string = '$(AppConfigReaderGroupId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

@allowed([
  'A'
])
param KeyVaultSKUFamily string = 'A'

@allowed([
  'standard'
  'premium'
])
param KeyVaultSKUName string = 'standard'

@allowed([
  'Basic'
  'Free'
  'Standard'
])
param integrationAccountSku string = 'Free'

@allowed([
  'Free'
  'Standard'
])
param appConfigSku string = 'Free'
// param VendorAPIKey string = 'Demo'
// param ASNAPIKey string = 'Demo'
// param apim_environmentType string = 'Non-Production'
// param apim_environment string = 'dev'

var appconfig_name = 'appcs-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var loganalyticsWorkspace_name = 'log-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var appInsights_name = 'appi-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var apim_name = 'apim-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var integrationAccount_name = 'ia-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var keyvault_name = 'kv-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var storage_name = 'st${toLower(BaseName)}${toLower(EnvironmentName)}'

var functionHostingPlanName = 'asp-func-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var functionStorageName = 'stfunc${toLower(BaseName)}${toLower(EnvironmentName)}'
var functionAppName = 'func-${toLower(BaseName)}-${toLower(EnvironmentName)}'

var LogicAppStdHostingPlanName = 'asp-logic-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var LogicAppStdStorageName = 'stlogic${toLower(BaseName)}${toLower(EnvironmentName)}'
var LogicAppStdAppName = 'logic-${toLower(BaseName)}-${toLower(EnvironmentName)}'

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
var keyvaultadministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var keyvaultsecretuser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var appconfigdataowner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
var appconfigdatareader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

var storageaccountcontributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')

//****************************************************************
// Azure App Config
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appconfig_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: appConfigSku
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource appconfigAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appconfig
  name: 'AuditSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'Audit'
        enabled: true
      }
    ]
  }
}

resource appconfigDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appconfig
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        category: 'HttpRequest'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource appconfigRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AzureDevOpsServiceConnectionId, appconfigdataowner)
  properties: {
    roleDefinitionId: appconfigdataowner
    principalId: AzureDevOpsServiceConnectionId
    principalType: 'ServicePrincipal'
  }
}

resource appconfigRoleAssignmentAppConfigAdministratorsGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AppConfigAdministratorsGroupId, appconfigdataowner)
  properties: {
    roleDefinitionId: appconfigdataowner
    principalId: AppConfigAdministratorsGroupId
    principalType: 'Group'
  }
}

resource appconfigRoleAssignmentAppConfigReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AppConfigReaderGroupId, appconfigdatareader)
  properties: {
    roleDefinitionId: appconfigdatareader
    principalId: AppConfigReaderGroupId
    principalType: 'Group'
  }
}

module nestedTemplateAppConfigAppConfigEndpoint './nestedTemplateAppConfig.bicep' = {
  name: 'appconfig-endpoint'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'appconfig_endpoint'
    variables_value: appconfig.properties.endpoint
    variables_contentType: ''
  }
}

//****************************************************************
// Azure Log Anaytics Workspace
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: loganalyticsWorkspace_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource keyvaultSecretLogAnalyticsPrimaryKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'loganalytics-primarykey'
  parent: keyvault
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties:{
    value: loganalyticsWorkspace.listKeys().primarySharedKey
  }
}

module nestedTemplateAppConfigLogAnalyticsPrimaryKey './nestedTemplateAppConfig.bicep' = {
  name: 'loganalyticsworkspace_primarykey'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'loganalyticsworkspace_primarykey'
    variables_value: '{"uri":"${keyvaultSecretLogAnalyticsPrimaryKey.properties.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

module nestedTemplateAppConfigloganalyticsWorkspacename './nestedTemplateAppConfig.bicep' = {
  name: 'loganalyticsworkspace-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'loganalyticsworkspace_name'
    variables_value: loganalyticsWorkspace.name
  }
}

module nestedTemplateAppConfigloganalyticsWorkspaceresourcegroup './nestedTemplateAppConfig.bicep' = {
  name: 'loganalyticsworkspace-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'loganalyticsworkspace_resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure Application Insights
//****************************************************************

resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsights_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  kind:'web'
  properties:{
    Application_Type:'web'
    Request_Source: 'rest'
    WorkspaceResourceId: loganalyticsWorkspace.id
  }
}

module nestedTemplateAppConfigAppInsightsname './nestedTemplateAppConfig.bicep' = {
  name: 'appinsights-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'appinsights_name'
    variables_value: appinsights.name
  }
}

module nestedTemplateAppConfigAppInsightsresourcegroup './nestedTemplateAppConfig.bicep' = {
  name: 'appinsights-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'appinsights_resourcegroup'
    variables_value: resourceGroup().name
  }
}

resource keyvaultSecretAppInsightsInstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'appinsights-instrumentationKey'
  parent: keyvault
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties:{
    value: appinsights.properties.InstrumentationKey
  }
}

module nestedTemplateAppConfigAppInsightsInstrumentationKey './nestedTemplateAppConfig.bicep' = {
  name: 'appinsights-InstrumentationKey'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'appinsights-instrumentationKey'
    variables_value: '{"uri":"${keyvaultSecretAppInsightsInstrumentationKey.properties.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource keyvaultSecretAppInsightsConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'applicationinsights-connectionstring'
  parent: keyvault
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties:{
    value: appinsights.properties.ConnectionString
  }
}

module nestedTemplateAppConfigAppInsightsConnectionString './nestedTemplateAppConfig.bicep' = {
  name: 'applicationinsights-connectionstring'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'applicationinsights_connectionstring'
    variables_value: '{"uri":"${keyvaultSecretAppInsightsConnectionString.properties.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

//****************************************************************
// Azure Key Vault
//****************************************************************

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyvault_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties: {
    sku: {
      family: KeyVaultSKUFamily
      name: KeyVaultSKUName
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
  }
}

resource keyvaultAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyvault
  name: 'AuditSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'Audit'
        enabled: true
      }
    ]
  }
}

resource keyvaultDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyvault
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource keyvaultRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, AzureDevOpsServiceConnectionId, keyvaultadministrator)
  properties: {
    roleDefinitionId: keyvaultadministrator
    principalId: AzureDevOpsServiceConnectionId
    principalType: 'ServicePrincipal'
  }
}

resource keyvaultRoleAssignmentKeyVaultAdministratorsGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, KeyVaultAdministratorsGroupId, keyvaultadministrator)
  properties: {
    roleDefinitionId: keyvaultadministrator
    principalId: KeyVaultAdministratorsGroupId
    principalType: 'Group'
  }
}

resource keyvaultRoleAssignmentKeyVaultReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, KeyVaultReaderGroupId, keyvaultsecretuser)
  properties: {
    roleDefinitionId: keyvaultsecretuser
    principalId: KeyVaultReaderGroupId
    principalType: 'Group'
  }
}

module nestedTemplateAppConfigkeyvaultname './nestedTemplateAppConfig.bicep' = {
  name: 'keyvault-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'keyvault_name'
    variables_value: keyvault.name
  }
}

module nestedTemplateAppConfigkeyvaultresourcegroup './nestedTemplateAppConfig.bicep' = {
  name: 'keyvault-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'keyvault_resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure API Management
//****************************************************************

resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apim_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'bill@biztalkbill.com'
    publisherName: ApplicationTag
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    virtualNetworkType: 'None'
    enableClientCertificate: false
    apiVersionConstraint: {}
  }
}

resource keyvaultRoleAssignmentAPIM 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, apim.name, keyvaultsecretuser)
  properties: {
    roleDefinitionId: keyvaultsecretuser
    principalId: apim.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

module apimNameNestedTemplateAppConfig './nestedTemplateAppConfig.bicep' = {
  name: 'apimNameNestedTemplateAppConfig'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'apim_name'
    variables_value: apim.name
  }
}

module apimResourceGroupNestedTemplateAppConfig './nestedTemplateAppConfig.bicep' = {
  name: 'apimResourceGroupNestedTemplateAppConfig'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'apim_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module apimIdentityNestedTemplateAppConfig './nestedTemplateAppConfig.bicep' = {
  name: 'apimIdentityNestedTemplateAppConfig'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'apim_identity'
    variables_value: apim.identity.principalId
  }
}

resource apiManagementAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apim
  name: 'AuditSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'Audit'
        enabled: true
      }
    ]
  }
}

// resource apiManagementDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: apim
//   name: 'DiagnosticSettings'
//   properties: {
//     workspaceId: loganalyticsWorkspace.id
//     // logs: [
//     //   {
//     //     categoryGroup: 'allLogs'
//     //     enabled: true
//     //   }
//     // ]
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
// }

resource apiManagementLogging 'Microsoft.ApiManagement/service/loggers@2021-08-01'={
  name:'${appinsights.name}-logger'
  parent: apim
  properties:{
    loggerType:'applicationInsights'
    description:'Logger resources for APIM'
    credentials:{
      instrumentationKey:appinsights.properties.InstrumentationKey 
    }
  }
}

module apimLoggerNameNestedTemplateAppConfig './nestedTemplateAppConfig.bicep' = {
  name: 'apimLoggerNameNestedTemplateAppConfig'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'apimLogger_name'
    variables_value: apiManagementLogging.name
  }
}

resource apimAppInsights 'Microsoft.ApiManagement/service/diagnostics@2022-09-01-preview' = {
  name: 'applicationinsights'
  parent: apim
  properties:{
    loggerId: apiManagementLogging.id
    alwaysLog: 'allErrors'
  }
}


//****************************************************************
// Azure Function App Hosting Plan
//****************************************************************

resource functionHostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: functionHostingPlanName
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

module nestedTemplateAppConfigfunctionHostingPlanName './nestedTemplateAppConfig.bicep' = {
  name: 'functionhostingplan-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'functionhostingplan_name'
    variables_value: functionHostingPlan.name
  }
}

module nestedTemplateAppConfigfunctionHostingPlanResourcegroup './nestedTemplateAppConfig.bicep' = {
  name: 'functionhostingplan-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'functionhostingplan_resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure Logic App Std Hosting Plan
//****************************************************************

resource LogicAppStdHostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: LogicAppStdHostingPlanName
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  kind:'elastic'
  sku: {
    name: 'WS1'
  }
  properties: {}
}

module nestedTemplateAppConfigLogicAppStdHostingPlanName './nestedTemplateAppConfig.bicep' = {
  name: 'logicappstdhostingplan-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'logicappstdhostingplan_name'
    variables_value: LogicAppStdHostingPlan.name
  }
}

module nestedTemplateAppConfigLogicAppStdHostingPlanResourcegroup './nestedTemplateAppConfig.bicep' = {
  name: 'logicappstdhostingplan-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: EnvironmentName
    variables_key: 'logicappstdhostingplan_resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure Logic App Integration Account
//****************************************************************

resource integrationAccount 'Microsoft.Logic/integrationAccounts@2019-05-01' = {
  name: integrationAccount_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: integrationAccountSku
  }
  properties: {
    state: 'Enabled'
  }
}

resource integrationAccountDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: integrationAccount
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

module nestedTemplateAppConfig1 './nestedTemplateAppConfig.bicep' = {
  name: 'nestedTemplateAppConfig1'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: ''
    variables_key: 'integrationaccount_name'
    variables_value: integrationAccount.name

  }
}

module nestedTemplateAppConfigintegrationaccountresourcegroup './nestedTemplateAppConfig.bicep' = {
  name: 'integrationaccount-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: ''
    variables_key: 'integrationaccount_resourcegroup'
    variables_value: AppLocation

  }
}

//****************************************************************
// Azure Storage for Logic App Consumption 
//****************************************************************

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storage_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

module nestedTemplateAppConfigstoragename './nestedTemplateAppConfig.bicep' = {
  name: 'storage-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: ''
    variables_key: 'storage_name'
    variables_value: storage.name

  }
}

module nestedTemplateAppConfigstorageresourcegroup './nestedTemplateAppConfig.bicep' = {
  name: 'storage-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfigname: appconfig.name
    variables_environment: ''
    variables_key: 'storage_resourcegroup'
    variables_value: AppLocation

  }
}

resource storageDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: storage
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageBlobDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: blobService
  name: 'BlobDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageFileDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: fileService
  name: 'FileDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageTableDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: tableService
  name: 'TableDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageQueueDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: queueService
  name: 'QueueDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output subscriptionid string = subscription().subscriptionId
output resourcegroupName string = resourceGroup().name
output base_name string = BaseName
output baseshort_name string = BaseShortName
output environment_name string = EnvironmentName
output environmentshort_name string = EnvironmentShortName
output applocation string = AppLocation
output locationtag string = LocationTag
output ownertag string = OwnerTag
output organisationtag string = OrganisationTag
output environmenttag string = EnvironmentTag
output applicationtag string = ApplicationTag
output appconfig_name string = appconfig.name
output appconfig_resourcegroup string = resourceGroup().name
output appconfig_endpoint string = appconfig.properties.endpoint
