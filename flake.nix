{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      # System types to support.
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

      getErlangLibs = erlangPkg: 
        let
            erlangPath = "${erlangPkg}/lib/erlang/lib/";
            dirs = builtins.attrNames (builtins.readDir erlangPath);
            interfaceVersion = builtins.head (builtins.filter (s: builtins.substring 0 13 s == "erl_interface") dirs);
            interfacePath = erlangPath + interfaceVersion;
        in
        {
            path = erlangPath;
            dirs = dirs;
            interface = { version = interfaceVersion; path = interfacePath; };
        };

      getElixirLibs = elixirLsPkg: 
        let
            elixirLsPath = "${elixirLsPkg}/bin";
            launcher = "${elixirLsPath}/elixir-ls";
        in
        {
            path = elixirLsPath;
            launcher = launcher;
        };

      mkEnvVars = pkgs: erlangLatest: erlangLibs: raylib: {
        LOCALE_ARCHIVE = pkgs.lib.optionalString pkgs.stdenv.isLinux "${pkgs.glibcLocales}/lib/locale/locale-archive";
        LANG = "en_US.UTF-8";
        # https://www.erlang.org/doc/man/kernel_app.html
        ERL_AFLAGS = "-kernel shell_history enabled";
        ERL_INCLUDE_PATH = "${erlangLatest}/lib/erlang/usr/include";
        ERLANG_INTERFACE_PATH = "${erlangLibs.interface.path}";
        ERLANG_PATH = "${erlangLatest}";
      };

      mkElixirEnvVars = pkgs: elixirLibs: {
        LOCALE_ARCHIVE = pkgs.lib.optionalString pkgs.stdenv.isLinux "${pkgs.glibcLocales}/lib/locale/locale-archive";
        LANG = "en_US.UTF-8";
        # Language Server
        ELIXIR_LS_PATH = elixirLibs.launcher;
      };
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor."${system}";

          # Erlang shit
          erlangLatest = pkgs.erlang_26;
          erlangLibs = getErlangLibs erlangLatest;

          # Elixir
          elixirLibs = getElixirLibs pkgs.elixir-ls;

          # F#
          dotnet_8 = with pkgs.dotnetCorePackages; combinePackages [
            sdk_8_0
          ];

        in
        {
          # `nix develop .#ci`
          # reduce the number of packages to the bare minimum needed for CI
          ci = pkgs.mkShell {
            env = mkEnvVars pkgs erlangLatest erlangLibs;
            buildInputs = with pkgs; [ erlangLatest just rebar3 ];
          };

          # Erlang Environment
          # `nix develop .#erlang`
          erlang = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, lib, ... }: {
                packages = with pkgs; [
                  erlang-ls
                  erlfmt
                  rebar3
                  exercism
                ];

                languages.erlang = {
                  enable = true;
                  package = erlangLatest;
                };

                env = mkEnvVars pkgs erlangLatest erlangLibs;

                enterShell = ''
                  echo "Starting Erlang environment..."
                  exercism version
                '';
              })
            ];
          };

          # Elixir Environment
          # `nix develop .#elixir`
          elixir = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, lib, ... }: {
                packages = with pkgs; [
                  elixir-ls
                  exercism
                ];

                languages.elixir = {
                  enable = true;
                  package = pkgs.elixir_1_17;
                };

                env = mkElixirEnvVars pkgs elixirLibs;

                enterShell = ''
                  echo "Starting Elixir environment..."
                  exercism version
                '';
              })
            ];
          };

          # F# Environment
          # `nix develop .#fsharp`
          fsharp = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, lib, ... }: {
                packages = with pkgs; [
                  exercism

                  # .Net
                  icu
                  netcoredbg
                  fsautocomplete
                  fantomas
                ];

                languages.dotnet = {
                  enable = true;
                  package = dotnet_8;
                };

                enterShell = ''
                  echo "Starting F# environment..."
                  exercism version
                '';
              })
            ];
          };

          # Gleam Environment
          # `nix develop .#gleam`
          gleam = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, lib, ... }: {
                packages = with pkgs; [
                  exercism
                ];

                languages.gleam = {
                  enable = true;
                };

                enterShell = ''
                  echo "Starting Gleam environment..."
                  exercism version
                '';
              })
            ];
          };

          # Haskell Environment
          # `nix develop .#haskell`
          haskell = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, lib, ... }: {
                packages = with pkgs; [
                  exercism
                ];

                languages.haskell = {
                  enable = true;
                };

                enterShell = ''
                  echo "Starting Haskell environment..."
                  exercism version
                '';
              })
            ];
          };


        });
    };
}
