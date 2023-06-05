param variables_appconfigname string
param variables_name string
param variables_principalId string
param variables_roledefinition string

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: variables_appconfigname
}

resource logicAppInboundAS2X12RoleAssignmentAppConfig 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, variables_name, variables_roledefinition)
  properties: {
    roleDefinitionId: variables_roledefinition
    principalId: variables_principalId
    principalType: 'ServicePrincipal'
  }
}
