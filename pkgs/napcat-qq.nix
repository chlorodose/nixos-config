{
  lib,
  qq,
  fetchFromGitHub,
  buildNpmPackage,
  fetchNpmDeps,
  symlinkJoin,
  webuiPkg ? null,
}:
let
  version = "4.8.95";
  src = fetchFromGitHub {
    owner = "NapNeko";
    repo = "NapCatQQ";
    tag = "v${version}";
    hash = "sha256-GHy+dk1rpxBqerMVH3qN8QNk5yhdDj1yd+IfVcwhTkc=";
  };
  webui =
    if webuiPkg != null then
      webuiPkg
    else
      buildNpmPackage {
        pname = "napcat-qq-webui";
        sourceRoot = "${src.name}/napcat.webui";
        inherit version src;

        npmDepsHash = "sha256-q4cNexCnpBG0TfifvDm6NNkTnp04MXpK/VU6LFx8KjQ=";
        meta = with lib; {
          description = "Web UI for NapCatQQ";
          homepage = "https://napneko.github.io";
          license = licenses.unfree;
        };
      };
in
buildNpmPackage {
  pname = "napcat-qq";
  inherit version src;

  buildInputs = [ webui ];
  npmBuildScript = "build:shell";
  npmDepsHash = "sha256-rWygfIPK0ulM9GciwFtTMNFFSFiwQnDH+WNeb+4c4DE=";
  meta = with lib; {
    description = "Modern protocol-side framework based on NTQQ";
    homepage = "https://napneko.github.io";
    license = licenses.unfree;
  };
}
