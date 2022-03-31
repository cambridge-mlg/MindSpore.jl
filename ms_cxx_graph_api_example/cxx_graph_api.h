#include "ir/func_graph.h"
#include "vm/vm.h"

using namespace mindspore;

tensor::TensorPtr CreateOnesFloatTensor(const std::vector<int64_t> &shape);
tensor::TensorPtr CreateArangeFloatTensor(const std::vector<int64_t> &shape, float end);
FuncGraphPtr CreateFuncGraph();
ParameterPtr CreateAndAddParameter(const FuncGraphPtr &graph, const tensor::TensorPtr &input);
ParameterPtr CreateAndAddWeightParameter(const FuncGraphPtr &graph, const tensor::TensorPtr &input,
                                         const std::string &name);
ValueNodePtr CreatePrimitiveValueNode(const std::string &op_name);
CNodePtr CreateCNode(const FuncGraphPtr &graph, const std::vector<AnfNodePtr> &inputs,
                     const std::unordered_map<std::string, ValuePtr> &attrs = {});
compile::FinalVMPtr CompileGraphForCpuBackend(const FuncGraphPtr &graph);
