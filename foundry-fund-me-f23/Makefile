# Foundry FundMe 项目 Makefile

# 帮助信息
.PHONY: help
help:
	@echo "Foundry FundMe 项目命令列表"
	@echo ""
	@echo "开发命令:"
	@echo "  make build         - 编译合约"
	@echo "  make clean         - 清理编译文件"
	@echo "  make format        - 格式化 Solidity 代码"
	@echo ""
	@echo "测试命令:"
	@echo "  make test          - 运行所有测试"
	@echo "  make test-vv       - 运行所有测试（详细输出）"
	@echo "  make test-vvv      - 运行所有测试（非常详细输出）"
	@echo "  make test-sepolia  - 运行所有测试（连接 Sepolia）"
	@echo "  make test-fork     - 运行所有测试（Fork Sepolia）"
	@echo ""
	@echo "部署命令:"
	@echo "  make deploy-sepolia  - 部署合约到 Sepolia 测试网"
	@echo ""
	@echo "其他:"
	@echo "  make help          - 显示此帮助信息"

# 编译合约
.PHONY: build
build:
	forge build

# 清理编译文件
.PHONY: clean
clean:
	forge clean

# 格式化代码
.PHONY: format
format:
	forge fmt

# 运行所有测试
.PHONY: test
test:
	forge test

# 运行所有测试（详细输出）
.PHONY: test-vv
test-vv:
	forge test -vv

# 运行所有测试（非常详细输出）
.PHONY: test-vvv
test-vvv:
	forge test -vvv

# 运行所有测试（连接 Sepolia）
.PHONY: test-sepolia
test-sepolia:
	source .env && forge test --rpc-url $${SEPOLIA_RPC_URL} -vvv

# 运行所有测试（Fork Sepolia）
.PHONY: test-fork
test-fork:
	source .env && forge test --fork-url $${SEPOLIA_RPC_URL} -vvv

# 部署合约到 Sepolia 测试网
.PHONY: deploy-sepolia
deploy-sepolia:
	source .env && forge script script/DeployFundMe.s.sol --rpc-url $${SEPOLIA_RPC_URL} --broadcast -vvv