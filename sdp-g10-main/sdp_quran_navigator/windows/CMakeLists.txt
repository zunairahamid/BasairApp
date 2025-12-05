# Set minimum required CMake version with proper syntax
cmake_minimum_required(VERSION 3.10...3.28)

# Enable required policy for cross-directory linking
cmake_policy(SET CMP0079 NEW)

# Define project name
project(sdp_quran_navigator LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define build type if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Flutter configuration
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Configure build options
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  add_definitions(-D_UNICODE -DUNICODE)
endif()

# Custom apply_standard_settings function
function(apply_standard_settings target)
  message(STATUS "Applying standard settings to target: ${target}")
  
  set_target_properties(${target} PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
  )
  
  if(MSVC)
    target_compile_options(${target} PRIVATE
      /W4
      /WX-
      /wd4100  # unreferenced formal parameter
      /wd4201  # nameless struct/union
      /wd4456  # declaration hides previous local declaration
      /wd4458  # declaration hides class member
      /wd4459  # declaration hides global declaration
      /wd4505  # unreferenced local function has been removed
      /wd4996  # unsafe functions
    )
  else()
    target_compile_options(${target} PRIVATE
      -Wall
      -Wextra
      -Werror
      -Wno-unused-parameter
      -Wno-unused-function
    )
  endif()
endfunction()

# Create main.cpp if it doesn't exist
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp")
  file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp" "// Placeholder main.cpp - will be replaced by Flutter\nint main() { return 0; }")
  message(STATUS "Created placeholder main.cpp")
endif()

# Add the main executable with placeholder source
add_executable(${PROJECT_NAME} WIN32
  "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp"
)

apply_standard_settings(${PROJECT_NAME})

# Set target properties
set_target_properties(${PROJECT_NAME} PROPERTIES
  OUTPUT_NAME "sdp_quran_navigator"
  VERSION 1.0.0
  SOVERSION 1
)

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Windows-specific settings
if(WIN32)
  # Add Windows API libraries
  target_link_libraries(${PROJECT_NAME} PRIVATE
    dwmapi.lib
    shell32.lib
    ole32.lib
    oleaut32.lib
    comdlg32.lib
    gdi32.lib
    user32.lib
    advapi32.lib
  )

  # Add resource file if it exists
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/runner/resources.rc")
    target_sources(${PROJECT_NAME} PRIVATE
      "${CMAKE_CURRENT_SOURCE_DIR}/runner/resources.rc"
    )
  endif()

  # Add manifest file if it exists
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/runner/runner.exe.manifest")
    set_target_properties(${PROJECT_NAME} PROPERTIES
      LINK_FLAGS "/MANIFEST:EMBED"
    )
  endif()
endif()

# Custom command to generate Flutter files before build
add_custom_command(TARGET ${PROJECT_NAME} PRE_BUILD
  COMMAND ${CMAKE_COMMAND} -E echo "Generating Flutter files..."
  COMMAND cd "${CMAKE_SOURCE_DIR}" && flutter pub get
  COMMAND cd "${CMAKE_SOURCE_DIR}" && flutter assemble --depfile windows/flutter/ephemeral/build.d --output windows/flutter/ephemeral/ -d TargetPlatform=windows-x64 debug_bundle_windows_assets
  COMMENT "Generating Flutter ephemeral files"
)

# Function to add Flutter dependencies when available
function(add_flutter_dependencies)
  # Check if Flutter files exist and add them
  if(EXISTS "${FLUTTER_MANAGED_DIR}/ephemeral/cpp_client_wrapper/core_implementations.cc")
    # Add Flutter wrapper library
    add_library(flutter_wrapper_app STATIC
      "${FLUTTER_MANAGED_DIR}/ephemeral/cpp_client_wrapper/core_implementations.cc"
      "${FLUTTER_MANAGED_DIR}/ephemeral/cpp_client_wrapper/standard_codec.cc"
      "${FLUTTER_MANAGED_DIR}/ephemeral/cpp_client_wrapper/plugin_registrar.cc"
    )
    
    apply_standard_settings(flutter_wrapper_app)
    
    target_include_directories(flutter_wrapper_app PUBLIC
      "${FLUTTER_MANAGED_DIR}/ephemeral/cpp_client_wrapper/include"
      "${FLUTTER_MANAGED_DIR}/ephemeral"
    )
    
    target_link_libraries(${PROJECT_NAME} PRIVATE flutter_wrapper_app)
    
    # Add include directories
    target_include_directories(${PROJECT_NAME} PRIVATE
      "${FLUTTER_MANAGED_DIR}/ephemeral/cpp_client_wrapper/include"
      "${FLUTTER_MANAGED_DIR}/ephemeral"
    )
  endif()
  
  # Add generated plugin registrant if it exists
  if(EXISTS "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc")
    target_sources(${PROJECT_NAME} PRIVATE
      "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
    )
  endif()
  
  # Link plugins if they exist
  if(TARGET app_links_plugin)
    target_link_libraries(${PROJECT_NAME} PRIVATE app_links_plugin)
  endif()
  
  if(TARGET audioplayers_windows_plugin)
    target_link_libraries(${PROJECT_NAME} PRIVATE audioplayers_windows_plugin)
  endif()
  
  if(TARGET url_launcher_windows_plugin)
    target_link_libraries(${PROJECT_NAME} PRIVATE url_launcher_windows_plugin)
  endif()
endfunction()

# Call the function to add Flutter dependencies
add_flutter_dependencies()

# Post-build commands for Windows
if(WIN32)
  # Copy ICU data file if it exists
  add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "${FLUTTER_MANAGED_DIR}/ephemeral/icudtl.dat"
      "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
    COMMENT "Copying ICU data file"
  )

  # Copy Flutter engine DLL if it exists
  add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "${FLUTTER_MANAGED_DIR}/ephemeral/flutter_windows.dll"
      "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
    COMMENT "Copying Flutter engine DLL"
  )
endif()

# Print configuration summary
message(STATUS "==========================================")
message(STATUS "Project: ${PROJECT_NAME}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMake version: ${CMAKE_VERSION}")
message(STATUS "Flutter managed dir: ${FLUTTER_MANAGED_DIR}")
message(STATUS "==========================================")