cmake_minimum_required(VERSION 3.14.0)
project(MindsporeGraphApiJlCxx)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wall -fPIC")

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

find_package(JlCxx)
get_target_property(JlCxx_location JlCxx::cxxwrap_julia LOCATION)
get_filename_component(JlCxx_location ${JlCxx_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${JlCxx_location}")

message(STATUS "Found JlCxx at ${JlCxx_location}")

add_library(cxx_graph_api SHARED cxx_graph_api.cc)
target_include_directories(cxx_graph_api PUBLIC
    $ENV{MS_PATH}
    $ENV{MS_PATH}/mindspore/
    $ENV{MS_PATH}/mindspore/core/
    $ENV{MS_PATH}/mindspore/ccsrc/
    $ENV{MS_PATH}/mindspore/lib/
    $ENV{MS_PATH}/third_party/securec/include/
    $ENV{MS_PATH}/graphengine/third_party/fwkacllib/inc/
    $ENV{MS_PATH}/graphengine/inc/external/
    $ENV{MS_PATH}/build/mindspore/
    $ENV{EIGEN3_INCLUDE_PATH}
    $ENV{PYBIND11_INCLUDE_PATH}
    $ENV{NLOHMANN_JSON_INCLUDE_PATH}
    $ENV{GRPC_INCLUDE_PATH}
    $ENV{PROTOBUF_INCLUDE_PATH}
    $ENV{CONDA_ENV_PATH}/include/python3.7m/
    )

# add_executable(cxx_example main.cc)

target_link_libraries(
    # cxx_example
    cxx_graph_api
    JlCxx::cxxwrap_julia
    JlCxx::cxxwrap_julia_stl
    $ENV{MS_PATH}/mindspore/_c_expression.cpython-37m-x86_64-linux-gnu.so
    -lmindspore_gvar -lpython3.7m -lm -lstdc++ -ldl -lgcc_s -lpthread
    )

# install(TARGETS
#   cxx_graph_api
# LIBRARY DESTINATION lib
# ARCHIVE DESTINATION lib
# RUNTIME DESTINATION lib)
