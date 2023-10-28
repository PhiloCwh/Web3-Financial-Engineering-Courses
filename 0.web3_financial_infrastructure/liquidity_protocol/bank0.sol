// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*
资产存入
资产借出
利息计算
资产归还
资产清算
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract liquidity_protocol
{
    /*
    计算的过程
    用户存入资产记住存入标签
    用户取出资产记录取出时间（主要记录用户在不同时间的资产存量）
    计算时用每段用户的 ∑ i>>n  debt(i) * profitrate(i) * timespan(i)
    */


    IERC20 asset;


    


    

    constructor(address _asset){
        asset = IERC20(_asset);
    }
}
