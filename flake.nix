{
  description = "Flake to build PandoraLauncher with a contained FHS environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          minecraftLibs =
            pkgs: with pkgs; [
              stdenv.cc.cc
              zlib
              libuuid
              at-spi2-atk
              mesa
              vulkan-loader
              libGL
              flite
              libpulseaudio
              alsa-lib
              libogg
              libvorbis
              libopus
              openssl
              curl
              expat
              nss
              icu
              fuse3
              glib
              libudev0-shim
              wayland
              libxkbcommon
              pciutils
              libXrender
              libXtst
              libX11
              libXcursor
              libXrandr
              libXext
              libXxf86vm
              libXi
              libXinerama
              libXcomposite
              libXdamage
              libXfixes
              libxcb
              flac
              freeglut
              libjpeg
              libpng
              libsamplerate
              libmikmod
              libtheora
              libtiff
              pixman
              speex
              SDL2
            ];

          pandora-bin = pkgs.rustPlatform.buildRustPackage rec {
            pname = "pandora-launcher-base";
            version = "3.2.1";

            src = pkgs.fetchFromGitHub {
              owner = "Moulberry";
              repo = "PandoraLauncher";
              rev = "v${version}";
              hash = "sha256-elPKbnnjrNakZhCl34qz7bW5PEkjSKs3v1IaZEVB64w=";
            };

            cargoHash = "sha256-jxJXEgZbLIcZizokJhaTcEfGt+KHclbQ+uZVdEF+hnQ=";

            nativeBuildInputs = with pkgs; [
              pkg-config
              copyDesktopItems
              libxcb
              libX11
            ];

            buildInputs = with pkgs; [
              openssl
              wayland
              libxkbcommon
              libGL
              vulkan-loader
              libX11
              libXcursor
              libXi
              libXrandr
              libxcb
              dbus
            ];

            desktopItems = [
              (pkgs.makeDesktopItem {
                name = "pandora";
                exec = "pandora_launcher";
                icon = "pandora";
                desktopName = "Pandora Launcher";
                genericName = "Minecraft Launcher";
                categories = [ "Game" ];
              })
            ];

            postInstall = ''
              install -Dm644 assets/icons/pandora.svg $out/share/icons/hicolor/256x256/apps/pandora.svg
            '';
          };

          pandora-fhs = pkgs.buildFHSEnv {
            name = "pandora_launcher";
            targetPkgs = minecraftLibs;
            runScript = "${pandora-bin}/bin/pandora_launcher";
          };

        in
        {
          default = pkgs.symlinkJoin {
            name = "pandora-launcher";
            paths = [
              pandora-fhs
              pandora-bin
            ];

            meta = with pkgs.lib; {
              description = "Modern Minecraft launcher (FHS Wrapped)";
              homepage = "https://github.com/Moulberry/PandoraLauncher";
              license = licenses.mit;
              mainProgram = "pandora_launcher";
            };
          };
        }
      );
    };
}
