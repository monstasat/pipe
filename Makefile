CC = g++

PROG = zmq

CFLAGS =
CFLAGS += `pkg-config --cflags libzmq`

LDFLAGS =
LDFLAGS += `pkg-config --libs libzmq`

SOURCES = zmq.cpp

OBJECTS=$(SOURCES:.cpp=.o)

$(PROG): $(OBJECTS)
	@echo " Linking..."; $(CC) $(LIBS) $(LDFLAGS) $(OBJECTS) -o $(PROG)

%.o: %.c
	@echo " CC $<"; $(CC) $(CFLAGS) -c $<

all: $(PROG)

default: $(PROG)

clean:
	@echo " Cleaning..."; rm *.o
