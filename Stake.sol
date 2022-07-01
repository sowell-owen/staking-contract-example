//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Stake {
    address public owner;
    IERC20 public rewardToken;
    IERC20 public depositToken;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(address _depositToken, address _rewardToken) {
        depositToken = IERC20(_depositToken);
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "amount can't be 0");
        depositToken.transferFrom(msg.sender, address(this), _amount);

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    function unstakeTokens() public {
        uint256 amountStaked = stakingBalance[msg.sender];
        require(amountStaked > 0, "staking balance cannot be 0");

        depositToken.transfer(msg.sender, amountStaked);

        // Update staking status + reset balance
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    function distributeRewards() public {
        require(msg.sender == owner, "caller must be the owner");

        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];
            if (balance > 0) {
                rewardToken.transfer(recipient, balance);
            }
        }
    }
}
