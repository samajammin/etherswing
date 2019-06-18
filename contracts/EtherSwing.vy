# TODO use import
# import uniswap_factory_interface as UniswapFactoryInterface
# import uniswap_exchange_interface as UniswapExchangeInterface

# TODO remove once imported
contract UniswapFactoryInterface():
    # Create Exchange
    def createExchange(token: address) -> address: modifying
    # Public Variables
    def exchangeTemplate() -> address: constant
    def tokenCount() -> uint256: constant
    # Get Exchange and Token Info
    def getExchange(token_addr: address) -> address: constant
    def getToken(exchange: address) -> address: constant
    def getTokenWithId(token_id: uint256) -> address: constant
    # Initialize Factory
    def initializeFactory(template: address): modifying

# TODO remove once imported
contract UniswapExchangeInterface():
    # Public Variables
    def tokenAddress() -> address: constant
    def factoryAddress() -> address: constant
    # Providing Liquidity
    def addLiquidity(min_liquidity: uint256, max_tokens: uint256, deadline: timestamp) -> uint256: modifying
    def removeLiquidity(amount: uint256, min_eth: uint256(wei), min_tokens: uint256, deadline: timestamp) -> (uint256(wei), uint256): modifying
    # Trading
    def ethToTokenSwapInput(min_tokens: uint256, deadline: timestamp) -> uint256: modifying
    def ethToTokenTransferInput(min_tokens: uint256, deadline: timestamp, recipient: address) -> uint256: modifying
    def ethToTokenSwapOutput(tokens_bought: uint256, deadline: timestamp) -> uint256(wei): modifying
    def ethToTokenTransferOutput(tokens_bought: uint256, deadline: timestamp, recipient: address) -> uint256(wei): modifying
    def tokenToEthSwapInput(tokens_sold: uint256, min_eth: uint256(wei), deadline: timestamp) -> uint256(wei): modifying
    def tokenToEthTransferInput(tokens_sold: uint256, min_eth: uint256(wei), deadline: timestamp, recipient: address) -> uint256(wei): modifying
    def tokenToEthSwapOutput(eth_bought: uint256(wei), max_tokens: uint256, deadline: timestamp) -> uint256: modifying
    def tokenToEthTransferOutput(eth_bought: uint256(wei), max_tokens: uint256, deadline: timestamp, recipient: address) -> uint256: modifying
    def tokenToTokenSwapInput(tokens_sold: uint256, min_tokens_bought: uint256, min_eth_bought: uint256(wei), deadline: timestamp, token_addr: address) -> uint256: modifying
    def tokenToTokenTransferInput(tokens_sold: uint256, min_tokens_bought: uint256, min_eth_bought: uint256(wei), deadline: timestamp, recipient: address, token_addr: address) -> uint256: modifying
    def tokenToTokenSwapOutput(tokens_bought: uint256, max_tokens_sold: uint256, max_eth_sold: uint256(wei), deadline: timestamp, token_addr: address) -> uint256: modifying
    def tokenToTokenTransferOutput(tokens_bought: uint256, max_tokens_sold: uint256, max_eth_sold: uint256(wei), deadline: timestamp, recipient: address, token_addr: address) -> uint256: modifying
    def tokenToExchangeSwapInput(tokens_sold: uint256, min_tokens_bought: uint256, min_eth_bought: uint256(wei), deadline: timestamp, exchange_addr: address) -> uint256: modifying
    def tokenToExchangeTransferInput(tokens_sold: uint256, min_tokens_bought: uint256, min_eth_bought: uint256(wei), deadline: timestamp, recipient: address, exchange_addr: address) -> uint256: modifying
    def tokenToExchangeSwapOutput(tokens_bought: uint256, max_tokens_sold: uint256, max_eth_sold: uint256(wei), deadline: timestamp, exchange_addr: address) -> uint256: modifying
    def tokenToExchangeTransferOutput(tokens_bought: uint256, max_tokens_sold: uint256, max_eth_sold: uint256(wei), deadline: timestamp, recipient: address, exchange_addr: address) -> uint256: modifying
    # Get Price
    def getEthToTokenInputPrice(eth_sold: uint256(wei)) -> uint256: constant
    def getEthToTokenOutputPrice(tokens_bought: uint256) -> uint256(wei): constant
    def getTokenToEthInputPrice(tokens_sold: uint256) -> uint256(wei): constant
    def getTokenToEthOutputPrice(eth_bought: uint256(wei)) -> uint256: constant
    # Pool Token ERC20 Compatibility
    def balanceOf() -> address: constant
    def allowance(_owner : address, _spender : address) -> uint256: constant
    def transfer(_to : address, _value : uint256) -> bool: modifying
    def transferFrom(_from : address, _to : address, _value : uint256) -> bool: modifying
    def approve(_spender : address, _value : uint256) -> bool: modifying
    # Setup
    def setup(token_addr: address): modifying

# EtherSwing contract

# Storage
owner: address
# dai_token_address: address
# dai_exchange_adress: address
uniswap_factory: UniswapFactoryInterface
uniswap_dai_exchange: UniswapExchangeInterface

# TODO mapping of user addresses to CDPs
# TODO CDP struct

# Constructor
@public
def __init__(_uniswap_factory_address: address, _dai_token_address: address):
  self.owner = msg.sender
  self.uniswap_factory = UniswapFactoryInterface(_uniswap_factory_address)
  dai_exchange_address: address = self.uniswap_factory.getExchange(_dai_token_address)
  self.uniswap_dai_exchange = UniswapExchangeInterface(dai_exchange_address)

# Fund the contract's treasury balance
@public
@payable
def fund():
  assert msg.value > 0, "Must send value to call this function."

# Transfer contract's treasury balance
@public
def transfer(recipient: address, amount: uint256(wei)):
  assert msg.sender == self.owner, "Must be contract owner to call this function."
  assert self.balance >= amount, "Insufficient contract balance."
  send(recipient, amount)

# #######
# Uniswap
#########

# TODO set private once tested
# Exchange ETH for DAI on Uniswap, returns value of DAI received
@public
def exchangeDai(dai_contract: address, amount_eth: uint256) -> uint256:
  # TODO how to send value (amount_eth) in contract call?
  # amount_received = uniswap_dai_exchange.ethToTokenSwapInput.value(amount_eth)(min_tokens, deadline)
  min_tokens: uint256 = 1 #TODO: implement this correctly, see "sell order" logic in docs
  deadline: timestamp = block.timestamp + 300
  # TODO call this from convertCurrency
  return self.uniswap_dai_exchange.ethToTokenSwapInput(min_tokens, deadline)
  # TODO send amount_received to user's CDP

@public
@constant
def getOwner() -> address:
  return self.owner

@public
@constant
def getBalance() -> uint256(wei):
  return self.balance

##########
# MakerDAO
##########

# @public
# @payable
# def deposit():
  # assert msg.value > 0, "Must send value to call this function."
  # assert self.balance >= msg.value, "Insufficient contract balance to match deposit. Please use a smaller amount or try again later."
  
  # check if msg.sender already has an open cdp

  # if they do...
  # add msg.value & matching balance value to existing cdp
        
  # if not...
  # use msg.value & matching balance value to open a cdp

  # return anything?
  # how to confirm cdp was opened / contributed to succesfully?

# @public
# def withdraw():
  # close CDP
  # transfer all funds (minus contract contribution & fees) to msg.sender
