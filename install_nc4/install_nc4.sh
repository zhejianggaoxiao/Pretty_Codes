#########################################################################
# File Name: install_nc.sh
# Author: Gaox
# Mail: gaox1993@mail.ustc.edu.cn
# Created Time: 2017年08月08日 星期二 20时14分29秒
# Version: 7.0
#########################################################################
#!/bin/bash

clear

##############################################
#        Remove the unzip directory          #
##############################################

PKGS="zlib* hdf* netcdf-[!f]* netcdf-f* mpich*"

for i in $PKGS
do
  if [ -e $i ]
  then
    if [ -d $i ]
    then
      rm -r $i
    fi
  fi
done

##############################################
#              Network Check                 #
##############################################
timeout=5
target=www.baidu.com

which curl > /dev/null 2>&1
if [ ! $? -eq 0  ]
then
  sudo apt-get install curl
  if [ $? -ne 0 ]
  then
    echo -e "\033[31m* Error notice:"
    echo -e "    curl couldn't be installed. Please install it manually.\033[0m"
    echo
    exit 1
  fi

  clear
fi

ret_code=`curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`

if [ $ret_code -eq 200 ]
then
  NetWork=0  # network ok
else
  NetWork=1  # network fail
fi

##############################################
#        User Defined Installatuion          #
##############################################

echo
echo -e "  \033[36mYou can choose what to install: \033[0m"
echo
echo "    1. Only install netcdf4"
echo "    2. Only install mpich"
echo "    3. Install both above"
echo
echo -n "    Enter a number[1-3]: "
read OPT1
echo

case $OPT1 in
  1) InsPkg="netcdf4"
    ;;
  2) InsPkg="mpich"
    ;;
  3) InsPkg="netcdf and mpich"
    ;;
  *) echo -e "\033[31m* Error notice:"
     echo -e "    能不能好好玩了，啊......\033[0m"
     exit 1
     ;;
esac
echo -e "    You will install \033[32m$InsPkg\033[0m."

sleep 1

echo
echo
echo -e "  \033[36mYou can install the packages in two ways: \033[0m"
echo
echo "    1.Online  ( Network is Required. )"
echo "    2.Offline ( You should include all the needed packages. )"
echo
echo -n "    Enter a number[1-2]: "
read OPT2

case $OPT2 in
  1)if [ $NetWork -eq 1 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    You're offline. Please Check the Network......"
      echo -e "    Or You can choose Offline Installation.\033[0m"
      exit 1
    else
      echo
      echo -e "    You will install the packages \033[32monline\033[0m."
    fi
  ;;
  2)echo
    echo -e "    You will install the packages \033[32moffline\033[0m."
  ;;
  *)echo
    echo -e "\033[31m* Error notice:"
    echo -e "    能不能好好玩了，啊......\033[0m"
    exit 1
  ;;
esac

sleep 1

##############################################
#        Specify the Install routine         #
##############################################

USER=`whoami`
DefDir=/home/$USER/netcdf

echo
echo
echo -e "  \033[36mThe following things You must do before installation: \033[0m"
echo
echo -e "    * All the following packages are compiled by the\033[33m Intel Compiler\033[0m."
echo "      So you must install Intel Compiler before this installation."

echo
echo -e "    * Make sure You have \033[33mincluded\033[0m the following packages in the current directory:"
echo

if [ $OPT1 -ne 2 -a $OPT2 -eq 2 ]
then
  echo "       - zlib*.tar.gz"
  echo "       - hdf5*.tar.gz"
  echo "       - netcdf-c*.tar.gz"
  echo "       - netcdf-fortran*.tar.gz"
fi

if [ $OPT1 -ne 1 -a $OPT2 -eq 2 ]
then
  echo "       - mpich*.tar.gz"
fi

echo
echo "    * You can specify the directory where you want to install."
echo
echo -e "      \033[31mIn this shell script, You can't install these packages with "
echo -e "      SuperUser, which means You can't specfy the path out of "
echo -e "      /home/$USER/. It's very important.\033[0m"
echo
echo -n "      By default, it will be installed in: "
echo -e "\033[33m $DefDir\033[0m"
echo
echo -n "      Also, if you want to change it,you can enter the path(Enter for default):"
# User-defined Path
read UseDir

if [ -z $UseDir ]
then
  echo
  echo -n "      The library will be installed in: "
  echo -e "\033[32m$DefDir\033[0m"
  echo
  if [ ! -d $DefDir ]
  then
    mkdir $DefDir
  fi
  InsDir=$DefDir
else
  if [ -d $UseDir ]
  then
    echo
    echo -n "    The library will be installed in: "
    echo -e "\033[32m$UseDir\033[0m"
    InsDir=$UseDir
  else
    mkdir $UseDir
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    The directory you specified doesn't exist."
      echo -e "    Please mkdir first.\033[0m"
      exit 1
    fi
    echo
    echo -n "    The library will be installed in: "
    echo -e "\033[32m$UseDir\033[0m"
    InsDir=$UseDir
  fi
fi

sleep 1

##############################################
#           Install Dependency               #
##############################################

# m4 - netcdfc
echo
echo
echo -e "  \033[36mChecking some Dependency......\033[0m"
echo
echo -n "    1. m4: "
which m4
if [ $? -ne 0 ]
then
  echo
  echo "  Installing m4"
  sudo apt-get -y install m4
  if [ $? -ne 0 ]
  then
    echo -e "\033[31m* Error notice:"
    echo -e "    m4 couldn't be installed. Please install it manually.\033[0m"
    echo
    exit 1
  fi
  echo
fi

# wget - download
echo -n "    2. wget: "
which wget
if [ $? -ne 0 ]
then
  echo
  echo "  Installing wget"
  sudo apt-get -y install wget
  if [ $? -ne 0 ]
  then
    echo -e "\033[31m* Error notice:"
    echo -e "    wget couldn't be installed. Please install it manually.\033[0m"
    echo
    exit 1
  fi
  echo
fi

echo
echo -e "    \033[32mAll dependencies have been installed.\033[0m"
echo

sleep 1


##############################################
#         Check the Intel Compiler           #
##############################################

echo
echo
echo -e "  \033[36mChecking the Intel Compiler......\033[0m"
echo
echo -n "    Where is the icc: "
which icc
echo -n "    Where is the ifort: "
which ifort
if [ $? -ne 0 ]
then
  echo
  echo -e "\033[31m* Error notice: "
  echo -e "    I don't know how to say......"
  echo -e "    You know actually"
  echo -e "    You have to install the Intel Compiler first"
  echo -e "    So, Prepare well before running this shell script\033[0m"
  echo
  exit 1
else
  echo
  echo -e "    \033[32mIntel Compiler has been installed.\033[0m"
  echo
fi

sleep 1


##############################################
#           Download Packages                #
##############################################


echo
echo -e "  \033[36mCheck the packages......\033[0m"
echo

if [ $OPT1 -ne 2 ]
then

  # zlib
  if [ ! -f zlib* ]
  then
    echo "    Zlib package doesn't exist."
    echo
    echo "--> Now begin to download zlib ......"
    echo
    wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4/zlib-1.2.8.tar.gz
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Download zlib package failed. Retry~\033[0m"
      exit 1
    fi
  else
    echo "    Zlib package exists. "
    echo
  fi

  # hdf5
  if [ ! -f hdf5* ]
  then
    echo
    echo "    Hdf5 package doesn't exist."
    echo
    echo "--> Now begin to download hdf5 ......"
    echo
    wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4/hdf5-1.8.9.tar.gz

    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Download hdf5 package failed. Retry~\033[0m"
      exit 1
    fi
  else
    echo "    Hdf5 package exists."
    echo
  fi

  # netcdf-c
  if [ ! -f netcdf-[!f]* ]
  then
    echo
    echo "  Netcdf-c package doesn't exist."
    echo
    echo "--> Now begin to download netcdf-c ......"
    echo
    wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.tar.gz

    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Download netcdf-c package failed. Retry~\033[0m"
      exit 1
    fi
  else
    echo "    Netcdf-c package exists."
    echo
  fi


  # netcdf-fortran
  if [ ! -f netcdf-fortran* ]
  then
    echo
    echo "  Netcdf-fortran package doesn't exist."
    echo
    echo "--> Now begin to download netcdf-fortran ......"
    echo
    wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.4.tar.gz

    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Download netcdf-fortran package failed. Retry~\033[0m"
      exit 1
    fi
  else
    echo "    Netcdf-fortran exists."
    echo
  fi

fi # [ $OPT1 -ne 2 ]


if [ $OPT1 -ne 1 ]
then

  # mpich
  if [ ! -e mpich* ]
  then
    echo
    echo "    Mpich package doesn't exist."
    echo
    echo "--> Now begin to download mpich ......"
    echo
    wget http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz

    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Download mpich package failed. Retry~\033[0m"
      exit 1
    fi
  else
    echo "    Mpich package exists."
    echo
  fi

fi

echo -e "    \033[32mAll packages are included.\033[0m"

sleep 1


##############################################
#         Compile Environment Setting        #
##############################################

echo
echo
echo -e "  \033[36mSetting the Compiling Environment......\033[0m"
export CC=icc
export CXX=icpc
export CFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export CXXFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export F77=ifort
export FC=ifort
export FCFLAGS='-O3 -xHost -ip -no-prec-div -static-intel'
export CPP='icc -E'
export CXXCPP='icpc -E'
export F90=ifort

if [ `echo $F90` != 'ifort'  ]
then
  echo
  echo -e "\033[31m* Error notice: "
  echo -e "    Wrong in compile environment setting step"
  echo -e "    Please stop and check\033[0m"
  exit 1
else
  echo
  echo -e "    \033[32mCompiling Environment is OK.\033[0m"
fi

sleep 1


##############################################
#              Zlib install                  #
##############################################

if [ $OPT1 -ne 2 ]
then

  echo
  echo
  echo -e "  \033[36mInstalling Zlib\033[0m"

  # tar package
  ZLIB1=`ls -d zlib*`


  # find the zlib package
  if [ -n $ZLIB1 ]
  then
    echo
    echo "    Find zlib install package"
    echo
  else
    echo
    echo -e "\033[31m* Error notice: "
    echo -e "    You have to put the zlib package in this folder.\033[0m"
    echo
    exit 1
  fi

  # uncompressed the packages

  case $ZLIB1 in
    *.tar) tar -xf $ZLIB1
      ;;
    *.tar.gz) tar -xzf $ZLIB1
      ;;
    *.tar.bz2) tar -xjf $ZLIB1
      ;;
    *.tar.Z) tar -xZf $ZLIB1
      ;;
    *.rar) unrar e $ZLIB1
      ;;
    *.zip) unzip $ZLIB1
      ;;
  esac



  # go into the directory
  for i in `ls -d zlib*`
  do
    if [ $i != $ZLIB1 ]
    then
      cd $i
      ZLBD=$i
    fi
  done

  # installing
  ZDIR=${InsDir}/zlib

  if [ ! -d ${ZDIR} ]
  then
    mkdir ${ZDIR}
    ./configure --prefix=${ZDIR}
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Zlib: congifure step failed.\033[0m"
      exit 1
    fi
    make check
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Zlib: make check step failed.\033[0m"
      exit 1
    fi
    make install
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Zlib: make install step failed.\033[0m"
      exit 1
    fi
    clear
  else
    if [ `ls ${ZDIR}|wc -l` -eq 0 ]
    then
      ./configure --prefix=${ZDIR}
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Zlib: congifure step failed.\033[0m"
        exit 1
      fi
      make check
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Zlib: make check step failed.\033[0m"
        exit 1
      fi
      make install
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Zlib: make install step failed.\033[0m"
        exit 1
      fi
      clear
    else
      echo "    Zlib has already installed."
    fi
  fi

  echo
  echo
  echo -e "    \033[32mZLIB has been installed successfully.\033[0m"

  # exit to the up directory
  cd ..

  # clean
  #rm -r ${ZLBD}

  sleep 2

fi



##############################################
#              HDF5 install                  #
##############################################

if [ $OPT1 -ne 2 ]
then

  echo
  echo
  echo -e "  \033[36mInstalling HDF5\033[0m"

  # tar package
  HDF1=`ls -d hdf5*`

  # find the hdf5 package
  if [ -n $HDF1 ]
  then
    echo
    echo "    Find hdf5 install package"
    echo
  else
    echo
    echo -e "\033[31m* Error notice:"
    echo -e "    You have to put the hdf5 package in this folder.\033[0m"
    echo
    exit 1
  fi


  # uncompressed the packages

  case $HDF1 in
    *.tar) tar -xf $HDF1
      ;;
    *.tar.gz) tar -xzf $HDF1
      ;;
    *.tar.bz2) tar -xjf $HDF1
      ;;
    *.tar.Z) tar -xZf $HDF1
      ;;
    *.rar) unrar e $HDF1
      ;;
    *.zip) unzip $HDF1
      ;;
  esac



  # go into the directory
  for i in `ls -d hdf5*`
  do
    if [ $i != $HDF1 ]
    then
      cd $i
      HDFD=$i
    fi
  done

  # installing
  H5DIR=${InsDir}/hdf5

  if [ ! -d ${H5DIR} ]
  then
    mkdir ${H5DIR}
    ./configure --with-zlib=${ZDIR} --prefix=${H5DIR} #-enable-fortran -enable-cxx
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Hdf5: congifure step failed.\033[0m"
      exit 1
    fi
    make check
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Hdf5: make check step failed.\033[0m"
      exit 1
    fi
    make install
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Hdf5: make install step failed.\033[0m"
      exit 1
    fi
    clear
  else
    if [ `ls ${H5DIR}|wc -l` -eq 0 ]
    then
      ./configure --with-zlib=${ZDIR} --prefix=${H5DIR} #-enable-fortran -enable-cxx
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Hdf5: congifure step failed.\033[0m"
        exit 1
      fi
      make check
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Hdf5: make check step failed."
        echo -e "    For most reason, You should use the 1.4.9 edition of Hdf5.\033[0m"
        exit 1
      fi
      make install
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Hdf5: make install step failed.\033[0m"
        exit 1
      fi
      clear
    else
      echo "    Hdf5 has already installed."
    fi
  fi

  echo
  echo
  echo -e "    \033[32mHDF5 has been installed successfully.\033[0m "


  # exit to the up directory
  cd ..

  # clean
  #rm -r ${HDFD}

  sleep 2

fi



##############################################
#           Netcdf-c install                 #
##############################################

if [ $OPT1 -ne 2 ]
then

  echo
  echo
  echo -e "  \033[36mInstalling Netcdf-c\033[0m"

  # tar package
  NCC1=`ls -d netcdf-[!f]*`

  # find the nc package
  if [ -n $NCC1 ]
  then
    echo
    echo "    Find Netcdf-c install package"
    echo
  else
    echo
    echo -e "\033[31m* Error notice:"
    echo -e "    You have to put the Netcdf-c package in this folder.\033[0m"
    echo
    exit 1
  fi


  # uncompressed the packages

  case $NCC1 in
    *.tar) tar -xf $NCC1
      ;;
    *.tar.gz) tar -xzf $NCC1
      ;;
    *.tar.bz2) tar -xjf $NCC1
      ;;
    *.tar.Z) tar -xZf $NCC1
      ;;
    *.rar) unrar e $NCC1
      ;;
    *.zip) unzip $NCC1
      ;;
  esac


  # go into the directory
  for i in `ls -d netcdf-[!f]*`
  do
    if [ $i != $NCC1 ]
    then
      cd $i
      NCCD=$i
    fi
  done

  # add LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${H5DIR}/lib

  # installing
  NCDIR=${InsDir}/netcdfc

  if [ ! -d ${NCDIR} ]
  then
    mkdir ${NCDIR}
    CPPFLAGS="-I${H5DIR}/include -I${ZDIR}/include" LDFLAGS="-L${H5DIR}/lib -L${ZDIR}/lib"  ./configure  --prefix=${NCDIR} --enable-netcdf-4 --enable-largefile --disable-dap
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Netcdf-c: congifure step failed.\033[0m"
      exit 1
    fi
    make check
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Netcdf-c: make check step failed.\033[0m"
      exit 1
    fi
    make install
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Netcdf-c: make install step failed.\033[0m"
      exit 1
    fi
    clear
  else
    if [ `ls ${NCDIR}|wc -l` -eq 0 ]
    then
      CPPFLAGS="-I${H5DIR}/include -I${ZDIR}/include" LDFLAGS="-L${H5DIR}/lib -L${ZDIR}/lib"  ./configure  --prefix=${NCDIR} --enable-netcdf-4 --enable-largefile --disable-dap
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Netcdf-c: congifure step failed.\033[0m"
        exit 1
      fi
      make check
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Netcdf-c: make check step failed.\033[0m"
        exit 1
      fi
      make install
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Netcdf-c: make install step failed.\033[0m"
        exit 1
      fi
      clear
    else
      echo "    Netcdf-c has already installed."
    fi
  fi

  echo
  echo
  echo -e "    \033[32mNetcdfc has been installed successfully.\033[0m "


  # exit to the up directory
  cd ..

  # clean
  #rm -r ${NCCD}

  sleep 2

fi


##############################################
#        Netcdf-fortran install              #
##############################################


if [ $OPT1 -ne 2 ]
then

  echo
  echo
  echo -e "  \033[36mInstalling Netcdf-fortran\033[0m"

  # tar package
  NCF1=`ls -d  netcdf-fortran*`


  # find the nf package
  if [ -n $NCF1 ]
  then
    echo
    echo "    Find Netcdf-fortran install package"
    echo
  else
    echo
    echo -e "\033[31m* Error notice:"
    echo -e "    You have to put the Netcdf-c package in this folder.\033[0m"
    echo
    exit 1
  fi

  # uncompressed the packages

  case $NCF1 in
    *.tar) tar -xf $NCF1
      ;;
    *.tar.gz) tar -xzf $NCF1
      ;;
    *.tar.bz2) tar -xjf $NCF1
      ;;
    *.tar.Z) tar -xZf $NCF1
      ;;
    *.rar) unrar e $NCF1
      ;;
    *.zip) unzip $NCF1
      ;;
  esac


  # go into the directory
  for i in `ls -d netcdf-fortran*`
  do
    if [ $i != $NCF1 ]
    then
      cd $i
      NCFD=$i
    fi
  done

  # installing
  NFDIR=${InsDir}/netcdff

  if [ ! -d ${NFDIR} ]
  then
    mkdir ${NFDIR}
    CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib ./configure  --prefix=${NFDIR} --disable-fortran-type-check
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Netcdf-fortran: congifure step failed.\033[0m"
      exit 1
    fi
    make check
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Netcdf-fortran: make check step failed.\033[0m"
      exit 1
    fi
    make install
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Netcdf-fortran: make install step failed.\033[0m"
      exit 1
    fi
    clear
  else
    if [ `ls ${NFDIR}|wc -l` -eq 0 ]
    then
      CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib ./configure  --prefix=${NFDIR} --disable-fortran-type-check
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Netcdf-fortran: congifure step failed.\033[0m"
        exit 1
      fi
      make check
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Netcdf-fortran: make check step failed.\033[0m"
        exit 1
      fi
      make install
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Netcdf-fortran: make install step failed.\033[0m"
        exit 1
      fi
      clear
    else
      echo "    Netcdf-fortran has already installed."
    fi
  fi


  echo
  echo
  echo -e "    \033[32mNetcdf-fortran has been installed successfully.\033[0m "


  # exit to the up directory
  cd ..

  # clean
  #rm -r ${NCFD}

  sleep 2

fi


##############################################
#             MPICH  Install                 #
##############################################


if [ $OPT1 -ne 1 ]
then

  echo
  echo
  echo -e "  \033[36mInstalling mpich\033[0m"

  # tar package
  MPI1=`ls -d  mpich*`


  # find the mpich package
  if [ -n $MPI1 ]
  then
    echo
    echo "    Find mpich install package"
    echo
  else
    echo
    echo -e "\033[31m* Error notice:"
    echo -e "    You have to put the mpich package in this folder.\033[0m"
    echo
    exit 1
  fi

  # uncompressed the packages

  case $MPI1 in
    *.tar) tar -xf $MPI1
      ;;
    *.tar.gz) tar -xzf $MPI1
      ;;
    *.tar.bz2) tar -xjf $MPI1
      ;;
    *.tar.Z) tar -xZf $MPI1
      ;;
    *.rar) unrar e $MPI1
      ;;
    *.zip) unzip $MPI1
      ;;
  esac


  # go into the directory
  for i in `ls -d mpich*`
  do
    if [ $i != $MPI1 ]
    then
      cd $i
      MPID=$i
    fi
  done

  # installing
  MPIDIR=${InsDir}/mpich


  # unset F90 and F90FLAGS
  unset F90
  unset F90FLAGS

  if [ ! -d ${MPIDIR} ]
  then
    mkdir ${MPIDIR}
    ./configure  --prefix=${MPIDIR}
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Mpich: configure step failed.\033[0m"
      exit 1
    fi
    make check
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Mpich: make check step failed.\033[0m"
      exit 1
    fi
    make install
    if [ $? -ne 0 ]
    then
      echo
      echo -e "\033[31m* Error notice:"
      echo -e "    Mpich: make install step failed.\033[0m"
      exit 1
    fi
    clear
  else
    if [ `ls ${MPIDIR}|wc -l` -eq 0 ]
    then
      ./configure  --prefix=${MPIDIR}
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Mpich: configure step failed.\033[0m"
        exit 1
      fi
      make check
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Mpich: make check step failed.\033[0m"
        exit 1
      fi
      make install
      if [ $? -ne 0 ]
      then
        echo
        echo -e "\033[31m* Error notice:"
        echo -e "    Mpich: make install step failed.\033[0m"
        exit 1
      fi
      clear
    else
      echo "    Mpich has already installed."
    fi
  fi


  echo
  echo
  echo -e "    \033[32mMpich has been installed successfully.\033[0m "


  # exit to the up directory
  cd ..

  # clean
  #rm -r ${MPID}

  sleep 2

fi


##############################################
#            Final Check                     #
##############################################

# netcdf4
if [ $OPT1 -ne 2 ]
then
  export PATH=${PATH}:${NFDIR}/bin
  echo
  echo -e "  \033[36mTesting whether the installation of Netcdf4 is OK\033[0m"
  echo -n "    nf-config --version: "
  nf-config --version
  if [ $? -eq 0 ]
  then
    echo
    echo -e "    \033[32mNetcdf4 has been installed successfully.\033[0m"
  else
    echo
    echo -e "    \033[31mSorry, it occurs some problems, you need reinstall Netcdf4.\033[0m"
    echo
    exit 1
  fi
  sleep 2
fi

# mpich
if [ $OPT1 -ne 1 ]
then
  export PATH=${PATH}:${MPIDIR}/bin
  echo
  echo -e "  \033[36mTesting whether the installation of MPICH is OK\033[0m"
  echo -n "    mpif90 -v: "
  mpif90 -v
  if [ $? -eq 0 ]
  then
    echo
    echo -e "    \033[32mMPICH has been installed successfully.\033[0m"
  else
    echo
    echo -e "    \033[31mSorry, it occurs some problems, you need reinstall MPICH.\033[0m"
    echo
    exit 1
  fi
  sleep 2
fi

##############################################
#            Rest Clean Work                 #
##############################################

echo
echo -e "  \033[36mSome Cleaning Work\033[0m"

# uncompressed packages
echo
echo -n "    Do you want to delete the uncompressed packages (Not include the *.tar.gz) ? [y/n]"

read OPT3

case $OPT3 in
  y)echo
    echo -e "    You will \033[31mdelete\033[0m the uncompressed packages."
    rm -r $ZLBD $HDFD $NCCD $NCFD  $MPID
    ;;
  n)echo
    echo -e "    You will \033[32mreserve\033[0m the uncompressed packages."
    ;;
  *)echo
    echo "    I dno't know why you don't enter the proper options."
    echo -e "    But by default, it will \033[31mdelete\033[0m these uncompressed packages."
    rm -r $ZLBD $HDFD $NCCD $NCFD  $MPID
    ;;
esac


# source  packages
echo
echo -n "    Do you want to delete the source packages (the *.tar.gz) ? [y/n]"

read OPT4

case $OPT4 in
  y)echo
    echo -e "    You will \033[31mdelete\033[0m the source packages."
    rm -r $ZLIB1 $HDF1 $NCC1 $NCF1  $MPI1
    ;;
  n)echo
    echo -e "    You will \033[32mreserve\033[0m the source packages."
    ;;
  *)echo
    echo "    I dno't know why you don't enter the proper options."
    echo -e "    But by default, it will \033[31mdelete\033[0m these source packages."
    rm -r $ZLIB1 $HDF1 $NCC1 $NCF1  $MPI1
    ;;
esac

echo
echo -e "  \033[36mIn addition, there are some paths you may need:\033[0m"
if [ $OPT1 -ne 2 ]
then
  echo
  echo "  For zlib:"
  echo "    - bin_path:      ${ZDIR}/bin"
  echo "    - header_path:   ${ZDIR}/include"
  echo "    - library_path:  ${ZDIR}/lib"
  echo
  echo "  For hdf5:"
  echo "    - bin_path:      ${H5DIR}/bin"
  echo "    - header_path:   ${H5DIR}/include"
  echo "    - library_path:  ${H5DIR}/lib"
  echo
  echo "  For netcdf-c:"
  echo "    - bin_path:      ${NCDIR}/bin"
  echo "    - header_path:   ${NCDIR}/include"
  echo "    - library_path:  ${NCDIR}/lib"
  echo
  echo "  For netcdf-fortran:"
  echo "    - bin_path:      ${NFDIR}/bin"
  echo "    - header_path:   ${NFDIR}/include"
  echo "    - library_path:  ${NFDIR}/lib"
fi

if [ $OPT1 -ne 1 ]
then
  echo
  echo "  For mpich:"
  echo "    - bin_path:      ${MPIDIR}/bin"
  echo "    - header_path:   ${MPIDIR}/include"
  echo "    - library_path:  ${MPIDIR}/lib"
fi


echo
echo
echo -e "  \033[32mAll have been done. Enjoy it ~\033[0m"
echo


