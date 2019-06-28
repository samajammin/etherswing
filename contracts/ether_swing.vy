# NOTE: import statements are interpreted from CWD, so must call command to compile in /contracts/
import uniswap_factory_interface as UniswapFactoryInterface
import uniswap_exchange_interface as UniswapExchangeInterface

# EtherSwing contract

# Storage
owner: address
# uniswap_factory_address: public(address)
# uniswap_dai_exchange_address: public(address)
# uniswap_factory: UniswapFactoryInterface
# uniswap_dai_exchange: UniswapExchangeInterface

# Constructor
# def __init__(_uniswap_factory_address: address, _dai_token_address: address):
@public
def __init__():
  # assert _uniswap_factory_address != ZERO_ADDRESS
  # assert _dai_token_address != ZERO_ADDRESS
  self.owner = msg.sender
  # self.uniswap_factory_address = _uniswap_factory_address
  # self.uniswap_factory = UniswapFactoryInterface(_uniswap_factory_address)
  # self.uniswap_dai_exchange_address = self.uniswap_factory.getExchange(_dai_token_address)
  # self.uniswap_dai_exchange = UniswapExchangeInterface(self.uniswap_dai_exchange_address)

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
# @public
# def exchangeDai(dai_contract: address, amount_eth: uint256) -> uint256:
  # TODO how to send value (amount_eth) in contract call?
  # amount_received = uniswap_dai_exchange.ethToTokenSwapInput.value(amount_eth)(min_tokens, deadline)
  # min_tokens: uint256 = 1 #TODO: implement this correctly, see "sell order" logic in docs
  # deadline: timestamp = block.timestamp + 300
  # TODO call this from convertCurrency
  # return min_tokens
  # return self.uniswap_dai_exchange.ethToTokenSwapInput(min_tokens, deadline)
  # TODO send amount_received to user's CDP

@public
@constant
def getBalance() -> uint256(wei):
  return self.balance

##########
# MakerDAO
##########

# Storage
# TODO mapping of user addresses to CDPs
# TODO CDP struct

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
