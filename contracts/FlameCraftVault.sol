// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * FlameCraftVault - 火之文明充值合约
 * 接收 ROON 原生币，emit 充值事件供后端监听
 * 管理员可提取资金和更换管理员
 */
contract FlameCraftVault {
    address public admin;
    
    event Deposit(address indexed player, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed to, uint256 amount);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // 玩家充值 - 直接转 ROON 到合约
    receive() external payable {
        require(msg.value > 0, "Zero amount");
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    // 也支持 fallback
    fallback() external payable {
        require(msg.value > 0, "Zero amount");
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    // 管理员提取
    function withdraw(address payable to, uint256 amount) external onlyAdmin {
        require(amount <= address(this).balance, "Insufficient balance");
        to.transfer(amount);
        emit Withdraw(to, amount);
    }

    // 提取全部
    function withdrawAll(address payable to) external onlyAdmin {
        uint256 bal = address(this).balance;
        require(bal > 0, "No balance");
        to.transfer(bal);
        emit Withdraw(to, bal);
    }

    // 更换管理员
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    // 查询余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
