{
  pkgs,
  lib,
  ...
}: (pkgs.rustPlatform.buildRustPackage rec {
  pname = "swayosd";
  version = "5c2176ae6a01a18fdc2b0f5d5f593737b5765914";

  src = pkgs.fetchFromGitHub {
    owner = "ErikReider";
    repo = pname;
    rev = version;
    hash = "sha256-rh42J6LWgNPOWYLaIwocU1JtQnA5P1jocN3ywVOfYoc=";
  };

  cargoSha256 = "f/MaNADm/jkEqofd5ixQBcsPr3mjt4qTMRrr0A0J5sI=";

  nativeBuildInputs = with pkgs; [pkg-config];
  buildInputs = with pkgs; [
    glib
    atk
    gtk3
    gtk-layer-shell
    pulseaudio
  ];

  meta = with lib; {
    description = "A GTK based on screen display for keyboard shortcuts like caps-lock and volume";
    homepage = "https://github.com/ErikReider/SwayOSD";
    license = licenses.gpl3;
  };
})
