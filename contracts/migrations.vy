
# TODO say this implements this?
contract Migrations():
  def setCompleted(completed: uint256): modifying
  def upgrade(new_address: address): modifying

owner: public(address)
last_completed_migration: public(uint256)

@public
def __init__():
  self.owner = msg.sender

@public
def setCompleted(completed: uint256):
  assert msg.sender == self.owner
  self.last_completed_migration = completed

@public
def upgrade(new_address: address):
  assert msg.sender == self.owner
  upgraded: Migrations = Migrations(new_address) # Invalid base type: Migrations
  upgraded.setCompleted(self.last_completed_migration)
