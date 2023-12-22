#
# Copyright 2017 The Abseil Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# NOTE: copied from https://github.com/abseil/abseil-cpp/blob/master/CMake/AbseilHelpers.cmake
# renamed absl to nt_kernal
#
#
include(CMakeParseArguments)

# The IDE folder for XPlatform-NG that will be used if XPlatform-NG is included in a CMake
# project that sets
#    set_property(GLOBAL PROPERTY USE_FOLDERS ON)
# For example, Visual Studio supports folders.
set(NT_KERNEL_IDE_FOLDER NT_KERNEL_FOLDER)



# xpng_cc_test()
#
# CMake function to imitate Bazel's cc_test rule.
#
# Parameters:
# NAME: name of target (see Usage below)
# SRCS: List of source files for the binary
# DEPS: List of other libraries to be linked in to the binary targets
# COPTS: List of private compile options
# DEFINES: List of public defines
# LINKOPTS: List of link options
# BENCH: This is a benchmark test, will add nt-kernal-benchmark label instead of
#        nt-kernal-unittest label
#
# Note:
# By default, nt_kernal_cc_test will always create a binary named nt_kernal_${NAME}.
# This will also add it to ctest list as nt_kernal_${NAME}.
#
# Usage:
#
# nt_kernal_cc_test(
#   NAME
#     awesome_test
#   INCLUDE
#     awesome_test
#   HDRS
#     "a.h"
#   SRCS
#     "awesome_test.cc"
#   DEPS
#     xpng::awesome
#     gmock
#     gtest_main
# )
function(nt_kernel_cc_test)
  if(NOT NT_KERNEL_RUN_TESTS)
    return()
  endif()

  cmake_parse_arguments(NT_KERNEL_CC_TEST
    "BENCH"
    "NAME"
    "INCLUDE;SRCS;COPTS;DEFINES;LINKOPTS;DEPS"
    ${ARGN}
  )

  if (NT_KERNEL_CC_TEST_BENCH)
    if (NOT NT_KERNEL_BENCHMARK)
      return()
    endif()
  endif()

  set(_NAME "${NT_KERNEL_CC_TEST_NAME}")

  add_executable(${_NAME} "")
  target_sources(${_NAME} PRIVATE ${NT_KERNEL_CC_TEST_SRCS})

  target_include_directories(${_NAME}
    PUBLIC ${NT_KERNEL_CC_TEST_INCLUDE}
    PRIVATE ${GMOCK_INCLUDE_DIRS} ${GTEST_INCLUDE_DIRS}
  )

  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../bin/${CMAKE_SYSTEM_NAME})

  # targeting ios
  if (DEFINED PLATFORM)
    set_target_properties(${_NAME} PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME ${_NAME}
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.nt-kernel.gtest.${_NAME}"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "0.0.0"
        MACOSX_BUNDLE_LONG_VERSION_STRING "0.0.0"
        MACOSX_BUNDLE_BUNDLE_VERSION "0.0.0")
  endif()

# to check 编译dll时 todo
#  if (${NT_KERNA_BUILD_DLL})
#    target_compile_definitions(${_NAME}
#      PUBLIC
#        ${XPNG_CC_TEST_DEFINES}
#        ABSL_CONSUME_DLL
#        USING_XPNG_SHARED=1
#        GTEST_LINKED_AS_SHARED_LIBRARY=1
#    )
#
#    # Replace dependencies on targets inside the DLL with xpng_dll itself.
#    xpng_internal_dll_targets(
#      DEPS ${XPNG_CC_TEST_DEPS}
#      OUTPUT XPNG_CC_TEST_DEPS
#    )
#    absl_internal_dll_targets(
#        DEPS ${XPNG_CC_TEST_DEPS}
#        OUTPUT XPNG_CC_TEST_DEPS
#    )
#  else()
#    target_compile_definitions(${_NAME}
#      PUBLIC
#        ${XPNG_CC_TEST_DEFINES}
#    )
#  endif()
  add_definitions(-DNT_TEST)
  # 静态库
  target_compile_definitions(${_NAME}
  PUBLIC
  ${NT_KERNEL_CC_TEST_DEFINES}
  )

  target_compile_options(${_NAME}
    PRIVATE ${NT_KERNEL_CC_TEST_COPTS}
  )

  target_link_libraries(${_NAME}
    PUBLIC ${NT_KERNEL_CC_TEST_DEPS}
    PRIVATE ${NT_KERNEL_CC_TEST_LINKOPTS}
  )
  # Add all NT_KERNAL targets to a folder in the IDE for organization.
  set_property(TARGET ${_NAME} PROPERTY FOLDER ${NT_KERNEL_IDE_FOLDER}/test)

  set(NT_KERNEL_CXX_STANDARD "${CMAKE_CXX_STANDARD}")

  set_property(TARGET ${_NAME} PROPERTY CXX_STANDARD ${NT_KERNEL_CXX_STANDARD})
  set_property(TARGET ${_NAME} PROPERTY CXX_STANDARD_REQUIRED ON)

  add_test(NAME ${_NAME} COMMAND ${_NAME})
  if (NT_KERNEL_CC_TEST_BENCH)
    set_tests_properties(${_NAME} PROPERTIES LABELS "TESTLABEL;nt-kernel-benchmark")
  else()
    set_tests_properties(${_NAME} PROPERTIES LABELS "TESTLABEL;nt-kernel-unittest")
  endif()
  target_code_coverage(${_NAME} ALL)
endfunction()


function(check_target my_target)
  if(NOT TARGET ${my_target})
    message(FATAL_ERROR " NT-KERNEL: compiling NT-KERNEL requires a ${my_target} CMake target in your project,
                   see CMake/README.md for more details")
  endif(NOT TARGET ${my_target})
endfunction()
