PROGRAM project1

	CALL get_samples(1,8)
	CALL system("mv fort.1 ../data/Fortran_RC.csv")
	CALL get_samples(2,8)
	CALL system("mv fort.1 ../data/Fortran_CR.csv")

END PROGRAM

! Get the samples
SUBROUTINE get_samples(implementation_version, bytes_per_element)

	INTEGER, INTENT(IN) :: implementation_version
	INTEGER, INTENT(IN) :: bytes_per_element

	! Declaring some variables;
	CHARACTER(30) :: line_content

	REAL(8), ALLOCATABLE :: A(:,:)
	REAL(8), ALLOCATABLE :: x(:)
	REAL(8), ALLOCATABLE :: b(:)
	
	INTEGER A_allocationStat, x_allocationStat, b_allocationStat

	INTEGER :: nmax, n, size_nElements;
	REAL(8) :: t1, t2, t_elapsed;

	! Getting the maximum value of n
	CALL find_nmax(bytes_per_element, nmax)
	
	! Generating the samples
	n = 1

	DO WHILE(n.LE.nmax)

		size_nElements = bytes_per_element*n

		! Trying to allocate both matrix and the two vectors
		allocate(A(size_nElements,size_nElements), stat=A_allocationStat)
		allocate(x(size_nElements),stat=x_allocationStat)
		allocate(b(size_nElements),stat=b_allocationStat)

		! If all have been done successfully
		IF ((A_allocationStat == 0).AND.(x_allocationStat == 0).AND.(b_allocationStat == 0)) THEN 
			
			! Initialing A, x and b
			CALL squareMatrix_randomInitializer(n, A)
			CALL vector_randomInitializer(n, x)
			CALL vector_zerosInitializer(n, b)

			IF (implementation_version == 1) THEN
				
				! Start time counting
				CALL cpu_time(t1)

				CALL mult_matrixVector_version1(n, A, x, b)

				! Stop clocktime counting
				CALL cpu_time(t2)
		
			ELSE
				
				! Start time counting
				CALL cpu_time(t1)

				CALL mult_matrixVector_version2(n, A, x, b)

				! Stop time counting
				CALL cpu_time(t2)
			END IF

			t_elapsed = (t2-t1) * (10**6)

			! Writing sample to file
			WRITE(line_content,"(I10.1,A1,I15)") n,",",int(t_elapsed)
			WRITE(1,*) line_content

			! Free allocated memory
			IF (A_allocationStat == 0) THEN
				DEALLOCATE(A)
			END IF
			
			IF (x_allocationStat == 0) THEN
				DEALLOCATE(x)
			END IF

			IF (b_allocationStat == 0) THEN
				DEALLOCATE(b)
			END IF

		! Otherwise
		ELSE
			
			! Free allocated memory
			IF (A_allocationStat == 0) THEN
				DEALLOCATE(A)
			END IF
			
			IF (x_allocationStat == 0) THEN
				DEALLOCATE(x)
			END IF

			IF (b_allocationStat == 0) THEN
				DEALLOCATE(b)
			END IF

			! Stop loop
			STOP

		END IF

		n = 2*n

	END DO 

END SUBROUTINE

! Square Matrix random initialization
SUBROUTINE squareMatrix_randomInitializer(n, matrix)
	
	INTEGER, INTENT(IN) :: n
	REAL(8), DIMENSION(n,n), INTENT(OUT) :: matrix
	DO i = 1,n
		DO j = 1,n
			matrix(i,j) = RAND()*100
		END DO
	END DO

END SUBROUTINE

! Vector random initialization
SUBROUTINE vector_randomInitializer(n, vector)

	INTEGER, INTENT(IN) :: n
	REAL(8), DIMENSION(n), INTENT(OUT) :: vector
	DO i = 1,n
		vector(i) = RAND()*100
	END DO

END SUBROUTINE

! Initialize vector with zeros
SUBROUTINE vector_zerosInitializer(n, vector)

	INTEGER, INTENT(IN) :: n
	REAL(8), DIMENSION(n), INTENT(OUT) :: vector
	
	vector(:) = 0

END SUBROUTINE

! Matrix-vector product, version 1 (outer loop along rows and inner loop along columns)
SUBROUTINE mult_matrixVector_version1(n, matrix, vector, result)

	INTEGER, INTENT(IN) :: n
	REAL(8), DIMENSION(n,n), INTENT(IN) :: matrix
	REAL(8), DIMENSION(n), INTENT(IN) :: vector
	REAL(8), DIMENSION(n), INTENT(OUT) :: result

	! Multiplying matrix by vector and storing it in result
	DO i = 1, n
		DO j = 1, n
			result(i) = result(i) + matrix(i,j) * vector(j);
		END DO
	END DO

END SUBROUTINE

! Matrix-vector product, version 2 (outer loop along columns and inner loop along rows)
SUBROUTINE mult_matrixVector_version2(n, matrix, vector, result)

	INTEGER, INTENT(IN) :: n
	REAL(8), DIMENSION(n,n), INTENT(IN) :: matrix
	REAL(8), DIMENSION(n), INTENT(IN) :: vector
	REAL(8), DIMENSION(n), INTENT(OUT) :: result

	! Multiplying matrix by vector and storing it in result
	DO j = 1, n
		DO i = 1, n
			result(i) = result(i) + matrix(i,j) * vector(j);
		END DO
	END DO

END SUBROUTINE

! Find maximum value of parameter n
SUBROUTINE find_nmax(bytes_per_element, nmax)

	INTEGER, INTENT(IN) :: bytes_per_element
	INTEGER, INTENT(OUT) :: nmax
	
	! Defining some variables
	INTEGER freeMemoryInBytes, size_nElements
	INTEGER A_allocationStat, x_allocationStat, b_allocationStat

	INTEGER n_ideal
	INTEGER n_current
	INTEGER n_last

	REAL(8), ALLOCATABLE :: A(:,:)
	REAL(8), ALLOCATABLE :: x(:)
	REAL(8), ALLOCATABLE :: b(:)

	! Getting free memory
	CALL system('python3 freeMemory.py')

	OPEN(unit=1,file='./freeMemory.txt')
	READ(1,*) freeMemoryInBytes
	CLOSE(unit=1)

	! Initializing some variables
	n_ideal = (-1 + INT(sqrt(1.0 + REAL(freeMemoryInBytes/bytes_per_element))))
	n_current = (n_ideal/2)
	n_last = 0;

	! Finding maximum value of n
	DO WHILE (n_last /= n_current)

		size_nElements = bytes_per_element*n_current

		! Uncomment the line below to print the current value of n
		! PRINT *, n_current

		! Trying to allocate both matrix and the two vectors
		allocate(A(size_nElements,size_nElements), stat=A_allocationStat)
		allocate(x(size_nElements),stat=x_allocationStat)
		allocate(b(size_nElements),stat=b_allocationStat)

		! If all have been done successfully
		IF ((A_allocationStat == 0).AND.(x_allocationStat == 0).AND.(b_allocationStat == 0)) THEN 
			n_last = n_current
			n_current = (n_ideal + n_current)/2
		! Otherwise
		ELSE
			n_current = (n_last + n_current)/2;
		END IF
		
		! Free allocated memory for the next iteration
		IF (A_allocationStat == 0) THEN
			DEALLOCATE(A)
		END IF
		
		IF (x_allocationStat == 0) THEN
			DEALLOCATE(x)
		END IF

		IF (b_allocationStat == 0) THEN
			DEALLOCATE(b)
		END IF

	END DO
        
        PRINT *, n_current
	nmax = n_current

	RETURN 

END SUBROUTINE
