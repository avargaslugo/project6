pragma solidity ^0.4.24;
import {ProducerRole} from "../pharmaaccesscontrol/ProducerRole.sol";
import {DistributorRole} from "../pharmaaccesscontrol/DistributorRole.sol";
import {RetailerRole} from "../pharmaaccesscontrol/RetailerRole.sol";
import {ConsumerRole} from "../pharmaaccesscontrol/ConsumerRole.sol";
import {Ownable} from "../pharmacore/Ownable.sol";

// Define a contract 'Supplychain'
contract SupplyChain is ProducerRole, DistributorRole, RetailerRole, ConsumerRole{
  // Define 'owner'
  address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Produced,  // 0
    PaidFor, // 1
    Shipped,    // 2
    Received,   // 3
    Owned  // 4
    }

  State constant defaultState = State.Produced;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address producerID; // Metamask-Ethereum address of the Farmer
    string  producerName; // Farmer Name
    string  producerPlantInformation;  // Farmer Information
    string  producerPlantLatitude; // Farm Latitude
    string  producerPlantLongitude;  // Farm Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address distributorID;  // Metamask-Ethereum address of the Distributor
    address retailerID; // Metamask-Ethereum address of the Retailer
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Produced(uint upc);
  event PaidFor(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event Owned(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner, "this function is only reserved for the contract owner");
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address, "wrong caller"); 
    _;
  }

  modifier upcAvailable(uint _upc){
    require(items[_upc].ownerID==0, "UPC has already been registered"); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier canPayDrug(uint _upc) { 
    require(msg.value >= items[_upc].productPrice, "Not enough funds in the message"); 
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Produced
  modifier produced(uint _upc) {
    require(items[_upc].itemState == State.Produced, "Drug has not been produced yet");
    _;
  }

  modifier paidFor(uint _upc) {
    require(items[_upc].itemState == State.PaidFor, "Drug has not been paid for yet");
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped, "Item has not been shipped");
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].itemState == State.Received, "Item has not been received by the retailer");
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }

  // Define a function 'produceDrug' that allows a farmer to mark an item 'Produced'
  function produceDrug(uint _upc, string _producerName, string _producerPlantInformation, string  _producerPlantLatitude, string  _producerPlantLongitude, string  _productNotes, address _retailerID, address _distributorID, uint _productPrice) public onlyProducer() upcAvailable(_upc)
  {
    
    // Add the new item as part of Harvest
    items[_upc] = Item({sku: sku, upc: _upc, ownerID: msg.sender, producerID: msg.sender, producerName: _producerName, producerPlantInformation: _producerPlantInformation, producerPlantLatitude: _producerPlantLatitude, producerPlantLongitude: _producerPlantLongitude,productID: sku+upc ,productNotes: _productNotes, productPrice: _productPrice, itemState: State.Produced, distributorID: _distributorID, retailerID: _retailerID, consumerID: address(0) });
    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit Produced(_upc);
  }

  function payForDrug(uint _upc) public produced(_upc) onlyRetailer() canPayDrug(_upc) payable{

    address producer = items[_upc].producerID;
    uint drugPrice = items[_upc].productPrice;

    uint returnChange = msg.value - drugPrice;
    msg.sender.transfer(returnChange);
    producer.transfer(drugPrice);
    items[_upc].itemState = State.PaidFor;
    emit PaidFor(_upc);
  }

  // Define a function 'shipItem' that allows the distributor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  function shipItem(uint _upc) public onlyDistributor() paidFor(_upc)
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Call modifier to verify caller of this function
    
    {
    address targetDistributor = items[_upc].distributorID;
    require(targetDistributor == msg.sender, "Wrong Distributor");

    items[_upc].ownerID = items[_upc].distributorID;
    items[_upc].itemState = State.Shipped;
    // Update the appropriate fields
    emit Shipped(_upc);
    // Emit the appropriate event
    
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) public onlyRetailer() shipped(_upc) //onlyRetailer()
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Access Control List enforced by calling Smart Contract / DApp
    {
    address targetRetailer = items[_upc].retailerID;
    require(targetRetailer == msg.sender, "Wrong retailer");

    items[_upc].ownerID = items[_upc].retailerID;
    items[_upc].itemState = State.Received;
    items[_upc].productPrice = (items[_upc].productPrice * 6) / 5;
    // Update the appropriate fields
    emit Received(upc);
    // Emit the appropriate event
    
  }

  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function buyDrug(uint _upc) public  received(_upc) onlyConsumer() payable
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Access Control List enforced by calling Smart Contract / DApp
    {
    address seller = items[_upc].retailerID;
    uint price = items[_upc].productPrice;
    // Update the appropriate fields - ownerID, consumerID, itemState
    uint returnChange = msg.value - price;
    msg.sender.transfer(returnChange);
    seller.transfer(price);
    items[_upc].ownerID = msg.sender;
    items[_upc].itemState = State.Owned;
    
    // Emit the appropriate event
    emit Owned(_upc);
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address producerID,
  string  originFarmName,
  string  producerPlantInformation,
  string  producerPlantLatitude,
  string  producerPlantLongitude
  ) 
  {
  // Assign values to the 8 parameters
  
  itemSKU = items[_upc].sku;
  itemUPC = items[_upc].upc;
  ownerID = items[_upc].ownerID;
  producerID = items[_upc].producerID;
  originFarmName = items[_upc].producerName;
  producerPlantInformation = items[_upc].producerPlantInformation;
  producerPlantLatitude = items[_upc].producerPlantLatitude;
  producerPlantLongitude = items[_upc].producerPlantLongitude;
  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  producerID,
  originFarmName,
  producerPlantInformation,
  producerPlantLatitude,
  producerPlantLongitude
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  uint    itemState,
  address distributorID,
  address retailerID,
  address consumerID
  ) 
  {
    // Assign values to the 9 parameters
  itemSKU = items[_upc].sku;
  itemUPC = items[_upc].upc;
  
  productID = items[_upc].productID;
  productNotes = items[_upc].productNotes;
  productPrice = items[_upc].productPrice;
  itemState = uint(items[_upc].itemState);
  distributorID = items[_upc].distributorID;
  retailerID = items[_upc].retailerID;
  consumerID = items[_upc].consumerID;
    
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  retailerID,
  distributorID,
  consumerID
  );
  }
}
