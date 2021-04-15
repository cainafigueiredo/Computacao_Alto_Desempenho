from matplotlib import pyplot as plt
import pandas as pd
from math import log

# FOR C RESULTS
# =============

# C implementation with outer loop being in rows and inner loop being in columns
c_rc = pd.read_csv("../data/C_RC.csv")

c_rc['n'] = c_rc['n'].apply(lambda x: log(x,2))
c_rc['time(microseconds)'] = c_rc['time(microseconds)'].apply(lambda x: x/(1000000))
c_rc.columns = ['n','time(ms)']

# C implementation with outer loop being in columns and inner loop being in rows
c_cr = pd.read_csv("../data/C_CR.csv")

c_cr['n'] = c_cr['n'].apply(lambda x: log(x,2))
c_cr['time(microseconds)'] = c_cr['time(microseconds)'].apply(lambda x: x/(1000000))
c_cr.columns = ['n','time(ms)']


# FOR FORTRAN RESULTS
# ===================

try:
	for f_path in ['../data/Fortran_RC.csv','../data/Fortran_CR.csv']:

		results = open(f_path,'r').read().replace(" ", "")

		with open(f_path,'w') as f:
			f.write(results)
except:
	pass

# Fortran implementation with outer loop being in columns and inner loop being in rows
fortran_rc = pd.read_csv("../data/Fortran_RC.csv", names = ['n','time(microseconds)'])

fortran_rc['n'] = fortran_rc['n'].apply(lambda x: log(x,2))
fortran_rc['time(microseconds)'] = fortran_rc['time(microseconds)'].apply(lambda x: x/(1000000))
fortran_rc.columns = ['n','time(ms)']

# Fortran implementation with outer loop being in columns and inner loop being in rows
fortran_cr = pd.read_csv("../data/Fortran_CR.csv", names = ['n','time(microseconds)'])

fortran_cr['n'] = fortran_cr['n'].apply(lambda x: log(x,2))
fortran_cr['time(microseconds)'] = fortran_cr['time(microseconds)'].apply(lambda x: x/(1000000))
fortran_cr.columns = ['n','time(ms)']


plt.plot(c_rc['n'].values,c_rc['time(ms)'].values)
plt.plot(c_cr['n'].values,c_cr['time(ms)'].values)
plt.plot(fortran_rc['n'].values,fortran_rc['time(ms)'].values)
plt.plot(fortran_cr['n'].values,fortran_cr['time(ms)'].values)
plt.legend(['C: Outer(rows), Inner(columns)', 'C: Outer(columns), Inner(rows)',
			'Fortran: Outer(rows), Inner(columns)','Fortran: Outer(columns), Inner(rows)'])
plt.xlabel('log(n,2)')
plt.ylabel('time(s)')
plt.title("Tempo de uma operação Produto Matriz-Vetor")
plt.savefig("../img/plot.png")