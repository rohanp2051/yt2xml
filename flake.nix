{
  description = "yt2xml - Fetch video transcripts via yt-dlp, output clean XML";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    forAllSystems = fn:
      nixpkgs.lib.genAttrs [
        "x86_64-linux" "aarch64-linux"
        "x86_64-darwin" "aarch64-darwin"
      ] (system: fn nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: {
      default = pkgs.writeShellApplication {
        name = "yt2xml";
        runtimeInputs = with pkgs; [ yt-dlp gawk coreutils gnugrep ];
        bashOptions = [];
        text = builtins.readFile ./yt2xml;
        meta = {
          description = "Fetch video transcripts via yt-dlp, output clean XML";
          license = pkgs.lib.licenses.gpl3Only;
          platforms = pkgs.lib.platforms.unix;
          mainProgram = "yt2xml";
        };
      };
    });
  };
}
