# {pkgs, lib, ...}:

# with pkgs;
# let shared-packages = import ../shared/pkgs.nix { inherit pkgs; }; in
# shared-packages ++ [
#   # Utility
#   betterdisplay
# ]
{ pkgs, lib, ... }:

let
  shared-packages = import ../shared/pkgs.nix { inherit pkgs; };
in
{
  config = {
    environment.systemPackages = shared-packages ++ [
      # Utility
      pkgs.betterdisplay
      pkgs.rectangle
      pkgs.oh-my-posh
      pkgs.tailscale
    ];
  };
}
