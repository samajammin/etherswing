count: int128

@public
def increment():
    self.count += 1

@public
def decrement():
    self.count -= 1

@public
@constant
def get() -> int128:
    return self.count
