#include "cxx_graph_api.h"

// void TensorAddExample() {

// }

void RunBlankGraph() {
  auto graph = CreateFuncGraph();
  compile::FinalVMPtr vm = CompileGraphForCpuBackend(graph);
  VectorRef args;
  BaseRef output = vm->Eval(args);
}

int main() {
  RunBlankGraph();
  // TensorAddExample();
  return 0;
}
