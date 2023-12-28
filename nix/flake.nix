{
  description = "koka-base64";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: {
    # TODO: Remove overlay once these changes are upstreamed.
    overlays.koka-int-updates = final: prev: {
      koka = prev.koka.overrideAttrs (oldAttrs:
        let
          isKklib = pkg: pkg != null && final.lib.getName pkg == "kklib";
          oldVersion = oldAttrs.version;
          inherit (builtins) filter head replaceStrings;
        in
        rec {
          version = "2.4.3";
          src = final.fetchFromGitHub {
            owner = "TimWhiting";
            repo = "koka";
            rev = "d6349537aa7c36dd0c1ca0105ef6eefc1abc03d6";
            sha256 = "zvZwstoew2sDZfiYrNhIR6Gkb3Z1xRc0RD8+oam7XII=";
            fetchSubmodules = true;
          };
          buildInputs =
            let
              overrideKklibAttrs = oldAttrs: {
                inherit version;
                src = "${src}/kklib";
                postInstall = replaceStrings [ oldVersion ] [ version ]
                  oldAttrs.postInstall;
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
            replaceStrings [ oldKklib.dev.outPath oldVersion ]
              [ newKklib.dev.outPath version ]
              oldAttrs.postInstall;
        });
    };
  } // utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        overlays = [ self.overlays.koka-int-updates ];
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
