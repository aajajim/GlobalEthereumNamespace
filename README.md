# GEN or GlobalEthereumNamespace


##Purpose:
This idea of this contract immerged from a limitation of Ethereum that imposes that any update in a deployed Smart Contract
results in the deployement of the new version to a new address.
So when working in a professional project or a general public project where the only way to use you deployed contract is to 
use and communicate the public address, this can be headache if you want to update the code of contract, and where you need
to communicate the new address to all your clients and change your client code too.

GEN or Global Ethereum Namespace helps you not to deal with this. Indeed, it provides a data structure registering minimal
necessary inforamtion about your contract: Name, Address, Version and Owner. 


##Where the contract is located ?
This Global Ethereum Namespace contract is deployed both on the MainNet and on the TestNet.

- **MainNet**: 0x
- **TestNet**: 0x
- **Contract's ABI**: 
    ```
    [{"constant":false,"inputs":[{"name":"_contractName","type":"string"},{"name":"_deploymentAddress","type":"address"},{"name":"_version","type":"string"}],"name":"RegisterContract","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_contractName","type":"string"}],"name":"GetVersion","outputs":[{"name":"_version","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_contractName","type":"string"}],"name":"GetContract","outputs":[{"name":"_deploymentAddress","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_contractName","type":"string"},{"name":"_newDeploymentAddress","type":"address"},{"name":"_newVersion","type":"string"}],"name":"UpdateContract","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"inputs":[],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_contractName","type":"string"},{"indexed":false,"name":"_deploymentAddress","type":"address"},{"indexed":false,"name":"_version","type":"string"}],"name":"registerContract","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_contractName","type":"string"},{"indexed":false,"name":"_newDeploymentAddress","type":"address"},{"indexed":false,"name":"_newVersion","type":"string"}],"name":"updateContract","type":"event"}]
    ```

##How yo use it ?
The contract is quiet simple to use, so that on the:

1. **Developer side**:

    - Register a new contract by calling:
        ```

        function RegisterContract(string _contractName, address _deploymentAddress, uint _version) returns (bool success)
        ```
        Please make sure to test the return result to ensure that your contract has been correctly registered.

    - Update an existing contract by calling:
        ```

            function UpdateContract(string _contractName, address _newAddress, uint _newVersion) returns (bool success)
        ```
        Please make sure to test the return result to ensure that your contract has been correctly updated.

2. **Client side**:

    The only things a client needs from the developer is the GlobalEthereumNamespace address and the smart contract public 
    name. Let's assume this name is "MySmartContract", here is a JavaScript snippet using web3 library (using the TestNet address):
    
    ```
    var gen_abi = [{"constant":false,"inputs":[{"name":"_contractName","type":"string"},{"name":"_deploymentAddress","type":"address"},{"name":"_version","type":"string"}],"name":"RegisterContract","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_contractName","type":"string"}],"name":"GetVersion","outputs":[{"name":"_version","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_contractName","type":"string"}],"name":"GetContract","outputs":[{"name":"_deploymentAddress","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_contractName","type":"string"},{"name":"_newDeploymentAddress","type":"address"},{"name":"_newVersion","type":"string"}],"name":"UpdateContract","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"inputs":[],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_contractName","type":"string"},{"indexed":false,"name":"_deploymentAddress","type":"address"},{"indexed":false,"name":"_version","type":"string"}],"name":"registerContract","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_contractName","type":"string"},{"indexed":false,"name":"_newDeploymentAddress","type":"address"},{"indexed":false,"name":"_newVersion","type":"string"}],"name":"updateContract","type":"event"}]
    var genContract = web3.eth.contarct(gen_abi)
    var globalNamespace = genContract.at("")
    var developerContract = globalNamespace.GetContract("MySmartContract")
    ```

##Usage fees
Registering a new contarct costs 1ETH
Updating an existing contract consts 0.25ETH
These fees are ment to pay for the data storage on the long run but also to work as DoS protection from an attacker that
would send infinite registering calls.

##Donations
If you like this idea and would like to help in continuing this work, you can make a donnation at: 0x673c15d2ac19939e263b7549d600a14d58d0e55d