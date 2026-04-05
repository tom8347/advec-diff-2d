
{
  description = "Fortran + MPI + Python (numpy) dev env";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in
  {
    devShells = forAllSystems (system:
    let
      pkgs = import nixpkgs { inherit system; };
      isDarwin = pkgs.stdenv.isDarwin;

      py = pkgs.python3.withPackages (ps: with ps; [
        numpy
        matplotlib
        scipy
        mpi4py
        ipython
        pynvim
        python-lsp-server
        pylsp-mypy
        pylsp-rope
        pyqt6
      ] ++ pkgs.lib.optionals (!isDarwin) [
        # vtk nixpkg is Linux-only; install manually on macOS if needed
        vtk
      ]);
    in
    {
      default = pkgs.mkShell {
        packages = [
          pkgs.gfortran
          pkgs.openmpi
          pkgs.fortls
          py
          pkgs.gnumake
          pkgs.pkg-config
        ] ++ pkgs.lib.optionals (!isDarwin) [
          # Wayland Qt plugin only needed on Linux
          pkgs.qt6.qtwayland
        ];

        shellHook = ''
          ${if isDarwin then ''
            # Use the native macOS matplotlib backend
            export MPLBACKEND=MacOSX
          '' else ''
            export MPLBACKEND=QtAgg
            export QT_QPA_PLATFORM=wayland
          ''}

          echo "Fortran:  $(gfortran --version | head -n1)"
          echo "MPI:      $(mpirun --version | head -n1)"
          echo "mpifort:  $(command -v mpifort || command -v mpif90)"
          echo "Python:   $(python --version)"
        '';
      };
    });
  };
}
