
{
  description = "Fortran + MPI + Python (numpy) dev env";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    py = pkgs.python3.withPackages (ps: with ps; [
      numpy
      matplotlib
      scipy
      mpi4py
      ipython
      vtk
      pynvim
      python-lsp-server
      pylsp-mypy
      pylsp-rope
      pyqt6
    ]);
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.gfortran
        pkgs.openmpi
        pkgs.fortls
        py

        # nice-to-haves (optional; include if you want them available even if your base system changes)
        pkgs.gnumake
        pkgs.pkg-config

        # neede for native wayland qt
        pkgs.qt6.qtwayland
      ];

      shellHook = ''

        # Force Matplotlib to use Qt and force Qt to use Wayland
        export MPLBACKEND=QtAgg
        export QT_QPA_PLATFORM=wayland

        echo "Fortran:  $(gfortran --version | head -n1)"
        echo "MPI:      $(mpirun --version | head -n1)"
        echo "mpifort:  $(command -v mpifort || command -v mpif90)"
        echo "Python:   $(python --version)"
      '';
    };
  };
}
