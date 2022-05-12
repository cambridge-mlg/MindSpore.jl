struct GraphBuilder
    func_graph
end
GraphBuilder() = GraphBuilder(GraphAPI.CreateFuncGraph())

function build!(builder, ::Ones, n)
    return nothing
end

function build!(builder, ::Add, x, y)
    node = GraphAPI.CreatePrimitiveValueNode("Add")
    GraphAPI.CreateCNode(builder.graph, [node, x, y])
end

function ms_build(ir)
    builder = GraphBuilder()
    for (v, st) in ir
        if st isa Expr && st.head == :call
            build!(builder, st.args[1], st.args[2:end]...)
        end
    end
    return nothing
end
