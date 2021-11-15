// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "../BuidlNFT.sol";

contract ErrorLootBox is ILootBox {
  function afterHarbergerBuy(uint256, address) override external pure {
    revert("error");
  }
}
