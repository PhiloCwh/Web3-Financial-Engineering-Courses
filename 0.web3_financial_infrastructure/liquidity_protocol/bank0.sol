// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
存入
取出
*/
//存入erc20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract bank0{

    mapping (address => uint) _balance;

    receive() external payable { }

    function depositEth() public payable  {
        _balance[msg.sender] += msg.value;

    }

    function withdrawEth(uint _amount) public payable {
        address payable  user = payable (msg.sender);
        user.transfer(_amount);
        _balance[msg.sender] -= msg.value;
    }

    

}
