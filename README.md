# gnuplot-qt

gnuplot with the interactive **Qt** terminal (mouse-over coordinates, zoom).
Built against Qt5 on Rocky 9.

Build

```bash
make
```

Run (interactive window needs X11 forwarding, `ssh -X`)

```bash
apptainer run gnuplot-qt_rocky.sif
# gnuplot> plot sin(x)
# gnuplot> set mouse
```

Notes

* Qt5, not Qt6: on EL9 the Qt5 build tools are on PATH and gnuplot's Qt5
  autodetect is reliable; Qt6 needs a PATH + pkg-config workaround for no gain.
* All dependencies are in BaseOS/AppStream (no EPEL, no CRB).
* The def has build gates + a `%test` so a rebuild fails loudly at the exact
  step if a dependency or version drifts. Two values age: the base image pin
  and `GPVER`.
