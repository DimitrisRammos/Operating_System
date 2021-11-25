# paths
MODULES = ../modules
INCLUDE = ../include
FILES = ../Input

# Compile options. Το -I<dir> λέει στον compiler να αναζητήσει εκεί include files
CFLAGS = -Wall -no-pie -fPIE -g -I$(INCLUDE)

# Αρχεία .o
INCL = $(INCLUDE)/
OBJS = program.o
OBJS1 = child_process.o

# the executable program
EXEC = program
EXEC1 = child_process

# parameters
ARGS = 1 10 10

$(EXEC) $(EXEC1): $(OBJS) $(OBJS1) $(INCL)
	gcc -lpthread -pthread $(OBJS) -o $(EXEC)
	gcc -lpthread -pthread $(OBJS1) -o $(EXEC1)

clean:
	rm -f $(OBJS) $(EXEC) $(OBJS1) $(EXEC1)


run: $(EXEC)
	./$(EXEC) $(ARGS)

gdb: $(OBJS)
	g++ $(OBJS) -g3 -o $(EXEC)
	gdb $(EXEC)