echo "* Preparing build directory..."
mkdir -p $SDE/build/customer/int
curr_dir=$(pwd)

echo "* Configuring build..."
cd $SDE/build/customer/int
$SDE/pkgsrc/p4-build/configure \
P4PPFLAGS="-I$SDE/install/share/p4c/p4include/" \
P4_VERSION=p4-16 \
P4_ARCHITECTURE=tna \
P4FLAGS="--verbose 2 --create-graphs -g" \
P4JOBS=4 \
P4_PATH=~/src/In_band_telemetry_bmv2/int.p4app/p4src/int_v1.0/int.p4 \
P4_NAME=int \
enable_thrift=yes \
--with-tofino \
--prefix=$SDE_INSTALL

echo "* Compiling program..."
make

echo "* Installing program..."
make install

cd $curr_dir
echo "* Done"

