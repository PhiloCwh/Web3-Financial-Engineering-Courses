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
    struct ProfitStruct{
        uint starTime;
        uint endTime;
        uint ratePerSecond;
    }

    ProfitStruct [] profitStructArray;

    uint public index;
    mapping (uint => ProfitStruct) public profitStructSort;
    mapping (address =>mapping (uint => uint)) public indexBorrowed;

    IERC20 asset;

    uint public AllBalance;
    uint public AllBorrowed;

    mapping (address => uint) balance;
    mapping (address => uint) borrowed;
    


    

    constructor(address _asset){
        asset = IERC20(_asset);
        index = 0;
    }

    function deposit(uint _amount) public 
    {
        index ++;
        asset.transferFrom(msg.sender, address(this), _amount);

        profitStructSort[index - 1].endTime = block.timestamp;
        profitStructSort[index].starTime = block.timestamp;

        profitStructSort[index -1].ratePerSecond = calProfitRatePerSecond();

        balance[msg.sender] += _amount;
        AllBalance += _amount;


    }

    function borrow(uint _amount) public 
    {
        index ++;
        require(borrowed[msg.sender] + _amount <= balance[msg.sender],"fuck");
        asset.transfer(msg.sender, _amount);

        profitStructSort[index - 1].endTime = block.timestamp;
        profitStructSort[index].starTime = block.timestamp;

        profitStructSort[index -1].ratePerSecond = calProfitRatePerSecond();

        borrowed[msg.sender] += _amount;
        AllBorrowed += _amount;
        indexBorrowed[msg.sender][index] = borrowed[msg.sender];
    }
    /*
    1.计算用户在各个时间点的存入资产
    2.每个时间段的利息
    3.计算 利息*时间 得到总利息
    */
    function calProfit() public view returns(uint)
    {
        uint profit;
        for(uint i = 1; i <= index; i ++)
        {
            uint spanProfit;
            if(i == index)
            {
                spanProfit = indexBorrowed[msg.sender][i] * calProfitRatePerSecond() * (block.timestamp - profitStructSort[i].starTime);
            }else{
                spanProfit = indexBorrowed[msg.sender][i] * profitStructSort[i].ratePerSecond * (profitStructSort[i].endTime - profitStructSort[i].starTime);  
            }
            profit += spanProfit;
        }
        return profit;




    }

    function calProfitReal()public view returns(uint)
    {
        return calProfit()/10e18;
    }
    /*
    rate = allBorrowed/AllBalance (0 < rate <1);
    如果rate是apr的话
    可以添加一个新函数来计算每秒利息
    */
    function calProfitRate() public view returns(uint)
    {
        if(AllBalance == 0){
            return 0;
        }else{
            uint rate = 10e18 * AllBorrowed / AllBalance;

            return rate;
        }
    }
    
    function calProfitRatePerSecond() public view returns (uint)
    {
        return calProfitRate() / 86400;
    }

    function assetLiquidation()public 
    {
        
    }

    function liquidationConditionFactor() public view returns(uint)
    {
        uint factor = 10e18 * (calProfitReal() + borrowed[msg.sender] ) / balance[msg.sender];
        return factor;
    }

    function liquidationCondition() public view returns(bool)
    {
        if(liquidationConditionFactor() > (10e17 * 8))
        {
            return true;
        }
        else{
            return false;
        }
    }




}// SPDX-License-Identifier: MIT
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
    struct ProfitStruct{
        uint starTime;
        uint endTime;
        uint ratePerSecond;
    }

    ProfitStruct [] profitStructArray;

    uint public index;
    mapping (uint => ProfitStruct) public profitStructSort;
    mapping (address =>mapping (uint => uint)) public indexBorrowed;

    IERC20 asset;

    uint public AllBalance;
    uint public AllBorrowed;

    mapping (address => uint) balance;
    mapping (address => uint) borrowed;
    


    

    constructor(address _asset){
        asset = IERC20(_asset);
        index = 0;
    }

    function deposit(uint _amount) public 
    {
        index ++;
        asset.transferFrom(msg.sender, address(this), _amount);

        profitStructSort[index - 1].endTime = block.timestamp;
        profitStructSort[index].starTime = block.timestamp;

        profitStructSort[index -1].ratePerSecond = calProfitRatePerSecond();

        balance[msg.sender] += _amount;
        AllBalance += _amount;


    }

    function borrow(uint _amount) public 
    {
        index ++;
        require(borrowed[msg.sender] + _amount <= balance[msg.sender],"fuck");
        asset.transfer(msg.sender, _amount);

        profitStructSort[index - 1].endTime = block.timestamp;
        profitStructSort[index].starTime = block.timestamp;

        profitStructSort[index -1].ratePerSecond = calProfitRatePerSecond();

        borrowed[msg.sender] += _amount;
        AllBorrowed += _amount;
        indexBorrowed[msg.sender][index] = borrowed[msg.sender];
    }
    /*
    1.计算用户在各个时间点的存入资产
    2.每个时间段的利息
    3.计算 利息*时间 得到总利息
    */
    function calProfit() public view returns(uint)
    {
        uint profit;
        for(uint i = 1; i <= index; i ++)
        {
            uint spanProfit;
            if(i == index)
            {
                spanProfit = indexBorrowed[msg.sender][i] * calProfitRatePerSecond() * (block.timestamp - profitStructSort[i].starTime);
            }else{
                spanProfit = indexBorrowed[msg.sender][i] * profitStructSort[i].ratePerSecond * (profitStructSort[i].endTime - profitStructSort[i].starTime);  
            }
            profit += spanProfit;
        }
        return profit;




    }

    function calProfitReal()public view returns(uint)
    {
        return calProfit()/10e18;
    }
    /*
    rate = allBorrowed/AllBalance (0 < rate <1);
    如果rate是apr的话
    可以添加一个新函数来计算每秒利息
    */
    function calProfitRate() public view returns(uint)
    {
        if(AllBalance == 0){
            return 0;
        }else{
            uint rate = 10e18 * AllBorrowed / AllBalance;

            return rate;
        }
    }
    
    function calProfitRatePerSecond() public view returns (uint)
    {
        return calProfitRate() / 86400;
    }

    function assetLiquidation()public 
    {
        
    }

    function liquidationConditionFactor() public view returns(uint)
    {
        uint factor = 10e18 * (calProfitReal() + borrowed[msg.sender] ) / balance[msg.sender];
        return factor;
    }

    function liquidationCondition() public view returns(bool)
    {
        if(liquidationConditionFactor() > (10e17 * 8))
        {
            return true;
        }
        else{
            return false;
        }
    }




}
