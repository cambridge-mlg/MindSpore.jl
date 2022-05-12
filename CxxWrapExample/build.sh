#!/bin/bash

set -e
set -x

# you should modify these lines according to your own paths.
######################################################################################################
export CONDA_ENV_PATH=/home/ross/miniconda3/envs/mindspore_py37
export MS_PATH=/home/ross/msproj/mindspore
export MS_LIB_PATH=/home/ross/msproj/mindspore/build/mindspore/.mslib

export EIGEN3_INCLUDE_PATH=${MS_LIB_PATH}/eigen3_951666374a92d62fcd880d2baa7db402/include/eigen3/
export PYBIND11_INCLUDE_PATH=${MS_LIB_PATH}/pybind11_4ff815e53c2c9c54255c528ad480c451/include/
export NLOHMANN_JSON_INCLUDE_PATH=${MS_LIB_PATH}/nlohmann_json_b73a91c3af99db76a4468ecba3b99509/
export GRPC_INCLUDE_PATH=${MS_LIB_PATH}/grpc_e7883cdfd9a19339cbf13de2c19818dc/include
export PROTOBUF_INCLUDE_PATH=${MS_LIB_PATH}/protobuf_322c5db6eaf87dbd3b69affa275cf14f/include

export CXXWRAP_PREFIX=/home/ross/.julia/artifacts/8de94188522d7beaa28624509e9bfa5f5eaf7859
######################################################################################################

BASEPATH=$(cd "$(dirname $0)"; pwd)
BUILD_PATH="${BASEPATH}/build/"
export LIBRARY_PATH=${MS_PATH}/mindspore/lib:${CONDA_ENV_PATH}/lib:${LIBRARY_PATH}
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}


mkdir -p ${BUILD_PATH}
# cmake --verbose=1 -S ./ -B build
# cmake -S ./ -B build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${CXXWRAP_PREFIX} -B ${BUILD_PATH} ./ccsrc
cmake --build ./build --config Release --verbose
