struct MindSporeBackend <: Backend end

struct MindSporeFunction
    func_graph::FuncGraph
    str::String
end
# We don't currently have a way of compiling MSIR to a callable function, so just returns itself for debugging purposes
(m::MindSporeFunction)(args...) = m

function compile_graph_backend(::MindSporeBackend, func_graph)
    msir = anf_to_msir(func_graph)
    f = compile_msir(msir)
    return f
end

anf_to_msir = identity  # the ANF currently used is exactly MindIR anyway

# Everything below here is a very quick and very dirty proof of concept

function compile_msir(msir::FuncGraph)
    statements = topological_sort(msir.root)
    str = msir_string(statements)
    return MindSporeFunction(msir, str)
end

function topological_sort(root_node::AnfNode)
    visited = Set{AnfNode}()
    statements = Vector{AnfNode}()
    topological_sort!(root_node, visited, statements)
    return statements
end

function topological_sort!(node::AnfNode, visited, statements)
    node in visited && return
    for n in parents(node)
        topological_sort!(n, visited, statements)
    end
    push!(visited, node)
    push!(statements, node)
end

function msir_string(statements::Vector{<:AnfNode})
    return string(msir_string.(statements)...)
end

function msir_string(cnode::CNode)
    return "$(msir_var(cnode))([CNode]$(cnode.name)) = $(msir_var(cnode.anfnodes[1]))($(msir_vars(cnode.anfnodes[2:end])))\n"
end

function msir_string(rnode::ValueNode{Return})
    "Return($(msir_var(rnode.value.cnode)))\n"
end

msir_string(v::ValueNode{T}) where T = ""

function msir_vars(cnodes::Vector{AnfNode})
    str = ""
    for c in cnodes
        str = str * msir_var(c) * ", "
    end
    return str[1:end-2]
end

msir_var(c::CNode) = "%$(c.var)"

msir_var(v::ValueNode{T}) where T = msir_var(v.value)

msir_var(::Add) = "Add"
msir_var(::Fill) = "Fill"
msir_var(v) = string(v)
