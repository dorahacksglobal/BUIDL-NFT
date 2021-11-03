// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "../BuidlNFT.sol";

contract ComplexLootBox is ILootBox {
  uint256 public n;
  function afterHarbergerBuy(uint256, address) override external {
    for (uint256 i = 0; i < 1000; i++) {
      n += i;
    }
  }
}
