#include "cxx_graph_api.h"


// The example of constructing an simple a+b+c graph.
FuncGraphPtr CreateTensorAddGraph(const tensor::TensorPtr &a, const tensor::TensorPtr &b, const tensor::TensorPtr &c) {
  auto graph = CreateFuncGraph();
  // Create Add node1.
  std::vector<AnfNodePtr> inputs1{CreatePrimitiveValueNode("Add"), CreateAndAddParameter(graph, a),
                                  CreateAndAddParameter(graph, b)};
  auto cnode1 = CreateCNode(graph, inputs1);
  cnode1->set_abstract(a->ToAbstract());
  // Create Add node2.
  std::vector<AnfNodePtr> inputs2{CreatePrimitiveValueNode("Add"), cnode1, CreateAndAddParameter(graph, c)};
  auto cnode2 = CreateCNode(graph, inputs2);
  cnode2->set_abstract(a->ToAbstract());
  // Set graph output.
  graph->set_output(cnode2);
  return graph;
}

FuncGraphPtr CreateConv2DGraph(const tensor::TensorPtr &input, const tensor::TensorPtr &weight,
                               const std::vector<int64_t> &conv2d_shape) {
  auto graph = CreateFuncGraph();
  auto monad = NewValueNode(kUMonad);
  monad->set_abstract(kUMonad->ToAbstract());
  auto input_parameter = CreateAndAddParameter(graph, input);
  auto weight_parameter = CreateAndAddWeightParameter(graph, weight, "w");
  // Create Conv2D node
  std::unordered_map<std::string, ValuePtr> attrs;
  attrs["group"] = MakeValue(1);
  attrs["stride"] = MakeValue(std::vector<int64_t>({1, 1, 1, 1}));
  attrs["dilation"] = MakeValue(std::vector<int64_t>({1, 1, 1, 1}));
  attrs["pad_mode"] = MakeValue(2);
  attrs["pad_list"] = MakeValue(std::vector<int64_t>({0, 0, 0, 0}));
  auto conv2d = CreateCNode(graph, {CreatePrimitiveValueNode("Conv2D"), input_parameter, weight_parameter}, attrs);
  conv2d->set_abstract(
    std::make_shared<abstract::AbstractTensor>(kFloat32, std::make_shared<abstract::Shape>(conv2d_shape)));
  graph->set_output(conv2d);
  return graph;
}

// The example of creating a a+b+c graph, and then compile and run the graph.
void TensorAddExample() {
  // Create three tensors as the inputs of the graph.
  auto tensor_a = CreateOnesFloatTensor({1, 2, 3, 4});
  auto tensor_b = CreateOnesFloatTensor({1, 2, 3, 4});
  auto tensor_c = CreateOnesFloatTensor({1, 2, 3, 4});
  // Create the a+b+c graph.
  auto graph = CreateTensorAddGraph(tensor_a, tensor_b, tensor_c);
  FuncGraphManagerPtr manager = MakeManager({graph}, true);
  // Compile the graph in cpu backend.
  compile::FinalVMPtr vm = CompileGraphForCpuBackend(graph);
  // Construct the input args.
  VectorRef args;
  args.push_back(tensor_a);
  args.push_back(tensor_b);
  args.push_back(tensor_c);
  // Run graph.
  BaseRef output = vm->Eval(args);
  auto output_tensor = utils::cast<tensor::TensorPtr>(output);
  MS_LOG(INFO) << "output: " << output_tensor->ToString();
}

// The example of creating a conv2D graph, and then compile and run the graph.
void Conv2DExample() {
  // Create two tensors as the input and weight of the graph.
  auto tensor_x = CreateArangeFloatTensor({1, 3, 3, 3}, 1 * 3 * 3 * 3);
  auto tensor_w = CreateArangeFloatTensor({2, 3, 1, 1}, 2 * 3 * 1 * 1);
  // Create the a+b+c graph.
  auto graph = CreateConv2DGraph(tensor_x, tensor_w, {1, 2, 3, 3});
  FuncGraphManagerPtr manager = MakeManager({graph}, true);
  // Compile the graph in cpu backend.
  compile::FinalVMPtr vm = CompileGraphForCpuBackend(graph);
  // Construct the input args.
  VectorRef args;
  args.push_back(tensor_x);
  args.push_back(tensor_w);
  // Run graph.
  BaseRef output = vm->Eval(args);
  auto output_tensor = utils::cast<tensor::TensorPtr>(output);
  MS_LOG(INFO) << "output: " << output_tensor->ToString();
}

int main() {
  TensorAddExample();
  Conv2DExample();
  return 0;
}

