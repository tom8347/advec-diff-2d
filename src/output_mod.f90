module output_mod
    use mpi
    use params_mod, only: Lx, Ly, Nx, Ny
    implicit none
    private
    public :: bin_particles, write_snapshot

contains

    subroutine bin_particles(xp, yp, Np_local, conc_local)
        integer, intent(in) :: Np_local
        double precision, intent(in)  :: xp(Np_local), yp(Np_local)
        double precision, intent(out) :: conc_local(Nx, Ny)
        integer :: i, ix, iy
        double precision :: dx, dy

        dx = Lx / dble(Nx)
        dy = Ly / dble(Ny)

        conc_local = 0.0d0

        do i = 1, Np_local
            ix = int(xp(i) / dx) + 1
            iy = int(yp(i) / dy) + 1
            ! Clamp to grid (shouldn't be needed with modulo, but safe)
            ix = min(max(ix, 1), Nx)
            iy = min(max(iy, 1), Ny)
            conc_local(ix, iy) = conc_local(ix, iy) + 1.0d0
        end do
    end subroutine bin_particles

    subroutine write_snapshot(xp, yp, Np_local, step)
        integer, intent(in) :: Np_local, step
        double precision, intent(in) :: xp(Np_local), yp(Np_local)

        double precision, allocatable :: conc_local(:,:), conc_global(:,:)
        integer :: rank, ierr, i, j
        character(len=256) :: filename
        integer :: Nx4, Ny4

        allocate(conc_local(Nx, Ny))
        allocate(conc_global(Nx, Ny))

        call bin_particles(xp, yp, Np_local, conc_local)

        call MPI_ALLREDUCE(conc_local, conc_global, Nx*Ny, MPI_DOUBLE_PRECISION, &
                           MPI_SUM, MPI_COMM_WORLD, ierr)

        call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)

        if (rank == 0) then
            write(filename, '(A,I6.6,A)') "output/snap_", step, ".bin"

            open(unit=20, file=trim(filename), form='unformatted', &
                 access='stream', status='replace')
            Nx4 = Nx
            Ny4 = Ny
            write(20) Nx4, Ny4
            ! Write row-major: loop over y (rows) then x (columns)
            do j = 1, Ny
                do i = 1, Nx
                    write(20) conc_global(i, j)
                end do
            end do
            close(20)
        end if

        deallocate(conc_local, conc_global)
    end subroutine write_snapshot

end module output_mod
