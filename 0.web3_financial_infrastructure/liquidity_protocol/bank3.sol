// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*

目前问题：
用户资产存在不同的index
合理的方式应该是用到跟index不同的index1来记录，
并且把index和index1关联起来知道第几个index1用户资产发生变动
*/
/*
存入
取出
计算利息
* 资产借出
*/
//存入erc20

/*
关于私有变量index的统一问题
插入数据来记录第几个index改变资产就ok
erc20index
userReserve
有一个index来记录第几个index存入或取出多少资产

*/
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract bank3{
    struct publicVariable{
        uint starTime;
        uint endTime;
        uint reserveRate;
        uint debtRate;
    }
    

    //uint _index;
    mapping (address => uint) erc20Index;
    mapping (uint => publicVariable) publicVariableIndex;
    mapping (uint => mapping (address => publicVariable)) public erc20PublicVariableIndex;//index => assetType => publiVariable
    //mapping (uint => userVariable) userVariableIndex;

    mapping (address => uint) AllReserve;//erc20 => amount
    mapping (address => uint) AllBorrowed;

    mapping (uint =>mapping (address => mapping (address => uint))) userReserveIndex;//index => user => assetType => amount

    //大于index找最后一个插入index的数额
    mapping (uint =>mapping (address => mapping (address => uint))) userDebtIndex;
    mapping (address => mapping (address => uint)) userReserve;
    mapping (address => mapping (address => uint)) userDebt;

    uint AllETHReserve;
    uint ALlETHBorrowed;

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

        erc20Index[_erc20]++;
        uint index = erc20Index[_erc20];

        if(index == 1){
        erc20PublicVariableIndex[index-1][_erc20].starTime = block.timestamp;   
        }

        address user = msg.sender;

        IERC20 erc20 = IERC20(_erc20);
        erc20.transferFrom(user, address(this), _amount);

        //_erc20Balance[user][_erc20] += _amount;

        //userReserveIndex[index][user][_erc20] += _amount;

        erc20PublicVariableIndex[index-1][_erc20].endTime = block.timestamp;
        erc20PublicVariableIndex[index-1][_erc20].reserveRate = calReserveRate(_erc20);
        erc20PublicVariableIndex[index-1][_erc20].debtRate = calDebtRate(_erc20);
        erc20PublicVariableIndex[index][_erc20].starTime = block.timestamp;

        //资产数据更新
        AllReserve[_erc20] += _amount;
        userReserveIndex[index][user][_erc20] += _amount;



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

    function borrowErc20Asset(address _erc20, uint _amount) public
    {
        erc20Index[_erc20] ++;
        uint index = erc20Index[_erc20];

        address user = msg.sender;
        uint reserve = userReserveIndex[index][user][_erc20];
        uint debt = userDebtIndex[index][user][_erc20];
        require((debt + _amount) <= (reserve/2),"debt must less reserve/2");

        //userDebtIndex[index][user][_erc20] += _amount;

        erc20PublicVariableIndex[index-1][_erc20].endTime = block.timestamp;
        erc20PublicVariableIndex[index-1][_erc20].reserveRate = calReserveRate(_erc20);
        erc20PublicVariableIndex[index-1][_erc20].debtRate = calDebtRate(_erc20);
        erc20PublicVariableIndex[index][_erc20].starTime = block.timestamp;

        //资产数据更新
        AllBorrowed[_erc20] += _amount;
        userDebtIndex[index][user][_erc20] += _amount;


        




    }


    function calProfitForETH() public view returns(uint)
    {


    }

    function calProfitForErc20(address _erc20) public view returns(uint)
    {
        address user = msg.sender;
        uint profit;
        for (uint i;i <= erc20Index[_erc20];i++){
            if(i==erc20Index[_erc20]){
                uint endTime = block.timestamp;
                uint deltaT = endTime - erc20PublicVariableIndex[i][_erc20].starTime;
                profit += deltaT * erc20PublicVariableIndex[i][_erc20].reserveRate * userReserveIndex[i][user][_erc20];

            }
            else{
                profit += calProfitForErc20S(i,_erc20);
            }
        }
        return profit;


    }

    function calProfitForErc20S(uint _index,address _erc20) public view returns(uint)
    {
        address user = msg.sender;
        publicVariableIndex[_index];
        //userVariableIndex[index];
        uint deltaT = (erc20PublicVariableIndex[_index][_erc20].endTime - erc20PublicVariableIndex[_index][_erc20].starTime);
        uint profitS = deltaT * erc20PublicVariableIndex[_index][_erc20].reserveRate * userReserveIndex[_index][user][_erc20];
        return profitS;

    }
    function calReserveRate(address _erc20) public view returns(uint)
    {
        if(AllReserve[_erc20] == 0){
            return 0;
        }else{
            return 8*10e17*AllBorrowed[_erc20]/AllReserve[_erc20];
        //计算时再除于10e18
        }
    }
    function calDebtRate(address _erc20) public view returns(uint)
    {
        if(AllReserve[_erc20] == 0){
            return 0;
        }else{
        return 10e18*AllBorrowed[_erc20]/AllReserve[_erc20];
        }
    }

    

}
