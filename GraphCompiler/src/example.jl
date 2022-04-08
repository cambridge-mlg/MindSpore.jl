using CodeInfoTools
using GraphCompiler

function foo()
    x = ones(5)
    y = ones(5)
    return x + y
end

ir = code_inferred(foo)

# wraps foo in a GraphFunction - does not actually compile anything until
# concrete argument types are supplied
g_foo = graph_compile(foo)

# compiles g_foo and evaluates it - currently can't actually evaluate so just
# returns the "compiled" MindSporeFunction for debugging
f = g_foo()

# print the MindIR string representation
print(f.str)
