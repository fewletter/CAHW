CC = gcc
OBJS = VariableByte.o
OUT = VariableByteout

all: test

%.o: %.c
	$(CC) -c -o $@ $<

test: $(OBJS)
	$(CC) -o $(OUT) $^
	./$(OUT)

clean: 
	rm -f $(OBJS) $(OUT)