#----------------------------------------------------------------
# Generated CMake target import file for configuration "RELEASE".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "netCDF::netcdf" for configuration "RELEASE"
set_property(TARGET netCDF::netcdf APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(netCDF::netcdf PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/netcdf.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/netcdf.dll"
  )

list(APPEND _cmake_import_check_targets netCDF::netcdf )
list(APPEND _cmake_import_check_files_for_netCDF::netcdf "${_IMPORT_PREFIX}/lib/netcdf.lib" "${_IMPORT_PREFIX}/bin/netcdf.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
