from vyper.interfaces import ERC20

struct CDP:
  owner: address
  lockedEth: uint256(wei)

# Interfaces

contract UniswapFactory():
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

contract UniswapExchange():
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

contract MakerTub():
  def wipe(cup: bytes32, wad: uint256): modifying
  def gov() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def sai() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def tab(cup: bytes32) -> uint256: modifying
  def rap(cup: bytes32) -> uint256: modifying
  def pep() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor

# Events

# TODO add events for user actions
Payment: event({_amount: uint256(wei), _from: indexed(address)})

# Storage

owner: address
userToCDP: map(address, CDP)

daiToken: ERC20
uniswapFactory: public(UniswapFactory) # TODO no need to be public
daiExchange: public(UniswapExchange)
makerTub: public(MakerTub)

# Constructor
# TODO pass in MakerTub address. will need interface
# w/ MakerTub interface, can get dai address & weth address
@public
@payable
def __init__(uniswap_factory_address: address, mkr_tub_address: address, dai_token_address: address):
  assert uniswap_factory_address != ZERO_ADDRESS
  assert mkr_tub_address != ZERO_ADDRESS
  self.owner = msg.sender

  # Get Dai address
  self.makerTub = MakerTub(mkr_tub_address)
  # TODO doesn't work :( 
    # b/c SaiTub.sai() refers to an interface?? Even though it returns an address?
    # daiTokenAddress: address = self.makerTub.sai()
  # TODO approve MakerTub to transfer Dai & MKR

  # Get Dai exchange
  self.uniswapFactory = UniswapFactory(uniswap_factory_address)
  # TODO change mkr_tub_address to daiTokenAddress
  daiExchangeAddress: address = self.uniswapFactory.getExchange(dai_token_address)
  self.daiExchange = UniswapExchange(daiExchangeAddress)

  # # Approve Dai exchange to transfer funds
  self.daiToken = ERC20(dai_token_address)
  self.daiToken.approve(daiExchangeAddress, MAX_UINT256)


# Need default function to receive ETH from Dai exchange
# https://vyper.readthedocs.io/en/v0.1.0-beta.10/structure-of-a-contract.html#default-function
@public
@payable
def __default__():
    log.Payment(msg.value, msg.sender)

# Fund the contract's treasury
@public
@payable
def fund():
  assert msg.value > 0, "Must send value to call this function."

# Transfer contract's treasury
@public
def transfer(recipient: address, amount: uint256(wei)):
  assert msg.sender == self.owner, "Must be contract owner to call this function."
  assert self.balance >= amount, "Insufficient contract balance."
  send(recipient, amount)

# Open leveraged ETH position
@public
@payable
def openPosition(leverage: uint256):
  assert msg.value > 0, "Must send value to call this function."
  assert leverage < 3, "Leverage multiplier must be below 3." # TODO how to support decimals? 2.5x
  ethLoan: uint256(wei) = msg.value * leverage
  assert self.balance >= ethLoan, "Insufficient contract balance. Please use a smaller amount or try again later."
  totalEth: uint256(wei) = msg.value + ethLoan

  # check if msg.sender already has an open CDP
  # if they do...
    # add totalEth to existing CDP
  # else...
    # open CDP w/ totalEth
  self.userToCDP[msg.sender] = CDP({owner: msg.sender, lockedEth: totalEth})

# Close leveraged ETH position & return funds to user
# @public
# def closePosition():
  # assert user has an open position
  # use treasury balance to exchange ETH for Dai on Uniswap
  # close CDP by sending Dai
  # transfer all funds (minus ethLoan & fees) to msg.sender

# TODO set private once tested
# Exchange DAI for ETH on Uniswap, returns value of ETH received
@public
def exchangeDaiForEth(dai_to_sell: uint256) -> uint256(wei):
  dai_balance: uint256 = self.daiToken.balanceOf(self)
  assert dai_balance > dai_to_sell, "Insufficient contract balance to sell DAI."
  min_eth_to_buy: uint256(wei) = 1
  deadline: timestamp = block.timestamp + 300
  eth_bought: uint256(wei) = self.daiExchange.tokenToEthSwapInput(dai_to_sell, min_eth_to_buy, deadline)
  return eth_bought
  # TODO send amount_received to user's CDP

# TODO set private once tested
# Exchange ETH for DAI on Uniswap, returns value of DAI received
@public
def exchangeEthForDai(wei_to_sell: uint256(wei)) -> uint256:
  assert self.balance >= wei_to_sell, "Insufficient contract balance to sell ETH."
  min_tokens_to_buy: uint256 = 1
  deadline: timestamp = block.timestamp + 300
  dai_received: uint256 = self.daiExchange.ethToTokenSwapInput(min_tokens_to_buy, deadline, value=wei_to_sell)
  return dai_received
  # TODO send amount_received to user's CDP

@public
@constant
def getContractBalance() -> uint256(wei):
  return self.balance

@public
@constant
def getLockedEthBalance() -> uint256(wei):
  return self.userToCDP[msg.sender].lockedEth