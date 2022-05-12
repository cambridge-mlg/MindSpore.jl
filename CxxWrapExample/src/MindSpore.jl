module MindSpore

using CodeInfoTools

include("compiler.jl")
include("graph_api.jl")
include("graph_builder.jl")

function foo()
    x = ones(5)
    y = ones(5)
    return x + y
end

# ms_foo = ms(foo)
# println(ms_foo())

# println(MindSpore.GraphAPI.CreateOnesFloatTensor(StdVector([2, 3])))

end
