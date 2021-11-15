// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "../BuidlNFT.sol";

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
