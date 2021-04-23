# ms_cxx_graph_api_example

#### 介绍
该仓库代码为mindspore c++接口的构图样例。样例中使用mindspore的c++接口进行了进一步的封装，用来构造前端的func_graph，并调用后端图编译接口与图执行接口。最后可以通过编译main.cc中的样例执行。

#### 使用说明

##### 样例编译与执行步骤：

1、编译该样例需要链接mindspore的共享库，需要先修改下mindspore库上根目录下的mindspore/ccsrc/CMakeLists.txt文件，把_c_expression设置成共享的。
![输入图片说明](https://images.gitee.com/uploads/images/2021/0423/152834_7fe751ba_6574899.png "屏幕截图.png")

2、编译mindspore，例如编译cpu后端的mindspore命令：

`bash build.sh -e cpu -H off`
 （mindspore编译默认会加上-fvisibility=hidden的编译属性，这里加-H off是取消该行为，使得后面可以链接成功）

3、修改build.sh文件

![输入图片说明](https://images.gitee.com/uploads/images/2021/0423/154007_99960f1b_6574899.png "屏幕截图.png")

以上路径需要手工修改，其中
- CONDA_ENV_PATH：自己的conda环境路径，例如执行mindspore的conda环境
- MS_PATH：mindspore仓库的路径
- MS_LIB_PATH：编译mindspore时设置MSLIBS_CACHE_PATH环境变量的值
- EIGEN3_INCLUDE_PATH：MS_LIB_PATH下面的eigen3目录下的头文件路径
- PYBIND11_INCLUDE_PATH：MS_LIB_PATH下面的pybind11目录下的头文件路径
- NLOHMANN_JSON_INCLUDE_PATH：MS_LIB_PATH下面的nlohmann_json目录下的头文件路径
- GRPC_INCLUDE_PATH：MS_LIB_PATH下面的grpc目录下的头文件路径
- PROTOBUF_INCLUDE_PATH：MS_LIB_PATH下面的protobuf目录下的头文件路径

4、执行脚本编译

`bash build.sh`

5、执行样例
```
export LD_LIBRARY_PATH=${MS_PATH}/mindspore/lib:${CONDA_ENV_PATH}/lib
cd build
./cxx_example
```
其中MS_PATH和CONDA_ENV_PATH即步骤3中写的路径