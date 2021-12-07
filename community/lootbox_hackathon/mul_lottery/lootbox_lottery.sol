// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import "./ChainLinkIntegration/VRFConsumerBase.sol";

interface ILootBox {
  function afterHarbergerBuy(uint256 _tokenId, address _newOwner) external;
}

interface ERC20 {
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract LotteryLootBox is ILootBox, VRFConsumerBase {
  address[] public players;
  address public rewardToken;
  address public owner;
  address public buidlNFT;
  uint256 public mintTokenId;
  address public lastWinner;
  uint256 public random;
  bytes32 internal keyHash;
  bytes32 public requestID;
  uint256 internal fee;
  uint256 public prizePool;


  enum LOTTERYSTATE {
    OPEN,
    CLOSED,
    CALCULATING
  }

  LOTTERYSTATE public lotterystate;
  event ReqRandomness(bytes32 indexed requestId);
  event RequestRandomnessFulfilled(bytes32 indexed requestId, uint256 randomness);

  //CHAINLINK randomaizer integration
  //settings for ethereum mainnet network https://docs.chain.link/docs/vrf-contracts/
  address public _VRFCoordinator = 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952;
  address public _LinkToken = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
  bytes32 internal _keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
  uint256 internal _fee = 2 * 10**18; // 2 LINK !! Don't forget send LINK and ETH for fees on this contract !!

  //DORA token integration and BUILD NFT data
  address public _rewardToken = 0xbc4171f45EF0EF66E76F979dF021a34B46DCc81d;
  address public  _buidlNFT = 0x7D5256D3e0c340FaBa6d6Ecd27E7B9e07f76aa94;
  uint256 public _mintTokenId = 1474;

  constructor() VRFConsumerBase(_VRFCoordinator, _LinkToken) {
    owner = msg.sender;
    rewardToken = _rewardToken;
    buidlNFT = _buidlNFT;
    mintTokenId = _mintTokenId;
    lotterystate = LOTTERYSTATE.CLOSED;
    prizePool = 0;
    //LINK settings
    keyHash = _keyHash;
    fee = _fee;

  }

  function getLastWinner() public view returns (address) {
        return lastWinner;
  }

  function getPrizePool() public view returns (uint256) {
        return prizePool;
  }

  function PlayersCount() public view returns (uint256) {
        return players.length;
  }

  function getPlayer(uint256 index) public view returns (address) {
        return players[index];
  }

  function launchLottery(uint256 _prizePool) public {
    require(msg.sender == owner);
    require(lotterystate == LOTTERYSTATE.CLOSED);
    require(ERC20(rewardToken).transferFrom(owner, address(this), _prizePool));
    prizePool = _prizePool;
    lotterystate = LOTTERYSTATE.OPEN;
  }

  // Emergency withdrawals -->
  function emergencyStop(uint256 _prizePool) public { 
    require(msg.sender == owner);
    require(ERC20(rewardToken).balanceOf(address(this)) >= _prizePool);
    require(ERC20(rewardToken).transfer(msg.sender, _prizePool));
    lotterystate = LOTTERYSTATE.CLOSED;
    players = new address[](0);
  }

  function emergencyWithdrawETH(uint256 _amount) public {
    require(msg.sender == owner);
    payable(msg.sender).transfer(_amount);
  }

  function emergencyWithdrawLINK(uint256 _amount) public {
    require(msg.sender == owner);
    require(LINK.transfer(msg.sender, _amount));
  }
  // <--

  function stopLottery() public returns (bytes32){
    require(msg.sender == owner);
    require(lotterystate == LOTTERYSTATE.OPEN);
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
    lotterystate = LOTTERYSTATE.CALCULATING;
    bytes32 requestId = requestRandomness(keyHash, fee);
    emit ReqRandomness(requestId); 
    return requestId;
  }

  function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
    require(lotterystate == LOTTERYSTATE.CALCULATING);
    require(_randomness > 0);
    uint256 Win_idx = _randomness % players.length;
    lastWinner = players[Win_idx];
    require(ERC20(rewardToken).transfer(lastWinner, prizePool));
    players = new address[](0);
    lotterystate = LOTTERYSTATE.CLOSED;
    random = _randomness;
    emit RequestRandomnessFulfilled(_requestId, _randomness);
    }

  function afterHarbergerBuy(uint256 _tokenId, address _newOwner) override external {
    require(msg.sender == buidlNFT);
    require(_tokenId == mintTokenId);
    if (lotterystate == LOTTERYSTATE.OPEN) {
    players.push(_newOwner);
    }
  }

}