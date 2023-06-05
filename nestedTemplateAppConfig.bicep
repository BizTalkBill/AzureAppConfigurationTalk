param variables_appconfigname string
param variables_environment string
param variables_key string
param variables_value string
param variables_contentType string = ''

resource variables_appconfig_name_keyvault_name_Demo 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  name: '${variables_appconfigname}/${variables_key}$${variables_environment}'
  properties: {
    value: variables_value
    contentType: variables_contentType
  }
}

