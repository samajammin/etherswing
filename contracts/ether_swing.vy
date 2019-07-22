from vyper.interfaces import ERC20

struct CDP:
  owner: address
  lockedPeth: uint256

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

# MakerDAO's SaiTub
contract MakerTub():
  def gov() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def sai() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def pep() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def pip() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def skr() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def gem() -> address: constant # TODO since this seems to break, pass addresses into ether_swing constructor
  def per() -> uint256: constant
  def open() -> bytes32: modifying
  def join(wad: uint256): modifying
  def exit(wad: uint256): modifying
  def tab(cupId: bytes32) -> uint256: modifying
  def rap(cupId: bytes32) -> uint256: modifying
  def wipe(cupId: bytes32, wad: uint256): modifying
  def give(cupId: bytes32, guy: address): modifying
  def lock(cupId: bytes32, wad: uint256): modifying
  def free(cupId: bytes32, wad: uint256): modifying
  def draw(cupId: bytes32, wad: uint256): modifying

# Can't use ERC20 since WETH extends w/ deposit() & withdraw()
contract WETH():
  def balanceOf(owner: address) -> uint256: constant
  def approve(spender: address, amount: uint256) -> bool: modifying
  def deposit(): modifying
  def withdraw(amount: uint256): modifying

# to read pip, reference price feed
contract DSValue():
  def read() -> bytes32: constant

# Events

# TODO add events for user actions
Payment: event({_amount: uint256(wei), _from: indexed(address)})

# Storage

owner: address
userToCDP: map(address, CDP)

dai: ERC20
mkr: ERC20
weth: WETH
peth: ERC20
# TODO remove public from these once tested:
uniswapFactory: public(UniswapFactory) 
daiExchange: public(UniswapExchange)
makerTub: public(MakerTub)
mkrExchange: public(UniswapExchange)
# TODO worth assigning storage to exchanges & tokens?
# ... can access them all indirectly via Factory & Tub functions. prob cheaper.

# Constructor
@public
@payable
def __init__(factory: address, tub: address):
  assert factory != ZERO_ADDRESS
  assert tub != ZERO_ADDRESS
  self.owner = msg.sender

  self.makerTub = MakerTub(tub)
  self.dai = ERC20(self.makerTub.sai())
  self.mkr = ERC20(self.makerTub.gov())
  self.weth = WETH(self.makerTub.gem())
  self.peth = ERC20(self.makerTub.skr()) # TODO needed?

  # Approve MakerDAO to transfer Dai, MKR, PETH, WETH 
  self.dai.approve(self.makerTub, MAX_UINT256)
  self.mkr.approve(self.makerTub, MAX_UINT256)
  self.weth.approve(self.makerTub, MAX_UINT256)
  self.peth.approve(self.makerTub, MAX_UINT256)

  # Get Uniswap exchanges & approve token transfers
  self.uniswapFactory = UniswapFactory(factory)

  daiExchangeAddress: address = self.uniswapFactory.getExchange(self.makerTub.sai())
  self.daiExchange = UniswapExchange(daiExchangeAddress)
  self.dai.approve(daiExchangeAddress, MAX_UINT256)

  mkrExchangeAddress: address = self.uniswapFactory.getExchange(self.makerTub.gov())
  self.mkrExchange = UniswapExchange(mkrExchangeAddress)
  self.mkr.approve(mkrExchangeAddress, MAX_UINT256)

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

# TODO set private once tested
# Exchange DAI for ETH on Uniswap, returns value of ETH received
@public
def exchangeDaiForEth(dai_to_sell: uint256) -> uint256(wei):
  dai_balance: uint256 = self.dai.balanceOf(self)
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

# Open leveraged ETH position
@public
@payable
def openPosition(leverage: decimal):
  assert msg.value > 0, "Must send value to call this function."
  assert leverage < 3.0, "Leverage multiplier must be below 3."
  userDeposit: decimal = convert(as_unitless_number(msg.value), decimal)
  weiLoan: decimal =  userDeposit * leverage
  contractBalance: decimal = convert(as_unitless_number(self.balance), decimal)
  assert contractBalance >= weiLoan, "Insufficient contract balance. Please use a smaller amount or try again later."
  totalWeiDeposit: decimal = userDeposit + weiLoan
  
  # https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md#opening-a-cdp
  # TODO check out SaiProxy lockAndDraw & confirm steps are correct

  # convert ETH to WETH
  self.weth.deposit(value=totalWeiDeposit) # TODO works? no need to convert to uint256(wei)?

  # TODO check if msg.sender has an existing CDP, if so, add totalWeiDeposit to existing CDP?
  # open CDP
  cupId: bytes32 = self.makerTub.open()
  # convert WETH to PETH
  pethAmount: decimal = totalWeiDeposit / convert(self.makerTub.per(), decimal) # TODO fix. how to calculate?
  self.makerTub.join(convert(pethAmount, uint256))
  # Lock PETH in CDP
  self.makerTub.lock(cupId, convert(pethAmount, uint256))
  self.userToCDP[msg.sender] = CDP({owner: msg.sender, lockedPeth: convert(pethAmount, uint256)})
  # draw Dai
  daiToDraw: decimal = weiLoan * convert(DSValue(self.makerTub.pip()).read(), decimal) # TODO fix. how to calculate?
  self.exchangeDaiForEth(convert(daiToDraw, uint256))
  # TODO add platform fee

# Close leveraged ETH position & return funds to user
# @public
# def closePosition():
  # assert user has an open position
  # use treasury balance to exchange ETH for Dai on Uniswap
  # pay stability fees w/ Dai: 
  # https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md#pay-stability-fees-with-dai
  # close CDP by sending Dai
  # transfer all funds (minus ethLoan & fees) to msg.sender

@public
@constant
def getContractBalance() -> uint256(wei):
  return self.balance

@public
@constant
def getLockedEthBalance() -> uint256:
  return self.userToCDP[msg.sender].lockedPeth