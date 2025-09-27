{
  lib,
  makeWrapper,
  python3Packages,
  stdenvNoCC,
}:
let
  inherit (python3Packages) python;
  pythonDeps = with python3Packages; [
    pillow
  ];
in
stdenvNoCC.mkDerivation {
  buildInputs = [
    python
  ];
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm555 "$src" "$out/bin/bdftoimg"
    wrapProgram "$out/bin/bdftoimg" \
      --prefix PYTHONPATH : "${
        lib.makeSearchPathOutput "out" python.sitePackages (pythonDeps ++ [ python ])
      }"}
    runHook postInstall
  '';
  meta = {
    description = "BDF to PNGs converter";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
    ];
  };
  nativeBuildInputs = [
    makeWrapper
  ];
  pname = "bdftoimg";
  propagatedBuildInputs = pythonDeps;
  src = ./bdftoimg.py;
  version = "0.1.0";
}
