using MindSpore, CxxWrap

graph = MindSpore.GraphAPI.CreateFuncGraph()
# mgr = MindSpore.GraphAPI.CreateGraphManager(graph)
vm = MindSpore.GraphAPI.CompileGraphForCpuBackend(graph)
out = MindSpore.GraphAPI.Eval(vm, MindSpore.GraphAPI.VectorRef())

# graph = MindSpore.GraphAPI.CreateFuncGraph()
# a = MindSpore.GraphAPI.CreateOnesFloatTensor(StdVector([2, 3]))
# b = MindSpore.GraphAPI.CreateOnesFloatTensor(StdVector([2, 3]))

# inputs = MindSpore.GraphAPI.AnfNode[
#     MindSpore.GraphAPI.CreatePrimitiveValueNode("Add"),
#     MindSpore.GraphAPI.CreateAndAddParameter(graph, a),
#     MindSpore.GraphAPI.CreateAndAddParameter(graph, b)
# ]

# cnode = MindSpore.GraphAPI.CreateCNode(graph, StdVector(inputs))

# mgr = MindSpore.GraphAPI.CreateGraphManager(graph)
# vm = MindSpore.GraphAPI.CompileGraphForCpuBackend(graph)
