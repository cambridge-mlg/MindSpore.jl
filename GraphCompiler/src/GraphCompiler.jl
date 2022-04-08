module GraphCompiler

using CodeInfoTools

export graph_compile

# TODO:
# types & shapes for CNodes
# parameters
# multiple subgraphs
# control flow
# higher order functions/lambdas

abstract type Backend end

struct GraphFunction{Tfunc, Tbackend<:Backend, Tcache}
    func::Tfunc
    backend::Tbackend
    cache::Tcache
end

abstract type AnfNode end
abstract type ANode <: AnfNode end

struct CNode <: AnfNode
    name::Symbol
    var::Symbol
    anfnodes::Vector{AnfNode}
end
CNode(var::Symbol, anfnodes::Vector{<:AnfNode}) = CNode(gensym(), var, anfnodes)

parents(c::CNode) = c.anfnodes

# Formal parameter of a function
struct ParameterNode <: ANode
    parameter
end

parents(::ParameterNode) = []

abstract type PrimitiveOp end

const default_float = Float32

const GFloat  = Union{Float64,Float32,Float16}
const GInt    = Union{Int64,Int32,Int16}
const GScalar = Union{GFloat,GInt}

GType = Type{<:GScalar}  #TODO: const

# Contains both the element type `T` and shape `dims`
GShape{N} = NTuple{N,GInt}  #TODO: const

ValueType = Union{PrimitiveOp, GScalar, GType, <:GShape}  #TODO: const

struct ValueNode{T<:ValueType} <: ANode
    value::T
end
ValueNode(value::GType) = ValueNode{Type{value}}(value)

parents(::ValueNode{T}) where T = []

struct Return <: PrimitiveOp
    cnode::CNode  # should this be AnfNode?
end

parents(ret::ValueNode{Return}) = [ret.value.cnode]

const IRVar = Union{Core.SSAValue, Core.SlotNumber}

struct FuncGraph
    root::AnfNode
    parameters::Vector{ParameterNode}
end

function (f::GraphFunction)(args...)
    T = typeof.(args)
    if haskey(f.cache, T)
        callable = f.cache[T]
    else
        ir = CodeInfoTools.code_inferred(f.func, T...)
        func_graph = translate(ir)  # Convert Julia operations into generic graph operations
        callable = compile_graph_backend(f.backend, func_graph)  # Compile the ANF IR to a specific backend
    end
    return callable(args...)
end

value_node(var::ValueType) = ValueNode(var)

# get the node associated with var
# either var is a constant/value, so a ValueNode needs to be created
get_node(var, bindings, ir) = value_node(var)
# or, var is a variable which must refer to an existing node
get_node(var::IRVar, bindings, ir) = get(() -> error("No binding found for ", var), bindings, _to_symbol(var))

function translate(ir)
    bindings = Dict{Symbol, AnfNode}()

    local root_node
    for (idx, line) in enumerate(ir.code)
        root_node = translate!(Core.SSAValue(idx), line, bindings, ir)
    end
    params = []  # TODO: extract parameters

    return FuncGraph(root_node, params)
end

function translate!(var, line::Expr, bindings, ir)
    _bind_fn = (x) -> get_node(x, bindings, ir)
    if line.head == :(=)
        lhs = line.args[1]  # a SlotNumber
        rhs = line.args[2]
        return translate!(lhs, rhs, bindings, ir)  #TODO: deal with rhs being a constant/ValueNode
    elseif line.head == :call
        op, args = graph_op(line.args[1], line.args[2:end]...)
        arg_nodes = map(_bind_fn, args)

        name = _to_symbol(var)
        cnode = CNode(name, [op, arg_nodes...])
        bindings[name] = cnode
        return cnode
    end
end

function translate!(var, line::Core.ReturnNode, bindings, ir)
    ret = Return(get_node(line.val, bindings, ir))
    return ValueNode(ret)
end

_to_symbol(var::Core.TypedSlot) = Symbol(:_, var.id)
_to_symbol(var::Core.SlotNumber) = Symbol(:_, var.id)
_to_symbol(var::Core.SSAValue) = Symbol(var.id)

struct Fill <: PrimitiveOp end  #TODO: this should really be Fill... how to deal with args?
struct Add <: PrimitiveOp end

graph_op(f::GlobalRef, args...) = graph_op(getproperty(f.mod, f.name), args...)

graph_op(::typeof(Main.ones), ::Type{T}, args...) where {T<:GScalar} = ValueNode(Fill()), [T, GShape(args...), one(T)]
graph_op(f::typeof(Main.ones), args...) = graph_op(f, default_float, args...)

graph_op(::typeof(+), args...) = ValueNode(Add()), args
graph_op(_) = error("unrecognised operation")

# ** Compilation to backend

include("mindspore.jl")

const default_backend = MindSporeBackend()

graph_compile(f; backend=default_backend) = GraphFunction(f, backend, Dict())

end
