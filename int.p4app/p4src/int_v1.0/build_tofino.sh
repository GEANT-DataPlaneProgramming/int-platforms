set -e

echo "* Preparing build directory..."
target_dir=$SDE/build/customer/int
mkdir -p $target_dir
curr_dir=$(pwd)

echo
echo "* Configuring build..."
cd $target_dir
$SDE/pkgsrc/p4-build/configure \
P4_VERSION=p4-16 \
P4_ARCHITECTURE=tna \
P4FLAGS="--verbose 2 --create-graphs -g" \
P4PPFLAGS="-DTOFINO" \
P4JOBS=4 \
P4_PATH=$curr_dir/int.p4 \
P4_NAME=int \
enable_thrift=yes \
--with-tofino \
--prefix=$SDE_INSTALL

echo
echo "* Cleaning up..."
make clean

echo
echo "* Compiling program..."
make

echo
echo "* Installing program..."
make install

cd $curr_dir
echo "* Done"

