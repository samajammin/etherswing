# TODO delete once incorporated into ether_swing
# https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md#create-a-script

contract UniswapExchange():
  def tokenToTokenSwapOutput(tokens_bought: uint256, max_tokens_sold: uint256, max_eth_sold: uint256(wei), deadline: timestamp, token_addr: address) -> uint256: modifying
  def getEthToTokenOutputPrice(tokens_bought: uint256) -> uint256(wei): constant
  def getTokenToEthOutputPrice(eth_bought: uint256(wei)) -> uint256: constant

contract Token():
  def allowance(owner: address, spender: address) -> uint256: constant
  def balanceOf(owner: address) -> uint256: constant
  def approve(spender: address, amount: uint256): modifying
  def transfer(recipient: address, amount: uint256) -> bool: modifying
  def transferFrom(sender: address, recipient: address, amount: uint256) -> bool: modifying

contract MakerTub():
  def wipe(cup: bytes32, wad: uint256): modifying
  def gov() -> address: constant # confirm this works, solidity interface returns Token
  def sai() -> address: constant # confirm this works, solidity interface returns Token
  def tab(cup: bytes32) -> uint256: modifying
  def rap(cup: bytes32) -> uint256: modifying
  def pep() -> address: constant # confirm this works, solidity interface returns PepLike

contract PepLike():
  def peek() -> (bytes32, bool): modifying


tub: MakerTub
daiExchange: UniswapExchange
mkrExchange: UniswapExchange
dai: Token
mkr: Token
pep: PepLike

@private
def setAllowance(tokenAddress: address, spender: address):
  if (Token(tokenAddress).allowance(self, spender) != MAX_UINT256):
    Token(tokenAddress).approve(spender, MAX_UINT256)

@public
def wipeWithDai(_tub: address, _daiExchange: address, _mkrExchange: address, cupid: uint256, wad: uint256):
  # Checks
  assert wad > 0, "Amount of Dai debt to pay back on the CDP must greater than 0."
  # Initialize variables
  self.tub = MakerTub(_tub)
  self.daiExchange = UniswapExchange(_daiExchange)
  self.mkrExchange = UniswapExchange(_mkrExchange)
  daiAddress: address = self.tub.sai()
  self.dai = Token(daiAddress)
  mkrAddress: address = self.tub.sai()
  self.mkr = Token(mkrAddress)
  pepAddress: address = self.tub.pep()
  self.pep = PepLike(pepAddress)
  cup: bytes32 = convert(cupid, bytes32)
  # Set all allowances
  self.setAllowance(daiAddress, _tub)
  self.setAllowance(mkrAddress, _tub)
  self.setAllowance(daiAddress, _daiExchange)
  # Transfer Dai to the DSProxy contract
  # Read the current MKRUSD price
  mkrUsdPrice: bytes32
  ok: bool
  mkrUsdPrice, ok = self.pep.peek()
  # Calculate the amount of MKR needed to execute wipe by dividing the stability fee amount accrued in Dai with the current value reported by the MKRUSD price oracle contract
  # One liner (uint)
  # mkrFee: uint256 = wad * (self.tub.rap(cup) / self.tub.tab(cup)) / convert(val, uint256)
  # One liner (decimal):
  # mkrFee: decimal = convert(wad, decimal) * (convert(self.tub.rap(cup), decimal) / convert(self.tub.tab(cup), decimal)) / convert(mkrUsdPrice, decimal)
  totalFeesInDai: decimal = convert(self.tub.rap(cup), decimal)
  totalDrawnDai: decimal = convert(self.tub.tab(cup), decimal)
  feesPerDai: decimal = totalFeesInDai / totalDrawnDai
  mkrFee: decimal = convert(wad, decimal) * feesPerDai / convert(mkrUsdPrice, decimal)

  # Calculate the additional Dai needed to buy MKR from Uniswap...
  # First calculate the amount of ETH needed to buy the required MKR
  ethAmt: uint256(wei) = self.mkrExchange.getEthToTokenOutputPrice(convert(mkrFee, uint256))
  # Then calculate the amount of Dai needed to buy the required ETH
  daiAmt: uint256 = self.daiExchange.getTokenToEthOutputPrice(ethAmt)
  # calculate the total amount of Dai and transfer it from the user's address to their DSProxy contract
  daiAmt = daiAmt + wad
  self.dai.transferFrom(msg.sender, self, daiAmt)
  # Exchange Dai for MKR on Uniswap
  if ok and mkrUsdPrice != convert(0, bytes32):
    max_eth_sold: uint256(wei) = 999000000000000000000
    deadline: timestamp = block.timestamp + 300
    self.daiExchange.tokenToTokenSwapOutput(convert(mkrFee, uint256), daiAmt, max_eth_sold, deadline, mkrAddress)
  # Wipe Dai debt from the CDP
  self.tub.wipe(cup, wad)
