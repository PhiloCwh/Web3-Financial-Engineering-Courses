// SPDX-License-Identifier: MIT
/*
to do list
1.after swap userreserve slope 交易后的变化率问题
2.k线利息的理想积分模型
3.清算过程
*/

import "./Idatastore.sol";
import "./lptoken.sol";
import "./Algorithm.sol";

pragma solidity ^0.8.20;

//to do list pay liquidity

contract swap{

    IERC20 WETH;
    receive() payable external {}
    Idatastore datastore;

    modifier reEntrancyMutex() {
        bool _reEntrancyMutex;

        require(!_reEntrancyMutex,"FUCK");
        _reEntrancyMutex = true;
        _;
        _reEntrancyMutex = false;

    }

    constructor(address store){
        datastore = Idatastore(store);
    }

//贷款业务
    function isWhiteListPair(address tokenA,address tokenB) public view returns(bool)
    {
        if(datastore.whiteListToken(tokenA) && datastore.whiteListToken(tokenB))
        {
            return true;
        }else {
            return false;
        }
    }

    





//业务合约
    //添加流动性




    function addLiquidity(address _token0, address _token1, uint _amount0,uint _amount1) public returns (uint shares) {
        
        //lptoken lptoken;//lptoken接口，为了mint 和 burn lptoken
        
        require(_amount0 > 0 ,"require _amount0 > 0 && _amount1 >0");
        require(_token0 != _token1, "_token0 == _token1");
        IERC20 token0 = IERC20(_token0);
        IERC20 token1 = IERC20(_token1);
        
        //token1.transferFrom(msg.sender, address(this), _amount1);
        address lptokenAddr;

        /*
        How much dx, dy to add?
        xy = k
        (x + dx)(y + dy) = k'
        No price change, before and after adding liquidity
        x / y = (x + dx) / (y + dy)
        x(y + dy) = y(x + dx)
        x * dy = y * dx
        x / y = dx / dy
        dy = y / x * dx
        */
        //问题：
        /*
        如果项目方撤出所有流动性后会存在问题
        1.添加流动性按照比例 0/0 会报错

        解决方案：
        每次添加至少n个token
        且remove流动性至少保留n给在amm里面

        */


        if (datastore.getLpToken(_token0,_token1) == address(0)) {
            //当lptoken = 0时，创建lptoken
            shares = Algorithm._sqrt(_amount0 * _amount1);

            createPair(_token0,_token1);

            lptokenAddr = datastore.getLpToken(_token0,_token1);
            //lptoken = LPToken(lptokenAddr);//获取lptoken地址
            datastore.pairCreator(lptokenAddr,msg.sender);

            token0.transferFrom(msg.sender, address(this), _amount0);
            token1.transferFrom(msg.sender, address(this), _amount1);

            
        } else {
            lptokenAddr = datastore.getLpToken(_token0,_token1);
            //lptoken = LPToken(lptokenAddr);//获取lptoken地址
            shares = Algorithm._min(
                (_amount0 * lptoken(lptokenAddr).totalSupply()) / datastore.getReserve(lptokenAddr,_token0),
                (_amount1 * lptoken(lptokenAddr).totalSupply()) / datastore.getReserve(lptokenAddr,_token1)
            );
            _amount1 = datastore.getReserve(lptokenAddr,_token1) * _amount0 / datastore.getReserve(lptokenAddr,_token0);
            token0.transferFrom(msg.sender, address(this), _amount0);
            token1.transferFrom(msg.sender, address(this), _amount1);
            /*
            if(_token0 > _token1)
            {
                userlpdata[msg.sender][lptokenAddr].tokenaAmount += _amount0;
                userlpdata[msg.sender][lptokenAddr].tokenbAmount += _amount1;
            }else {
                userlpdata[msg.sender][lptokenAddr].tokenbAmount += _amount0;
                userlpdata[msg.sender][lptokenAddr].tokenaAmount += _amount1;

            }*/
            //获取lptoken地址
        }
        require(shares > 0, "shares = 0");
        lptoken(lptokenAddr).mint(msg.sender,shares);


        update(msg.sender,lptokenAddr,_token0,_token1,_amount0,_amount1);

        
        
        //_update(lptokenAddr,_token0, _token1, datastore.reseve(lptokenAddr,_token0) + _amount0, datastore.reseve(lptokenAddr,_token1) + _amount1);
    }

    function update(address user,address lptokenAddr,address _token0, address _token1, uint _amount0,uint _amount1) internal 
    {

        datastore.reserve(lptokenAddr,_token0,datastore.getReserve(lptokenAddr,_token0)+_amount0);
        datastore.reserve(lptokenAddr,_token1,datastore.getReserve(lptokenAddr,_token1)+_amount1);

        datastore.userReserve(user,lptokenAddr,_token0,datastore.getUserReserve(user,lptokenAddr,_token0)+_amount0);
        datastore.userReserve(user,lptokenAddr,_token1,datastore.getUserReserve(user,lptokenAddr,_token1)+_amount1);

    }

    function update2(address user,address lptokenAddr,address _token0, address _token1, uint _amount0,uint _amount1) internal 
    {

        datastore.reserve(lptokenAddr,_token0,datastore.getReserve(lptokenAddr,_token0)+_amount0);
        datastore.reserve(lptokenAddr,_token1,datastore.getReserve(lptokenAddr,_token1)+_amount1);

        datastore.userReserve(user,lptokenAddr,_token0,datastore.getReserve(lptokenAddr,_token0)-_amount0);
        datastore.userReserve(user,lptokenAddr,_token1,datastore.getReserve(lptokenAddr,_token1)-_amount1);

    }

    function borrowAsset(address asset,uint amount) public 
    {
        
        bool j;
        for(uint i; i < datastore.getWhiteListTokenList().length;i++)
        {
            if(datastore.getWhiteListTokenList()[i] == asset){
                j = true;
            }
        }
        require(j,"invalid asset");
        uint leftingBorrowAmount;

        leftingBorrowAmount = datastore.calUserTokenReserve(msg.sender,asset) / 2 - datastore.getUserWhiteListBorrowed(msg.sender,asset);

        require(leftingBorrowAmount > amount,"amount too big");
        datastore.userWhiteListBorrowed(msg.sender,asset,datastore.getUserBorrowedAmount(msg.sender) + amount);
        datastore.whiteListBorrowed(asset,datastore.getWhiteListBorrowed(asset) + amount);

        IERC20 token = IERC20(asset);
        token.transfer(msg.sender,amount);



    }

    function getUserLeftingBorrowAmount(address user, address asset) public view returns(uint)
    {
        uint leftingBorrowAmount = datastore.calUserTokenReserve(user,asset) / 2 - datastore.getUserWhiteListBorrowed(user,asset);
        return leftingBorrowAmount;
    }
    

    function payDebt(address asset,uint amount) public 
    {
        require(datastore.getUserWhiteListBorrowed(msg.sender,asset)>0,"you are no in debt");

        IERC20 token = IERC20(asset);
        token.transferFrom(msg.sender,address(this),amount);

        datastore.userWhiteListBorrowed(msg.sender,asset,datastore.getUserBorrowedAmount(msg.sender) - amount);
        datastore.whiteListBorrowed(asset,datastore.getWhiteListBorrowed(asset) - amount);

    }












    function removeLiquidity(
        address _token0,
        address _token1,
        uint _shares
    ) public  returns (uint amount0, uint amount1) {

        require(datastore.getUserBorrowedAmount(msg.sender) < 100,"you are in debt");
        //LPToken lptoken;//lptoken接口，为了mint 和 burn lptoken
        IERC20 token0 = IERC20(_token0);
        IERC20 token1 = IERC20(_token1);
        address lptokenAddr = datastore.getLpToken(_token0,_token1);

        //lptoken = LPToken(lptokenAddr);
        /*

        if(datastore.pairCreator(lptokenAddr) == msg.sender)
        {
            require(lptoken(lptokenAddr).balanceOf(msg.sender) - _shares > 100 ,"paieCreator should left 100 wei lptoken in pool");
        }
        */

        amount0 = (_shares * datastore.getReserve(lptokenAddr,_token0)) / lptoken(lptokenAddr).totalSupply();//share * totalsuply/bal0
        amount1 = (_shares * datastore.getReserve(lptokenAddr,_token1)) / lptoken(lptokenAddr).totalSupply();
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        lptoken(lptokenAddr).burn(msg.sender, _shares);
        //_update(lptokenAddr,_token0, _token1, datastore.reseve(lptokenAddr,_token0) - amount0, datastore.reseve(lptokenAddr,_token1) - amount1);
        

        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
        update(msg.sender,lptokenAddr,_token0,_token1,amount0,amount1);
        //update(msg.sender,lptokenAddr,_token0,_token1, datastore.reseve(lptokenAddr,_token0) - amount0, datastore.reseve(lptokenAddr,_token1) - amount1);
    }

    //交易

 




/*

    function swapByPath(uint _amountIn, uint _disirSli,address [] memory _path) public {
        uint amountIn = _amountIn;
        for(uint i; i < _path.length - 1; i ++ ){
            (address tokenIn,address tokenOut) = (_path[i],_path[i + 1]);
            amountIn = swapByLimitSli(tokenIn, tokenOut, amountIn, _disirSli);
        }
    }
*/

    function swap1(address _tokenIn, address _tokenOut, uint _amountIn) public returns(uint amountOut){
        require(
            datastore.getLpToken(_tokenIn,_tokenOut) != address(0),
            "invalid token"
        );
        require(_amountIn > 0, "amount in = 0");
        require(_tokenIn != _tokenOut);
        //require(_amountIn >= 1000, "require amountIn >= 1000 wei token");

        IERC20 tokenIn = IERC20(_tokenIn);
        IERC20 tokenOut = IERC20(_tokenOut);
        address lptokenAddr = datastore.getLpToken(_tokenIn,_tokenOut);
        uint reserveIn = datastore.getReserve(lptokenAddr,_tokenIn);
        uint reserveOut = datastore.getReserve(lptokenAddr,_tokenOut);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);


        //交易税收 
        uint amountInWithFee = (_amountIn * (100000-datastore.getLpFee()-datastore.getFundFee())) / 100000;
        if(datastore.getFundFee() > 0){
            tokenIn.transfer(datastore.getFundAddr(),datastore.getFundFee() * _amountIn / 100000);
        }
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        //检查滑点
        //setSli(amountInWithFee,reserveIn,reserveOut,_disirSli);


        tokenOut.transfer(msg.sender, amountOut);
        uint totalReserve0 = datastore.getReserve(lptokenAddr,_tokenIn) + _amountIn; 
        uint totalReserve1 = datastore.getReserve(lptokenAddr,_tokenOut) - amountOut;

        datastore.reserve(lptokenAddr,_tokenIn,totalReserve0);
        datastore.reserve(lptokenAddr,_tokenOut,totalReserve1);

        //uint profit = lpFee * _amountIn / 100000;

        //_lpProfit[lptokenAddr] += profit;

        //_update(lptokenAddr,_tokenIn, _tokenOut, totalReserve0, totalReserve1);

    }

    function swap2(address _tokenIn, address _tokenOut, uint _amountIn) public returns(uint amountOut){
        address lptokenAddr = datastore.getLpToken(_tokenIn,_tokenOut);
        require(
            lptokenAddr != address(0),
            "invalid token"
        );
        require(_amountIn > 0, "amount in = 0");
        require(_tokenIn != _tokenOut);
        //require(_amountIn >= 1000, "require amountIn >= 1000 wei token");

        IERC20 tokenIn = IERC20(_tokenIn);
        IERC20 tokenOut = IERC20(_tokenOut);

        uint reserveIn = datastore.getReserve(lptokenAddr,_tokenIn);
        uint reserveOut = datastore.getReserve(lptokenAddr,_tokenOut);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);


        //交易税收 
        uint amountInWithFee = (_amountIn * (100000-datastore.getLpFee()-datastore.getFundFee())) / 100000;
        /*if(datastore.getFundFee() > 0){
            tokenIn.transfer(datastore.getFundAddr(),datastore.getFundFee() * _amountIn / 100000);
        }
        */
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        //检查滑点
        //setSli(amountInWithFee,reserveIn,reserveOut,_disirSli);


        tokenOut.transfer(msg.sender, amountOut);
        uint totalReserve0 = datastore.getReserve(lptokenAddr,_tokenIn) + _amountIn; 
        uint totalReserve1 = datastore.getReserve(lptokenAddr,_tokenOut) - amountOut;

        datastore.reserve(lptokenAddr,_tokenIn,totalReserve0);
        datastore.reserve(lptokenAddr,_tokenOut,totalReserve1);

        //uint profit = lpFee * _amountIn / 100000;

        //_lpProfit[lptokenAddr] += profit;

        //_update(lptokenAddr,_tokenIn, _tokenOut, totalReserve0, totalReserve1);

    }
    /*
    function swapByLimitSli(address _tokenIn, address _tokenOut, uint _amountIn, uint _disirSli) public returns(uint amountOut){
        require(
            datastore.getLpToken(_tokenIn,_tokenOut) != address(0),
            "invalid token"
        );
        require(_amountIn > 0, "amount in = 0");
        require(_tokenIn != _tokenOut);
        //require(_amountIn >= 1000, "require amountIn >= 1000 wei token");

        IERC20 tokenIn = IERC20(_tokenIn);
        IERC20 tokenOut = IERC20(_tokenOut);
        address lptokenAddr = datastore.getLpToken(_tokenIn,_tokenOut);
        uint reserveIn = datastore.getReserve(lptokenAddr,_tokenIn);
        uint reserveOut = datastore.getReserve(lptokenAddr,_tokenOut);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);


        //交易税收 
        uint amountInWithFee = (_amountIn * (100000-datastore.getLpFee()-datastore.getFundFee())) / 100000;
        if(datastore.getFundFee() > 0){
            tokenIn.transfer(datastore.getFundAddr(),datastore.getFundFee() * _amountIn / 100000);
        }
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        //检查滑点
        setSli(amountInWithFee,reserveIn,reserveOut,_disirSli);


        tokenOut.transfer(msg.sender, amountOut);
        uint totalReserve0 = datastore.getReserve(lptokenAddr,_tokenIn) + _amountIn; 
        uint totalReserve1 = datastore.getReserve(lptokenAddr,_tokenOut) - amountOut;

        datastore.reserve(lptokenAddr,_tokenIn,totalReserve0);
        datastore.reserve(lptokenAddr,_tokenOut,totalReserve1);

        //uint profit = lpFee * _amountIn / 100000;

        //_lpProfit[lptokenAddr] += profit;

        //_update(lptokenAddr,_tokenIn, _tokenOut, totalReserve0, totalReserve1);

    }*/
    /*
    function swapByLimitSli2(address _tokenIn, address _tokenOut, uint _amountIn, uint _disirSli) public returns(uint amountOut){
        require(
            findLpToken[_tokenIn][_tokenOut] != address(0),
            "invalid token"
        );
        require(_amountIn > 0, "amount in = 0");
        require(_tokenIn != _tokenOut);
        //require(_amountIn >= 1000, "require amountIn >= 1000 wei token");

        IERC20 tokenIn = IERC20(_tokenIn);
        //IERC20 tokenOut = IERC20(_tokenOut);
        address lptokenAddr = findLpToken[_tokenIn][_tokenOut];
        uint reserveIn = reserve[lptokenAddr][_tokenIn];
        uint reserveOut = reserve[lptokenAddr][_tokenOut];

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);


        //交易税收 
        uint amountInWithFee = (_amountIn * (100000-lpFee-fundFee)) / 100000;
        if(getFundFee() > 0){
            tokenIn.transfer(fundAddr,fundFee * _amountIn / 100000);
        }
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        //检查滑点
        setSli(amountInWithFee,reserveIn,reserveOut,_disirSli);


        //tokenOut.transfer(msg.sender, amountOut);
        uint totalReserve0 = reserve[lptokenAddr][_tokenIn] + _amountIn; 
        uint totalReserve1 = reserve[lptokenAddr][_tokenOut] - amountOut;

        uint profit = lpFee * _amountIn / 100000;

        _lpProfit[lptokenAddr] += profit;

        _update(lptokenAddr,_tokenIn, _tokenOut, totalReserve0, totalReserve1);

    }*/
    //pair op
    /*

    function getUserAllLpInfo(address user) public view returns(address [] memory, uint [] memory)
    {

        uint [] memory balanceList;
        for(uint i; i< userPairList[user].length; i++){
            balanceList[i] =  lptoken(userPairList[user][i]).balanceOf(user);
        }
    }

    */

//依赖方法
    //creatpair

    function createPair(address addrToken0, address addrToken1) internal returns(address){
        bytes32 _salt = keccak256(
            abi.encodePacked(
                addrToken0,addrToken1
            )
        );

        address lptokenAddr = address(new lptoken{
            salt : bytes32(_salt)
        }
        (addrToken0,addrToken1));

         //检索lptoken
        //_lpTokenAddressList.push(lptokenAddr);
        datastore.lpToken(addrToken0,addrToken1,lptokenAddr);
        //getLpToken[addrToken1][addrToken0] = lptokenAddr;
        datastore.lpToken(addrToken1,addrToken0,lptokenAddr);
        

        //_lpInfo[lptokenAddr] = [addrToken0,addrToken1];

        return lptokenAddr;
    }



    function getBytecode() internal pure returns(bytes memory) {
        bytes memory bytecode = type(lptoken).creationCode;
        return bytecode;
    }

    function getAddress(bytes memory bytecode, bytes32 _salt)
        internal
        view
        returns(address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
            )
        );

        return address(uint160(uint(hash)));
    }




    //数据更新


//数学库





    function setSli(uint dx, uint x, uint y, uint _disirSli) private pure returns(uint){


        uint amountOut = (y * dx) / (x + dx);

        uint dy = dx * y/x;
        /*
        loseAmount = Idea - ammOut
        Sli = loseAmount/Idea
        Sli = [dx*y/x - y*dx/(dx + x)]/dx*y/x
        */
        uint loseAmount = dy - amountOut;

        uint Sli = loseAmount * 10000 /dy;
        
        require(Sli <= _disirSli, "Sli too large");
        return Sli;

    }










}
