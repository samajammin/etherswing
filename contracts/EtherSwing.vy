owner: address

@public
def __init__():
  self.owner = msg.sender

@public
@payable
def fund():
  assert msg.value > 0, "Must send value to call this function."

@public
def transfer(_recipient: address, _amount: uint256(wei)):
  assert msg.sender == self.owner, "Must be contract owner to call this function."
  assert self.balance >= _amount, "Insufficient contract balance."
  send(_recipient, _amount)

@public
@constant
def getOwner() -> address:
  return self.owner

@public
@constant
def getBalance() -> uint256(wei):
  return self.balance
