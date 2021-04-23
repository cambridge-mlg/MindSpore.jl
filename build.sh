#!/bin/bash

set -e
set -x

export CONDA_ENV_PATH=/home/miniconda3/envs/yjf
export MS_PATH=/home/yjf/gitee/mindspore
export MS_LIB_PATH=/home/yjf/.mslibs
export EIGEN3_INCLUDE_PATH=
export PYBIND11_INCLUDE_PATH=
export NLOHMANN_JSON_INCLUDE_PATH=
export GRPC_INCLUDE_PATH=
export PROTOBUF_INCLUDE_PATH=

BASEPATH=$(cd "$(dirname $0)"; pwd)
BUILD_PATH="${BASEPATH}/build/"
export LIBRARY_PATH=${MS_PATH}/mindspore/lib:${CONDA_ENV_PATH}/lib:${LIBRARY_PATH}
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}


mkdir -p ${BUILD_PATH}
cmake --verbose=1 -S ./ -B build
cmake --build ./build --target cxx_example --verbose
