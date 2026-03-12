module random_mod
    implicit none
    private
    public :: init_random_seed, randn

contains

    subroutine init_random_seed(base_seed, rank)
        integer, intent(in) :: base_seed, rank
        integer :: n, i
        integer, allocatable :: seed_arr(:)

        call random_seed(size=n)
        allocate(seed_arr(n))
        seed_arr = base_seed + rank * 1000 + [(i, i=1, n)]
        call random_seed(put=seed_arr)
    end subroutine init_random_seed

    function randn() result(z)
        ! Box-Muller transform: returns one standard normal variate
        double precision :: z
        double precision :: u1, u2
        double precision, parameter :: TWO_PI = 8.0d0 * atan(1.0d0)

        call random_number(u1)
        call random_number(u2)
        ! Avoid log(0)
        u1 = max(u1, 1.0d-30)
        z = sqrt(-2.0d0 * log(u1)) * cos(TWO_PI * u2)
    end function randn

end module random_mod
