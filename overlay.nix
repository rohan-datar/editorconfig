# nixpkgs' pkl 0.32.1 no longer builds: the gradle dependency cache shipped with
# the package (pkgs/by-name/pk/pkl/deps.json) has no entry for the
# `org.gradle.kotlin.kotlin-dsl` plugin that the Gradle 9.9.1 bump now asks for,
# so the offline build dies while configuring `build-logic`:
#
#   Plugin [id: 'org.gradle.kotlin.kotlin-dsl', version: '6.7.13'] was not found
#
# cache.nixos.org has no build of that derivation either, so this is broken
# upstream rather than locally. Until nixpkgs' pkl builds again, use the release
# binary Apple publishes per platform: it is the same GraalVM native image the
# from-source derivation would produce. Drop this overlay once `pkgs.pkl` builds.
final: prev:
let
  version = "0.32.1";
  sources = {
    aarch64-darwin = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-aarch64";
      hash = "sha256-Vj61HJogsWo2JUZO10XGde2XUDgfISZyJpag18rB2dM=";
    };
    x86_64-darwin = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-macos-amd64";
      hash = "sha256-W3S5AyNAR5YBRPZvLOvdEtJn2bmOgVXtkdKuXtJ+LR8=";
    };
    x86_64-linux = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-amd64";
      hash = "sha256-MYC2LalcDK0dkE6btsX0qPkDJBPCHlMZS7kf8e5fMhE=";
    };
    aarch64-linux = {
      url = "https://github.com/apple/pkl/releases/download/${version}/pkl-linux-aarch64";
      hash = "sha256-p20t1H2kNaj5EbA0c3P0fH5Z6lT7df+EbSC43xDboFg=";
    };
  };
  source = sources.${final.stdenv.hostPlatform.system};
in
{
  pkl = final.stdenvNoCC.mkDerivation {
    pname = "pkl";
    inherit version;

    src = final.fetchurl { inherit (source) url hash; };

    nativeBuildInputs = [ final.installShellFiles ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 $src $out/bin/pkl

      installShellCompletion --cmd pkl \
        --bash <($out/bin/pkl shell-completion bash) \
        --zsh <($out/bin/pkl shell-completion zsh) \
        --fish <($out/bin/pkl shell-completion fish)

      runHook postInstall
    '';

    meta = {
      description = "Configuration-as-code language with rich validation and tooling";
      homepage = "https://pkl-lang.org";
      license = prev.lib.licenses.asl20;
      platforms = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "pkl";
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  };
}
