find_package(Doxygen OPTIONAL_COMPONENTS dot)

if(NOT DOXYGEN_FOUND)
  message(STATUS "Doxygen not found — skipping docs target")
  return()
endif()

set(DOXYGEN_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in
  ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
  @ONLY
)

add_custom_target(docs
  COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMENT "Generating documentation with Doxygen"
  VERBATIM
)