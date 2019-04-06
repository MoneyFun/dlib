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
if (NOT TARGET dlib)
   message(STATUS "Using CMake version: ${CMAKE_VERSION}")
   message(STATUS "Compiling dlib version: ${VERSION}")
endif()


include(cmake_utils/set_compiler_specific_options.cmake)


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

include(cmake_utils/use_cpp_11.cmake)

# Set DLIB_VERSION in the including CMake file so they can use it to do whatever they want.
set(DLIB_VERSION ${VERSION} PARENT_SCOPE)

set (BUILDING_PYTHON_IN_MSVC false)

# DLIB_IN_PROJECT_BUILD==true means you are using dlib by invoking
# add_subdirectory(dlib) in the parent project. In this case, we always want
# to build dlib as a static library so the parent project doesn't need to
# deal with some random dlib shared library file.  It is much better to
# statically compile dlib into the parent project.  So the following bit of
# CMake ensures that happens.  However, we have to take care to compile dlib
# with position independent code if appropriate (i.e. if the parent project
# is a shared library).
if (BUILD_SHARED_LIBS)
   if (CMAKE_COMPILER_IS_GNUCXX)
      # Just setting CMAKE_POSITION_INDEPENDENT_CODE should be enough to set
      # -fPIC for GCC but sometimes it still doesn't get set, so make sure it
      # does.
      add_definitions("-fPIC")
   endif()
   set(CMAKE_POSITION_INDEPENDENT_CODE true)
endif()

# Tell cmake to build dlib as a static library
set(BUILD_SHARED_LIBS false)

set(CUDA_LINK_LIBRARIES_KEYWORD PUBLIC)


macro (enable_preprocessor_switch option_name)
   list(APPEND active_preprocessor_switches "-D${option_name}")
endmacro()

macro (disable_preprocessor_switch option_name)
   if (active_preprocessor_switches)
      list(REMOVE_ITEM active_preprocessor_switches "-D${option_name}")
   endif()
endmacro()

macro (toggle_preprocessor_switch option_name)
   if (${option_name})
      enable_preprocessor_switch(${option_name})
   else()
      disable_preprocessor_switch(${option_name})
   endif()
endmacro()


# Don't try to call add_library(dlib) and setup dlib's stuff if it has already
# been done by some other part of the current cmake project.  We do this
# because it avoids getting warnings/errors about cmake policy CMP0002.  This
# happens when a project tries to call add_subdirectory() on dlib more than
# once.  This most often happens when the top level of a project depends on two
# or more other things which both depend on dlib.
if (NOT TARGET dlib)

   set (DLIB_ISO_CPP_ONLY_STR
      "Enable this if you don't want to compile any non-ISO C++ code (i.e. you don't use any of the API Wrappers)" )
   set (DLIB_ENABLE_STACK_TRACE_STR
      "Enable this if you want to turn on the DLIB_STACK_TRACE macros" )
   set (DLIB_USE_MKL_SEQUENTIAL_STR
      "Enable this if you have MKL installed and want to use the sequential version instead of the multi-core version." )
   set (DLIB_USE_MKL_WITH_TBB_STR
      "Enable this if you have MKL installed and want to use the tbb version instead of the openmp version." )
   set (DLIB_PNG_SUPPORT_STR
      "Disable this if you don't want to link against libpng" )
   set (DLIB_GIF_SUPPORT_STR
      "Disable this if you don't want to link against libgif" )
   set (DLIB_USE_MKL_FFT_STR
      "Disable this is you don't want to use the MKL DFTI FFT implementation" )
   set (DLIB_ENABLE_ASSERTS_STR
      "Enable this if you want to turn on the DLIB_ASSERT macro" )


   option(DLIB_ENABLE_ASSERTS ${DLIB_ENABLE_ASSERTS_STR} OFF)
   option(DLIB_ISO_CPP_ONLY ${DLIB_ISO_CPP_ONLY_STR} OFF)
   toggle_preprocessor_switch(DLIB_ISO_CPP_ONLY)
   option(DLIB_ENABLE_STACK_TRACE ${DLIB_ENABLE_STACK_TRACE_STR} OFF)
   toggle_preprocessor_switch(DLIB_ENABLE_STACK_TRACE)
   option(DLIB_USE_MKL_SEQUENTIAL ${DLIB_USE_MKL_SEQUENTIAL_STR} OFF)
   option(DLIB_USE_MKL_WITH_TBB ${DLIB_USE_MKL_WITH_TBB_STR} OFF)


   # Set these variables so they are set in the config.h.in file when dlib
   # is installed.
   set (DLIB_DISABLE_ASSERTS true)
   set (ENABLE_ASSERTS false)
   disable_preprocessor_switch(ENABLE_ASSERTS)
   # Never force the asserts off when doing an in project build.  The only
   # time this matters is when using visual studio.  The visual studio IDE
   # has a drop down that lets the user select either release or debug
   # builds.  The DLIB_ASSERT macro is setup to enable/disable automatically
   # based on this drop down (via preprocessor magic).  However, if
   # DLIB_DISABLE_ASSERTS is defined it permanently disables asserts no
   # matter what, which would defeat the visual studio drop down.  So here
   # we make a point to not do that kind of severe disabling when in a
   # project build.  It should also be pointed out that DLIB_DISABLE_ASSERTS
   # is only needed when building and installing dlib as a separately
   # installed library.  It doesn't matter when doing an in project build.

   option(DLIB_PNG_SUPPORT ${DLIB_PNG_SUPPORT_STR} ON)
   option(DLIB_GIF_SUPPORT ${DLIB_GIF_SUPPORT_STR} ON)
   option(DLIB_USE_MKL_FFT ${DLIB_USE_MKL_FFT_STR} ON)
   toggle_preprocessor_switch(DLIB_PNG_SUPPORT)
   toggle_preprocessor_switch(DLIB_GIF_SUPPORT)
   toggle_preprocessor_switch(DLIB_USE_MKL_FFT)


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


   set(dlib_needed_libraries)
   set(dlib_needed_includes)

   if(UNIX)
      set(CMAKE_THREAD_PREFER_PTHREAD ON)
      find_package(Threads REQUIRED)
      set(dlib_needed_libraries ${dlib_needed_libraries} ${CMAKE_THREAD_LIBS_INIT})
   endif()

   # link to the nsl library if it exists.  this is something you need sometimes
   find_library(nsllib nsl)
   if (nsllib)
      set (dlib_needed_libraries ${dlib_needed_libraries} ${nsllib})
   endif ()

   # link to the socket library if it exists.  this is something you need on solaris
   find_library(socketlib socket)
   if (socketlib)
      set (dlib_needed_libraries ${dlib_needed_libraries} ${socketlib})
   endif ()

   mark_as_advanced(nsllib pthreadlib socketlib)

   INCLUDE (CheckFunctionExists)

   if (DLIB_USE_MKL_FFT)
      if (DLIB_USE_MKL_WITH_TBB AND DLIB_USE_MKL_SEQUENTIAL)
         set(DLIB_USE_MKL_SEQUENTIAL OFF CACHE STRING ${DLIB_USE_MKL_SEQUENTIAL_STR} FORCE )
         toggle_preprocessor_switch(DLIB_USE_MKL_SEQUENTIAL)
         message(STATUS "Disabling DLIB_USE_MKL_SEQUENTIAL. It cannot be used simultaneously with DLIB_USE_MKL_WITH_TBB.")
      endif()

      if (DLIB_USE_MKL_FFT)
         if (found_intel_mkl AND found_intel_mkl_headers)
            set (dlib_needed_includes ${dlib_needed_includes} ${mkl_include_dir})
            set (dlib_needed_libraries ${dlib_needed_libraries} ${mkl_libraries})
         else()
            set(DLIB_USE_MKL_FFT OFF CACHE STRING ${DLIB_USE_MKL_FFT_STR} FORCE )
            toggle_preprocessor_switch(DLIB_USE_MKL_FFT)
         endif()
      endif()
   endif()


   # Tell CMake to build dlib via add_library()/cuda_add_library()
   add_library(dlib ${source_files} )

   target_include_directories(dlib
      INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
      INTERFACE $<INSTALL_INTERFACE:include>
      PUBLIC ${dlib_needed_includes}
      )
   target_link_libraries(dlib PUBLIC ${dlib_needed_libraries})
   target_compile_options(dlib PUBLIC ${active_preprocessor_switches})

   enable_cpp11_for_target(dlib)
   target_compile_options(dlib PUBLIC $<$<COMPILE_LANGUAGE:CXX>:${active_compile_opts}>)
   target_compile_options(dlib PRIVATE $<$<COMPILE_LANGUAGE:CXX>:${active_compile_opts_private}>)

endif()

add_library(dlib::dlib ALIAS dlib)
