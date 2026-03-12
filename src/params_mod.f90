module params_mod
    implicit none

    ! Domain
    double precision :: Lx = 1.0d0
    double precision :: Ly = 1.0d0

    ! Particles
    integer :: Np = 10000
    double precision :: dt = 1.0d-3
    integer :: Nt = 1000
    integer :: seed = 12345

    ! Flow
    double precision :: Ux = 0.0d0
    double precision :: Uy = 0.0d0
    integer :: flow_type = 1   ! 1=uniform, 2=shear, 3=Taylor-Green

    ! Diffusion
    double precision :: D = 0.01d0

    ! Output
    integer :: output_interval = 100
    integer :: Nx = 100
    integer :: Ny = 100

    ! Initial condition
    integer :: ic_type = 1     ! 1=Gaussian, 2=block, 3=sinusoidal
    double precision :: ic_x0 = 0.5d0
    double precision :: ic_y0 = 0.5d0
    double precision :: ic_sigma = 0.05d0

    ! Namelist groups
    namelist /domain/ Lx, Ly
    namelist /particles/ Np, dt, Nt, seed
    namelist /flow/ Ux, Uy, flow_type
    namelist /diffusion/ D
    namelist /output/ output_interval, Nx, Ny
    namelist /initial_condition/ ic_type, ic_x0, ic_y0, ic_sigma

contains

    subroutine read_params()
        integer :: iunit, ios

        iunit = 10
        open(unit=iunit, file="input/params.nml", status="old", &
             action="read", iostat=ios)
        if (ios /= 0) then
            print *, "ERROR: cannot open input/params.nml"
            stop 1
        end if

        read(iunit, nml=domain)
        read(iunit, nml=particles)
        read(iunit, nml=flow)
        read(iunit, nml=diffusion)
        read(iunit, nml=output)
        read(iunit, nml=initial_condition)
        close(iunit)
    end subroutine read_params

    subroutine print_params()
        print '(A)',        "=== Simulation parameters ==="
        print '(A,2F10.4)', "  Lx, Ly        = ", Lx, Ly
        print '(A,I8)',     "  Np            = ", Np
        print '(A,ES10.3)', "  dt            = ", dt
        print '(A,I8)',     "  Nt            = ", Nt
        print '(A,I8)',     "  seed          = ", seed
        print '(A,2F10.4)', "  Ux, Uy        = ", Ux, Uy
        print '(A,I2)',     "  flow_type     = ", flow_type
        print '(A,ES10.3)', "  D             = ", D
        print '(A,I6)',     "  output_interval= ", output_interval
        print '(A,2I6)',    "  Nx, Ny        = ", Nx, Ny
        print '(A,I2)',     "  ic_type       = ", ic_type
        print '(A,2F10.4)', "  ic_x0, ic_y0  = ", ic_x0, ic_y0
        print '(A,ES10.3)', "  ic_sigma      = ", ic_sigma
        print '(A)',        "============================="
    end subroutine print_params

end module params_mod
