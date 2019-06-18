# import uniswap_factory_interface as UniswapFactoryInterface
# import uniswap_exchange_interface as UniswapExchangeInterface

owner: address
# factory: UniswapFactoryInterface
# TODO mapping of user addresses to CDPs

# TODO CDP struct

@public
def __init__():
# def __init__(_uniswap_factory_address: address):
  self.owner = msg.sender
  # self.factory = UniswapFactoryInterface(_uniswap_factory_address)

@public
@payable
def fund():
  assert msg.value > 0, "Must send value to call this function."

@public
def transfer(_recipient: address, _amount: uint256(wei)):
  assert msg.sender == self.owner, "Must be contract owner to call this function."
  assert self.balance >= _amount, "Insufficient contract balance."
  send(_recipient, _amount)

# @public
# @payable
# def deposit():
#   assert msg.value > 0, "Must send value to call this function."
#   assert self.balance >= msg.value, "Insufficient contract balance to match deposit. Please use a smaller amount or try again later."
  
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

@public
@constant
def getOwner() -> address:
  return self.owner

@public
@constant
def getBalance() -> uint256(wei):
  return self.balance
