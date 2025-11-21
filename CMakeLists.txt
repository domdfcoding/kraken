cmake_minimum_required(VERSION 3.5)
project(kraken)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/CMake")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/CMake")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/CMake")

file(REMOVE_RECURSE "${CMAKE_BINARY_DIR}/bin/CMake")

set(CMAKE_CXX_STANDARD 17)
if(WIN32)
   # disable on win build
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
endif()
if(APPLE)
  message(STATUS "Configuring universal macOS build (x86_64 + arm64)")
  set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "" FORCE)
endif()


function(add_cxx_compiler_flags)
    set(CMAKE_REQUIRED_QUIET true)
    include(CheckCXXCompilerFlag)
    set(flags ${CMAKE_CXX_FLAGS})
    foreach(flag ${ARGV})
        string(REGEX REPLACE "[^_A-Za-z0-9]" "_" stripped_flag "${flag}")
        set(var "CXX_COMPILER_FLAG_${stripped_flag}")
        check_cxx_compiler_flag("${flag}" "${var}")
        if(${var})
            set(flags "${flags} ${flag}")
        endif()
    endforeach()
    set(CMAKE_CXX_FLAGS ${flags} PARENT_SCOPE)
endfunction()
if(WIN32)
add_cxx_compiler_flags(-pedantic -fno-permissive -pedantic-errors -Wall -Wextra -Wshadow -Wstrict-aliasing -Wno-misleading-indentation "-ftemplate-depth=1024")
elseif(APPLE)
  message(STATUS "Configuring for macOS")
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
  add_cxx_compiler_flags(-O3 -mavx -mavx2 -fPIC -pedantic -fpermissive -pedantic-errors -Wstrict-aliasing -Wno-misleading-indentation "-ftemplate-depth=1024" -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable -Wno-missing-braces -Wno-deprecated-declarations)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
  add_cxx_compiler_flags(-O3 -fopenmp-simd -fPIC -pedantic -fpermissive -pedantic-errors -Wstrict-aliasing -Wno-misleading-indentation "-ftemplate-depth=1024" -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable -Wno-missing-braces -Wno-deprecated-declarations)
endif()
  add_definitions(-DSIMDE_ENABLE_NATIVE_ALIASES -DSIMDE_ENABLE_OPENMP)

  include_directories(simde)
endif()
include_directories(.)

set(SOURCE
        kraken.h
        kraken.cpp
        )

add_library(kraken SHARED ${SOURCE})
add_library(kraken_static STATIC ${SOURCE})
