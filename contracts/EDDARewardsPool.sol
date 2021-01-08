pragma solidity ^0.6.6;

import "./RewardsPool.sol";

contract EDDARewardsPool is RewardsPool {
  constructor(
    address lp_,
    IERC20 outToken_,
    address rewardDistribution_,
    uint256 stakeDurationSeconds_
  ) public RewardsPool(lp_, outToken_, rewardDistribution_, stakeDurationSeconds_) {}
}
