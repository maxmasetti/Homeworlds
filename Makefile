UNAME := $(shell uname -s)

ifeq ($(UNAME),Darwin)
  CC = gcc
  CXX = g++
  ifneq (,$(findstring -std=c++11,$(CXXFLAGS)))
    CXXFLAGS += -stdlib=libc++
  endif
else
  CC = gcc
  CXX = g++
endif

INCLUDES = -Icore-src
CFLAGS += -W -Wall -Wextra -march=native ${INCLUDES}

# The release setup.
#CFLAGS += -O3 -fomit-frame-pointer -DNDEBUG
# The profiling setup.
#CFLAGS += -O3 -pg -DNDEBUG
# The debug setup.
CFLAGS += -O2 -g

# Replace this line to use a different evaluation function.
AIEVAL = core-src/AIStaticEval3.cc

OBJS = mprintf.o PieceCollection.o StarSystem.o GameState.o WholeMove.o ApplyMove.o
AIOBJS = AllMoves.o AIMove.o AIStaticEval.o PlanetNames.o ${OBJS}

all: annotate wxgui

annotate: annotatemain.o getline.o InferMove.o ${AIOBJS}
	${CXX} ${CFLAGS} ${CXXFLAGS} $^ -o $@

wxgui: wxmain.o wxPiece.o wxSystem.o wxStash.o wxGalaxy.o wxMouse.o getline.o InferMove.o ${AIOBJS}
	${CXX} ${CFLAGS} ${CXXFLAGS} $^ `wx-config --libs` -o $@

AIStaticEval.o: ${AIEVAL} core-src/*.h
	${CXX} ${CFLAGS} ${CXXFLAGS} $< -c -o $@

getline.o: core-src/getline.c core-src/getline.h
	${CC} ${CFLAGS} $< -c -o $@

%.o: core-src/%.cc core-src/*.h
	${CXX} ${CFLAGS} ${CXXFLAGS} $< -c -o $@

%.o: wxgui-src/%.cc wxgui-src/*.h core-src/*.h
	${CXX} ${CFLAGS} ${CXXFLAGS} $< `wx-config --cppflags` -c -o $@

clean:
	rm -f *.o annotate wxgui
