PREFIX	:= /usr/local
CC	= cc
RM	= rm
CFLAGS  =
LDFLAGS	= -lncipher

all: n_cipher_encode n_cipher_decode

n_cipher_encode: encode.c
	$(CC) $(LDFLAGS) $(CFLAGS) $< -o $@

n_cipher_decode: decode.c
	$(CC) $(LDFLAGS) $(CFLAGS) $< -o $@

install-bin: n_cipher_encode n_cipher_decode
	install -pd $(PREFIX)/bin
	install -pm 755 n_cipher_encode $(PREFIX)/bin
	install -pm 755 n_cipher_decode $(PREFIX)/bin

clean:
	-$(RM) -f n_cipher_encode n_cipher_decode

install: install-bin

.PHONY:	all		\
	install		\
	install-bin	\
	clean
