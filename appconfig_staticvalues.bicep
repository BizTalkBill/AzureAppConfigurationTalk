param appconfig_name string = 'appcs-appconfigtalk-demo'
param keyvault_name string = '$(keyvault_name)'

//****************************************************************
// Existing resources
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appconfig_name
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

//****************************************************************
// static values 
//****************************************************************

resource testvalue1 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: 'testvalue1$Demo'
  parent: appconfig
  properties: {
    value: 'test value #1 from App Config'
  }
}

resource testvalue1Local 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: 'testvalue1$LOCAL'
  parent: appconfig
  properties: {
    value: 'test value #1 from App Config using LOCAL'
  }
}

resource keyvaultSecrettestvalue2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'testvalue2'
  parent: keyvault
  properties:{
    value: 'test value #1 from App Config referencing Key Vault'
  }
}

resource testvalue2 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: 'testvalue2$Demo'
  parent: appconfig
  properties: {
    value: '{"uri":"${keyvaultSecrettestvalue2.properties.secretUri}"}'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource Section_Value1 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: 'Section:Value1$Demo'
  parent: appconfig
  properties: {
    value: 'Sectionvalue1'
  }
}

resource Section_Value2 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: 'Section:Value2$Demo'
  parent: appconfig
  properties: {
    value: 'Sectionvalue2'
  }
}

resource Section_Value3 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: 'Section:Value3$Demo'
  parent: appconfig
  properties: {
    value: 'Sectionvalue3'
  }
}
