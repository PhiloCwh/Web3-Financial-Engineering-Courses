
<h1 align="center">
  <span style="font-size: 32px;"> 流动性金融协议 </span>
  
</h1>

- 公共资产架构（用于计算利息）
- 结构体的3个数据结构
- 1.开始时间
- 2.结束时间
- 3.期间收益率
- index：用于记录不同的struct（用于计算收益）
- 通过index把用户不同时间的利息加起来（引出需要保存用户不同时间的资产负债）
- userindexborrowed 为 address => uint => uint (user => index => borrowed)
- 某一时间段利息计算：收益pi（t0到t1的差额t） = 用户资产负债 * t * 利息率
- 总收益 $$P = \sum_{i=0}^{n} p_i$$
- $$P = \sum_{i=0}^{n} p_i   / p_i =  userborrow_i * profitrate _i * t_i$$
- $$profitrate_i = borrowed_i/reserve_i (0 < profitrate < 1)$$
## 1.存入资产


## 2.借出资产

## 3.计算利息
### 先微分（计算用户每个时间段需要付有多少的利息和得到多少利润）
- 开始时间
- 结束时间
- 用户资产
- 用户负债
- 资产利润率
- 负债利息率
#### 利润微分 = （结束时间 - 开始时间）* 用户资产 * 资产利润率
- $$p_i = (t_i - t_{i-1}) * userReserve_i * reserveRate_i$$
#### 负债利息微分 = （结束时间 - 开始时间）* 用户负债 * 负债利润率 
- $$d_i = (t_i - t_{i-1}) * userDebt_i * DebtRate_i$$

- 总利润 $$P = \sum_{i=0}^{n} p_i$$
- 总负债利息 $$D = \sum_{i=0}^{n} d_i$$
  
## 4.偿还贷款和收益

## 5.清算资产
