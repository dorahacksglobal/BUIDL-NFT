// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "./InfiniteToken.sol";
import "../BuidlNFT.sol";

contract Test {
  InfiniteToken public token;
  BuidlNFT public nft;

  constructor() {
    token = new InfiniteToken();
    nft = new BuidlNFT(token, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf);
  }
}
