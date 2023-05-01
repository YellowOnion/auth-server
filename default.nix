{ mkDerivation, aeson, base, bytestring, containers, cryptonite
, http-api-data, lib, memory, mtl, servant, servant-server, stm
, text, transformers, wai, wai-extra, warp
}:
mkDerivation {
  pname = "auth-server";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base bytestring containers cryptonite http-api-data memory
    mtl servant servant-server stm text transformers wai wai-extra warp
  ];
  license = "unknown";
}
