TMPDIR ?= /tmp
PREFIX := .

CONTAINER_SIF := $(PREFIX)/gnuplot-qt_rocky.sif
CONTAINER_DEF := gnuplot-qt_rocky.def

.PHONY: all
all: $(CONTAINER_SIF)

$(CONTAINER_SIF): $(CONTAINER_DEF)
	apptainer build --fakeroot --bind=$(TMPDIR):/tmp $@ $<

.PHONY: clean
clean:
	rm -f $(CONTAINER_SIF)
