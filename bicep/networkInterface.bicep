// Parameters
@description('Specifies the name of the Network Interface.')
param name string

// Resources
resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' existing = {
  name: name
}

// Outputs
output privateIPAddress string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
