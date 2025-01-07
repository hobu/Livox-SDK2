cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

project(livox_sdk2)

set(CMAKE_CXX_STANDARD 11)

message(STATUS "main project dir: " ${PROJECT_SOURCE_DIR})

if (CMAKE_CROSSCOMPILING)
	set(THREADS_PTHREAD_ARG
		"PLEASE_FILL_OUT-FAILED_TO_RUN"
		CACHE STRING "Result from TRY_RUN" FORCE)
endif()

if (UNIX)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
endif(UNIX)

set(SDK_EXAMPLE_COMPILE_OPTIONS
    $<$<CXX_COMPILER_ID:GNU>:-Wall>
    $<$<CXX_COMPILER_ID:AppleClang>:-Wno-unknown-pragmas -Wall -Werror>
    $<$<CXX_COMPILER_ID:Clang>:-Wno-unknown-pragmas -Wall -Werror -Wno-unused-private-field>
    $<$<CXX_COMPILER_ID:GNU>:-flto=auto>
    $<$<CXX_COMPILER_ID:Clang>:-flto=thin>
    -O3
)

add_subdirectory(livox_lidar_quick_start)
add_subdirectory(multi_lidars_upgrade)
add_subdirectory(logger)
add_subdirectory(debug_point_cloud)
add_subdirectory(lidar_cmd_observer)
add_subdirectory(livox_lidar_rmc_time_sync)
