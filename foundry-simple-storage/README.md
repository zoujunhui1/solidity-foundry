# Foundry Simple Storage

一个基于 Foundry 的 Solidity 智能合约学习项目。

## 项目概述

本项目包含一个简单的 `SimpleStorage` 合约，用于存储和管理用户的喜爱数字。

## Foundry 工具链

Foundry 是一个用 Rust 编写的以太坊应用开发工具包，包含：

- **Forge**: 以太坊测试框架
- **Cast**: 与 EVM 智能合约交互的工具
- **Anvil**: 本地以太坊节点
- **Chisel**: Solidity REPL

## 快速开始

### 安装依赖

```shell
$ forge install
```

### 构建合约

```shell
$ forge build
```

### 运行测试

```shell
$ forge test
```

### 格式化代码

```shell
$ forge fmt
```

### 本地开发节点

```shell
$ anvil
```

## 合约说明

### SimpleStorage

`SimpleStorage` 合约提供以下功能：

- `store(uint256)` - 存储一个数字
- `retrieve()` - 获取存储的数字
- `addPerson(string, uint256)` - 添加一个人的信息（姓名和喜爱数字）

## 部署到测试网

### 配置环境变量

在 `.env` 文件中配置：

```env
SEPOLIA_PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your_api_key
```

### 部署脚本

```shell
$ forge script script/DeploySimpleStorage.s.sol:DeploySimpleStorage --rpc-url $SEPOLIA_RPC_URL --private-key $SEPOLIA_PRIVATE_KEY --broadcast
```

### 与合约交互

```shell
# 调用 store 函数
$ cast send <合约地址> "store(uint256)" 123 --rpc-url $SEPOLIA_RPC_URL --private-key $SEPOLIA_PRIVATE_KEY

# 调用 retrieve 函数
$ cast call <合约地址> "retrieve()" --rpc-url $SEPOLIA_RPC_URL
```

## VS Code 配置

已配置自动格式化，保存时自动使用 `forge fmt` 格式化代码。

## 学习资源

- [Foundry 官方文档](https://book.getfoundry.sh/)
- [Solidity 官方文档](https://docs.soliditylang.org/)
