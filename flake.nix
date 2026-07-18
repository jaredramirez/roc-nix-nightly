{
  description = "Roc nightly compiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      rocRelease = {
        versionDate = "2026-07-15";
        buildId = "c2d30e8";
        baseUrl = "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-July-15-c2d30e8";
        archives = {
          aarch64-darwin = {
            platform = "macos_apple_silicon";
            hash = "sha256-zayFDXAedaauJt/4bUnm4P5DD7B+6YktE+Y1acUbgWI=";
          };
          aarch64-linux = {
            platform = "linux_arm64";
            hash = "sha256-KUpGfbS3RlizAb9zcdOOC63cS2Ol13O7+VQP5PhQvRk=";
          };
          x86_64-linux = {
            platform = "linux_x86_64";
            hash = "sha256-KOCGnvjFCGwkiU9uQr95J2UUInNuBgLXIVLb3CDPHqY=";
          };
        };
      };

      mkRoc =
        pkgs: system:
        let
          archive = rocRelease.archives.${system};
          archiveName = "roc_nightly-${archive.platform}-${rocRelease.versionDate}-${rocRelease.buildId}";
        in
        pkgs.stdenvNoCC.mkDerivation {
          pname = "roc";
          version = "${rocRelease.versionDate}-${rocRelease.buildId}";

          src = pkgs.fetchurl {
            url = "${rocRelease.baseUrl}/${archiveName}.tar.gz";
            inherit (archive) hash;
          };
          sourceRoot = archiveName;

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            install -Dm755 roc "$out/bin/roc"
            install -Dm644 LICENSE legal_details -t "$out/share/licenses/roc"

            runHook postInstall
          '';

          meta = {
            description = "Roc programming language compiler";
            homepage = "https://roc-lang.org";
            mainProgram = "roc";
            platforms = systems;
          };
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        rec {
          roc = mkRoc pkgs system;
          default = roc;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.roc ];
          };
        }
      );
    };
}
