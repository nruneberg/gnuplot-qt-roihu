# gnuplot-qt (Roihu)

gnuplot with the interactive **Qt** terminal — mouse-over coordinates, zoom,
pan. Delivered as an Apptainer container, optionally wrapped with Tykky so
`gnuplot` lands on `PATH`.

**Self-service / unsupported.** The central Roihu `gnuplot` module is x11-only
by design; this repo lets a user or project build the Qt variant themselves.

## Build

On a **roihu-cpu** login node (x86_64; Apptainer needs no module load):

```bash
git clone https://github.com/nruneberg/gnuplot-qt-roihu.git
cd gnuplot-qt-roihu
make                    # builds gnuplot-qt_rocky.sif (build runs in $TMPDIR-backed /tmp)
```

Quick check — run from the directory holding your data; the interactive window
needs X11 forwarding (`ssh -X`):

```bash
cd /scratch/<project>/results
apptainer run /path/to/gnuplot-qt-roihu/gnuplot-qt_rocky.sif
# gnuplot> set term qt
# gnuplot> set mouse
# gnuplot> plot "results.dat"
```

## Permanent install (on PATH, via Tykky)

Build once, share it under your project. Needs the `tykky` module:

```bash
module load tykky
make wrap   PROJECT=<project>     # -> /projappl/<project>/gnuplot-qt/bin/gnuplot
make module PROJECT=<project>     # optional: installs an Lmod modulefile
```

Then use it:

```bash
# via module:
module use /projappl/<project>/modules
module load gnuplot-qt
gnuplot

# or plain PATH:
export PATH="/projappl/<project>/gnuplot-qt/bin:$PATH"
gnuplot
```

The Tykky wrapper adds CSC's common bind mounts, so `/scratch` and `/projappl`
are visible by absolute path — no `--bind`, and no need to `cd` into the data
directory first.

`make wrap` builds the shared install under `/projappl`; run it once per
version, not per user.

## Files

    gnuplot-qt_rocky.def   Apptainer definition (the recipe)
    Makefile               build / wrap / module / clean
    gnuplot-qt.lua         modulefile template (filled in by `make module`)

## Notes

* Qt5, not Qt6: on EL9 the Qt5 build tools are on PATH and gnuplot's Qt5
  autodetect is reliable; Qt6 needs a PATH + pkg-config workaround for no gain.
* Dependencies are all in BaseOS/AppStream (no EPEL, no CRB).
* The def has build gates + a `%test`, so a rebuild fails loudly at the exact
  step if a dependency or version drifts. Two values age: the base-image pin
  (`rockylinux:9.8`) and `GPVER`.
* For a `CSCfi/singularity-recipes` contribution, use the build-only subset:
  the def, a thin Makefile (`all` + `clean`), and a short README without the
  Tykky/module steps.
