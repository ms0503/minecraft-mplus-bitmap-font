{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];
  perSystem =
    { inputs', pkgs, ... }:
    {
      treefmt.programs = {
        mdformat = {
          enable = true;
          package = pkgs.mdformat.withPlugins (
            ps: with ps; [
              mdformat-footnote
              mdformat-frontmatter
              mdformat-gfm
              mdformat-tables
            ]
          );
          settings = {
            end-of-line = "lf";
            number = true;
            wrap = 80;
          };
        };
        nixfmt.enable = true;
        rustfmt = {
          edition = "2024";
          enable = true;
          package = inputs'.fenix.packages.latest.rustfmt;
        };
        taplo.enable = true;
      };
    };
}
