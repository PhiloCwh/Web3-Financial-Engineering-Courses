// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
存入
取出
*/
//存入erc20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract bank1{

    mapping (address => uint) _balance;//user => amount
    mapping (address => mapping (address => uint)) _erc20Balance;//user => erc20 => amount

    receive() external payable { }

    function depositEth() public payable  {
        _balance[msg.sender] += msg.value;

    }

    function withdrawEth(uint _amount) public payable {
        address payable  user = payable (msg.sender);
        user.transfer(_amount);
        _balance[msg.sender] -= msg.value;
    }

    function depositErc20(address _erc20,uint _amount) public {
        /*

        */
        address user = msg.sender;

        IERC20 erc20 = IERC20(_erc20);
        erc20.transferFrom(user, address(this), _amount);

        _erc20Balance[user][_erc20] += _amount;

    }

    function withdrawErc20(address _erc20,uint _amount) public {
        /*
        1.检查数量
        2.合约发送erc20
        3.改写钱包数量
        */
        address user = msg.sender;
        require(_erc20Balance[user][_erc20] >= _amount,"???");

        IERC20 erc20 = IERC20(_erc20);
        erc20.transfer(user, _amount);

        _erc20Balance[user][_erc20] -= _amount;
    }

    

}
