cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

set(DEMO_NAME livox_lidar_quick_start)
add_executable(${DEMO_NAME} main.cpp)

find_package(fmt CONFIG REQUIRED)
target_link_libraries(${DEMO_NAME}
        PUBLIC
        livox_lidar_sdk_static
        PRIVATE
        fmt::fmt
				)

target_compile_options(${DEMO_NAME} PRIVATE ${SDK_EXAMPLE_COMPILE_OPTIONS})
target_link_options(${DEMO_NAME} PRIVATE ${SDK_EXAMPLE_COMPILE_OPTIONS})
