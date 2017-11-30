#!/bin/bash

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/lib/g4py/__init__.pyc

if (not_there g4py $checkfile);
then

    cd $SIMPATH/transport/geant4/environments/g4py
    mypatch ../../../g4py.patch


    cd $SIMPATH/transport/geant4
    mkdir build_g4py
    cd build_g4py

    . $SIMPATH/scripts/checklib.sh
    checklib "xerces" --
    have_sys_xerces=$check
    checklib "boost" --
    have_sys_boost=$check
    
    cmake_flags="-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
    if [ $have_sys_boost -eq 1 ]; then
    	cmake_flags=$cmake_flags" -DBOOST_ROOT=${SIMPATH_INSTALL} -DBoost_NO_SYSTEM_PATHS=TRUE -DBoost_NO_BOOST_CMAKE=TRUE"
    fi
    if [ $have_sys_xerces -eq 1 ]; then
    	cmake_flags=$cmake_flags" -DXERCESC_ROOT_DIR=${SIMPATH_INSTALL}"
    fi

    cmake $cmake_flags ../environments/g4py

    $MAKE_command -j$number_of_processes
    $MAKE_command install -j$number_of_processes

    if [ "$platform" = "macosx" ];
    then
      cd  $install_prefix/lib
      create_links dylib so
    fi

    check_all_libraries  $install_prefix/lib

    check_success g4py $checkfile
    check=$?

fi

cd $SIMPATH

return 1
