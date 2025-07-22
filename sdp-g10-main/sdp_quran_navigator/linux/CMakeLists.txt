# Set minimum CMake version and policy
cmake_minimum_required(VERSION 3.10)
cmake_policy(SET CMP0079 NEW)  # Required for cross-directory target linking

# Project configuration
project(sdp_quran_navigator LANGUAGES CXX)

# Flutter-specific configurations
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run")

# Locate Flutter and its dependencies
find_program(FLUTTER flutter PATHS ENV FLUTTER_ROOT)
if(NOT FLUTTER)
    message(FATAL_ERROR "Flutter not found. Please ensure Flutter SDK is installed and in your PATH")
endif()

# Configure build options
add_compile_options(
    "$<$<CONFIG:Debug>:-DDEBUG>"
    "$<$<NOT:$<CONFIG:Debug>>:-DNDEBUG>"
)

# Include Flutter tooling
include(flutter/generated_plugins.cmake)

# Add executable target
add_executable(sdp_quran_navigator
    "main.cc"
    "${FLUTTER_TARGET_PLATFORM}/flutter_export.h"
    "${FLUTTER_TARGET_PLATFORM}/flutter_export.cc"
    "${FLUTTER_TARGET_PLATFORM}/flutter_messenger.h"
    "${FLUTTER_TARGET_PLATFORM}/flutter_messenger.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/flutter/generated_plugin_registrant.cc"
)

# Link Flutter libraries and plugins
target_link_libraries(sdp_quran_navigator PRIVATE flutter flutter_wrapper_app)
target_link_libraries(sdp_quran_navigator PRIVATE PkgConfig::GTK)  # For Linux desktop

# Include generated plugins
include(flutter/generated_plugins.cmake)

# Add install target
install(TARGETS sdp_quran_navigator
    RUNTIME DESTINATION "${INSTALL_BINDIR}"
    LIBRARY DESTINATION "${INSTALL_LIBDIR}"
)

# Post-build copy for Linux desktop
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    add_custom_command(TARGET sdp_quran_navigator POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${FLUTTER_APPLICATION_PATH}/data/flutter_assets"
        "$<TARGET_FILE_DIR:sdp_quran_navigator>/data/flutter_assets"
    )
endif()