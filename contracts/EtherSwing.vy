owner: address

@public
def __init__():
  self.owner = msg.sender

@public
@constant
def getOwner() -> address:
  return self.owner