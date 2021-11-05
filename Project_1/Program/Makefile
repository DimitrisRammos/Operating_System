# paths
MODULES = ../modules
INCLUDE = ../include
FILES = ../Input

# Compile options. Το -I<dir> λέει στον compiler να αναζητήσει εκεί include files
CFLAGS = -Wall -no-pie -fPIE -g -I$(INCLUDE)

# Αρχεία .o
INCL = $(INCLUDE)/
OBJS = mapcol.o $(MODULES)/

# the executable program
EXEC = 

# parameters
ARGS =

$(EXEC): $(OBJS) $(INCL)
	gcc $(OBJS) -o $(EXEC)

$(EXEC1): $(OBJS1)
	gcc $(OBJS1) -o $(EXEC1)

clean:
	rm -f $(OBJS) $(EXEC)


run: $(EXEC)
	./$(EXEC) $(ARGS)

gdb: $(OBJS)
	g++ $(OBJS) -g3 -o $(EXEC)
	gdb $(EXEC)