{ lib, rustPlatform }:
let
  cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
in
rustPlatform.buildRustPackage {
  inherit (cargoToml.package) version;
  cargoLock.lockFile = ./Cargo.lock;
  meta = {
    description = "extract char list from bdf and update font json";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
    ];
  };
  pname = cargoToml.package.name;
  src = ./.;
}
