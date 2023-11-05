// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract lptoken is ERC20, Ownable {

    address token0;
    address token1;



    constructor(address _token0,address _token1 ) ERC20("lptoken", "LPT") {
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address account,uint256 amount) public onlyOwner{
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner
    {
        _burn(account,amount);
    }
    function getTokenAddr() public view returns(address,address){
        return (token0,token1);
    }



}
