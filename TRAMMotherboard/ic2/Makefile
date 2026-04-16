NAME := tmp11

WINE     ?= wine
CUPL_DIR ?= C:/WinCUPL/Shared
CUPL     := $(CUPL_DIR)/cupl.exe
CUPL_DL  := $(CUPL_DIR)/cupl.dl

# -m0 no minimization, -j JEDEC, -a absolute (for sim), -l list,
# -x PLA expansion, -s run simulator, -n use source filename for
# outputs (not the Name field), -u <library>
CUPLFLAGS := -m0 -j -a -l -x -s -n -u $(CUPL_DL)

.PHONY: all clean

all: $(NAME).jed

# cupl.exe produces all of these in a single invocation
$(NAME).jed $(NAME).abs $(NAME).lst $(NAME).pla $(NAME).so $(NAME).sim $(NAME).wo: $(NAME).pld $(NAME).si
	$(WINE) $(CUPL) $(CUPLFLAGS) $(NAME)

clean:
	rm -f $(NAME).jed $(NAME).abs $(NAME).lst $(NAME).pla
	rm -f $(NAME).so $(NAME).sim $(NAME).wo
