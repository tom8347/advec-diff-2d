module particles_mod
    use params_mod, only: Lx, Ly, Ux, Uy, dt, D, flow_type, &
                          ic_type, ic_x0, ic_y0, ic_sigma
    use random_mod, only: randn
    use velocity_mod, only: get_velocity
    implicit none
    private
    public :: init_particles, advance_particles

contains

    subroutine init_particles(xp, yp, Np_local)
        integer, intent(in) :: Np_local
        double precision, intent(out) :: xp(Np_local), yp(Np_local)
        integer :: i
        double precision :: r1, r2, weight, threshold

        select case (ic_type)
        case (1) ! Gaussian blob centred at (ic_x0, ic_y0)
            do i = 1, Np_local
                xp(i) = ic_x0 + ic_sigma * randn()
                yp(i) = ic_y0 + ic_sigma * randn()
            end do

        case (2) ! Block: uniform in [x0-sigma, x0+sigma] x [y0-sigma, y0+sigma]
            do i = 1, Np_local
                call random_number(r1)
                call random_number(r2)
                xp(i) = ic_x0 + ic_sigma * (2.0d0*r1 - 1.0d0)
                yp(i) = ic_y0 + ic_sigma * (2.0d0*r2 - 1.0d0)
            end do

        case (3) ! Sinusoidal: density ~ 1 + sin(2*pi*x/Lx)
            i = 1
            do while (i <= Np_local)
                call random_number(r1)
                call random_number(r2)
                r1 = r1 * Lx
                r2 = r2 * Ly
                weight = 1.0d0 + sin(8.0d0*atan(1.0d0)*r1/Lx)
                call random_number(threshold)
                if (threshold * 2.0d0 < weight) then
                    xp(i) = r1
                    yp(i) = r2
                    i = i + 1
                end if
            end do

        case default
            print *, "ERROR: unknown ic_type =", ic_type
            stop 1
        end select

        ! Apply periodic BCs to initial positions
        do i = 1, Np_local
            xp(i) = modulo(xp(i), Lx)
            yp(i) = modulo(yp(i), Ly)
        end do
    end subroutine init_particles

    subroutine advance_particles(xp, yp, Np_local)
        integer, intent(in) :: Np_local
        double precision, intent(inout) :: xp(Np_local), yp(Np_local)
        integer :: i
        double precision :: u, v, diff_scale

        diff_scale = sqrt(2.0d0 * D * dt)

        do i = 1, Np_local
            ! Get velocity at current position
            call get_velocity(xp(i), yp(i), flow_type, Ux, Uy, Lx, Ly, u, v)

            ! Advection + diffusion
            xp(i) = xp(i) + u * dt + diff_scale * randn()
            yp(i) = yp(i) + v * dt + diff_scale * randn()

            ! Periodic boundary conditions
            xp(i) = modulo(xp(i), Lx)
            yp(i) = modulo(yp(i), Ly)
        end do
    end subroutine advance_particles

end module particles_mod
