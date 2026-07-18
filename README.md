# Roc Nix Nightly

[![Update Roc nightly](https://github.com/jaredramirez/roc-nix-nightly/actions/workflows/update-roc-nightly.yml/badge.svg)](https://github.com/jaredramirez/roc-nix-nightly/actions/workflows/update-roc-nightly.yml)

A Nix flake that packages the latest supported [Roc nightly](https://github.com/roc-lang/nightlies) compiler binaries.

## Usage

Run Roc directly:

```sh
nix run github:jaredramirez/roc-nix-nightly -- --version
```

Or enter a development shell with `roc` available:

```sh
nix develop github:jaredramirez/roc-nix-nightly
roc --version
```

To use the package from another flake:

```nix
{
  inputs.roc-nightly.url = "github:jaredramirez/roc-nix-nightly";

  outputs =
    { nixpkgs, roc-nightly, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ roc-nightly.packages.${system}.roc ];
      };
    };
}
```

## Supported systems

- `aarch64-darwin`
- `aarch64-linux`
- `x86_64-linux`

## Nightly updates

The [update workflow](.github/workflows/update-roc-nightly.yml) runs every night at 04:17 UTC and can also be started manually. When Roc publishes a new nightly, it:

1. Finds the latest release from `roc-lang/nightlies`.
2. Prefetches each supported archive and calculates its Nix hash.
3. Updates the release metadata in `flake.nix`.
4. Evaluates the flake for every supported system.
5. Commits the update as `github-actions[bot]`.
