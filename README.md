# ms_cxx_graph_api_example

[Link](https://gitee.com/ginfung/ms_cxx_graph_api_example) to the original repo with Chinese README. 

#### Introduction 
This repository code is an example of the MindSpore C++ interface. In the example, the C++ interface of MindSpore is used for further encapsulation, which is used to construct the front-end `func_graph`, and call the back-end graph compilation interface and graph execution interface. Finally, it can be executed by compiling the example in `main.cc`.

#### Instructions

##### 样例编译与执行步骤：

1、To compile this example, you need to link the shared library of MindSpore. You need to modify the `mindspore/ccsrc/CMakeLists.txt` file in the root directory of the MindSpore library, and set `_c_expression` to shared.
![Enter image description](https://images.gitee.com/uploads/images/2021/0423/152834_7fe751ba_6574899.png "screenshot.png")

2. Compile MindSpore, for example, here is how to compile MindSpore for CPU backend:

`bash build.sh -e cpu -H off`
  (MindSpore compilation will add the compilation attribute of `-fvisibility=hidden` by default. Adding `-H` off here will remove this default behavior, so that the subsequent link can be successful)

3. Modify the `build.sh` file

![Enter image description](https://images.gitee.com/uploads/images/2021/0423/154007_99960f1b_6574899.png "screenshot.png")

The above paths need to be modified manually, among which
- `CONDA_ENV_PATH`: your own conda environment path, such as the conda environment where MindSpore is installed
- `MS_PATH`: the path to the MindSpore repository
- `MS_LIB_PATH`: set the value of the `MSLIBS_CACHE_PATH` environment variable when compiling MindSpore
- `EIGEN3_INCLUDE_PATH`: the header file path in the `eigen3` directory under `MS_LIB_PATH`
- `PYBIND11_INCLUDE_PATH`: the header file path in the `pybind11` directory under `MS_LIB_PATH`
- `NLOHMANN_JSON_INCLUDE_PATH`: the header file path in the `nlohmann_json` directory under `MS_LIB_PATH`
- `GRPC_INCLUDE_PATH`: the header file path in the `grpc` directory under `MS_LIB_PATH`
- `PROTOBUF_INCLUDE_PATH`: the header file path in the `protobuf` directory under `MS_LIB_PATH`

4. Execute the compilation script

`bash build.sh`

5. Execute the compiled example
````
export LD_LIBRARY_PATH=${MS_PATH}/mindspore/lib:${CONDA_ENV_PATH}/lib
cd build
./cxx_example
````
Where `MS_PATH` and `CONDA_ENV_PATH` are the paths found in step 3.
