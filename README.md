## 哈希时间锁实现跨链交易的示例

前端代码见 https://github.com/EthanInMel/hashedtimelock-web

## 环境准备

1. 安装Foundry
https://book.getfoundry.sh/getting-started/installation

2. 根目录下运行 `forge install`


## 启动本地测试链
1. 启动anvil 本地测试链A 终端中输入 `anvil `  输出的私钥会在部署时用到

2. 在另一个终端下启动anvil 本地测试链B `anvil --chain-id 31338 -p 8546`


## 单元测试
1. 根目录下运行 `forge test -vvv --gas-report`  输出带gas消耗报告

## 部署合约到测试链
1. 创建 .env 文件 加入 PRIVATE_KEY=‘’ 从上面任意选一个地址部署
2. 部署到测试链A `forge script script/Deploy.s.sol:DeployScript --fork-url http://localhost:8545 --broadcast --force `

3. 部署到测试链B `forge script script/Deploy.s.sol:DeployScript --fork-url http://localhost:8546 --broadcast --force`

部署后会输出合约地址，前端目前写死

## 设计逻辑
Alice在A链上发起交易创建Lock，前端持续查询合约检测到该交易，Bob选择接受该交易，钱包申请切换到B链并在B链使用A的信息创建交易，A切换到B链，使用密钥Claim资产，B拿到密钥后切换到A链解锁A链上的资产完成交易。


## Todo
- [ ] 部署合约信息输出到文件
- [ ] 更多测试用例
- [ ] 使用后台服务存储lock
