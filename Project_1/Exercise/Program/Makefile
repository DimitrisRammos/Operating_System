# paths
MODULES = ../modules
INCLUDE = ../include
FILES = ../Input

# Compile options. Το -I<dir> λέει στον compiler να αναζητήσει εκεί include files
CFLAGS = -Wall -no-pie -fPIE -g -I$(INCLUDE)

# Αρχεία .o
INCL = $(INCLUDE)/inclu.h $(INCLUDE)/shared_memory.h
OBJS = parent_process.o $(MODULES)/shared_memory.o
OBJS1 = child_process.o $(MODULES)/shared_memory.o

# the executable program
EXEC = parent_process
EXEC1 = child_process

# parameters
ARGS = file.txt 10 10

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