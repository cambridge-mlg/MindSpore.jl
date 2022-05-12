struct MSFunction2
    func
    cache
end
MSFunction = MSFunction2

function (f::MSFunction)(args...)
    T = typeof.(args)
    if haskey(f.cache, T)
        ms_func = f.cache[T]
    else
        # Proably need to know the return type? code_inferred?
        ir = code_info(f.func, T...)
        ir = convert_ms(ir, T)
        ms_graph = ms_build(ir)
        ms_func = ms_compile(ms_graph)
    end
    return ms_func(args...)
end

ms(f) = MSFunction(f, Dict())

function convert_ms(ir, T)
    b = CodeInfoTools.Builder(ir)
    b = msops!(b)
    return finish(b)
end

function msops!(b)
    for (v, st) in b
        st isa Expr || continue
        st.head == :call || continue
        b[v] = msop(st.args[1], st.args[2:end]...)
    end
end

struct Ones end
struct Add end

msop(::typeof(ones), n::Integer) = Expr(:call, Ones(), n)
msop(::typeof(+), a, b) = Expr(:call, Add(), a, b)
msop(f, args...) = error("unrecognised operation")

function ms_compile(ms_graph)
    vm = GraphAPI.CompileGraphForCpuBackend(ms_graph)
    return (args...) -> GraphAPI.Eval(vm, args...)
end
