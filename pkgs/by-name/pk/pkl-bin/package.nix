{ stdenv
, zlib
, autoPatchelfHook
, lib
, fetchurl
}:

let
  pname = "pkl-bin";
  version = "0.26.0";
  release_urls = {
    "aarch64-linux" = fetchurl {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-aarch64";
      hash = "sha256-Gj4BvKazAiFNCX6CDR33DlrjkZzI/D62p5b0f7rsVP4=";
    };
    "x86_64-linux" = fetchurl {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-amd64";
      hash = "sha256-nEBdnl8ZUU2W9OGMZiphucslqj41EVN8FtPUSTbUQYk=";
    };
  };

  src = release_urls."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation rec {
  inherit pname version src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/pkl
    chmod +x $out/bin/pkl
  '';

  meta = with lib; {
    description = "A configuration as code language with rich validation and tooling.";
    homepage = "https://pkl-lang.org";
    licence = licenses.asl20;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "pkl";
  };
}

