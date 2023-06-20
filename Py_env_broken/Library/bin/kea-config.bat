@echo off

IF "%1"=="" (
   echo kea-config.bat [OPTIONS]
   echo Options:
   echo     [--prefix]
   echo     [--version]
   echo     [--libs]
   echo     [--cflags]
   echo     [--includes]
   EXIT /B 1
) ELSE (
:printValue
    if "%1" neq "" (
	    IF "%1"=="--prefix" echo C:/Users/bbact/miniforge3/envs/Py_env/Library
	    IF "%1"=="--version" echo 1.4.15
	    IF "%1"=="--cflags" echo -IC:/Users/bbact/miniforge3/envs/Py_env/Library/include
	    IF "%1"=="--libs" echo -LIBPATH:C:/Users/bbact/miniforge3/envs/Py_env/Library/lib libkea.lib 
	    IF "%1"=="--includes" echo C:/Users/bbact/miniforge3/envs/Py_env/Library/include
		shift
		goto :printValue
    )
	EXIT /B 0
)
