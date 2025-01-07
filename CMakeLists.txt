cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

project(livox_sdk2)

set(CMAKE_CXX_STANDARD 17)

message(STATUS "main project dir: " ${PROJECT_SOURCE_DIR})

if (CMAKE_CROSSCOMPILING)
	set(THREADS_PTHREAD_ARG
		"PLEASE_FILL_OUT-FAILED_TO_RUN"
		CACHE STRING "Result from TRY_RUN" FORCE)
endif()

if (UNIX)

find_package(Threads)

endif(UNIX)

add_subdirectory(sdk_core)
add_subdirectory(samples)
