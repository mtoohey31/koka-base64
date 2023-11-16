{
  description = "koka-base64";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: {
    overlays = {
      koka-int8-box = final: prev:
        let patchPath = ./0001-add-kk_int8-un-box.patch; in {
          koka = prev.koka.overrideAttrs (oldAttrs:
            let
              isKklib = pkg: pkg != null && final.lib.getName pkg == "kklib";
              inherit (builtins) filter head map replaceStrings;
            in
            rec {
              buildInputs =
                let
                  overrideKklibAttrs = oldAttrs: {
                    patches = (oldAttrs.patches or [ ]) ++ [ patchPath ];
                  };
                  mapBuildInputs = pkg:
                    if isKklib pkg
                    then pkg.overrideAttrs overrideKklibAttrs
                    else pkg;
                in
                map mapBuildInputs oldAttrs.buildInputs;
              postInstall =
                let
                  oldKklib = head (filter isKklib oldAttrs.buildInputs);
                  newKklib = head (filter isKklib buildInputs);
                in
                replaceStrings [ oldKklib.dev.outPath ] [ newKklib.dev.outPath ]
                  oldAttrs.postInstall;
            });
        };
    };
  } // utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        overlays = [ self.overlays.koka-int8-box ];
        inherit system;
      };
      inherit (pkgs) clang-tools koka mkShell nodejs;
    in
    {
      devShells.default = mkShell {
        packages = [ clang-tools koka nodejs ];
      };
    });
}
