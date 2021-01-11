// File: @openzeppelin/contracts/math/Math.sol

pragma solidity ^0.6.6;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./IRewardDistributionRecipient.sol";
import "./LPTokenWrapper.sol";

contract RewardsPool is LPTokenWrapper, IRewardDistributionRecipient, ReentrancyGuard {
  IERC20 public outToken;

  uint256 public constant DURATION = 7 days;
  uint256 public stakeDurationSeconds = 3 days;
  uint256 public constant MIN_STAKE_DURATION_SECONDS = 2 minutes;
  uint256 public constant REWARD_DELAY_SECONDS = 1 minutes;

  uint256 public periodFinish = 0;
  uint256 public rewardRate = 0;
  uint256 public lastUpdateTime;
  uint256 public rewardPerTokenStored;
  mapping(address => uint256) public userRewardPerTokenPaid;
  mapping(address => uint256) public rewards;
  mapping(address => uint256) public canWithdrawTime;
  mapping(address => uint256) public canGetRewardTime;

  event RewardAdded(uint256 reward);
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);

  constructor(
    address lp_,
    IERC20 outToken_,
    address rewardDistribution_,
    uint256 stakeDurationSeconds_
  ) public LPTokenWrapper(lp_) {
    require(stakeDurationSeconds_ >= MIN_STAKE_DURATION_SECONDS, "!minStakeDurationSeconds");
    rewardDistribution = rewardDistribution_;
    outToken = outToken_;
    stakeDurationSeconds = stakeDurationSeconds_;
  }

  modifier updateReward(address account) {
    rewardPerTokenStored = rewardPerToken();
    lastUpdateTime = lastTimeRewardApplicable();
    if (account != address(0)) {
      rewards[account] = earned(account);
      userRewardPerTokenPaid[account] = rewardPerTokenStored;
    }
    _;
  }

  function lastTimeRewardApplicable() public view returns (uint256) {
    return Math.min(block.timestamp, periodFinish);
  }

  function rewardPerToken() public view returns (uint256) {
    if (totalSupply() == 0) {
      return rewardPerTokenStored;
    }
    return
      rewardPerTokenStored.add(
        lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(totalSupply())
      );
  }

  function earned(address account) public view returns (uint256) {
    return
      balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
  }

  function stake(uint256 amount) public override nonReentrant updateReward(msg.sender) {
    require(amount > 0, "Cannot stake 0");
    canWithdrawTime[msg.sender] = now + stakeDurationSeconds;
    canGetRewardTime[msg.sender] = now + REWARD_DELAY_SECONDS;
    emit Staked(msg.sender, amount);
    super.stake(amount);
  }

  function withdraw(uint256 amount) public override nonReentrant updateReward(msg.sender) {
    require(amount > 0, "Cannot withdraw 0");
    require(now > canWithdrawTime[msg.sender], "The mortgage will take some time to redeem");
    emit Withdrawn(msg.sender, amount);
    super.withdraw(amount);
  }

  // Is not `nonReentrant` because of calls have this modifier.
  function exit() external {
    withdraw(balanceOf(msg.sender));
    getReward();
  }

  function getReward() public nonReentrant updateReward(msg.sender) {
    require(now > canGetRewardTime[msg.sender], "Delay after Stake is required");
    uint256 reward = earned(msg.sender);
    if (reward > 0) {
      rewards[msg.sender] = 0;
      emit RewardPaid(msg.sender, reward);
      outToken.safeTransfer(msg.sender, reward);
    }
  }

  function notifyRewardAmount(uint256 reward)
    external
    override
    nonReentrant
    onlyRewardDistribution
    updateReward(address(0))
  {
    if (block.timestamp >= periodFinish) {
      rewardRate = reward.div(DURATION);
    } else {
      uint256 remaining = periodFinish.sub(block.timestamp);
      uint256 leftover = remaining.mul(rewardRate);
      rewardRate = reward.add(leftover).div(DURATION);
    }
    lastUpdateTime = block.timestamp;
    periodFinish = block.timestamp.add(DURATION);
    emit RewardAdded(reward);
  }

  function lockedDetails() external view returns (bool, uint256) {
    return (false, periodFinish);
  }

  function voteLock(address account) external view returns (uint256) {
    return (canWithdrawTime[account]);
  }
}
