{
  perSystem =
    { inputs', pkgs, ... }:
    let
      inherit (pkgs) callPackage makeRustPlatform;
    in
    {
      packages =
        let
          rustPlatform = makeRustPlatform {
            cargo = inputs'.fenix.packages.latest.toolchain;
            rustc = inputs'.fenix.packages.latest.toolchain;
          };
        in
        {
          bdftoimg = callPackage ./bdftoimg { };
          mcfontcharsfrombdf = callPackage ./mcfontcharsfrombdf {
            inherit rustPlatform;
          };
        };
    };
}
