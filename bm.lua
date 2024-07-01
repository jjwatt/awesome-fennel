function factorial_recursive(n)
    if n == 0 then
        return 1
    else
        return n * factorial_recursive(n - 1)
    end
end

function factorial_iterative(n)
    local result = 1
    for i = 1, n do
        result = result * i
    end
    return result
end

-- Benchmark setup
local number = 1000
local iterations = 1000

-- Benchmark the recursive factorial function
local start_time = os.clock()
for i = 1, iterations do
    factorial_recursive(number)
end
local recursive_time = os.clock() - start_time
print(string.format("Recursive factorial: %.6f seconds", recursive_time))

-- Benchmark the iterative factorial function
start_time = os.clock()
for i = 1, iterations do
    factorial_iterative(number)
end
local iterative_time = os.clock() - start_time
print(string.format("Iterative factorial: %.6f seconds", iterative_time))
