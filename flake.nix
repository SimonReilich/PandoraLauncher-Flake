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
              libxrender
              libxtst
              libx11
              libxcursor
              libxrandr
              libxext
              libxxf86vm
              libxi
              libxinerama
              libxcomposite
              libxdamage
              libxfixes
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
            version = "4.0.0";

            src = pkgs.fetchFromGitHub {
              owner = "Moulberry";
              repo = "PandoraLauncher";
              rev = "v${version}";
              hash = "sha256-8RHYbrt1Tu3Kv+0WdfBtCvin9YBkTM2mbCSl539ri7E=";
            };

            cargoHash = "sha256-FuMR9Dq6Js6xh4lcBcusK8Mb8RxMf5tEC4fJo7cr9iM=";

            nativeBuildInputs = with pkgs; [
              pkg-config
              copyDesktopItems
              libxcb
              libx11
            ];

            buildInputs = with pkgs; [
              openssl
              wayland
              libxkbcommon
              libGL
              vulkan-loader
              libx11
              libxcursor
              libxi
              libxrandr
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
