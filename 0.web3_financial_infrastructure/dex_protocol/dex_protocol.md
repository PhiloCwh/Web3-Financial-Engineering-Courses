
<h1 align="center">
  <span style="font-size: 32px;"> dex 协议 </span>
  
</h1>


# dex类型
## AMM类型 （类uniswap）
- 全做市交易所
- 价格由算法来规范
- 价格算法双边平等
## 关键功能
### 添加流动性
- 添加条件
- 判断是否为第一次添加
### 如果是
- 创建新的lptoken
- 写入相关数据
- 计算lptoken数(用平方根方法计算 )
- 第一次添加流动性
        
- $$lpAmount = \sqrt{token_A * token_B}$$
- 该算法只是其中之一，具体看需求，会影响到做市商。

  
- 发送token到合约
  ### 如果不是
        写入相关数据
        计算lptoken数
        发送token到合约
    给用户mint lptoken
    更新数据
### 交易
    
- 条件
- 计算能兑换出多少token
- $$amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee)$$
- 兑换
- 更新数据

### 移除流动性
- 要求
- 计算
- $$amount0 = (_shares * datastore.getReserve(lptokenAddr,_token0)) / lptoken(lptokenAddr).totalSupply()$$
- $$amount1 = (_shares * datastore.getReserve(lptokenAddr,_token1)) / lptoken(lptokenAddr).totalSupply()$$
- 兑换
- 更新
## orderbook类型


