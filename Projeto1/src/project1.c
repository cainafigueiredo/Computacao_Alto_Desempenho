#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/mman.h>
#include <time.h>

int find_nmax(size_t bytes_per_element) {
	/* This function calculates and retuns the maximum value for n for our problem, i.e, we are 
	considering that we need to allocate a square matrix (n x n) and two vectors 
	n-dimensional.
	
	Parameter
	=========
	size_t bytes_per_element: number of bytes allocated per matrix/vector's element
	*/

	// Getting free memory
	char buffer[20];
	size_t freeMemoryInBytes;

	system("python3 freeMemory.py");

	FILE *f;
	f = fopen("./freeMemory.txt", "r"); 
	fscanf(f,"%s",buffer);
	freeMemoryInBytes = (size_t) atoi(buffer);
	fclose(f);

	// Defining some variable
	int n_ideal, n_current, n_last;
	double *A, *x, *b;

	// Initializing some variables
	n_ideal = (int) (-1 + sqrt(1 + (freeMemoryInBytes/bytes_per_element)));
	n_current = (int) (n_ideal/2);
	n_last = 0;

	// Finding maximum value of n
	while (n_last != n_current) {

		// Uncomment the line below to print the current value of n
		// printf("%d\n",n_current);

		// Trying to allocate both matrix and the two vectors
		A = (double*) calloc(bytes_per_element, (size_t) pow(n_current,2));
		x = (double*) calloc(bytes_per_element, (size_t) n_current);
		b = (double*) calloc(bytes_per_element, (size_t) n_current);

		// If all have been done successfully
		if ((A != NULL) && (x != NULL) && (b != NULL)) {
			n_last = n_current;
			n_current = (int) (n_ideal + n_current)/2;
		} 
		// Otherwise
		else {
			n_current = (int) (n_last + n_current)/2;
		}

		// Free allocated memory for the next iteration
		free((void*) A);
		free((void*) x);
		free((void*) b);
	}
	printf("n_max: %d\n", n_current);
	return n_current;
}

void Vector_Zeros(int n, double *vector) {
	/* 
	It initializes the vector passed as reference as an array of zeros.

	Parameter
	=========

	int n: dimension of the vector
	double *vector: array with n entries
	*/

	for (int i = 0; i < n; i++) {
		vector[i] = (double) 0;
	}
}

void Mult_MatrixVector_Version1(int n, double *matrix, double *vector, double *result) {
	/* 
	It calculates the vector 'result' as a multiplication of the matrix by the vector.
	In comparison with Mult_MatrixVector_Version2 function, the only difference is the order of loops.

	Parameter
	=========

	int n: dimension of square matrix A and the vectors
	double matrix[n][n]: bidimensional array, i.e., a square matrix
	double vector[n]: array with n entries
	double result[n]: array with n entries. This vector is used to store the results and should be a
					  vector of zeros.
	*/ 

	// Multiplying matrix by vector and storing it in result
	for (int i = 0; i < n; i++) {

		for (int j = 0; j < n; j++) {
			result[i] += matrix[i*n + j] * vector[j];
		}

	}
}

void Vector_RandomInitializer(int n, double *vector) {
	/* 
	It initializes a vector n-dimensional with random values between 0 and 100. 
	All the coefficients are written directly in the vector passed as reference.

	Parameter
	=========

	int n: vector dimension
	double vector[n]: array with n entries
	*/

	// Setting random seed
	srand(time(NULL));

	// Initializing all the coefficients
	for (int i = 0; i < n; i++) {

		vector[i] = ((double) rand())/RAND_MAX * 100;
		
	}
}

void SquareMatrix_RandomInitializer(int n, double *matrix) {
	/* 
	It initializes a square matrix (n x n) with random values between 0 and 100. 
	All the coefficients are written directly in the matrix passed as reference.

	Parameter
	=========

	int n: matrix dimension
	double matrix[n][n]: bidimensional array, i.e., a square matrix
	*/

	// Setting random seed
	srand(time(NULL));

	// Initializing all the coefficients
	for (int i = 0; i < n; i++) {

		for (int j = 0; j < n; j++) {
			matrix[i*n + j] = ((double) rand())/RAND_MAX * 100;
		}

	}
}

void Mult_MatrixVector_Version2(int n, double *matrix, double *vector, double *result) {
	/* 
	It calculates the vector 'result' as a multiplication of the matrix by the vector.
	In comparison with Mult_MatrixVector_Version1 function, the only difference is the order of loops.

	Parameter
	=========

	int n: dimension of square matrix A and the vectors
	double matrix[n][n]: bidimensional array, i.e., a square matrix
	double vector[n]: array with n entries
	double result[n]: array with n entries. This vector is used to store the results and should be a
					  vector of zeros.
	*/ 

	// Multiplying matrix by vector and storing it in result
	for (int j = 0; j < n; j++) {
		
		for (int i = 0; i < n; i++) {
			result[i] += matrix[i*n + j] * vector[j];
		}

	}
}

void get_samples(int implementation_version, size_t bytes_per_element, char *destiny) {
	/* 

	Parameter
	=========

	int implementation_version: if 1, it uses the first version of matrix-vector product.
								If 2, it uses the second version of matrix-vector product.

	size_t bytes_per_element: number of bytes allocated per matrix/vector's element

	char *destiny: directory + filename. This parameter will define where the 
				   samples will be stored
	*/

	// Defining some variables;
	double *A, *x, *b;
	int nmax, n;
	clock_t t1,t2;
	long t_elapsed;

	// Openning the file where samples will be written and writing columns names
	FILE *samples;
	samples = fopen(destiny, "w");
	fprintf(samples, "n,time(microseconds)\n");

	// Getting the maximum value of n
	nmax = find_nmax(bytes_per_element);
	
	// Generating the samples
	n = 1;
	while(n <= nmax) {

		// Trying to allocate both matrix and the two vectors
		A = (double*) calloc(bytes_per_element, (size_t) pow(n,2));
		x = (double*) calloc(bytes_per_element, (size_t) n);
		b = (double*) calloc(bytes_per_element, (size_t) n);

		// If all have been done successfully
		if ((A != NULL) && (x != NULL) && (b != NULL)) {
			// Initialing A, x and b
			SquareMatrix_RandomInitializer(n, A);
			Vector_RandomInitializer(n, x);
			Vector_Zeros(n, b);

			if (implementation_version == 1) {
				// Start time counting
				t1 = clock();

				Mult_MatrixVector_Version1(n, A, x, b);

				// Stop clocktime counting
				t2 = clock();
			} 
			else {
				// Start time counting
				t1 = clock();

				Mult_MatrixVector_Version2(n, A, x, b);

				// Stop time counting
				t2 = clock();
			}

			t_elapsed = ((double) t2 - t1) / CLOCKS_PER_SEC * pow(10,6); 


			// Writing sample to file
			fprintf(samples, "%d,%ld\n", n, t_elapsed);

			// Free allocated memory
			free((void*) A);
			free((void*) x);
			free((void*) b);

		} else {
			// Free allocated memory
			free((void*) A);
			free((void*) x);
			free((void*) b);

			// Stop loop
			break;
		}

		n = 2*n;
	}

	// Closing samples file
	fclose(samples);
}


void main() {
	get_samples(1, sizeof(double), "../data/C_RC.csv");
	get_samples(2, sizeof(double), "../data/C_CR.csv");
}
