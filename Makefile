-include .env

# install dependencies
install :
	forge install cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit

# deploy to local anvil chain
# firstly open second terminal and run anvil
deploy-anvil:
	forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast

deploy-sepolia:
	forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL_ETHEREUM_SEPOLIA) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv


#interactions
fund-anvil:
	forge script script/Interactions.s.sol:FundFundMe --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast

fund-sepolia:
	forge script script/Interactions.s.sol:FundFundMe --rpc-url $(RPC_URL_ETHEREUM_SEPOLIA) --private-key $(PRIVATE_KEY) --broadcast

withdraw-anvil:
	forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast

withdraw-sepolia:
	forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $(RPC_URL_ETHEREUM_SEPOLIA) --private-key $(PRIVATE_KEY) --broadcast


# create a folder with coverage report in .html format
coverage-report:
	forge coverage --report lcov
	genhtml -o coverage_report --branch-coverage lcov.info

# testing
fork-test_mainnet-eth:
	forge test --fork-url $(RPC_URL_ETHEREUM_MAINNET)

fork-test_mainnet-arb:
	forge test --fork-url $(RPC_URL_ARBIRUM_MAINNET)

#gas
gas-report:
	forge snapshot