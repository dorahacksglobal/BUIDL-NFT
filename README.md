# BUIDL NFT Loot Box 

## Simple Summary

An NFT protocol that implements [BUIDL NFT](https://dorafactory.medium.com/hackers-painters-open-source-projects-nfts-and-simplified-harberger-tax-b6a672ade89f) with Loot Box. A loot box is a smart contract that contains any programmable behavior upon a successful BUIDL NFT transaction.

## Use Cases

In general, anything that can be written as programs can be implemented in the loot box. Some initial use cases include perks, swags, token rewards, airdrops, on-chain registrations, whitelisting, etc. But definitely what loot boxes can do is unlimited.

## Specificaiton

The miner of NFT can bind a LootBox contract for his BUIDL NFT with `setLootBox(uint256,address)` (or initializing while minting).

``` solidity
interface BuidlNFT {
  function setLootBox(uint256 tokenId, address lootBoxAddr) external;
  function mint(uint256 initPrice, uint256 bid, address lootBoxAddr, bytes calldata sign) external;
  function mint(uint256 initPrice, uint256 bid, bytes calldata sign) external;
}

interface ILootBox {
  function afterHarbergerBuy(uint256 tokenId, address newNFTOwner) external;
}
```

When an NFT is `harbergerBuy()` by anyone, if there is a bound LootBox, it will try to call the `afterHarbergerBuy()` on the LootBox. The miner of NFT can arbitrarily define the behavior of `afterHarbergerBuy()`. Generally, it will be a buyers incentives / rewards. NFT buyers can predict the behavior of this function before purchase.

To ensure safety, the LootBox should always check:

- msg.sender: Prevent the interface from being abused.
- tokenID: Prevent other NFTs to use a same LootBox.

### Example

The following is a simple example of an AirdropLootBox contract：

``` solidity
pragma solidity 0.8.6;

import "./BuidlNFT.sol";

contract AirdropLootBox is ILootBox {
  address public token;
  address public owner;
  address public entrypoint;
  uint256 public mintTokenId;

  constructor(address _toAirdropToken, address _ep, uint256 _mintTokenId) {
    owner = msg.sender;
    token = _toAirdropToken;
    entrypoint = _ep;
    mintTokenId = _mintTokenId;
  }

  function afterHarbergerBuy(uint256 _tokenId, address _newOwner) override external {
    require(msg.sender == entrypoint);
    require(_tokenId == mintTokenId);

    (,,,uint256 currentPrice,,,,) = BuidlNFT(msg.sender).metadataOf(_tokenId);
    ERC20(token).transferFrom(owner, _newOwner, currentPrice / 100);
  }
}
```

## Background

BUIDL NFT was first proposed in an [article](https://dorafactory.medium.com/hackers-painters-open-source-projects-nfts-and-simplified-harberger-tax-b6a672ade89f) that discusses how NFTs with simple Harberger tax like transaction mechanisms can help fund Web3 open source software, as well as creating fun for collectors of the unique collectables created for open source projects.

The mechanism was first experimented on HackerLink. There are more than a dozen of HackerLink BUIDLs minted their BUIDL NFTs. A [leaderboard](https://hackerlink.io/buidl/leaderboard) of all BUIDL NFTs is available on HackerLink.

In the original article, the party that mints the NFTs shall define the meaning of the NFTs. It has two requirements that are undesired in the Web3 era:

- It requires unverifiable trust. Like Web2 / offline services, rights are confirmed off-chain. One example is crowdfunding platforms, where benefits and rights are often written in text and difficult to enforce / verify after actual purchases.
- It limits what the NFTs can do.

BUIDL NFTs were first described as the "Uniswap Socks" of open source projects / public goods. Now with loot box, the meaning of BUIDL NFTs can be programmed, offering developers and NFT collectors with much more flexibilities to interact.

## Ideas

For ideas of interesting use cases of loot box, we are maintaining an idea list. Everyone can contribute to the idea list and enlighten others of what loot box can do.