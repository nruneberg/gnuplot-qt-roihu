# gnuplot-qt on Roihu: build -> wrap (Tykky) -> module install.
# Build on a roihu-cpu login node (x86_64).
#
#   make            build gnuplot-qt_rocky.sif
#   make wrap       wrap the .sif into on-PATH executables under $(INSTALL_DIR)
#   make module     install the Lmod modulefile under $(MODULEPATH)
#   make clean      remove the built .sif
#
# Override the target project on the command line, e.g.:
#   make wrap PROJECT=project_2001199
#
# NOTE: for a CSCfi/singularity-recipes PR keep only the build + clean targets;
# wrap/module are site deployment and stay in the internal/working repo.

TMPDIR  ?= /tmp
PREFIX  := .

PROJECT     ?= project_2001199
VERSION     ?= 6.0.3
INSTALL_DIR ?= /projappl/$(PROJECT)/gnuplot-qt
MODULEPATH  ?= /projappl/$(PROJECT)/modules

CONTAINER_SIF := $(PREFIX)/gnuplot-qt_rocky.sif
CONTAINER_DEF := gnuplot-qt_rocky.def

.PHONY: all
all: $(CONTAINER_SIF)

$(CONTAINER_SIF): $(CONTAINER_DEF)
	apptainer build --fakeroot --bind=$(TMPDIR):/tmp $@ $<

.PHONY: wrap
wrap: $(CONTAINER_SIF)
	@command -v wrap-container >/dev/null || { echo "wrap-container not found -- run: module load tykky"; exit 1; }
	@if [ -e "$(INSTALL_DIR)/common.sh" ]; then \
	  echo "Removing previous Tykky install at $(INSTALL_DIR)"; \
	  rm -rf "$(INSTALL_DIR)"; \
	fi
	wrap-container -w /opt/gnuplot/bin --prefix $(INSTALL_DIR) $(CONTAINER_SIF)
	@echo
	@echo "Wrapped install: $(INSTALL_DIR)/bin/gnuplot"

.PHONY: module
module: gnuplot-qt.lua
	mkdir -p $(MODULEPATH)/gnuplot-qt
	sed 's|@INSTALL_DIR@|$(INSTALL_DIR)|g; s|@VERSION@|$(VERSION)|g' \
	    gnuplot-qt.lua > $(MODULEPATH)/gnuplot-qt/$(VERSION).lua
	@echo "Installed module: $(MODULEPATH)/gnuplot-qt/$(VERSION).lua"
	@echo "Use with:  module use $(MODULEPATH) && module load gnuplot-qt"

.PHONY: clean
clean:
	rm -f $(CONTAINER_SIF)
