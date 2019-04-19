# Trusted Pharma Supply Chain

The goal is of this project is to build a supply chain tracking system with that protects cutomers and producers agains counterfeit pharmaceuticals. The main idea is that every single box (down to a single antibiotics treatment) is tracked at all times in the supply chain. Drugs are produced by a pharmaceutical company with a retailer and distributor already assigned. Only the assigned distributor identified by it's address is allowed to pick up a drug an take it to the assigned reailer. Also only the assigned retailer is allowed to recive the drug from the distributor and seller to the consumer. The way a retailer requests a producer to produce a specifi drug and the way a specific distributor is chosen is an external bussiness process that is not included in this project. For example, producers can have an online catalog of different drugs they produce which retailers can access and make orders from it. This project only focuses in the supply chain from the production of a drug for a specific customer until it's purchased by a final consumer.

The goal is to remove untrusted third parties and to warranty that a product cannot be cloned, counterfeit or resold. Once the drug has been bought by a consumer it's considered outside the trusted supply chain.

Each drug is identified by a unique identifier, the UPC number, which acts also a mapping key in the supply chain smart contract. This number warranties that a given medicine has only been shipped once, received by a retailer once and never bought by a final customer. Every customer can check if the drug he or she is about to buy has followed the trusted supply chain in all step. He or she can make sure they are buing their medicines from the intended retailer and that those medicines have not been reported as owned. By buing their drugs through the trusted supply chain, customers also help prevent further counterfeit of medical products.

Drug counterfeit is a global problem that affect both custmers and producers. The crimes structures involved are highly organized, complex and technically develop; making it very difficult for patients, doctors and pharmacists to distinguish between real and fake products.



# Process

The business process can be visulized in the attached activity, state and sequence diagrams.

## Actors

There are 4 actos in the supply chain which have ownership and resposibility for a given drug at different points.

1) Producer; this is the pharmaceutical company which produces a specific drug. Owns the drug and is resposible for it from its production until it is shipped.

2) Distributor; this can be the logistics company taking care to deliver the drug to a local pharmacy. Owns the drug and is responsible for it during the whole shipping process to the retailer.

3) Retailer; this is the pharmacy that sells the items to the final customers. Owns the drug and it is responsible for it from the moment it received it from the distributor until it sells it to a final consumer.

4) Consumer; this is the final customer who buys the drugj for his/herown use. Owns the drug and it is responsible for it from the moment it receives it on. Once a drug has been purchased by a customer, it is consider to be outside the trusted supplychain and cannot be trusted.

Each one of the actors is a subclass of `Roles.sol` and has specific permisions in the supplychain, i.e only producers can produce a drug and only distributors are allow to ship it. 

## Drug States
A drug can have 5 states, a change in state is emited to the block chain. The transitions from one state to the other are sequential and one directional. The drug states are:

1) Produced; this is the first state of a drug once it's produced by the producer.

2) PaidFor; this corresponds to the retailer paying the producer for the drug.

3) Shipped; this corresponds to the distributor picking up the drug from the producer and transporting it the retailer.

4) Received; this corresponds to the retailer receiving the drug from the distributor.

5) Owned; this correspond to a final consumer puchesing the drug and claming the final ownership. This is the final state in the supply chain.

## Main methods

This are the main methods in the supply chain contract that allow the exchage of a drug among different actors:

1) produceDrug; takes care of producing a new drug with an alredy defined retailer and distributor. Sets the drug state to **Produced**.

2) payForDrug; takes care of paying the whole sale price for the drug to the producer. Sets the drug state to **PaidFor**.

3) shipItem; changes the state of the drug to **Shipped**. Can only be executed by the target distributor.

4) receiveItem; changes the state of the drug to **Received**. Can only be executed by the target retailer. This function also automatically increases the price of the drug by 10%.

5) purchaseDrug; takes care of paying for the drug and changes the state of the drug to **Owned**. Can only be executed by declared customers.

Methods have different modifiers depending on the specific use. These are declared and commented in the `SupplyChain.sol` file.


# Rinkeby contract address

## Supply Chain contract

`0x82eb41a36cd50b2a3de227e0389864b05528036f`

## Consumer Role Contract

`0x5c294555fb82d2f24d0e8ac9cd0b86eb7e177e22`

## Retailer Role Contract

`0x901953709304bed55c6ecdd8cc5621fd08275cbe`

## Distributor Role Contract

`0x0d17236ab511e12f873c92c11fd2eb287475c040`

## Producer Role Contract

`0x58b5d89017a9a6657546a4e79c16d571102e0552`

## Transaction ID

`0xd11fb1d480165398d292dc3c74cbafd2cdeea52c6b19b22b6d91d72add66227f`

# Additional Libraries and Frameworks.

No additional library or framework like IPFS was used for this project.

# References

Here are some external links with information regarding counterfeit drugs and possible uses of block chain technology to fight them.

https://www.bayer.com/en/background-information-on-counterfeit-drugs.aspx

https://www.mediledger.com/


