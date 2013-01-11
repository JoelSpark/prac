# Copyright 2010-2011 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.

if(DEFINED __INCLUDED_GR_SWIG_CMAKE)
    return()
endif()
set(__INCLUDED_GR_SWIG_CMAKE TRUE)

include(GrPython)


########################################################################
# Build a swig target for the common gnuradio use case. Usage:
# GR_SWIG_MAKE(target ifile ifile ifile...)
#
# Set the following variables before calling:
#   - GR_SWIG_FLAGS
#   - GR_SWIG_INCLUDE_DIRS
#   - GR_SWIG_LIBRARIES
#   - GR_SWIG_SOURCE_DEPS
#   - GR_SWIG_TARGET_DEPS

########################################################################
macro(GR_SWIG_MAKE name)
    set(ifiles ${ARGN})

    #append additional include directories
    find_package(PythonLibs)
    list(APPEND GR_SWIG_INCLUDE_DIRS ${PYTHON_INCLUDE_PATH}) #deprecated name (now dirs)
    list(APPEND GR_SWIG_INCLUDE_DIRS ${PYTHON_INCLUDE_DIRS})
    list(APPEND GR_SWIG_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR})
    list(APPEND GR_SWIG_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR})

    #determine include dependencies for swig file
    execute_process(
        COMMAND ${PYTHON_EXECUTABLE}
            ${CMAKE_BINARY_DIR}/get_swig_deps.py
            "${ifiles}" "${GR_SWIG_INCLUDE_DIRS}"
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE SWIG_MODULE_${name}_EXTRA_DEPS
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

    #Create a dummy custom command that depends on other targets
    include(GrMiscUtils)
    GR_GEN_TARGET_DEPS(_${name}_swig_tag tag_deps ${GR_SWIG_TARGET_DEPS})
    set(tag_file ${CMAKE_CURRENT_BINARY_DIR}/${name}.tag)
    add_custom_command(
        OUTPUT ${tag_file}
        DEPENDS ${GR_SWIG_SOURCE_DEPS} ${tag_deps}
        COMMAND ${CMAKE_COMMAND} -E touch ${tag_file}
    )

    #append the specified include directories
    include_directories(${GR_SWIG_INCLUDE_DIRS})
    list(APPEND SWIG_MODULE_${name}_EXTRA_DEPS ${tag_file})

    #setup the swig flags with flags and include directories
    set(CMAKE_SWIG_FLAGS -fvirtual -modern -keyword -w511 -module ${name} ${GR_SWIG_FLAGS})
    foreach(dir ${GR_SWIG_INCLUDE_DIRS})
        list(APPEND CMAKE_SWIG_FLAGS "-I${dir}")
    endforeach(dir)

    #set the C++ property on the swig .i file so it builds
    set_source_files_properties(${ifiles} PROPERTIES CPLUSPLUS ON)

    #setup the actual swig library target to be built
    include(UseSWIG)
    SWIG_ADD_MODULE(${name} python ${ifiles})
    SWIG_LINK_LIBRARIES(${name} ${PYTHON_LIBRARIES} ${GR_SWIG_LIBRARIES})

endmacro(GR_SWIG_MAKE)

########################################################################
# Install swig targets generated by GR_SWIG_MAKE. Usage:
# GR_SWIG_INSTALL(
#   TARGETS target target target...
#   [DESTINATION destination]
#   [COMPONENT component]
# )
########################################################################
macro(GR_SWIG_INSTALL)

    include(CMakeParseArgumentsCopy)
    CMAKE_PARSE_ARGUMENTS(GR_SWIG_INSTALL "" "DESTINATION;COMPONENT" "TARGETS" ${ARGN})

    foreach(name ${GR_SWIG_INSTALL_TARGETS})
        install(TARGETS ${SWIG_MODULE_${name}_REAL_NAME}
            DESTINATION ${GR_SWIG_INSTALL_DESTINATION}
            COMPONENT ${GR_SWIG_INSTALL_COMPONENT}
        )

        include(GrPython)
        GR_PYTHON_INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/${name}.py
            DESTINATION ${GR_SWIG_INSTALL_DESTINATION}
            COMPONENT ${GR_SWIG_INSTALL_COMPONENT}
        )

        GR_LIBTOOL(
            TARGET ${SWIG_MODULE_${name}_REAL_NAME}
            DESTINATION ${GR_SWIG_INSTALL_DESTINATION}
        )

    endforeach(name)

endmacro(GR_SWIG_INSTALL)

########################################################################
# Generate a python file that can determine swig dependencies.
# Used by the make macro above to determine extra dependencies.
# When you build C++, CMake figures out the header dependencies.
# This code essentially performs that logic for swig includes.
########################################################################
file(WRITE ${CMAKE_BINARY_DIR}/get_swig_deps.py "

import os, sys, re

include_matcher = re.compile('[#|%]include\\s*[<|\"](.*)[>|\"]')
include_dirs = sys.argv[2].split(';')

def get_swig_incs(file_path):
    file_contents = open(file_path, 'r').read()
    return include_matcher.findall(file_contents, re.MULTILINE)

def get_swig_deps(file_path, level):
    deps = [file_path]
    if level == 0: return deps
    for inc_file in get_swig_incs(file_path):
        for inc_dir in include_dirs:
            inc_path = os.path.join(inc_dir, inc_file)
            if not os.path.exists(inc_path): continue
            deps.extend(get_swig_deps(inc_path, level-1))
    return deps

if __name__ == '__main__':
    ifiles = sys.argv[1].split(';')
    deps = sum([get_swig_deps(ifile, 3) for ifile in ifiles], [])
    #sys.stderr.write(';'.join(set(deps)) + '\\n\\n')
    print(';'.join(set(deps)))
")
