#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "kmlbase" for configuration "Release"
set_property(TARGET kmlbase APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(kmlbase PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C;CXX"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/expat.lib;C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/z.lib;C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/minizip.lib;C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/uriparser.lib;C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/expat.lib"
  IMPORTED_LOCATION_RELEASE "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlbase.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS kmlbase )
list(APPEND _IMPORT_CHECK_FILES_FOR_kmlbase "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlbase.lib" )

# Import target "kmldom" for configuration "Release"
set_property(TARGET kmldom APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(kmldom PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "kmlbase"
  IMPORTED_LOCATION_RELEASE "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmldom.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS kmldom )
list(APPEND _IMPORT_CHECK_FILES_FOR_kmldom "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmldom.lib" )

# Import target "kmlxsd" for configuration "Release"
set_property(TARGET kmlxsd APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(kmlxsd PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "kmlbase"
  IMPORTED_LOCATION_RELEASE "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlxsd.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS kmlxsd )
list(APPEND _IMPORT_CHECK_FILES_FOR_kmlxsd "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlxsd.lib" )

# Import target "kmlengine" for configuration "Release"
set_property(TARGET kmlengine APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(kmlengine PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "kmlbase;kmldom"
  IMPORTED_LOCATION_RELEASE "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlengine.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS kmlengine )
list(APPEND _IMPORT_CHECK_FILES_FOR_kmlengine "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlengine.lib" )

# Import target "kmlconvenience" for configuration "Release"
set_property(TARGET kmlconvenience APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(kmlconvenience PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "kmlengine;kmldom;kmlbase"
  IMPORTED_LOCATION_RELEASE "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlconvenience.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS kmlconvenience )
list(APPEND _IMPORT_CHECK_FILES_FOR_kmlconvenience "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlconvenience.lib" )

# Import target "kmlregionator" for configuration "Release"
set_property(TARGET kmlregionator APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(kmlregionator PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "kmlbase;kmldom;kmlengine;kmlconvenience"
  IMPORTED_LOCATION_RELEASE "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlregionator.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS kmlregionator )
list(APPEND _IMPORT_CHECK_FILES_FOR_kmlregionator "C:/Users/bbact/Documents/GitHub/BNR_SEA/Py_env/Library/lib/kmlregionator.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
