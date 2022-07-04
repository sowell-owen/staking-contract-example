//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Stake {
    address public owner;
    IERC20 public rewardToken;
    IERC20 public depositToken;

    uint256 public TOTAL_STAKED;
    uint256 public YIELD_TOTAL;

    mapping(address => uint256) public USER_STAKED;
    mapping(address => uint256) public depositTime;
    mapping(address => uint256) internal rewards;

    constructor(address _depositToken, address _rewardToken) {
        depositToken = IERC20(_depositToken);
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    function setYield(uint256 _YIELD_TOTAL) {
        require(msg.sender == owner, "Only owner can set total yield");
        YIELD_TOTAL = _YIELD_TOTAL;
    }

    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "amount can't be 0");
        depositToken.transferFrom(msg.sender, address(this), _amount);

        USER_STAKED[msg.sender] += _amount;
        TOTAL_STAKED += _amount;

        // block time when deposit happened
        depositTime[msg.sender] = block.timestamp;
    }

    function unstakeTokens(uint256 _amount) public {
        require(USER_STAKED[msg.sender] > 0, "staking balance cannot be 0");

        depositToken.transfer(msg.sender, _amount);

        // Update staking status and user's staking balance
        USER_STAKED[msg.sender] -= _amount;
        TOTAL_STAKED -= _amount;
    }

    function calculateMontlyReward() public returns (uint256) {
        rewards[msg.sender] =
            (YIELD_TOTAL * USER_STAKED[msg.sender]) /
            TOTAL_STAKED;

        return rewards[msg.sender];
    }

    function withdrawRewards() public {
        uint256 lockupTime = depositTime[msg.sender] + 30 days;
        require(block.timestamp >= lockupTime, "Can't claim rewards");

        uint256 earnedRewards = calculateMontlyReward();

        if (earnedRewards > 0) {
            rewardToken.transfer(msg.sender, earnedRewards);
        }

        rewards[msg.sender] = 0;

        // renew lockup period for claimer
        depositTime[msg.sender] = block.timestamp;
    }
}
