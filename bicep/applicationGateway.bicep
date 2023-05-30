// Parameters
@description('Specifies the name of the Application Gateway.')
param name string

@description('Specifies the sku of the Application Gateway.')
param skuName string = 'WAF_v2'

@description('Specifies the frontend IP configuration type.')
@allowed([
  'Public'
  'Private'
  'Both'
])
param frontendIpConfigurationType string

@description('Specifies the name of the public IP adddress used by the Application Gateway.')
param publicIpAddressName string = '${name}PublicIp'

@description('Specifies the location of the Application Gateway.')
param location string

@description('Specifies the resource tags.')
param tags object

@description('Specifies the resource id of the subnet used by the Application Gateway.')
param subnetId string

@description('Specifies the resource id of the subnet used by the Application Gateway Private Link.')
param privateLinkSubnetId string

@description('Specifies the private IP address of the Application Gateway.')
param privateIpAddress string

@description('Specifies the availability zones of the Application Gateway.')
param availabilityZones array

@description('Specifies the workspace id of the Log Analytics used to monitor the Application Gateway.')
param workspaceId string

@description('Specifies the lower bound on number of Application Gateway capacity.')
param minCapacity int = 1

@description('Specifies the upper bound on number of Application Gateway capacity.')
param maxCapacity int = 10

@description('Specifies whether create or not a Private Link for the Application Gateway.')
param privateLinkEnabled bool = false

@description('Specifies the name of the WAF policy')
param wafPolicyName string = '${name}WafPolicy'

@description('Specifies the mode of the WAF policy.')
@allowed([
  'Detection'
  'Prevention'
])
param wafPolicyMode string = 'Prevention'

@description('Specifies the state of the WAF policy.')
@allowed([
  'Enabled'
  'Disabled '
])
param wafPolicyState string = 'Enabled'

@description('Specifies the maximum file upload size in Mb for the WAF policy.')
param wafPolicyFileUploadLimitInMb int = 100

@description('Specifies the maximum request body size in Kb for the WAF policy.')
param wafPolicyMaxRequestBodySizeInKb int = 128

@description('Specifies the whether to allow WAF to check request Body.')
param wafPolicyRequestBodyCheck bool = true

@description('Specifies the rule set type.')
param wafPolicyRuleSetType string = 'OWASP'

@description('Specifies the rule set version.')
param wafPolicyRuleSetVersion string = '3.2'

@description('Specifies the name of the Key Vault resource.')
param keyVaultName string

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var applicationGatewayResourceId = resourceId('Microsoft.Network/applicationGateways', name)
var keyVaultSecretsUserRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var gatewayIPConfigurationName = 'DefaultGatewayIpConfiguration'
var frontendPortName = 'DefaultFrontendPort'
var backendAddressPoolName = 'DefaultBackendPool'
var backendHttpSettingsName = 'DefaultBackendHttpSettings'
var httpListenerName = 'DefaultHttpListener'
var routingRuleName = 'DefaultRequestRoutingRule'
var privateLinkName = 'DefaultPrivateLink'
var publicFrontendIPConfigurationName = 'PublicFrontendIPConfiguration'
var privateFrontendIPConfigurationName = 'PrivateFrontendIPConfiguration'
var frontendIPConfigurationName = frontendIpConfigurationType == 'Public' ? publicFrontendIPConfigurationName : privateFrontendIPConfigurationName
var applicationGatewayZones = !empty(availabilityZones) ? availabilityZones : []

var publicFrontendIPConfiguration = {
  name: publicFrontendIPConfigurationName
  properties: {
    privateIPAllocationMethod: 'Dynamic'
    publicIPAddress: {
      id: applicationGatewayPublicIpAddress.id
    }
    privateLinkConfiguration: privateLinkEnabled && frontendIpConfigurationType == 'Public' ? {
      id: '${applicationGatewayResourceId}/privateLinkConfigurations/${privateLinkName}'
    } : null
  }
}

var privateFrontendIPConfiguration = {
  name: privateFrontendIPConfigurationName
  properties: {
    privateIPAllocationMethod: 'Static'
    privateIPAddress: privateIpAddress
    subnet: {
      id: subnetId
    }
    privateLinkConfiguration: privateLinkEnabled && frontendIpConfigurationType != 'Public'? {
      id: '${applicationGatewayResourceId}/privateLinkConfigurations/${privateLinkName}'
    } : null
  }
}

var frontendIPConfigurations = union(
  frontendIpConfigurationType == 'Public' ? array(publicFrontendIPConfiguration) : [],
  frontendIpConfigurationType == 'Private' ? array(privateFrontendIPConfiguration) : [],
  frontendIpConfigurationType == 'Both' ? concat(array(publicFrontendIPConfiguration), array(privateFrontendIPConfiguration)) : []
)

var sku = union({
    name: skuName
    tier: skuName
  }, maxCapacity == 0 ? {
    capacity: minCapacity
  } : {})

var applicationGatewayProperties = union({
    sku: sku
    gatewayIPConfigurations: [
      {
        name: gatewayIPConfigurationName
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: [
      {
        name: frontendPortName
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayResourceId}/frontendIPConfigurations/${frontendIPConfigurationName}'
          }
          frontendPort: {
            id: '${applicationGatewayResourceId}/frontendPorts/${frontendPortName}'
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: routingRuleName
        properties: {
          ruleType: 'Basic'
          priority: 1000
          httpListener: {
            id: '${applicationGatewayResourceId}/httpListeners/${httpListenerName}'
          }
          backendAddressPool: {
            id: '${applicationGatewayResourceId}/backendAddressPools/${backendAddressPoolName}'
          }
          backendHttpSettings: {
            id: '${applicationGatewayResourceId}/backendHttpSettingsCollection/${backendHttpSettingsName}'
          }
        }
      }
    ]
    privateLinkConfigurations: privateLinkEnabled ? [
      {
        name: privateLinkName
        properties: {
          ipConfigurations: [
            {
              name: 'PrivateLinkDefaultIPConfiguration'
              properties: {
                privateIPAllocationMethod: 'Dynamic'
                subnet: {
                  id: privateLinkSubnetId
                }
              }
            }
          ]
        }
      }
    ] : []
    firewallPolicy: {
      id: wafPolicy.id
    }
  }, maxCapacity > 0 ? {
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
  } : {})

var applicationGatewayLogCategories = [
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayFirewallLog'
  'ApplicationGatewayPerformanceLog'
]
var applicationGatewayMetricCategories = [
  'AllMetrics'
]
var applicationGatewayLogs = [for category in applicationGatewayLogCategories: {
  category: category
  enabled: true
}]
var applicationGatewayMetrics = [for category in applicationGatewayMetricCategories: {
  category: category
  enabled: true
}]

// Resources
resource applicationGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${name}Identity'
  location: location
}

resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = if (frontendIpConfigurationType != 'Private') {
  name: publicIpAddressName
  location: location
  zones: applicationGatewayZones
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: name
  location: location
  tags: tags
  zones: applicationGatewayZones
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayIdentity.id}': {}
    }
  }
  properties: applicationGatewayProperties
}

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-07-01' = {
  name: wafPolicyName
  location: location
  tags: tags
  properties: {
    customRules: [
      {
        name: 'BlockMe'
        priority: 1
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'QueryString'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'blockme'
            ]
          }
        ]
      }
      {
        name: 'BlockEvilBot'
        priority: 2
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'User-Agent'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'evilbot'
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: wafPolicyRequestBodyCheck
      maxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
      fileUploadLimitInMb: wafPolicyFileUploadLimitInMb
      mode: wafPolicyMode
      state: wafPolicyState
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: wafPolicyRuleSetType
          ruleSetVersion: wafPolicyRuleSetVersion
        }
      ]
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource keyVaultSecretsUserApplicationGatewayIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, applicationGatewayIdentity.name, 'keyVaultSecretsUser')
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleDefinitionId
    principalType: 'ServicePrincipal'
    principalId: applicationGatewayIdentity.properties.principalId
  }
}

resource applicationGatewayDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: applicationGateway
  properties: {
    workspaceId: workspaceId
    logs: applicationGatewayLogs
    metrics: applicationGatewayMetrics
  }
}

// Outputs
output id string = applicationGateway.id
output name string = applicationGateway.name
output privateLinkFrontendIPConfigurationName string = privateLinkEnabled ? frontendIPConfigurationName : ''
output principalId string = applicationGatewayIdentity.properties.principalId
