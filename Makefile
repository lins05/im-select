CC=gcc
NAME=im-select
MODULE=im-select-module
CFLAGS=-g -O0
LDFLAGS=-framework foundation -framework carbon

all: so

$(NAME):
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(NAME) $(NAME).m

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $^

%.so: %.o
	$(CC) $(CFLAGS) -g -O0 -L . -shared $(LDFLAGS) -o $@ $^ $(LDFLAGS)

so: $(MODULE).so

clean:
	rm -fv *.o *.so *.dylib im-select

.PHONY: clean so all
