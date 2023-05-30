// Parameters
@description('Specifies the name of the Azure OpenAI resource.')
param name string = 'aks-${uniqueString(resourceGroup().id)}'

@description('Specifies the resource model definition representing SKU.')
param sku object = {
  name: 'S0'
}

@description('Specifies the identity of the OpenAI resource.')
param identity object = {
  type: 'SystemAssigned'
}

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

@description('Specifies an optional subdomain name used for token-based authentication.')
param customSubDomainName string = ''

@description('Specifies whether or not public endpoint access is allowed for this account..')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Specifies the OpenAI deployments to create.')
param deployments array = [
  {
    name: 'text-embedding-ada-002'
    version: '2'
    raiPolicyName: ''
    capacity: 1
    scaleType: 'Standard'
  }
  {
    name: 'gpt-35-turbo'
    version: '0301'
    raiPolicyName: ''
    capacity: 1
    scaleType: 'Standard'
  }
  {
    name: 'text-davinci-003'
    version: '1'
    raiPolicyName: ''
    capacity: 1
    scaleType: 'Standard'
  }
]

@description('Specifies the workspace id of the Log Analytics used to monitor the Application Gateway.')
param workspaceId string

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var openAiLogCategories = [
  'Audit'
  'RequestResponse'
  'Trace'
]
var openAiMetricCategories = [
  'AllMetrics'
]
var openAiLogs = [for category in openAiLogCategories: {
  category: category
  enabled: true
}]
var openAiMetrics = [for category in openAiMetricCategories: {
  category: category
  enabled: true
}]

// Resources
resource openAi 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: name
  location: location
  sku: sku
  kind: 'OpenAI'
  identity: identity
  tags: tags
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: publicNetworkAccess
  }
}

resource model 'Microsoft.CognitiveServices/accounts/deployments@2022-12-01' = [for deployment in deployments: {
  name: deployment.name
  parent: openAi
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.name
      version: deployment.version
    }
    raiPolicyName: deployment.raiPolicyName
    scaleSettings: {
      capacity: deployment.capacity
      scaleType: deployment.scaleType
    }
  }
}]

resource openAiDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: openAi
  properties: {
    workspaceId: workspaceId
    logs: openAiLogs
    metrics: openAiMetrics
  }
}

// Outputs
output id string = openAi.id
output name string = openAi.name
