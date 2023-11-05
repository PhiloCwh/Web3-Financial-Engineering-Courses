// SPDX-License-Identifier: MIT

//import "./IAMM.sol";
import "./Idatastore.sol";
import "./Algorithm.sol";
import "./lptoken.sol";

pragma solidity ^0.8.9;


contract AMMData{
    Idatastore amm;
    uint constant ONE_ETH = 10 ** 18;
    constructor(address _amm){
        amm = Idatastore(_amm);

    }

    function resetAmm(address _amm) public {
        amm = Idatastore(_amm);
    }


    function getTokenOutAmount(address _tokenIn, address _tokenOut, uint _amountIn) public view returns(uint amountOut){
        require(
            amm.getLpToken(_tokenIn,_tokenOut) != address(0),
            "invalid token"
        );
        require(_amountIn > 0, "amount in = 0");
        require(_tokenIn != _tokenOut);

        address lptokenAddr = amm.getLpToken(_tokenIn,_tokenOut);
        uint reserveIn = amm.getReserve(lptokenAddr,_tokenIn);
        uint reserveOut = amm.getReserve(lptokenAddr,_tokenOut);




        //交易税收 
        uint amountInWithFee = (_amountIn * (100000-amm.getLpFee()-amm.getFundFee())) / 100000;

        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        //检查滑点
        //setSli(amountInWithFee,reserveIn,reserveOut,_disirSli);




        //uint profit = lpFee * _amountIn / 100000;

        //_lpProfit[lptokenAddr] += profit;

        //_update(lptokenAddr,_tokenIn, _tokenOut, totalReserve0, totalReserve1);

    }


    function getTokenPrice(address _tokenA, address _tokenB) public view returns(uint reserveA,uint reserveB, uint one_tokenA_price,uint one_tokenB_price)
    {
        address lptokenAddr = amm.getLpToken(_tokenA,_tokenB);
        reserveA = amm.getReserve(lptokenAddr, _tokenA);
        reserveB = amm.getReserve(lptokenAddr,_tokenB);

        one_tokenA_price = reserveB * ONE_ETH / reserveA;
        one_tokenB_price = reserveA * ONE_ETH / reserveB;

            
    }
/*
    function getTokenPriceStableCoin(address _tokenA, address _tokenB, uint amountIn) public view returns(uint reserveA,uint reserveB, uint tokenA_price,uint tokenB_price)
    {
        address lptokenAddr = amm.getLptoken(_tokenA,_tokenB);
        reserveA = amm.getReserve(lptokenAddr, _tokenA);
        reserveB = amm.getReserve(lptokenAddr,_tokenB);
        tokenA_price = StableAlgorithm.calOutput(amm.getA(lptokenAddr),reserveA + reserveB, reserveA,amountIn);
        tokenB_price = StableAlgorithm.calOutput(amm.getA(lptokenAddr),reserveA + reserveB, reserveB,amountIn);

        
        //tokenOutAmount = StableAlgorithm.calOutput(100,reserveA + reserveB, reserveA,_tokenInAmount);



            
    }
    

    function cacalTokenOutAmount(address _tokenIn, address _tokenOut, uint _tokenInAmount) public view returns(uint tokenOutAmount)
    {
        address lptokenAddr = amm.getLptoken(_tokenIn,_tokenOut);
        uint reserveIn = amm.getReserve(lptokenAddr, _tokenIn);
        uint reserveOut = amm.getReserve(lptokenAddr,_tokenOut);
        if(amm.isStablePair(lptokenAddr)){

            tokenOutAmount = StableAlgorithm.calOutput(amm.getA(lptokenAddr),reserveIn + reserveOut, reserveIn,_tokenInAmount);
        }else{
            tokenOutAmount = (reserveOut * _tokenInAmount) / (reserveIn + _tokenInAmount);
        }
    }
    */
    function cacalLpTokenAddAmount(address _tokenA, address _tokenB, uint _amountA) public view returns(uint _amountB)
    {
        address lptokenAddr = amm.getLpToken(_tokenA,_tokenB);
        _amountB = amm.getReserve(lptokenAddr,_tokenB) * _amountA / amm.getReserve(lptokenAddr, _tokenA);
    }

 

    function getRemoveLiquidityAmount(
        address _token0,
        address _token1,
        uint _shares
    ) public view  returns (uint amount0, uint amount1) {
        //ILPToken lptoken;//lptoken接口，为了mint 和 burn lptoken
        address lptokenAddr = amm.getLpToken(_token0,_token1);

        //lptoken = ILPToken(lptokenAddr);


        amount0 = (_shares * amm.getReserve(lptokenAddr,_token0)) / lptoken(lptokenAddr).totalSupply();//share * totalsuply/bal0
        amount1 = (_shares * amm.getReserve(lptokenAddr,_token1)) / lptoken(lptokenAddr).totalSupply();
    }


    function getUserLeftingBorrowAmount(address user, address asset) public view returns(uint)
    {
        uint leftingBorrowAmount = amm.calUserTokenReserve(user,asset) / 2 - amm.getUserWhiteListBorrowed(user,asset);
        return leftingBorrowAmount;
    }

    function _getUserWhiteListBorrowedAmount(address user,address asset) public view returns(uint)
    {
        return amm.getUserWhiteListBorrowed(user,asset);
    }
    function _getWhiteListBorrowedAmount(address asset)public view returns(uint)
    {
        return amm.getWhiteListBorrowed(asset);
    }

    function calAllTokenBorrowed() public view returns(uint)
    { 
        return amm.calAllTokenBorrowed();

    }


    

    
}
