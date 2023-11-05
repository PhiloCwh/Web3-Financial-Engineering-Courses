// SPDX-License-Identifier: MIT



pragma solidity ^0.8.9;

library  Algorithm{
    /*
    \frac{-4ADx^2-4x+4AD^2x+\sqrt{\left(4ADx^2+4x-4AD^2x\right)^2+16AD^3x}}{8ADx}

    \frac{-4ADx^2-4x+4AD^2x+\sqrt{\left(4ADx^2+4x-4AD^2x\right)^2+16AD^3x}}{8ADx}

    y=(4*A*D*D*X-4*X-4*A*D*X*X + calSqrt(A, D, X))/8*A*D*X
    dy = y - (4*A*D*D*X-4*X-4*A*D*X*X + calSqrt(A, D, X))/8*A*D*X
    */







    function calOutAmount(uint A, uint D, uint X)public pure returns(uint)
    {
        //return  (4*A*D*D*X+calSqrt(A, D, X) -4*X-4*A*D*X*X) / (8*A*D*X);
        uint a = 4*A*D*X+D*calSqrt(A, D, X)-4*A*X*X-D*X;
        //uint amountOut2 = y - amountOut1;
        return a/(8*A*X);

    }

    function calOutput(uint A, uint D, uint X,uint dx)public pure returns(uint)
    {
        //D = D * 10**18;
        //X = X * 10**18;
        //dx = dx* 10**18;
        uint S = X + dx;
        uint amount1 = calOutAmount(A, D, X);
        uint amount2 = calOutAmount(A, D, S);

        //uint amountOut2 = y - amountOut1;
        return amount1 - amount2;

    }

    


    function calSqrt(uint A, uint D, uint X)public pure returns(uint)
    {
        //uint T = t(A,D,X);
        //uint calSqrtNum = _sqrt((X*(4+T))*(X*(4+T))+T*T*D*D+4*T*D*D-2*X*T*D*(4+T));
        //return calSqrtNum;
        (uint a, uint b) = (4*A*X*X/D+X,4*A*X);
        uint c;
        if(a>=b){
            c = a -b;
        }else{
            c = b-a;
        }

        return _sqrt(c*c+4*D*X*A);

    }

    function _min(uint x, uint y) public pure returns (uint) {
        return x <= y ? x : y;
    }




    function _sqrt(uint y) public pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _sortAddr(address a, address b) public pure returns(address small,address big)
    {
        //a > b ? return(b,a) : return(a,b);
        a > b ? (big=a,small = b) : (big=b,small = a);
    }






}
