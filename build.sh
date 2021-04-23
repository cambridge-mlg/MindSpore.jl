#!/bin/bash

set -e
set -x

# you should modify these lines according to your own paths.
######################################################################################################
export CONDA_ENV_PATH=/home/miniconda3/envs/yjf
export MS_PATH=/home/yjf/gitee/mindspore
export MS_LIB_PATH=/home/yjf/.mslibs

export EIGEN3_INCLUDE_PATH=${MS_LIB_PATH}/eigen3_8bc33200b7a5cdc3cfcdbd20dd696e13/include/eigen3/
export PYBIND11_INCLUDE_PATH=${MS_LIB_PATH}/pybind11_8da2d5a72f08229485ae54a640a12c2a/include/
export NLOHMANN_JSON_INCLUDE_PATH=${MS_LIB_PATH}/nlohmann_json_5b587fc56540f6567ddb956d953e1cad/
export GRPC_INCLUDE_PATH=${MS_LIB_PATH}/grpc_33360dee01cf3cd9d4bd4c706ad50172/include
export PROTOBUF_INCLUDE_PATH=${MS_LIB_PATH}/protobuf_7a6b97e62ef96fd659b40b87cd4dbd73/include
######################################################################################################

BASEPATH=$(cd "$(dirname $0)"; pwd)
BUILD_PATH="${BASEPATH}/build/"
export LIBRARY_PATH=${MS_PATH}/mindspore/lib:${CONDA_ENV_PATH}/lib:${LIBRARY_PATH}
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}


mkdir -p ${BUILD_PATH}
cmake --verbose=1 -S ./ -B build
cmake --build ./build --target cxx_example --verbose
