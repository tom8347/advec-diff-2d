module velocity_mod
    implicit none
    private
    public :: get_velocity

    double precision, parameter :: PI = 4.0d0 * atan(1.0d0)

contains

    subroutine get_velocity(x, y, ftype, Ux, Uy, Lx, Ly, u, v)
        double precision, intent(in)  :: x, y, Ux, Uy, Lx, Ly
        integer,          intent(in)  :: ftype
        double precision, intent(out) :: u, v

        select case (ftype)
        case (1) ! Uniform
            u = Ux
            v = Uy

        case (2) ! Shear: u varies linearly with y
            u = Ux * y / Ly
            v = 0.0d0

        case (3) ! Taylor-Green vortex
            u = -Ux * sin(2.0d0*PI*x/Lx) * cos(2.0d0*PI*y/Ly)
            v =  Ux * cos(2.0d0*PI*x/Lx) * sin(2.0d0*PI*y/Ly)

        case default
            print *, "ERROR: unknown flow_type =", ftype
            stop 1
        end select
    end subroutine get_velocity

end module velocity_mod
