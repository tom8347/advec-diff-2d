FC      = mpifort
FFLAGS  = -Wall -Wextra -O2 -fimplicit-none -fcheck=all

# Nix injects C-only flags (e.g. -fmacro-prefix-map) via NIX_CFLAGS_COMPILE,
# which gfortran doesn't understand. Unexport it so it never reaches the compiler.
unexport NIX_CFLAGS_COMPILE

SRCDIR  = src
BLDDIR  = build
BIN     = $(BLDDIR)/advecdiff

# Source files (order matters for module dependencies)
SRCS = $(SRCDIR)/params_mod.f90 \
       $(SRCDIR)/random_mod.f90 \
       $(SRCDIR)/velocity_mod.f90 \
       $(SRCDIR)/particles_mod.f90 \
       $(SRCDIR)/output_mod.f90 \
       $(SRCDIR)/main.f90

OBJS = $(patsubst $(SRCDIR)/%.f90,$(BLDDIR)/%.o,$(SRCS))

all: $(BIN)

$(BIN): $(OBJS) | $(BLDDIR)
	$(FC) $(FFLAGS) -o $@ $(OBJS)

# Compile rule — put .mod files in build/
$(BLDDIR)/%.o: $(SRCDIR)/%.f90 | $(BLDDIR)
	$(FC) $(FFLAGS) -J$(BLDDIR) -c $< -o $@

# Module dependencies
$(BLDDIR)/particles_mod.o: $(BLDDIR)/params_mod.o $(BLDDIR)/random_mod.o $(BLDDIR)/velocity_mod.o
$(BLDDIR)/output_mod.o: $(BLDDIR)/params_mod.o
$(BLDDIR)/main.o: $(BLDDIR)/params_mod.o $(BLDDIR)/random_mod.o $(BLDDIR)/particles_mod.o $(BLDDIR)/output_mod.o

$(BLDDIR):
	mkdir -p $(BLDDIR)

clean:
	rm -rf $(BLDDIR)

run: $(BIN)
	mkdir -p output
	mpirun -np 6 $(BIN)

.PHONY: all clean run
