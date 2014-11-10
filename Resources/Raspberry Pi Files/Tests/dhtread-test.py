import dhtreader

type = 22
pin = 17

dhtreader.init()
print dhtreader.read(type, pin)
