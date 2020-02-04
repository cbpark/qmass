{ mkDerivation, base, lhapdf, stdenv }:
mkDerivation {
  pname = "qmass";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base ];
  executableSystemDepends = [ lhapdf ];
  homepage = "https://github.com/cbpark/qmass";
  description = "Calculate the running quark mass";
  license = stdenv.lib.licenses.bsd3;
}
