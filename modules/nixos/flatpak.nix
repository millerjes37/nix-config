{ pkgs, ... }:

{
  # Enable the Flatpak service and list packages to install
  services.flatpak = {
    enable = true;
    packages = [
      # Add Zen Browser using its Flathub application ID directly.
      # This is the recommended way.
      "app.zen_browser.zen"
    ];
  };
}