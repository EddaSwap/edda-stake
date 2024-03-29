pragma solidity ^0.6.6;

// Inheritance
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract IRewardDistributionRecipient is Ownable {
  address rewardDistribution;

  function notifyRewardAmount(uint256 reward) external virtual;

  modifier onlyRewardDistribution() {
    require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
    _;
  }

  function setRewardDistribution(address _rewardDistribution) external onlyOwner {
    rewardDistribution = _rewardDistribution;
  }
}
