#!/bin/bash
#
# CBM package compilation script
# m.al-turany@gsi.de, June 2006
# protopop@jlab.org, June 2006
# update of the script
# include debug version and
# intel compiler switches
# f.uhlig@gsi.de, July 2007

# debug options on :set -xv
# debug options off:set +xv
#
set +xv

# unset ROOTSYS. If it is set this can make problems when compiling Geant3
unset ROOTSYS

#Clean the enviroment
unset ROOTBUILD
unset THREAD
unset ZLIB
unset LZMA
unset OPENGL
unset MYSQL
unset ORACLE
unset PGSQL
unset SQLITE
unset QTDIR
unset SAPDB
unset RFIO
unset CASTOR
unset GFAL
unset GSL
unset HDFS
unset PYTHIA6
unset PYTHIA8
unset FFTW3
unset CFITSIO
unset GVIZ
unset PYTHONDIR
unset DCACHE
unset CHIRP
unset DNSSD
unset AVAHI
unset ALIEN
unset ASIMAGE
unset LDAP
unset GLOBUS_LOCATION
unset GLITE
unset MEMSTAT
unset MONALISA
unset SRP
unset SSL
unset AFS
unset ROOFIT
unset MINUIT2
unset TABLE
unset XMLDIR
unset ROOTDICTTYPE
unset PLATFORM

export SIMPATH=$PWD

# Set the cache file name
cache_file="config.cache"

# define the logfile
datum=$(date +%d%m%y_%H%M%S)
logfile=$PWD/Install_$datum.log
logfile_lib=$PWD/libraries_$datum.log
echo "The build process for the external packages for the FairRoot Project was started at" $datum | tee -a $logfile

source scripts/functions.sh

# check if there was a parameter given to the script.
# if yes then use some standard parameters and don't
# show the menus. Else get some input interactively.
if [ $# == "0" ];
then
  source scripts/menu.sh
elif [ $# == "1" ];
then
  # test if the file exist and if all needed varaibles are defined in the script
  if [ -e $1 ]; then
    source $1
    check_variables
  else
    echo "The file passed as parameter does not exist."
    exit 1
  fi
else
  echo "Call the script either with no parameter, then your are guided through the installation procedure,"
  echo "or with one parameter which defines an input file with the needed parameters."
  exit 1
fi

if [ "$install_sim" = "yes" ]
then
   onlyreco=0
   export Fortran_Needed=TRUE
elif [ "$install_sim" = "no" ]
then
   onlyreco=1
   export Fortran_Needed=FALSE
fi

if [ "$build_root6" = "yes" ]
then
  pluto=0
  export Root_Version=6
elif [ "$build_root6" = "no" ]
then
  pluto=1
  export Root_Version=5
fi


if [ "$installation_type" = "grid" ];
then
  export BUILD_BATCH=TRUE
else
  export BUILD_BATCH=FALSE
fi

if [ "$build_python" = "yes" ];
then
  export BUILD_PYTHON=TRUE
else
  export BUILD_PYTHON=FALSE
fi

export SIMPATH_INSTALL

# check the architecture automatically
# set the compiler options according to architecture, compiler
# debug and optimization options
source scripts/check_system.sh

# generate the config.cache file
generate_config_cache

echo "The following parameters are set." | tee -a $logfile
echo "System              : " $system | tee -a $logfile
echo "C++ compiler        : " $CXX | tee -a $logfile
echo "C compiler          : " $CC | tee -a $logfile
echo "Fortran compiler    : " $FC | tee -a $logfile
echo "CXXFLAGS            : " $CXXFLAGS | tee -a $logfile
echo "CFLAGS              : " $CFLAGS | tee -a $logfile
echo "FFLAGS              : " $FFLAGS | tee -a $logfile
echo "CMAKE BUILD TYPE    : " $BUILD_TYPE | tee -a $logfile
echo "Compiler            : " $compiler | tee -a $logfile
echo "Fortran compiler    : " $FC
echo "Debug               : " $debug | tee -a $logfile
echo "Optimization        : " $optimize | tee -a $logfile
echo "Platform            : " $platform | tee -a $logfile
echo "Architecture        : " $arch | tee -a $logfile
echo "G4System            : " $geant4_system | tee -a $logfile
echo "g4_data_files       : " $geant4_data_files | tee -a $logfile
echo "g4_get_data         : " $geant4_get_data | tee -a $logfile
echo "Number of parallel    " | tee -a $logfile
echo "processes for build : " $number_of_processes | tee -a $logfile
echo "Installation Directory: " $SIMPATH_INSTALL | tee -a $logfile

if [ "$onlyreco" = "1" ];
then
  echo "Reco Only Installation  "
fi

check=1

# set the versions of packages to be build
source scripts/package_versions.sh

# Create the installation directory and its substructure
create_installation_directories

# Now start compilations with checks
source scripts/checklib.sh

######################## CMake ################################
# This is only for safety reasons. If we find a machine where
# cmake is not installed, we install cmake and add the path
# to the environment variable PATH

checklib "cmake" "--"

if [ "$check" = "1" ];
then
  source scripts/install_cmake.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

############ Google Test framework ###############################

checklib "gtest" "--"

if [ "$check" = "1" ];
then
  source scripts/install_gtest.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

############ GNU scientific library ###############################

checklib "gsl" "--"

if [ "$check" = "1" ];
then
  source scripts/install_gsl.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

############ ICU libraries ###############################

checklib "icu" "--"

if [ "$check" = "1" -a "$compiler" = "Clang" -a "$platform" = "linux" ];
then
  source scripts/install_icu.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

############ Boost libraries ###############################

checklib "boost" "--"

if [ "$check" = "1" ];
then
  source scripts/install_boost.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### Pythia 6 #############################################

checklib "pythia" "Pythia" "6"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_pythia6.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### HepMC ## #############################################

checklib "HepMC" "--"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_hepmc.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### Pythia 8 #############################################

checklib "pythia" "Pythia" "8"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_pythia8.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### Xerces-C #############################################

checklib "xerces" "--"

if [ "$build_python" = "yes" ];
then
  if [ "$check" = "1" -a "$onlyreco" = "0" ];
  then
    source scripts/install_xercesc.sh
  if [ "$check" = "0" ]; then exit 1; fi
  fi
fi

############ Mesa libraries ###############################

checklib "GLU" "GL/glu"

if [ "$check" = "1" -a "$compiler" = "Clang" -a "$platform" = "linux" ];
then
  source scripts/install_mesa.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### GEANT 4 #############################################

checklib "geant" "--" "4"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_geant4.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

###################### GEANT 4 Data ########################################

if [ "$check" = "1" -a "$geant4_install_data_from_dir" = "yes" -a "$onlyreco" = "0" ];
then
  source scripts/install_geant4_data.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### ROOT #############################################

checklib "root" "--"

if [ "$check" = "1" ];
then
  source scripts/install_root6.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### G4Py #############################################

checklib "g4py" "--"

if [ "$build_python" = "yes" ];
then
  if [ "$check" = "1" -a "$onlyreco" = "0" ];
  then
    source scripts/install_g4py.sh
    if [ "$check" = "0" ]; then exit 1; fi
  fi
fi

##################### Pluto #############################################

checklib "pluto" "--"

if [ "$check" = "1" -a "$onlyreco" = "0" -a "$pluto" = "1" ];
then
     source scripts/install_pluto.sh
     if [ "$check" = "0" ]; then exit 1; fi
fi

##################### Geant 3 VMC #############################################

checklib "geant" "--" "3"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_geant3.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### VGM #############################################

checklib "vgm" "--"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
    source scripts/install_vgm.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### Geant 4 VMC #############################################

checklib "geant-vmc" "--" "4"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_geant4_vmc.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### Millepede #############################################

checklib "millepede" "--"

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_millepede.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### LibSodium ##################################################

#if [ "$check" = "1" ];
#then
#  source scripts/install_sodium.sh
#  if [ "$check" = "0" ]; then exit 1; fi
#fi

##################### ZeroMQ ##################################################

checklib "zmq" "--"

if [ "$check" = "1" ];
then
  source scripts/install_zeromq.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### Protocoll Buffers #######################################

checklib "protobuf" "google/protobuf"

if [ "$check" = "1" ];
then
  source scripts/install_protobuf.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### FlatBuffers ##############################################

checklib "flatbuffers" "--"

if [ "$check" = "1" ];
then
  source scripts/install_flatbuffers.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### MessagePack ##############################################

checklib "msgpack" "--"

if [ "$check" = "1" ];
then
  source scripts/install_msgpack.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

##################### nanomsg ##################################################

checklib "nanomsg" "--"

if [ "$check" = "1" ];
then
  source scripts/install_nanomsg.sh
  if [ "$check" = "0" ]; then exit 1; fi
fi

if [ "$check" = "1" ];
then
    echo "*** End installation of external packages without Errors***"  | tee -a $logfile
    echo ""
    if [ "$install_cmake" = "yes" ]; then
      echo "During the installation a new version of CMake has been installed in $SIMPATH_INSTALL/bin."
      echo "Please add this path to your environment variable PATH to use this new version of CMake."
    fi
    if [ "$install_alfasoft" = "yes" ];
    then
      echo "----------------- End of FairSoft installation ---------------"
    else
      exit 0
    fi
elif [ $check -eq 1 ]; then
    echo "*** End installation of external packages with Errors***"  | tee -a $logfile
    exit 42
fi
