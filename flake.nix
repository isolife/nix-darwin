{
  description = "Starter Configuration for MacOS";

  outputs = inputs@{ self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, disko, ...}:
  let
    # ---- SYSTEM SETTINGS ---- #
    systemSettings = {
      timeZone = "Europe/Oslo"; # system time zone
      username = "iso"; # username
      name = "Vetle"; # name/identifier
      email = "vetle.olstad@gmail.com"; # email (used for certain configurations)
      dotfilesDir = "~/dotfiles"; # absolute path of the local repo
    };

    # ----- CONFIGURATIONS ----- #

    #############
    #---MACOS---#
    #############
    macos = { pkgs, ... }: {
      #Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      #homebrew.enable = true;

      # Imports for MacOS configuration
      imports = [
        ({...}: { _module.args.systemSettings = systemSettings; })
        ./shared
        ./darwin
      ];
    };
  in
  {
    # ----- HOSTS ----- #
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MacOS
    # $ sudo darwin-rebuild switch --flake .#MacOS
    darwinConfigurations."MacOS" = darwin.lib.darwinSystem {
      modules = [
        # macOS configuration module
        macos
        # Homebrew setup
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = systemSettings.username;

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            # Optional: Enable fully-declarative tap management
            mutableTaps = false;
          };
        }
        # Optional: Align homebrew taps config with nix-homebrew
        ({config, ...}: {
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
        # Imports for MacOS configuration
        ./shared
        ./darwin
      ];
    };
  };

  # ----- INPUTS ----- #
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
