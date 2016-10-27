CC=gcc
NAME=im-select
MODULE=im-select-module
LDFLAGS=-framework foundation -framework carbon

$(NAME):
	$(CC) $(LDFLAGS) -o $(NAME) $(NAME).m

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $^

%.so: %.o
	$(CC) -L . -shared $(LDFLAGS) -o $@ $^ $(LDFLAGS)

so: $(MODULE).so

all: so
