// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*
1.添加流动性
2.交易
3.移除流动性
*/

/*
配合杠杆的玩法
1.lp杠杆：存lp贷出lp（做市杠杆）
2。pair币杠杆： 存lp贷出A or B（做市同时可做多做空莫token，即借出买入）
3. token杠杆 存A贷B （单token杠杆）
3.1 流程
- 存入tokenA到pair 根据对应的价格贷出70%贷出tokenB（贷出利息分给lp）
- 单币做市的可能性（a跟b比例相同的时候）
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AMM
{
    
    function addLiquidity(type name) {
        
    }
}