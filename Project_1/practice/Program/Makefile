# paths
MODULES = ../modules
INCLUDE = ../include
FILES = ../Input

# Compile options. Το -I<dir> λέει στον compiler να αναζητήσει εκεί include files
CFLAGS = -Wall -no-pie -fPIE -g -I$(INCLUDE)

# Αρχεία .o
INCL = $(INCLUDE)/s_memory.h
OBJS = reading.o $(MODULES)/s_memory.o
OBJS1 = writing.o $(MODULES)/s_memory.o

# the executable program
EXEC = reading
EXEC1 = writing

# parameters
ARGS =

$(EXEC) $(EXEC1): $(OBJS) $(OBJS1) $(INCL)
	gcc -lpthread -pthread $(OBJS) -o $(EXEC)
	gcc -lpthread -pthread $(OBJS1) -o $(EXEC1)

# $(EXEC1): $(OBJS1)
#	gcc $(OBJS1) -o $(EXEC1)

clean:
	rm -f $(OBJS) $(OBJS1) $(EXEC) $(EXEC1)


run: $(EXEC)
	./$(EXEC) $(ARGS)

gdb: $(OBJS)
	g++ $(OBJS) -g3 -o $(EXEC)
	gdb $(EXEC)