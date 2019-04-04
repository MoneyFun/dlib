cmake_minimum_required(VERSION 2.8.12)
# Every project needs a name.  We call this the "examples" project.
project(examples)


# Tell cmake we will need dlib.  This command will pull in dlib and compile it
# into your project.  Note that you don't need to compile or install dlib.  All
# cmake needs is the dlib source code folder and it will take care of everything.
add_subdirectory(../dlib dlib_build)


find_package(OpenCV QUIET)
if (OpenCV_FOUND)
   include_directories(${OpenCV_INCLUDE_DIRS})

   add_executable(webcam_face_pose_ex webcam_face_pose_ex.cpp)
   target_link_libraries(webcam_face_pose_ex dlib::dlib ${OpenCV_LIBS} )
else()
   message("OpenCV not found, so we won't build the webcam_face_pose_ex example.")
endif()
