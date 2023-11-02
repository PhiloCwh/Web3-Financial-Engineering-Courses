// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*
存入
取出
计算利息
*/
//存入erc20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract bank2{
    struct publicVariable{
        uint starTime;
        uint endTime;
        uint reserveRate;
        uint debtRate;
    }
    

    uint index;
    mapping (uint => publicVariable) publicVariableIndex;
    //mapping (uint => userVariable) userVariableIndex;

    mapping (address => uint) AllReserve;//erc20 => amount
    mapping (address => uint) AllBorrowed;

    mapping (uint =>mapping (address => mapping (address => uint))) userReserveIndex;//index => user => assetType => amount
    mapping (uint =>mapping (address => mapping (address => uint))) userDebtIndex;

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
    function calProfitForETH() public view returns(uint)
    {


    }

    function calProfitForErc20(address erc20) public view returns(uint)
    {
        address user = msg.sender;
        uint profit;
        for (uint i;i <= index;i++){
            if(i==index){
                uint endTime = block.timestamp;
                uint deltaT = endTime - publicVariableIndex[index].starTime;
                profit += deltaT * publicVariableIndex[index].reserveRate * userReserveIndex[index][user][erc20];

            }
            else{
                profit += calProfitForErc20S(i,erc20);
            }
        }
        return profit;


    }

    function calProfitForErc20S(uint _index,address erc20) public view returns(uint)
    {
        address user = msg.sender;
        publicVariableIndex[index];
        //userVariableIndex[index];
        uint deltaT = (publicVariableIndex[_index].endTime - publicVariableIndex[_index].starTime);
        uint profitS = deltaT * publicVariableIndex[_index].reserveRate * userReserveIndex[_index][user][erc20];
        return profitS;

    }
    function calReserveRate(address erc20) public view returns(uint)
    {
        return 8*10e17*AllBorrowed[erc20]/AllReserve[erc20];
        //计算时再除于10e18
    }
    function calDebtRate(address erc20) public view returns(uint)
    {
        return 10e18*AllBorrowed[erc20]/AllReserve[erc20];
    }

    

}
