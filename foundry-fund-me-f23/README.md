# solidity-foundry

## 学习笔记

### 一、测试框架基础

#### 1. 测试函数命名规范
测试函数必须以 `test` 开头：
```solidity
function testSomething() public {
    // 测试代码
}
```

#### 2. setUp() 函数
在每个测试函数执行前自动运行，用于初始化测试环境：
```solidity
function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
}
```

### 二、核心 Cheatcodes

#### 1. vm.expectRevert()
**作用**：预期接下来的调用会 revert，如果不 revert 则测试失败。

**使用方式**：
```solidity
function testFundFailsWithoutEnoughEth() public {
    vm.expectRevert("You need to spend more ETH!");
    fundMe.fund{value: 1 wei}();
}
```

**关键点**：必须**先写 expectRevert，再执行调用**。

#### 2. vm.prank()
**作用**：伪装成指定地址发送交易（只生效一次）。

**使用方式**：
```solidity
address constant USER = makeAddr("user");

function testFundAsUser() public {
    vm.prank(USER);  // 假装是 USER
    fundMe.fund{value: 1 ether}();  // 以 USER 身份调用
}
```

#### 3. vm.startPrank() / vm.stopPrank()
**作用**：持续伪装成指定地址（直到 stopPrank）。

**使用方式**：
```solidity
vm.startPrank(USER);
fundMe.fund{value: 1 ether}();
fundMe.fund{value: 2 ether}();  // 连续多次调用都以 USER 身份
vm.stopPrank();
```

#### 4. makeAddr()
**作用**：创建一个确定性的伪造地址，用于测试。

**使用方式**：
```solidity
address constant USER = makeAddr("user");  // 创建一个名为 "user" 的假地址
```

### 三、测试环境配置

#### 本地测试（无需 RPC）
```bash
forge test -vvv
```

#### 连接测试网（需要 RPC URL）
```bash
source .env
forge test --match-test testPriceFeedVersionIsAccurate -vvvv --rpc-url $SEPOLIA_RPC_URL
```

#### Fork 模式（本地模拟真实网络）
```bash
forge test --match-test testPriceFeedVersionIsAccurate -vvvv --fork-url $SEPOLIA_RPC_URL
```

### 四、常见问题

#### 问题 1：测试预言机失败
**原因**：本地环境没有 Chainlink 预言机合约。

**解决方案**：
- 连接真实测试网（使用 `--rpc-url`）
- 使用 Mock 合约（参考 `HelperConfig.s.sol`）

#### 问题 2：testOwnerIsCaller 失败
**原因**：`msg.sender` 在测试函数中是 Foundry 默认地址，不是测试合约地址。

**解决方案**：使用 `address(this)` 代替 `msg.sender`：
```solidity
function testOwnerIsCaller() public view {
    assertEq(fundMe.i_owner(), address(this));
}
```

#### 问题 3：pure 函数不能修改状态
**错误示例**：
```solidity
function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
    vm.startBroadcast();  // ❌ pure 函数不能调用非 pure 的函数
    ...
}
```

**解决方案**：将 `pure` 改为 `public` 或 `internal`。

### 五、使用 Makefile 快速操作

项目已配置 `Makefile`，可以使用简单命令完成常见操作：

| 命令 | 说明 |
|------|------|
| `make help` | 查看所有可用命令 |
| `make build` | 编译合约 |
| `make clean` | 清理编译文件 |
| `make format` | 格式化 Solidity 代码 |
| `make test` | 运行所有测试 |
| `make test-vvv` | 运行所有测试（详细输出） |
| `make test-sepolia` | 连接 Sepolia 测试网测试 |
| `make test-fork` | Fork Sepolia 模式测试 |
| `make deploy-sepolia` | 部署到 Sepolia 测试网 |

### 六、测试命令汇总

| 命令 | 说明 |
|------|------|
| `forge test` | 运行所有测试 |
| `forge test --match-test testName` | 运行指定测试 |
| `forge test -vvv` | 详细输出 |
| `forge test --rpc-url $URL` | 连接指定网络 |
| `forge test --fork-url $URL` | Fork 模式 |

### 七、学习要点总结

1. **测试驱动开发**：先写测试，再实现功能
2. **Mock 合约**：用于模拟外部依赖（如 Chainlink 预言机）
3. **环境分离**：本地测试 vs 测试网测试
4. **Cheatcodes**：强大的测试工具，掌握常用的几个
5. **错误处理**：使用 `expectRevert` 验证错误情况

---

*学习日期：2026年5月27日*