#include "cxx_graph_api.h"
#include "core/base/core_ops.h"
#include "vm/backend.h"
#include "vm/transform.h"
#include "vm/vm.h"

// #include "jlcxx/array.hpp"
#include "jlcxx/jlcxx.hpp"
#include "jlcxx/stl.hpp"

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
CNodePtr CreateCNode(const FuncGraphPtr &graph, const std::vector<AnfNodePtr> &inputs) {
  auto cnode = graph->NewCNode(inputs);
  auto prim = GetValueNode<PrimitivePtr>(cnode->input(0));
  // prim->SetAttrs(attrs);
  return cnode;
}

std::vector<AnfNodePtr> jl_to_vec(jlcxx::ArrayRef<AnfNodePtr> &inputs) {
  std::vector<AnfNodePtr> outs;
  for (unsigned int i = 0; i < inputs.size(); i++) {
    outs.push_back(inputs[i]);
  }
  return outs;
}

// // Create a CNode.
// CNodePtr CreateCNode(const FuncGraphPtr &graph, jlcxx::ArrayRef<AnfNodePtr> &inputs) {
//   std::vector<AnfNodePtr> inputs_vec;
//   for (unsigned int i = 0; i < inputs.size(); i++) {
//     inputs_vec.push_back(inputs[i]);
//   }
//   auto cnode = graph->NewCNode(inputs_vec);
//   auto prim = GetValueNode<PrimitivePtr>(cnode->input(0));
//   // prim->SetAttrs(attrs);
//   return cnode;
// }

FuncGraphManagerPtr CreateGraphManager(const FuncGraphPtr &graph) {
  return MakeManager({graph}, true);
}

// Compile a graph for cpu backend.
compile::FinalVMPtr CompileGraphForCpuBackend(const FuncGraphPtr &graph) {
  FuncGraphManagerPtr manager = MakeManager({graph}, true);  // TODO: remove?
  auto backend = std::make_shared<compile::MsBackend>("ms", "CPU", 0);
  const std::vector<PrimitivePtr> &cut_list = compile::GetMsNonlinearOps();
  auto compile = std::make_shared<compile::CompileGraphs>(backend, cut_list);
  compile::FinalVMPtr vm = compile->CompileAndLink(graph);
  return vm;
}

namespace jlcxx
{
  template<> struct SuperType<ValueNode> { typedef AnfNode type; };
  template<> struct SuperType<Parameter> { typedef AnfNode type; };
  // template<> struct SuperType<AnfNode> { typedef Base type; };
}

JLCXX_MODULE define_julia_module(jlcxx::Module& mod)
{
  mod.add_type<tensor::Tensor>("Tensor");
  mod.add_type<FuncGraph>("FuncGraph");
  mod.add_type<BaseRef>("BaseRef");
  mod.add_type<VectorRef>("VectorRef");
  mod.add_type<compile::FinalVM>("FinalVM")
    .method("Eval", &compile::FinalVM::Eval);
  mod.add_type<CNode>("CNode");
  mod.add_type<AnfNode>("AnfNode");
  mod.add_type<ValueNode>("ValueNode", jlcxx::julia_base_type<AnfNode>());
  mod.add_type<Parameter>("Parameter", jlcxx::julia_base_type<AnfNode>());
  mod.add_type<FuncGraphManager>("FuncGraphManager");

  jlcxx::stl::apply_stl<AnfNode*>(mod);

  mod.method("CreateFuncGraph", &CreateFuncGraph);
  mod.method("CreatePrimitiveValueNode", &CreatePrimitiveValueNode);
  mod.method("CreateAndAddParameter", &CreateAndAddParameter);
  mod.method("CreateCNode", &CreateCNode);
  mod.method("CreateOnesFloatTensor", &CreateOnesFloatTensor);
  mod.method("CreateGraphManager", &CreateGraphManager);
  mod.method("CompileGraphForCpuBackend", &CompileGraphForCpuBackend);

  mod.method("jl_to_vec", &jl_to_vec);
}
