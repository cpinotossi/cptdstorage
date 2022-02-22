targetScope='resourceGroup'

var parameters = json(loadTextContent('../parameters.json'))
param location string = resourceGroup().location
param myobjectid string
param myip string

module vnetModule 'vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    prefix: parameters.prefix
    location: location
  }
}

module vmModule 'vm.bicep' = {
  name: 'vmDeploy'
  params: {
    prefix: parameters.prefix
    location: location
    username: parameters.username
    password: parameters.password
    myObjectId: myobjectid
    postfix: 'lin'
    privateip: '10.0.0.4'
  }
  dependsOn:[
    vnetModule
  ]
}

module sabModule 'sab.bicep' = {
  name: 'sabDeploy'
  params: {
    prefix: parameters.prefix
    location: location
    myip: myip
    myObjectId: myobjectid
  }
  dependsOn:[
    vnetModule
  ]
}

// module lawModule 'law.bicep' = {
//   name: 'lawDeploy'
//   params:{
//     prefix: parameters.prefix
//     location: location
//   }
//   dependsOn:[
//     sabModule
//   ]
// }
