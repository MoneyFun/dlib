#
# This is a CMake makefile.  You can find the cmake utility and
# information about it at http://www.cmake.org
#


cmake_minimum_required(VERSION 2.8.12)

if(POLICY CMP0048)
   cmake_policy(SET CMP0048 NEW)
endif()

project(dlib)

set(CPACK_PACKAGE_NAME "dlib")
set(CPACK_PACKAGE_VERSION_MAJOR "19")
set(CPACK_PACKAGE_VERSION_MINOR "17")
set(CPACK_PACKAGE_VERSION_PATCH "99")
set(VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})
# Only print these messages once, even if dlib is added multiple times via add_subdirectory()

message(STATUS "Using CMake version: ${CMAKE_VERSION}")
message(STATUS "Compiling dlib version: ${VERSION}")


# Adhere to GNU filesystem layout conventions
include(GNUInstallDirs)

if (POLICY CMP0063)
   # This policy tells cmake to really honor CXX_VISIBILITY_PRESET rather than
   # ignore it for backwards compatibility.
   cmake_policy(SET CMP0063 NEW)
endif()
if (POLICY CMP0075)
   cmake_policy(SET CMP0075 NEW)
endif()

set(CMAKE_BUILD_TYPE "Release" CACHE STRING
   "Choose the type of build, options are: Debug Release
   RelWithDebInfo MinSizeRel." FORCE)

function(enable_cpp11_for_target target_name)

set(COMPILER_CAN_DO_CPP_11 1)
# Tell cmake that we need C++11 for dlib
target_compile_features(${target_name}
   PUBLIC
      cxx_rvalue_references
      cxx_variadic_templates
      cxx_lambdas
      cxx_defaulted_move_initializers
      cxx_delegating_constructors
      cxx_thread_local
      cxx_constexpr
      # cxx_decltype_incomplete_return_types  # purposfully commented out because cmake errors out on this when using visual studio and cmake 3.8.0
      cxx_auto_type
   )

message(STATUS "C++11 activated.")


endfunction()

# Set DLIB_VERSION in the including CMake file so they can use it to do whatever they want.
set(DLIB_VERSION ${VERSION} PARENT_SCOPE)

set(source_files
   base64/base64_kernel_1.cpp
   bigint/bigint_kernel_1.cpp
   bigint/bigint_kernel_2.cpp
   bit_stream/bit_stream_kernel_1.cpp
   entropy_decoder/entropy_decoder_kernel_1.cpp
   entropy_decoder/entropy_decoder_kernel_2.cpp
   entropy_encoder/entropy_encoder_kernel_1.cpp
   entropy_encoder/entropy_encoder_kernel_2.cpp
   tokenizer/tokenizer_kernel_1.cpp
   unicode/unicode.cpp
   )


# Tell CMake to build dlib via add_library()/cuda_add_library()
add_library(dlib ${source_files} )

target_include_directories(dlib
   INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
   )

enable_cpp11_for_target(dlib)


add_library(dlib::dlib ALIAS dlib)
