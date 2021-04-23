#include "cxx_graph_api.h"
#include "core/base/core_ops.h"
#include "vm/backend.h"
#include "vm/transform.h"

// Create a float32 tensor which fills with ones.
tensor::TensorPtr CreateOnesFloatTensor(const std::vector<int64_t> &shape) {
  auto tensor = std::make_shared<tensor::Tensor>(kNumberTypeFloat32, shape);
  float *data = reinterpret_cast<float *>(tensor->data_c());
  for (size_t i = 0; i < IntToSize(tensor->ElementsNum()); ++i) {
    data[i] = 1.0f;
  }
  return tensor;
}

// Create a float32 tensor which fills like np.arange(end).
tensor::TensorPtr CreateArangeFloatTensor(const std::vector<int64_t> &shape, float end) {
  auto tensor = std::make_shared<tensor::Tensor>(kNumberTypeFloat32, shape);
  auto tensor_elem_num = tensor->ElementsNum();
  if (end < 0 || ceil(end) != tensor_elem_num) {
    MS_LOG(EXCEPTION) << "Cannot arange the array with end = " << end;
  }
  float *data = reinterpret_cast<float *>(tensor->data_c());
  for (size_t i = 0; i < IntToSize(tensor_elem_num); ++i) {
    data[i] = i * 1.0f;
  }
  return tensor;
}

// Create an empty graph.
FuncGraphPtr CreateFuncGraph() {
  static int id = 0;
  auto graph = std::make_shared<FuncGraph>();
  graph->debug_info()->set_name("FuncGraph_" + std::to_string(id++));
  return graph;
}

// Create a parameter for a graph according to the tensor input.
ParameterPtr CreateAndAddParameter(const FuncGraphPtr &graph, const tensor::TensorPtr &input) {
  ParameterPtr param = graph->add_parameter();
  param->set_abstract(input->ToAbstract());
  return param;
}

// Create a weight parameter for a graph according to the tensor input.
ParameterPtr CreateAndAddWeightParameter(const FuncGraphPtr &graph, const tensor::TensorPtr &input,
                                         const std::string &name) {
  ParameterPtr param = graph->AddWeightParameter(name);
  param->set_abstract(input->ToAbstract());
  return param;
}

// Create the `input0` value node of a cnode, the primitive info is in the `input0`.
ValueNodePtr CreatePrimitiveValueNode(const std::string &op_name) {
  auto prim = std::make_shared<Primitive>(op_name);
  return NewValueNode(prim);
}

// Create a CNode.
CNodePtr CreateCNode(const FuncGraphPtr &graph, const std::vector<AnfNodePtr> &inputs,
                     const std::unordered_map<std::string, ValuePtr> &attrs) {
  auto cnode = graph->NewCNode(inputs);
  auto prim = GetValueNode<PrimitivePtr>(cnode->input(0));
  prim->SetAttrs(attrs);
  return cnode;
}

// Compile a graph for cpu backend.
compile::FinalVMPtr CompileGraphForCpuBackend(const FuncGraphPtr &graph) {
  auto backend = std::make_shared<compile::MsBackend>("ms", "CPU", 0);
  const std::vector<PrimitivePtr> &cut_list = compile::GetMsNonlinearOps();
  auto compile = std::make_shared<compile::CompileGraphs>(backend, cut_list);
  compile::FinalVMPtr vm = compile->CompileAndLink(graph);
  return vm;
}
