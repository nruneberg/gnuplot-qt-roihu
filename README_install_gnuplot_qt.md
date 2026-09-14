# gnuplot-qt (Roihu) — self-service container build

Qt-enabled `gnuplot` (interactive terminal: mouse-over coordinates, zoom) for
Roihu, delivered as an Apptainer container wrapped with Tykky.

**Status: self-service / unsupported.** Not maintained in the central stack.
The central `gnuplot` module is x11-only by design (RT #893533). This recipe
exists so users or staff can rebuild the Qt variant on demand. `gnuplot-qt.def`
is the source of truth; this README only covers the wrap and module steps
around it.

## Files

    gnuplot-qt.def   Apptainer definition (the build recipe)
    README...md      this file

## What to check when rebuilding

Two values age; update them for a new build, everything else follows:

- Base image pin `From: docker.io/rockylinux/rockylinux:9.8` — match Roihu's
  host RHEL minor version to keep fakeroot happy.
- `GPVER` in `%post` — the gnuplot version.

The def has three build gates (Qt5 tools, Qt5 pkg-config modules, configure
summary) plus a `%test` that checks the qt terminal is registered. A rebuild
either succeeds or fails loudly at the exact step — no silent drift.

## 1. Build (roihu-cpu login node, x86_64)

Build on local disk, not Lustre. Keep the Apptainer cache off `$HOME`
(15 GiB quota).

    export APPTAINER_CACHEDIR=/scratch/<project>/$USER/.apptainer
    cd $TMPDIR
    apptainer build --fakeroot --bind="$TMPDIR:/tmp" gnuplot-qt.sif gnuplot-qt.def

`$TMPDIR` is node-local and cleaned — copy the `.def` back to a persistent
location (repo / projappl) after building.

Quick manual check:

    apptainer run gnuplot-qt.sif
    gnuplot> plot sin(x)          # window needs X11 forwarding (ssh -X)

## 2. Wrap with Tykky (on-PATH executable)

Turns the `.sif` into a `bin/gnuplot` that runs transparently; the wrapper adds
CSC's common bind mounts automatically, so no `--bind` is needed at runtime.

    module load tykky            # confirm name on Roihu: module spider tykky
    wrap-container -w /opt/gnuplot/bin \
        --prefix /projappl/<project>/gnuplot-qt \
        gnuplot-qt.sif

Result (Tykky layout — only `bin/` is user-facing):

    /projappl/<project>/gnuplot-qt/
        bin/gnuplot        wrapper (on PATH)
        container.sif      in-prefix image copy the wrapper points at
        _bin, common.sh, share   Tykky internals — leave alone

Keep the source with the install:

    cp gnuplot-qt.def /projappl/<project>/gnuplot-qt/src/

## 3. Module (optional, for a group of users)

Install `gnuplot-qt.lua` as `<modulepath>/gnuplot-qt/6.0.3.lua` and set `root`
inside it to the prefix from step 2. Then:

    module use /projappl/<project>/modules
    module load gnuplot-qt
    gnuplot                       # -> .../gnuplot-qt/bin/gnuplot

Project members add the `module use` line to their shell (or a project init
snippet). Without a module, users just:

    export PATH="/projappl/<project>/gnuplot-qt/bin:$PATH"

## Notes

- Built against Qt5, not Qt6: on EL9 the Qt5 build tools are on PATH and
  gnuplot's Qt5 autodetect is reliable. Qt6 needs a PATH + pkg-config
  workaround (gnuplot bug 2649) for no functional gain here.
- All build dependencies are in BaseOS/AppStream (no EPEL, no CRB).
  `qt5-linguist` supplies `lrelease`; `patch` + `glibc-gconv-extra` are only
  for the localized-docs build step.
- `XDG_RUNTIME_DIR` is set in the image `%environment` so Qt doesn't warn about
  a missing `/run/user/<uid>` inside the container.
- For a future central build (if that decision changes), the CSC-native path is
  `spack install gnuplot+qt`, matching how the current module is built.
