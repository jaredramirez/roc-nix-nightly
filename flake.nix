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
        versionDate = "2026-08-10";
        buildId = "7df8509";
        baseUrl = "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-08-10-7df8509";
        archives = {
          aarch64-darwin = {
            platform = "macos_apple_silicon";
            hash = "sha256-YvG7Main1wJbKonuKDQlvTvPbTE5ndtSbJuTfM1MV+A=";
          };
          aarch64-linux = {
            platform = "linux_arm64";
            hash = "sha256-FEffP3cLWz3Tin8nFnr681MGon5W91UZUMmdX9TEv6g=";
          };
          x86_64-linux = {
            platform = "linux_x86_64";
            hash = "sha256-BvGa2clPXviE4bfu9gJb/B5+twQsVSeGhYlzGRz+DkM=";
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

            mkdir -p "$out/bin" "$out/libexec/roc"
            cp -R ./. "$out/libexec/roc/"
            chmod 755 "$out/libexec/roc/roc"
            ln -s ../libexec/roc/roc "$out/bin/roc"
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
