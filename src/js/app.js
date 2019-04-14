App = {
    web3Provider: null,
    contracts: {},
    emptyAddress: "0x0000000000000000000000000000000000000000",
    sku: 0,
    upc: 0,
    metamaskAccountID: "0x0000000000000000000000000000000000000000",
    ownerID: "0x0000000000000000000000000000000000000000",
    originFarmerID: "0x0000000000000000000000000000000000000000",
    originFarmName: null,
    originFarmInformation: null,
    originFarmLatitude: null,
    originFarmLongitude: null,
    productNotes: null,
    productPrice: 0,
    distributorID: "0x0000000000000000000000000000000000000000",
    retailerID: "0x0000000000000000000000000000000000000000",
    consumerID: "0x0000000000000000000000000000000000000000",

    init: async function () {
        //App.readForm();
        /// Setup access to blockchain
        return await App.initWeb3();
        
    },


    initWeb3: async function () {
        /// Find or Inject Web3 Provider
        /// Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
            console.log("using port 8545")
        }

        App.getMetaskAccountID();
        console.log("Starting Supply Chain")
        
        return App.initSupplyChain();
    },

    getMetaskAccountID: function () {
        web3 = new Web3(App.web3Provider);

        // Retrieving accounts
        web3.eth.getAccounts(function(err, res) {
            if (err) {
                console.log('Error:',err);
                return;
            }
            console.log('getMetaskID:',res);
            App.metamaskAccountID = res[0];
            // define default address as default retailer and distributor
        $("#newDrugRetailerID").val(App.metamaskAccountID)
        $("#newDrugDistributorID").val(App.metamaskAccountID)

        })
    },

    initSupplyChain: function () {
        /// Source the truffle compiled smart contracts
        var jsonSupplyChain='../../build/contracts/SupplyChain.json';
        
        /// JSONfy the smart contracts
        $.getJSON(jsonSupplyChain, function(data) {
            console.log('data',data);
            var SupplyChainArtifact = data;
            App.contracts.SupplyChain = TruffleContract(SupplyChainArtifact);
            App.contracts.SupplyChain.setProvider(App.web3Provider);
            
            //App.fetchItemBufferOne();
            //App.fetchItemBufferTwo();
            App.fetchEvents();

        });

        return App.bindEvents();
    },

    bindEvents: function() {
        $(document).on('click', App.handleButtonClick);
    },

    handleButtonClick: async function(event) {
        event.preventDefault();

        App.getMetaskAccountID();
        

        var processId = parseInt($(event.target).data('id'));
        console.log('processId',processId);

        switch(processId) {
            case 1:
                return await App.prduceDrug(event);
                break;
            case 5:
                console.log("pushed buy button")
                return await App.buyItem(event);
                break;
            case 6:
                console.log("pushed ship button")
                return await App.shipItem(event);
                break;
            case 7:
                return await App.receiveItem(event);
                break;
            case 8:
                return await App.purchaseItem(event);
                break;
            case 9:
                return await App.fetchItemBufferOne(event);
                break;
            case 10:
                await App.fetchItemBufferOne(event);
                return await App.fetchItemBufferTwo(event);
                break;
            }
    },

    prduceDrug: function(event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            console.log("New upc for new drug: " + $("#newUPC").val())
            return instance.produceDrug(
                $("#newUPC").val(), 
                $("#newDrugProducerName").val(), //App.originFarmName, 
                $("#newDrugProducerInformation").val(), //App.originFarmInformation, 
                $("#newDrugProducerPlantLatitude").val(), //App.originFarmLatitude, 
                $("#newDrugProducerPlantLongitud").val(), //App.originFarmLongitude, 
                $("#newDrugNotes").val(), //App.productNotes,
                $("#newDrugRetailerID").val(), //retailer ID
                $("#newDrugDistributorID").val(), //distributor ID
                web3.toWei($("#newDrugPrice").val(), "ether") //price
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            $("#upcStatus").text("Item UPC:" +$("#newUPC").val() +" has be created")
            console.log('harvestItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    processItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.processItem(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('processItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));
        
        App.contracts.SupplyChain.deployed().then(function(instance) {

            const walletValue = web3.toWei($("#messageValue").val(), "ether");
            return instance.payForDrug($("#upcToProcess").val(), {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            $("#upcStatus").text("Item with UPC: " + $("#upcToProcess").val() + " has been paid by retailer; shipment can start as soon as Distributor starts the shipment process");
            console.log('buyItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    shipItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.shipItem($("#upcToProcess").val(), {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            $("#upcStatus").text("Item with UPC: " + $("#upcToProcess").val() + " is being shipped");
            console.log('shipItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    receiveItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.receiveItem($("#upcToProcess").val(), {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#upcStatus").text("Item with UPC: " + $("#upcToProcess").val() + " has been received by retailer");
            $("#ftc-item").text(result);
            console.log('receiveItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    purchaseItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));
        const walletValue = web3.toWei($("#messageValue").val(), "ether");
        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.buyDrug($("#upcToProcess").val(), {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#upcStatus").text("Item with UPC: " + $("#upcToProcess").val() + " has been purchased and finalized by a consumer");
            $("#ftc-item").text(result);
            console.log('purchaseItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    fetchItemBufferOne: function () {
    ///   event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
        App.upc = $('#upc').val();
        console.log('upc',App.upc);

        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchItemBufferOne($("#upc").val());
        }).then(function(result) {
            $('#itemOwner').text(result[2])
            $("#ftc-item").text(result);
          console.log('fetchItemBufferOne', result);
        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchItemBufferTwo: function () {
    ///    event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
        console.log("fetching data for: " + $("#upc").val())
        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchItemBufferTwo.call($("#upc").val());
        }).then(function(result) {
            $("#SKU").text(result[0])
            $("#retailerID").text(result[6])
            $("#distributorID").text(result[7])
            $("#itemState").text(result[5])
            $("#itemPrice").text(web3.fromWei(result[4], "ether"))
            $("#ftc-item").text(result);
          console.log('fetchItemBufferTwo', result);
        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchEvents: function () {
        if (typeof App.contracts.SupplyChain.currentProvider.sendAsync !== "function") {
            App.contracts.SupplyChain.currentProvider.sendAsync = function () {
                return App.contracts.SupplyChain.currentProvider.send.apply(
                App.contracts.SupplyChain.currentProvider,
                    arguments
              );
            };
        }

        App.contracts.SupplyChain.deployed().then(function(instance) {
        var events = instance.allEvents(function(err, log){
          if (!err)
            $("#ftc-events").append('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
        });
        }).catch(function(err) {
          console.log(err.message);
        });
        
    }
};

$(function () {
    $(window).load(function () {
        App.init();
    });
});
