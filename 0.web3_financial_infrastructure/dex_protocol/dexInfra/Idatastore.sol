// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//to do list pay liquidity

interface   Idatastore{

    function calAllTokenBorrowed() external  view returns(uint);

    //function calAllTokenBorrowed() external  view returns(uint);
    function getUserBorrowedAmount(address asset) external  view returns(uint);

    function userBorrowed(address asset, uint amount) external  ;

    function calTokenReserve(address token) external view returns(uint);

    function calUserTokenReserve(address user,address token) external view returns(uint);

    function calAllTokenValue() external view returns(uint);

    function calUserAllTokenValue(address user) external view returns(uint);


    function setWhiteListLpTokenList(address lpAddr) external ;
    function getWhiteListTokenList() external  view returns(address[] memory);
    function getWhiteListLpTokenList() external view returns(address[] memory);
    function getWhiteListHealthFactor(address token) external view returns(uint);

    function getWhiteListBorrowed(address token)external view returns(uint);

    function whiteListBorrowed(address token, uint amount)external ;

    function getWhiteListReserve(address token)external view returns(uint);

    function whiteListReserve(address token, uint amount)external ;

    function getUserWhiteListReserve(address user, address asset) external view returns(uint);

    function userWhiteListReserve(address user, address asset, uint amount) external ;

    function getUserWhiteListBorrowed(address user, address asset) external view returns(uint);

    function userWhiteListBorrowed(address user, address asset, uint amount) external ;

    function whiteListToken(address token) external view returns(bool);

    function setWhiteListToken(address token, bool isWhiteListToken) external ;

    function pushTokenInWhiteList(address token) external ;
    function getCtoken(address token) external view returns(address);

    function ctoken (address token ,address c_token) external; 

    function getFundAddr()external view returns(address);


    function getUserReserve(address user,address lpAddr,address token)external  view returns(uint);

    function userReserve(address user,address lpAddr,address token,uint amount) external ;

    function getVirtualReserve(address lpAddr,address token) external  view returns(uint);
    function virtualReserve(address lpAddr,address token,uint amount) external  ;


    function getReserve(address lpAddr,address token) external  view returns(uint);
    function reserve(address lpAddr,address token,uint amount)external ;


    function getPairCreator (address lpAddr) external  view returns(address);

    function pairCreator(address lpAddr, address user)external  ;

    function getBorrowedAmount(address userAddr, address lpAddr, uint assetType) external view returns(uint);
 

    function borrowedAmount(address userAddr, address lpAddr, uint assetType, uint amount) external ;
 

    function getPayDebtAmount(address userAddr, address lpAddr, uint assetType) external view returns(uint);


    function payDebtAmount(address userAddr, address lpAddr, uint assetType, uint amount) external ;


    function getLpToken(address tokena, address tokenb) external view returns(address);
 
    function lpToken(address tokena, address tokenb,address lptokenAddr) external ;

    function getLpFee() external view returns(uint);

    function getFundFee() external view returns(uint);

    function getLpProfit(address lpAddr) external view returns(uint);

    function WETHAddr()external  view returns(address);



//管理人员权限

    function lpProfit(address lpAddr, uint profit)external ;

    function setLpFee(uint fee) external ;



    function setFundFee(uint fee)external ;

    function setFundAddr(address _fundAddr) external ;



    function setWeth(address _wethAddr) external ;
    function setLpSwapStatic(address _lpAddr, bool _static) external ;

    function updateReserve(address lptokenAddr,address tokena, address tokenb, uint reserve0, uint reserve1) external  ;
    //function updateUserReserve()

}
