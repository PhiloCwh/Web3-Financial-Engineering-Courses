// SPDX-License-Identifier: MIT

import "./lptoken.sol";
import "./IWETH.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Algorithm.sol";

pragma solidity ^0.8.20;

//to do list pay liquidity

contract Datastore is AccessControl{


    //lend
    mapping (address => address) _ctoken;
    mapping (address => bool) _whiteListToken;

    mapping (address => uint) _whiteListReserve;
    mapping (address => uint) _whiteListBorrowed;

    mapping (address => bool) _whiteListLpAddr;

    mapping (address => mapping (address => uint)) _userWhiteListReserve;
    mapping (address => mapping (address => uint)) _userWhiteListBorrowed;
    

    address[] _whiteListTokenList;


    bytes32 public constant FEE_CONTROL_ROLE = keccak256("FEE_CONTROL_ROLE");
    bytes32 public constant PAIR_CONTROL_ROLE = keccak256("PAIR_CONTROL_ROLE");
    bytes32 public constant DATA_CONTROL_ROLE = keccak256("DATA_CONTROL_ROLE");
    bytes32 public constant COMP_CONTROL_ROLE = keccak256("COMP_CONTROL_ROLE");


    mapping (address => mapping (address => mapping (uint => uint))) public _borrowedAmount;//user => lp => assetType => amount
    mapping (address => mapping (address => mapping (uint => uint))) public _payDebtAmount;
    mapping (address => mapping (uint => uint)) public _allBorrowedAmount;//lp => assetType => amount
    mapping (address => mapping (uint => uint)) public _allPayDebtAmount;



    uint constant public ONE_ETH = 10 ** 18;


    mapping(address => address) _pairCreator;//lpAddr pairCreator
    address [] _lpTokenAddressList;//lptoken的数组
    address [] _whiteListLpTokenList;

    mapping(address => mapping(address => uint)) _virtualReserve;
    mapping(address => mapping(address => uint)) _reserve;//第一个address是lptoken的address ，第2个是相应token的资产，uint是资产的amount
    mapping(address => mapping(address => uint)) _borrowed;

    mapping (address => mapping (address => mapping (address => uint))) _userReserve;
    //mapping (address => mapping (address => mapping (address => uint))) _userBorrowed;
    mapping(address => uint) _userBorrowed;


    uint _lpFee;//fee to pool
    uint _fundFee;
    mapping(address => mapping(address => address)) _lpToken;
    IWETH  WETH;
    address  _WETHAddr;

    //pair op

    //可以遍历出user的所有lp address
    mapping (address => address []) private _userPairList;

    //mapping (address => bool) public isStablePair;
    mapping (address => address[2]) _lpInfo;
    mapping (address => bool) _lpSwapStatic;
    mapping (address => uint) _lpProfit;
    mapping (address => uint) _lpCreatedTime;
    mapping (address => mapping (address => bool)) _userLpExist;
    mapping (address => address[]) _userLpTokenList;



    address public fundAddr;
    //lend
    constructor()  {
        address defaultAdmin = msg.sender;
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAIR_CONTROL_ROLE, defaultAdmin);
        _grantRole(DATA_CONTROL_ROLE, defaultAdmin);
        _grantRole(FEE_CONTROL_ROLE, defaultAdmin);
    }
/*
    function iswhiteListLpAddr(address lpAddr)public view returns(uint)
    {
        return _whiteListBorrowed[token];
    }

    function whiteListBorrowed(address token, uint amount)public onlyRole(DATA_CONTROL_ROLE)
    {
        _whiteListBorrowed[token] = amount;
    }*/

    function calAllTokenBorrowed() public view returns(uint)
    {
        uint amount;

        for(uint i=0;i < _whiteListTokenList.length;i ++)
        {
            amount +=  _whiteListBorrowed[_whiteListTokenList[i]];
            
        }
        
        return amount;

    }

    function getBorrowedAmount(address asset) public view returns(uint)
    {
        return _userBorrowed[asset];
    }

    function userBorrowed(address asset, uint amount) public 
    {
        _userBorrowed[asset] = amount;
    }

    function calTokenReserve(address token) public view returns(uint)
    {
        uint amount;
        for(uint i=0;i < _whiteListLpTokenList.length;i ++)
        {
            amount += _reserve[_whiteListLpTokenList[i]][token];
        }
        return amount;
    }

    function calUserTokenReserve(address user,address token) public view returns(uint)
    {
        uint amount;
        for(uint i=0;i < _whiteListLpTokenList.length;i ++)
        {
            amount += _userReserve[user][_whiteListLpTokenList[i]][token];
        }
        return amount;
    }



    function calAllTokenValue() public view returns(uint)
    {
        uint amount;
        for(uint i=0;i < _whiteListTokenList.length;i ++)
        {
            amount += calTokenReserve(_whiteListTokenList[i]);
            
        }
        
        return amount;
    }

    function calUserAllTokenValue(address user) public view returns(uint)
    {
        uint amount;
        for(uint i=0;i < _whiteListTokenList.length;i ++)
        {
            amount += calUserTokenReserve(user,_whiteListTokenList[i] );
        }
        
        return amount;
    }


    function setWhiteListLpTokenList(address lpAddr) public 
    {
        _whiteListLpTokenList.push(lpAddr);
    }
    function getWhiteListLpTokenList() public view returns(address[] memory)
    {
        return _whiteListLpTokenList;
    }

    function getWhiteListTokenList() public view returns(address[] memory)
    {
        return _whiteListTokenList;
    }

    function getWhiteListHealthFactor(address token) public view returns(uint)
    {
        uint tokenReserve = _whiteListReserve[token];
        uint tokenBorrowed = _whiteListBorrowed[token];
        uint initialReserve = tokenReserve + tokenBorrowed;
        return 10e18 * tokenBorrowed / initialReserve;
    }

    function getWhiteListBorrowed(address token)public view returns(uint)
    {
        return _whiteListBorrowed[token];
    }

    function whiteListBorrowed(address token, uint amount)public onlyRole(DATA_CONTROL_ROLE)
    {
        _whiteListBorrowed[token] = amount;
    }

    function getWhiteListReserve(address token)public view returns(uint)
    {
        return _whiteListReserve[token];
    }

    function whiteListReserve(address token, uint amount)public onlyRole(DATA_CONTROL_ROLE)
    {
        _whiteListReserve[token] = amount;
    }

    function getUserWhiteListReserve(address user, address asset) public view returns(uint)
    {
        return _userWhiteListReserve[user][asset];
    }

    function userWhiteListReserve(address user, address asset, uint amount) public onlyRole(DATA_CONTROL_ROLE)
    {
        _userWhiteListReserve[user][asset] = amount;
    }

    function getUserWhiteListBorrowed(address user, address asset) public view returns(uint)
    {
        return _userWhiteListBorrowed[user][asset];
    }

    function userWhiteListBorrowed(address user, address asset, uint amount) public onlyRole(DATA_CONTROL_ROLE)
    {
        _userWhiteListBorrowed[user][asset] = amount;
    }

    function whiteListToken(address token) public view returns(bool)
    {
        return _whiteListToken[token];
    }

    function setWhiteListToken(address token, bool isWhiteListToken) public onlyRole(DATA_CONTROL_ROLE)
    {
        _whiteListToken[token] = isWhiteListToken;
    }

    function pushTokenInWhiteList(address token) public onlyRole(DATA_CONTROL_ROLE){
        _whiteListTokenList.push(token);
    }
    function getCtoken(address token) public view returns(address)
    {
        return _ctoken[token];
    }

    function ctoken (address token ,address c_token) public onlyRole(COMP_CONTROL_ROLE)
    {
        _ctoken[token] = c_token;
    }

    function getUserReserve(address user,address lpAddr,address token) public view returns(uint)
    {
        return _userReserve[user][lpAddr][token];
    }

    function userReserve(address user,address lpAddr,address token,uint amount)public onlyRole(DATA_CONTROL_ROLE)
    {
        _userReserve[user][lpAddr][token] = amount;
    }

    function getVirtualReserve(address lpAddr,address token) public view returns(uint)
    {
        return _virtualReserve[lpAddr][token];
    }
    function virtualReserve(address lpAddr,address token,uint amount) public onlyRole(DATA_CONTROL_ROLE)
    {
        _virtualReserve[lpAddr][token] = amount;
    }

    function getReserve(address lpAddr,address token) public view returns(uint)
    {
        return _reserve[lpAddr][token];
    }
    function reserve(address lpAddr,address token,uint amount)public onlyRole(DATA_CONTROL_ROLE){
        _reserve[lpAddr][token] = amount;
    }


    function getPairCreator (address lpAddr) public view returns(address)
    {
        return _pairCreator[lpAddr];
    }

    function pairCreator(address lpAddr, address user)public onlyRole(DATA_CONTROL_ROLE)
    {
        _pairCreator[lpAddr] = user;
    }

    function getBorrowedAmount(address userAddr, address lpAddr, uint assetType) public view returns(uint)
    {
        return _borrowedAmount[userAddr][lpAddr][assetType];
    }

    function borrowedAmount(address userAddr, address lpAddr, uint assetType, uint amount) public onlyRole(DATA_CONTROL_ROLE)
    {
        _borrowedAmount[userAddr][lpAddr][assetType] = amount;
    }

    function getPayDebtAmount(address userAddr, address lpAddr, uint assetType) public view returns(uint)
    {
        return _payDebtAmount[userAddr][lpAddr][assetType];
    }

    function payDebtAmount(address userAddr, address lpAddr, uint assetType, uint amount) public onlyRole(DATA_CONTROL_ROLE)
    {
        _payDebtAmount[userAddr][lpAddr][assetType] = amount;
    }

    function getLpToken(address tokena, address tokenb) public view returns(address)
    {
        return _lpToken[tokena][tokenb];
    }
    function lpToken(address tokena, address tokenb,address lptokenAddr) public onlyRole(DATA_CONTROL_ROLE)
    {
        _lpToken[tokena][tokenb] = lptokenAddr;
    }

    function getLpFee() public view returns(uint)
    {
        return _lpFee;
    }

    function getFundFee() public view returns(uint)
    {
        return _fundFee;
    }

    function getLpProfit(address lpAddr) public view returns(uint)
    {
        return _lpProfit[lpAddr];
    }

    function WETHAddr() public view returns(address)
    {
        return _WETHAddr;
    }


//管理人员权限

    function lpProfit(address lpAddr, uint profit)public onlyRole(FEE_CONTROL_ROLE)
    {
        _lpProfit[lpAddr] = profit;
    }

    function setLpFee(uint fee) external onlyRole(FEE_CONTROL_ROLE){
        _lpFee = fee;// dx / 100000
    }



    function setFundFee(uint fee)external onlyRole(FEE_CONTROL_ROLE){
        _fundFee = fee;
    }

    function setFundAddr(address _fundAddr) external onlyRole(FEE_CONTROL_ROLE){
        fundAddr = _fundAddr;
    }



    function setWeth(address _wethAddr) public onlyRole(PAIR_CONTROL_ROLE){
        WETH = IWETH(_wethAddr);
        _WETHAddr = _wethAddr;
    }
    function setLpSwapStatic(address _lpAddr, bool _static) external onlyRole(PAIR_CONTROL_ROLE){
        _lpSwapStatic[_lpAddr] = _static;
    }

    function updateReserve(address lptokenAddr,address tokena, address tokenb, uint reserve0, uint reserve1) public onlyRole(DATA_CONTROL_ROLE) {
        _reserve[lptokenAddr][tokena] = reserve0;
        _reserve[lptokenAddr][tokenb] = reserve1;
    }




}
