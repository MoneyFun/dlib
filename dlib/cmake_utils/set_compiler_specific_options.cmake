
cmake_minimum_required(VERSION 2.8.12)

if (POLICY CMP0054)
   cmake_policy(SET CMP0054 NEW)
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
   execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
   if (GCC_VERSION VERSION_LESS 4.8)
      message(FATAL_ERROR "C++11 is required to use dlib, but the version of GCC you are using is too old and doesn't support C++11.  You need GCC 4.8 or newer. ")
   endif()
endif()


# push USING_OLD_VISUAL_STUDIO_COMPILER to the parent so we can use it in the
# examples CMakeLists.txt file.
get_directory_property(has_parent PARENT_DIRECTORY)
if(has_parent)
   set(USING_OLD_VISUAL_STUDIO_COMPILER ${USING_OLD_VISUAL_STUDIO_COMPILER} PARENT_SCOPE)
endif()



set(gcc_like_compilers GNU Clang  Intel)
set(intel_archs x86_64 i386 i686 AMD64 amd64 x86)


# Setup some options to allow a user to enable SSE and AVX instruction use.
if ((";${gcc_like_compilers};" MATCHES ";${CMAKE_CXX_COMPILER_ID};")  AND
   (";${intel_archs};"        MATCHES ";${CMAKE_SYSTEM_PROCESSOR};") AND NOT USE_AUTO_VECTOR)
   option(USE_SSE2_INSTRUCTIONS "Compile your program with SSE2 instructions" OFF)
   option(USE_SSE4_INSTRUCTIONS "Compile your program with SSE4 instructions" OFF)
   option(USE_AVX_INSTRUCTIONS  "Compile your program with AVX instructions"  OFF)
   if(USE_AVX_INSTRUCTIONS)
      list(APPEND active_compile_opts -mavx)
      message(STATUS "Enabling AVX instructions")
   elseif (USE_SSE4_INSTRUCTIONS)
      list(APPEND active_compile_opts -msse4)
      message(STATUS "Enabling SSE4 instructions")
   elseif(USE_SSE2_INSTRUCTIONS)
      list(APPEND active_compile_opts -msse2)
      message(STATUS "Enabling SSE2 instructions")
   endif()

elseif((";${gcc_like_compilers};" MATCHES ";${CMAKE_CXX_COMPILER_ID};")  AND
        ("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "^arm"))
   option(USE_NEON_INSTRUCTIONS "Compile your program with ARM-NEON instructions" OFF)
   if(USE_NEON_INSTRUCTIONS)
      list(APPEND active_compile_opts -mfpu=neon)
      message(STATUS "Enabling ARM-NEON instructions")
   endif()
endif()


if (CMAKE_COMPILER_IS_GNUCXX)
   # By default, g++ won't warn or error if you forget to return a value in a
   # function which requires you to do so.  This option makes it give a warning
   # for doing this.
   list(APPEND active_compile_opts "-Wreturn-type")
endif()

if ("Clang" MATCHES ${CMAKE_CXX_COMPILER_ID})
   # Increase clang's default tempalte recurision depth so the dnn examples don't error out.
   list(APPEND active_compile_opts "-ftemplate-depth=500")
endif()
