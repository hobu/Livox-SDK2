rm -rf build/
mkdir build
cd build

#SANITIZE="-fsanitize=address,alignment,unreachable,vla-bound,vptr"
#SANITIZE="-fsanitize=address,alignment,undefined"
SANITIZE=""
cmake   -G "Ninja"  \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_INSTALL_PREFIX=${CONDA_PREFIX} \
      -DCMAKE_EXE_LINKER_FLAGS="$SANITIZE" \
      -DCMAKE_CXX_FLAGS="$SANITIZE" \
      ..
ninja
