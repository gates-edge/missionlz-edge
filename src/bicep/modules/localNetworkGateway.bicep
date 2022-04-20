// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param localNetworkAddressPrefixes array = [
  '10.80.0.0/16'
]
param remoteGatewayIpAddress string = '20.141.65.52'
//param tags object = {}

resource vnetGateway 'Microsoft.Network/localNetworkGateways@2021-05-01' = {
  name: name
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: localNetworkAddressPrefixes
    }
    gatewayIpAddress: remoteGatewayIpAddress
  }
}
