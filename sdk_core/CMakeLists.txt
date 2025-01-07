cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

set(SDK_LIBRARY_STATIC livox_lidar_sdk_static)
set(SDK_LIBRARY_SHARED livox_lidar_sdk_shared)

add_library(${SDK_LIBRARY_STATIC} STATIC "")
add_library(${SDK_LIBRARY_SHARED} SHARED "")

set(LIVOX_SDK_MAJOR_VERSION "0")
set(LIVOX_SDK_MINOR_VERSION "0")
set(LIVOX_SDK_PATCH_VERSION "2")
set(LIVOX_SDK_VERSION_STRING "${LIVOX_SDK_MAJOR_VERSION}.${LIVOX_SDK_MINOR_VERSION}.${LIVOX_SDK_PATCH_VERSION}")

set(LIVOX_API_HEADER
        ../include/livox_lidar_def.h
        ../include/livox_lidar_api.h
        ../include/livox_lidar_cfg.h
        )

set_target_properties(${SDK_LIBRARY_STATIC} #${SDK_LIBRARY_SHARED}
        PROPERTIES
        PUBLIC_HEADER "${LIVOX_API_HEADER}"
        )

if(WIN32)
  set(PLATFORM win)
else(WIN32)
  set(PLATFORM unix)
endif (WIN32)

target_compile_options(${SDK_LIBRARY_STATIC}
        PRIVATE $<$<CXX_COMPILER_ID:GNU>:-Wall>#-Wno-c++11-long-long>
        PRIVATE $<$<CXX_COMPILER_ID:AppleClang>:-Wno-unknown-pragmas -Wall -Wno-unused-private-field -Wno-unused-const-variable -Wno-c++11-long-long>
        PRIVATE $<$<CXX_COMPILER_ID:Clang>:-Wno-unknown-pragmas -Wall  -Wno-c++11-long-long -Wno-delete-non-abstract-non-virtual-dtor -Wno-unused-const-variable -Wno-unused-private-field>
        )

target_compile_options(${SDK_LIBRARY_SHARED}
        PRIVATE $<$<CXX_COMPILER_ID:GNU>:-Wall>#-Wno-c++11-long-long>
        PRIVATE $<$<CXX_COMPILER_ID:AppleClang>:-Wno-unknown-pragmas -Wall -Wno-unused-private-field  -Wno-unused-const-variable -Wno-c++11-long-long>
        PRIVATE $<$<CXX_COMPILER_ID:Clang>:-Wno-unknown-pragmas -Wall  -Wno-c++11-long-long -Wno-unused-const-variable -Wno-delete-non-abstract-non-virtual-dtor -Wno-unused-private-field>
        )

# Options for optimization
target_compile_options(${SDK_LIBRARY_STATIC}
        PRIVATE $<$<CXX_COMPILER_ID:GNU>:-flto=auto>
        PRIVATE $<$<CXX_COMPILER_ID:Clang>:-flto=thin>
        PRIVATE -O3
        )

target_compile_options(${SDK_LIBRARY_SHARED}
        PRIVATE $<$<CXX_COMPILER_ID:GNU>:-flto=auto>
        PRIVATE $<$<CXX_COMPILER_ID:Clang>:-flto=thin>
        PRIVATE -O3
        )

# It's not necessary to add the optimization options to the link options for static library because
# the linkage of objects is done when building the downstream executables. flto (link time optimization)
# is made public to ensure the downstream executables are built with flto turned to conduct the link
# optimization for this static library.
target_link_options(${SDK_LIBRARY_STATIC}
        PUBLIC $<$<CXX_COMPILER_ID:GNU>:-flto=auto>
        PUBLIC $<$<CXX_COMPILER_ID:Clang>:-flto=thin>
        )

target_link_options(${SDK_LIBRARY_SHARED}
        PRIVATE $<$<CXX_COMPILER_ID:GNU>:-flto=auto>
        PRIVATE $<$<CXX_COMPILER_ID:Clang>:-flto=thin>
        PRIVATE -O3
        )

# Options for enable gdb symbols
set(MICROSTAR_GDB_COMPILE_OPTIONS
        -g3
        )

# cmake .. -DMICROSTAR_DEBUG_GDB=1 to enable gdb debug symbols
if(${MICROSTAR_DEBUG_GDB})
        message(WARNING "[Livox-SDK2]Enable GDB debug symbols")
        target_compile_options(${SDK_LIBRARY_STATIC}
                PRIVATE ${MICROSTAR_GDB_COMPILE_OPTIONS}
                )
        target_link_options(${SDK_LIBRARY_STATIC}
                PRIVATE ${MICROSTAR_GDB_COMPILE_OPTIONS}
                )
        target_compile_options(${SDK_LIBRARY_SHARED}
                PRIVATE ${MICROSTAR_GDB_COMPILE_OPTIONS}
                )
        target_link_options(${SDK_LIBRARY_SHARED}
                PRIVATE ${MICROSTAR_GDB_COMPILE_OPTIONS}
                )
endif()

# Options for enable memcheck
set(MICROSTAR_MEMCHECK_COMPILE_OPTIONS
        --param=max-vartrack-size=60000000
        -fsanitize=address,pointer-compare,pointer-subtract
        -fsanitize=undefined,bounds-strict
        -fsanitize=leak
        -fsanitize=alignment,object-size,pointer-overflow,unreachable,vla-bound
        -fsanitize=null,return,signed-integer-overflow,float-divide-by-zero,float-cast-overflow
        -fsanitize=vptr,builtin
        )

# cmake .. -DMICROSTAR_DEBUG_MEMCHECK=1 to enable memcheck
if(${MICROSTAR_DEBUG_MEMCHECK})
# the memory check options must be enabled for all translation units including the downstream projects
# so make them public
        message(WARNING "[Livox-SDK2]Enable memcheck")
        target_compile_options(${SDK_LIBRARY_STATIC}
                PUBLIC ${MICROSTAR_MEMCHECK_COMPILE_OPTIONS}
                )
        target_compile_options(${SDK_LIBRARY_SHARED}
                PUBLIC ${MICROSTAR_MEMCHECK_COMPILE_OPTIONS}
                )
        target_link_options(${SDK_LIBRARY_STATIC}
                PUBLIC ${MICROSTAR_MEMCHECK_COMPILE_OPTIONS}
                )
        target_link_options(${SDK_LIBRARY_SHARED}
                PUBLIC ${MICROSTAR_MEMCHECK_COMPILE_OPTIONS}
                )
endif()

set(LIVOX_PRIVATE_INCLUDE_DIR
        ../3rdparty
        .
        )
set(LIVOX_PUBLIC_INCLUDE_DIR
        ../include
        )

find_package(RapidJSON REQUIRED)

target_include_directories(
        ${SDK_LIBRARY_STATIC}
        PUBLIC
        ${LIVOX_PUBLIC_INCLUDE_DIR}
        PRIVATE
        ${LIVOX_PRIVATE_INCLUDE_DIR}
        ${RapidJSON_INCLUDE_DIRS}
        )
target_include_directories(
        ${SDK_LIBRARY_SHARED}
        PUBLIC
        ${LIVOX_PUBLIC_INCLUDE_DIR}
        PRIVATE
        ${LIVOX_PRIVATE_INCLUDE_DIR}
	${RapidJSON_INCLUDE_DIRS}
        )

find_package(spdlog REQUIRED)

target_link_libraries(
        ${SDK_LIBRARY_STATIC}
        PRIVATE
	spdlog::spdlog
        )
target_link_libraries(
        ${SDK_LIBRARY_SHARED}
        PRIVATE
	spdlog::spdlog
        )

set(MAIN_SOURCES
        device_manager.cpp
        livox_lidar_sdk.cpp
        params_check.cpp
        parse_cfg_file.cpp
        upgrade_manager.cpp
        )
set(BASE_SOURCES
        base/io_loop.cpp
        base/thread_base.cpp
        base/io_thread.cpp
        base/logging.cpp
        base/network/${PLATFORM}/network_util.cpp
        base/multiple_io/multiple_io_base.cpp
        base/multiple_io/multiple_io_epoll.cpp
        base/multiple_io/multiple_io_poll.cpp
        base/multiple_io/multiple_io_select.cpp
        base/multiple_io/multiple_io_kqueue.cpp
        base/wake_up/${PLATFORM}/wake_up_pipe.cpp
        )
set(COMM_SOURCES
        comm/comm_port.cpp
        comm/sdk_protocol.cpp
        comm/generate_seq.cpp
        )
set(UPGRADE_SOURCES
        upgrade_manager.cpp
        upgrade/firmware.cpp
        upgrade/livox_lidar_upgrader.cpp
        )
set(LOGGER_HANDLER_SOURCES
        logger_handler/logger_manager.cpp
        logger_handler/logger_handler.cpp
        logger_handler/file_manager.cpp
        )
set(DATA_HANDLER_SOURCES
        data_handler/data_handler.cpp
        )
set(COMMAND_HANDLER_SOURCES
        command_handler/command_impl.cpp
        command_handler/general_command_handler.cpp
        command_handler/hap_command_handler.cpp
        command_handler/mid360_command_handler.cpp
        command_handler/build_request.cpp
        command_handler/parse_lidar_state_info.cpp
        )
set(DEBUG_POINT_CLOUD_HANDLER_SOURCES
        debug_point_cloud_handler/debug_point_cloud_manager.cpp
        debug_point_cloud_handler/debug_point_cloud_handler.cpp
        )

set(LIVOX_SOURCES
        ../3rdparty/FastCRC/FastCRC_tables.h
        ../3rdparty/FastCRC/FastCRCsw.cpp
        ${MAIN_SOURCES}
        ${BASE_SOURCES}
        ${COMM_SOURCES}
        ${UPGRADE_SOURCES}
        ${LOGGER_HANDLER_SOURCES}
        ${DATA_HANDLER_SOURCES}
        ${COMMAND_HANDLER_SOURCES}
        ${DEBUG_POINT_CLOUD_HANDLER_SOURCES}
        )

target_sources(${SDK_LIBRARY_STATIC}
        PRIVATE
        ${LIVOX_SOURCES}
        )
target_sources(${SDK_LIBRARY_SHARED}
        PRIVATE
        ${LIVOX_SOURCES}
        )

install(TARGETS ${SDK_LIBRARY_STATIC} ${SDK_LIBRARY_SHARED}
        PUBLIC_HEADER DESTINATION include
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib)
