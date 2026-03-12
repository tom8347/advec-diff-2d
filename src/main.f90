program advecdiff
    use mpi
    use params_mod
    use random_mod, only: init_random_seed
    use particles_mod, only: init_particles, advance_particles
    use output_mod, only: write_snapshot
    implicit none

    integer :: rank, nprocs, ierr
    integer :: Np_local, remainder
    double precision, allocatable :: xp(:), yp(:)
    integer :: step

    ! ---------- MPI init ----------
    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, nprocs, ierr)

    ! ---------- Read parameters (all ranks) ----------
    call read_params()
    if (rank == 0) call print_params()

    ! ---------- Distribute particles ----------
    Np_local = Np / nprocs
    remainder = mod(Np, nprocs)
    if (rank < remainder) Np_local = Np_local + 1

    if (rank == 0) then
        print '(A,I4,A,I8,A)', " Running on ", nprocs, " rank(s), ", &
              Np, " total particles"
    end if

    allocate(xp(Np_local), yp(Np_local))

    ! ---------- Initialise ----------
    call init_random_seed(seed, rank)
    call init_particles(xp, yp, Np_local)

    ! Write initial condition
    call write_snapshot(xp, yp, Np_local, 0)
    if (rank == 0) print '(A,I6)', " [output] step ", 0

    ! ---------- Time loop ----------
    do step = 1, Nt
        call advance_particles(xp, yp, Np_local)

        if (mod(step, output_interval) == 0) then
            call write_snapshot(xp, yp, Np_local, step)
            if (rank == 0) print '(A,I6,A,I6)', " [output] step ", step, &
                           " / ", Nt
        end if
    end do

    if (rank == 0) print '(A)', " Done."

    deallocate(xp, yp)
    call MPI_FINALIZE(ierr)

end program advecdiff
