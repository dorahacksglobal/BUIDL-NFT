// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPlatinumSupporterNFT{
    function mintPOAP(address  supporter, string memory tokenURI) external returns (uint256);
}

interface ILootBox {
    function afterHarbergerBuy(uint256 _tokenId, address _newOwner) external;
}

interface BuidlNFT {
    function metadataOf(uint256 _tokenId) external view returns (
        address owner,
        uint256 bid,
        uint256 originalPrice,
        uint256 currentPrice,
        uint256 txs,
        address buidler,
        string memory url,
        address lootBox
    );
}

contract PiggyFiLootBox is ILootBox{

    event HarbergerBuy(address newOwner, uint256 currentPrice, uint256 txs, uint256 indexed nftId);

    address private immutable buildNftAddress;
    uint256 private immutable buildId;
    address  private immutable platinumSupporterNftAddress;

    string public metadataUrl = "https://ipfs.io/ipfs/QmVC5bDUK5zkgx69HrAsPDHbBTUwWfEnKFYQ8fnmN1Rfws?filename=poap.json";

    constructor(address _buildNftAddress,uint256 _buildId, address _platinumSupporterNftAddress){
        buildNftAddress = _buildNftAddress;
        buildId = _buildId;
        platinumSupporterNftAddress = _platinumSupporterNftAddress;
    }

    function afterHarbergerBuy(uint256 _tokenId, address _newOwner) override external {
        require(msg.sender == buildNftAddress, "PiggyFiLootBox: calling contract invalid");
        require(_tokenId == buildId, "PiggyFiLootBox: wrong build nft passed");

        (,,,uint256 currentPrice,uint256 txs,,,) = BuidlNFT(msg.sender).metadataOf(_tokenId);

        uint256 nftId = IPlatinumSupporterNFT(platinumSupporterNftAddress).mintPOAP(_newOwner, metadataUrl);

    emit HarbergerBuy(_newOwner, currentPrice, txs, nftId);
    }

    function setMetaDataUrl(string memory url) public returns (string memory){
        metadataUrl = url;
        return metadataUrl;
    }
}
