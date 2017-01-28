//---------------------------------------------------------------------------//
//                          GlobalEthereumNamespace
//  @author: Mohammed AAJAJI
//  @email : mohammed.aajaji.freelance@gmail.com
//  
//      This contract aims to work as a global namespace for all existing 
//  smartcontracts on the Ethereum blockchain.
//  Indeed, as there is no way today to update smartcontract code without
//  redeploying it in a new address, this may break clients compatibility as
//  these ones only rely on the contract address.
//  This registery solves this issue. This is done by keeping a reference to
//  the last address refeering to the last version of the contract, while in 
//  client side, they keep using only the smartcontract public name.
//
//---------------------------------------------------------------------------//

pragma solidity ^0.4.8;

/// @title Global Ethereum Namespace contract
contract GlobalEthereumNamespace {

    //------------------------------//
    //          Parameters
    //------------------------------//
    // The contract owner
    address owner;
    // The price in Wei(=1Ether) for registering a new contract.
    // If the ETH/USD goes too high, this parameter would be decreased.
    uint public registryPrice = 1000000000000000000;
    // The price in Wei(=0.25Ether) for updating the version of a registred contract.
    // If the ETH/USD goes too high, this parameter would be decreased.
    uint public updatePrice = 250000000000000000;
    
    //------------------------------//
    //      Namespace data
    //------------------------------//
    // The smart contract information.
    struct Infos {
        address contractOwner;
        string version;
        address deploymentAddress;
        string abi;
        uint lastUpdateTime;
    }
    // The registery of all deployed smart contracts with their latest address and version.
    mapping (string => Infos) deployedContracts;
    // The existing contracts registered
    mapping (string => bool) existingContracts;
    // Total number of registered contracts
    uint public totalRegisteredContracts;

    //------------------------------//
    //          Constructor
    //------------------------------//
    // @dev Constructor of the SmartContracts registery
    function GlobalEthereumNamespace(){
        owner = msg.sender;
        totalRegisteredContracts = 0;
    }

    //------------------------------//
    //          Functions
    //------------------------------//
    // @notice Function allowing to add a new smartcontract to the registery
    // @param _contractName : The public smartcontract name, this the identifier clients will use
    //                        to call your smartcontract
    // @param _deploymentAddress : The address at which the smartcontract has been deployed
    // @param _abi : The public interface of the smartcontract
    // @param _version : The version of you smartcontract 
    function RegisterContract(string _contractName, address _deploymentAddress, string _abi, string _version)
        PayRegister()
        NotRegistred(_contractName)
        payable
    {
        // Get paiement for registering and send back additional ETH
        if(msg.value > registryPrice)
        {
            if(msg.sender.send(msg.value - registryPrice) == false) throw;
        }
        // Add new contract to the registery 
        deployedContracts[_contractName] =  Infos({
            contractOwner : msg.sender,
            version : _version,
            deploymentAddress : _deploymentAddress,
            abi : _abi,
            lastUpdateTime : now
        });
        existingContracts[_contractName] = true;
        totalRegisteredContracts++;
        registerContract(_contractName, _deploymentAddress, _version);
    }

    // @notice Function allowing to update the address of an already registred smartcontract
    // @param _contractName : The public smartcontract name.
    // @param _newDeploymentAddress : The new address of the new version of the smartcontract
    // @param _abi : The public interface of the smartcontract
    // @param _version : The new version of the smartcontract
    function UpdateContract(string _contractName, address _newDeploymentAddress, string _abi, string _newVersion)
        PayUpdate()
        Registred(_contractName)
        OnlyContractOwner(_contractName)
        payable
    {
        // Get Paiement for update and send back additional ETH
        if(msg.value > updatePrice)
        {
            if(msg.sender.send(msg.value - updatePrice) == false) throw;
        }
        // Update contract address
        deployedContracts[_contractName].version = _newVersion;
        deployedContracts[_contractName].deploymentAddress = _newDeploymentAddress;
        deployedContracts[_contractName].abi = _abi;
        deployedContracts[_contractName].lastUpdateTime = now;
        updateContract(_contractName, _newDeploymentAddress, _newVersion);
    }

    //@notice Function returning all information of a smartcontract registered in this
    //        GlobalEthereumNamespace
    //@param _contractName : The public smartcontract name.
    //@return _deploymentAddress : The public address of the last known version of the smartcontract.
    function GetContract(string _contractName) 
        Registred(_contractName)
        public constant returns(address _deploymentAddress, string _abi, string _version)
    {
        return (deployedContracts[_contractName].deploymentAddress, deployedContracts[_contractName].abi, deployedContracts[_contractName].version);
    }

    //@notice Function returning the last deployment Address of a smartcontract registered in this
    //        GlobalEthereumNamespace
    //@param _contractName : The public smartcontract name.
    //@return _deploymentAddress : The public address of the last known version of the smartcontract.
    function GetAddress(string _contractName) 
        Registred(_contractName)
        public constant returns(address _deploymentAddress)
    {
        return deployedContracts[_contractName].deploymentAddress;
    }

    //@notice Function returning the last deployment Address of a smartcontract registered in this
    //        GlobalEthereumNamespace
    //@param _contractName : The public smartcontract name.
    //@return _abi : The public interface of the last known version of the smartcontract.
    function GetABI(string _contractName) 
        Registred(_contractName)
        public constant returns(string _abi)
    {
        return deployedContracts[_contractName].abi;
    }

    //@notice Function returning the latest version of a smartcontract registered in this
    //        GlobalEthereumNamespace
    //@param _contractName : The public smartcontract name.
    //@return _version : The latest version of the last known version of the smartcontract.
    function GetVersion(string _contractName) 
        Registred(_contractName)
        public constant returns(string _version)
    {
        return deployedContracts[_contractName].version;
    }

    //@notice Withdraw some amount of Ether in the contract to some address, the withdraw is intended
    //        to be done to the Ethereum Classic Foundation address when one will be created in order
    //        to support further developements of the foundation.
    //@param _to : The address of the foundation
    //@param _amount: The amount to be withdrawn
    //@return success : Result of the send operation   
    function Withdraw(address _to, uint _amount)
        Owner()
        returns(bool success)
    {
        if((_amount > this.balance) || !_to.send(_amount) )
        {
            return false;
        }
        return true;
    }


    //------------------------------//
    //          Modifiers
    //------------------------------//
    //Used to restrict registering if the caller doesn't have enough fund to pay for the service
    modifier PayRegister() { if(msg.value < registryPrice) throw; _;}
    //Used to restrict update if the caller doesn't have enough fund to pay for the service
    modifier PayUpdate() { if(msg.value < updatePrice) throw; _; }
    //Used to restrict usage only for registred contracts
    modifier Registred(string _contractName) { if(!existingContracts[_contractName]) throw; _;}
    //Used to restrict usage only for new contracts
    modifier NotRegistred(string _contractName) { if(existingContracts[_contractName]) throw; _;}
    //Used to restrict updates to only the owner of the smartcontract
    modifier OnlyContractOwner(string _contractName) {if(deployedContracts[_contractName].contractOwner != msg.sender) throw; _;}
    //Used to restrict usage for non-owner callers
    modifier Owner() {if (msg.sender != owner) throw; _;}
    
    //------------------------------//
    //          Event
    //------------------------------//
    event registerContract(string _contractName, address _deploymentAddress, string _version);
    event updateContract(string _contractName, address _newDeploymentAddress, string _newVersion);

    //------------------------------//
    //          Fallback
    //------------------------------//
    //@notice Fallback function: just throw an exception to stop execution.
    function (){ throw; }
    
    //@notice Fore testing purposes we need a kill function in order to destroy bad versions of the code
    function kill() public
        Owner()
    {
        suicide(owner);    
    }       
}