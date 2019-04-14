pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'DistributorRole' to manage this role - add, remove, check
contract RetailerRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event RetailerAdded(address indexed account);
  event RetailerRemoved(address indexed account);

  // Define a struct 'producers' by inheriting from 'Roles' library, struct Role
  Roles.Role private retailers;

  // In the constructor make the address that deploys this contract the 1st farmer
  constructor() public {
    _addRetailer(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyRetailer() {
    require(isRetailer(msg.sender), "Function is limited to Retailers");
    _;
  }

  // Define a function 'isDistributor' to check this role
  function isRetailer(address account) public view returns (bool) {
    return retailers.has(account);
  }

  // Define a function 'addDistributor' that adds this role
  function addRetailer(address account) public onlyRetailer {
    _addRetailer(account);
  }

  // Define a function 'renounceDistributor' to renounce this role
  function renounceRetailer() public {
    _removeRetailer(msg.sender);
  }

  // Define an internal function '_addDistributor' to add this role, called by 'addDistributor'
  function _addRetailer(address account) internal {
    retailers.add(account);
    emit RetailerAdded(account);
  }

  // Define an internal function '_removeDistributor' to remove this role, called by 'removeFarmer'
  function _removeRetailer(address account) internal {
    retailers.remove(account);
    emit RetailerRemoved(account);
  }
}