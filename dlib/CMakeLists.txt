cmake_minimum_required(VERSION 2.8.12)

project(dlib)

# Adhere to GNU filesystem layout conventions
include(GNUInstallDirs)

set(CMAKE_BUILD_TYPE "Release" CACHE STRING
   "Choose the type of build, options are: Debug Release
   RelWithDebInfo MinSizeRel." FORCE)

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

add_library(dlib::dlib ALIAS dlib)
