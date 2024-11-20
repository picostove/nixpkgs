{
  lib,
  stdenv,
  llvm_meta,
  symlinkJoin,
  monorepoSrc,
  src,
  runCommand,
  cmake,
  libclang,
  libllvm,
  libxml2,
  lit,
  mlir,
  ninja,
  python3,
  flang-unwrapped,
  version,
  packageVendor ? null,
}:
let
pname = "flang-rt";
#src' = if monorepoSrc != null then
#    runCommand "${pname}-src-${version}" {} (''
#      mkdir -p "$out"
#      cp -r ${monorepoSrc}/cmake "$out"
#      cp -r ${monorepoSrc}/${pname} "$out"
#      mkdir -p "$out"/flang
#      cp -r ${monorepoSrc}/flang/cmake "$out"/flang
#    '') else src;

src' =  runCommand "${pname}-src-${version}" {} ''
      mkdir -p "$out"
      cp -r ${/home/stove/src/llvm-project/cmake} "$out"/cmake

      mkdir -p "$out/llvm"
      cp -r ${/home/stove/src/llvm-project/llvm/cmake} "$out/llvm/cmake"
      cp -r ${/home/stove/src/llvm-project/llvm/utils} "$out/llvm/utils"
      cp -r ${/home/stove/src/llvm-project/third-party} "$out/third-party"

      cp -r ${/home/stove/src/llvm-project/flang-rt} "$out"/flang-rt
      cp -r ${/home/stove/src/llvm-project/flang} "$out"/flang
      cp -r ${/home/stove/src/llvm-project/runtimes} "$out"/runtimes
    '';


in

stdenv.mkDerivation rec {
  inherit pname version;

  src = src';

  sourceRoot = "${src'.name}/runtimes";

  outputs = ["out" "dev"];

  nativeBuildInputs = [flang-unwrapped cmake ninja python3];
  buildInputs = [libclang libllvm mlir];

  cmakeFlags =
    [
      "-DCMAKE_Fortran_COMPILER=${flang-unwrapped}/bin/flang"
      "-DCMAKE_Fortran_COMPILER_WORKS=ON"
      "-DCMAKE_Fortran_COMPILER_SUPPORTS_F90=ON"
      "-DCLANG_DIR=${libclang.dev}/lib/cmake/clang"
      "-DMLIR_DIR=${mlir.dev}/lib/cmake/mlir"
      "-DLLVM_DIR=${libllvm}/lib/cmake/llvm"
      "-DLLVM_BUILD_MAIN_SRC_DIR=${src}/llvm"
      # TODO: enable tests. These fail right now since they link against
      # LLVMSupport but are missing a transitive dep on LLVMDemangle.
      "-DFLANG_RT_INCLUDE_TESTS=OFF"
      "-DLLVM_ENABLE_RUNTIMES=flang-rt"
    ];

  meta =
    llvm_meta
    // {
      homepage = "https://flang.llvm.org";
      description = "LLVM Fortran Runtime";
    };
}

