import timeit

def factorial_iterative(n):
    result = 1
    for i in range(1, n + 1):
        result *= i
    return result

# Benchmark setup
number = 1000
iterations = 1000

# Time the iterative factorial function
iterative_time = timeit.timeit('factorial_iterative(number)', globals=globals(), number=iterations)
print(f"Iterative factorial: {iterative_time:.6f} seconds")
