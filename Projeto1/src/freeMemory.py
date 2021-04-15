memory_status = open("/proc/meminfo", 'r')
free_memory = 0
for line in memory_status:
	if ("MemFree" in line):
		free_memory = int(line.split()[1]) * (1024)
		break

with open("./freeMemory.txt",'w') as f:
	f.write(str(free_memory))