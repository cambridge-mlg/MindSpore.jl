#!/usr/bin/env python3

from mindspore import ms_function
import mindspore.context as context
import mindspore.numpy as np

## %%
context.set_context(mode=context.GRAPH_MODE, device_target="CPU")
context.set_context(save_graphs=True, save_graphs_path="./ir_files")

@ms_function
def foo(x):
    #
    y = np.ones((2, 3), np.float32)
    return x + y

## %%
from mindspore import Tensor

x = Tensor([[1, 2, 3], [4, 5, 6]], np.float32)
foo(x)

# foo()
