// Parameters
@description('Specifies the name of the existing AKS cluster.')
param aksClusterName string

@description('Specifies the name of the existing container registry.')
param acrName string

// Variables
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// Resources
resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-03-02-preview' existing = {
  name: aksClusterName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: acrName
}

resource acrPullRoleAssignmentName 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aksCluster.name, containerRegistry.id, acrPullRoleDefinitionId)
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: any(aksCluster.properties.identityProfile.kubeletidentity).objectId
    principalType: 'ServicePrincipal'
  }
}
