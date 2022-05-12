module GraphAPI

using CxxWrap
@wrapmodule(joinpath("/home/ross/msproj/MindSpore.jl/build/lib", "libcxx_graph_api"))

function __init__()
    @initcxx
end

end
