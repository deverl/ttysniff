#  Makefile for the ttysniff program.
#
# ttysniff is a command line program to hex-dump a file.
#

PLATFORM := $(shell uname)

ifeq ($(PLATFORM), Darwin)
    CC := clang
else
    CC := gcc
endif

CC_FLAGS = -c -Wall -pedantic -MMD -MP -MMD -MP

ifdef DEBUG
    CC_FLAGS += -g2 -O0 -DDEBUG -D_DEBUG
    OBJDIR := $(PLATFORM)_objd
else
    CC_FLAGS += -O3 -DNDEBUG -DRELEASE
    OBJDIR := $(PLATFORM)_objn
endif

ifeq ($(PLATFORM),Linux)
    CC_FLAGS += -DLINUX -D_LINUX -D__LINUX__
endif


C_SRC_FILES := ttysniff.c
OBJ_LIST    := $(C_SRC_FILES:.c=.o)
OBJ_FILES   := $(addprefix $(OBJDIR)/, $(OBJ_LIST))
DEP_FILES   := $(OBJ_FILES:.o=.d)


.DEFAULT : all

all : $(OBJDIR)/ttysniff

.PHONY : clean

dep : $(DEP_FILES)

-include $(OBJ_FILES:.o=.d)

$(OBJDIR)/ttysniff : $(OBJ_FILES) makefile
	@if [ ! -d $(@D) ] ; then mkdir -p $(@D) ; fi
	$(CC) -o $@ $(OBJ_FILES)
ifndef DEBUG
	strip $(OBJDIR)/ttysniff
endif

$(OBJDIR)/%.o : %.c makefile 
	@if [ ! -d $(@D) ] ; then mkdir -p $(@D) ; fi
	$(CC) $(CC_FLAGS) -o $@ $<

clean:
	rm -rf $(PLATFORM)_obj[dn] build

install: $(OBJDIR)/ttysniff
	cp $(OBJDIR)/ttysniff ~/bin

