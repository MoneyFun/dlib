# This script creates a function, enable_cpp11_for_target(), which checks if your
# compiler has C++11 support and enables it if it does.


cmake_minimum_required(VERSION 2.8.12)

if (POLICY CMP0054)
   cmake_policy(SET CMP0054 NEW)
endif()


set(_where_is_cmake_utils_dir ${CMAKE_CURRENT_LIST_DIR})

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

