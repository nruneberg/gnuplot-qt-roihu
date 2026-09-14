-- -*- lua -*-
-- Template modulefile. `make module` substitutes @INSTALL_DIR@ and @VERSION@
-- and installs it as <modulepath>/gnuplot-qt/<version>.lua.

local root    = "@INSTALL_DIR@"
local version = "@VERSION@"

whatis("Name        : gnuplot-qt")
whatis("Version     : " .. version)
whatis("Description : gnuplot with the interactive Qt terminal (mouse-over coordinates, zoom)")
whatis("Delivery    : Apptainer container wrapped with Tykky")

help([[
gnuplot built with the interactive Qt terminal, delivered as a
Tykky-wrapped Apptainer container.

    module load gnuplot-qt
    gnuplot
    gnuplot> plot sin(x)      -- window opens; "set mouse" for coordinates

The interactive window needs X11 forwarding (connect with `ssh -X`).
CSC's common bind mounts are added automatically by the wrapper, so
/scratch and /projappl are visible regardless of the working directory.
]])

-- Only the wrapper bin/ goes on PATH (not Tykky's internal _bin).
prepend_path("PATH", pathJoin(root, "bin"))
