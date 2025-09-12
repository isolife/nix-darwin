{ config, pkgs, systemSettings, lib, home-manager, ... }:
{
  users.users.${systemSettings.username} = {
    name = "${systemSettings.username}";
    home = "/Users/${systemSettings.username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  imports = [
    ./pkgs.nix
  ];

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./cask.nix {};
    brews = pkgs.callPackage ./brew.nix {};
    masApps = import ./mas.nix;
    #onActivation.cleanup = "uninstall";
    onActivation.upgrade = true;
    onActivation.autoUpdate = true;
  };



  # Import system settings from flake.nix
  # Set your time zone.
  time.timeZone = systemSettings.timeZone;
  nix.settings.trusted-users = [ systemSettings.username ];

  ###################################################################################
  #
  #  macOS's System configuration
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #  Incomplete list of macOS `defaults` commands :
  #    https://github.com/yannbertrand/macos-defaults
  #
  ###################################################################################
  
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
  targets.darwin.defaults."com.apple.Safari".AutoFillPasswords = false;

  system = {
    primaryUser = systemSettings.username;
    stateVersion = 6; # See the note about this option in the README

    defaults = {
      menuExtraClock.Show24Hour = true;  # show 24 hour clock

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true;  # enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0;  # disable beep sound when pressing volume up/down key
        AppleInterfaceStyle = "Dark";  # dark mode
        AppleKeyboardUIMode = 3;  # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = false;  # disable press and hold for keys
        #AppleShowAllExtensions = false; # show all file extensions
        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2; # key repeat rate
        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15; # delay until key repeat
        "com.apple.mouse.tapBehavior" = 1; # enable tap to click
        "com.apple.sound.beep.volume" = 0.0; # disable beep sound
        NSAutomaticSpellingCorrectionEnabled = true;  # disable auto spelling correction
      };

      dock = {
        autohide = true; #auto hide
        show-recents = true; #show recent apps
        launchanim = true; #animate opening apps
        orientation = "left"; #position
        tilesize = 32; #icon size
        largesize = 92; #icon size on hover
        autohide-delay = 0.1; # set dock autohide delay
        autohide-time-modifier = 0.20;  # set dock autohide time modifier
        magnification = true; #enable magnification
        persistent-apps = [
          {
            app = "Applications/Safari.app";
          }
          {
            app = "/System/Applications/Messages.app";
          }
          {
            app = "${pkgs.obsidian}/Applications/Obsidian.app";
          }
          {
            app = "${pkgs.alacritty}/Applications/Alacritty.app";
          }
          {
            app = "/Applications/Spotify.app";
          }
          {
            app = "/System/Applications/Photos.app";
          }
          {
            app = "/Applications/1Password.app";
          }
          {
            app = "/System/Applications/System Settings.app";
          }
        ];
        persistent-others = [
            "/Users/${systemSettings.username}/Downloads"
        ];
      };

      controlcenter = {
        BatteryShowPercentage = true; # show battery percentage
      };

      finder = {
        _FXShowPosixPathInTitle = false; # show full path in title
        AppleShowAllExtensions = false; # show all file extensions
        CreateDesktop = false; # don't show icons on desktop
        FXDefaultSearchScope = "SCcf"; # search current folder by default
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        FXPreferredViewStyle = "clmv"; # use column view by default
        FXRemoveOldTrashItems = true; # empty trash after 30 days
        NewWindowTarget = "Home"; # new finder windows open home folder
      };

      trackpad = {
        Clicking = true; # enable tap to click
        TrackpadThreeFingerDrag = true; # enable three finger drag
        TrackpadRightClick = true; # enable two finger right click
      };

      loginwindow = {
        GuestEnabled = false;  # disable guest user
        SHOWFULLNAME = false;  # show full name in login window
        autoLoginUser = systemSettings.username;  # auto login user
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      # 
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.

      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        # Disable personalized ads
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };

        # Disable auto opening of Image Capture
        "com.apple.ImageCapture" = {
          disableHotPlug = true;
        };
      };
    };
  };
}