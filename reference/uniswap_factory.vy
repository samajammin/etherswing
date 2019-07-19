# interface for uniswap_exchange.vy
contract Exchange():
    def setup(token_addr: address): modifying

# events
NewExchange: event({token: indexed(address), exchange: indexed(address)})

# exchangeTemplate == uniswap_exchange.vy
exchangeTemplate: public(address)
tokenCount: public(uint256)
# registry for ETH-ERC20 exchanges
token_to_exchange: address[address]
exchange_to_token: address[address]
id_to_token: address[uint256]

# constructor
@public
def initializeFactory(template: address):
    assert self.exchangeTemplate == ZERO_ADDRESS
    assert template != ZERO_ADDRESS
    self.exchangeTemplate = template

# deploy new ETH-ERC20 exchange contract 
# can only be called after initializeFactory
@public
def createExchange(token: address) -> address:
    assert token != ZERO_ADDRESS
    assert self.exchangeTemplate != ZERO_ADDRESS
    assert self.token_to_exchange[token] == ZERO_ADDRESS
    exchange: address = create_with_code_of(self.exchangeTemplate) # now create_forwarder_to: duplicates a contract’s code and deploys it as a new instance
    Exchange(exchange).setup(token)
    self.token_to_exchange[token] = exchange
    self.exchange_to_token[exchange] = token
    token_id: uint256 = self.tokenCount + 1
    self.tokenCount = token_id
    self.id_to_token[token_id] = token
    log.NewExchange(token, exchange)
    return exchange

@public
@constant
def getExchange(token: address) -> address:
    return self.token_to_exchange[token]

@public
@constant
def getToken(exchange: address) -> address:
    return self.exchange_to_token[exchange]

@public
@constant
def getTokenWithId(token_id: uint256) -> address:
    return self.id_to_token[token_id]
