{
  lib,
  ocaml,
  version ?
    if lib.versionAtLeast ocaml.version "5.2" then
      "1.3"
    else if lib.versionAtLeast ocaml.version "5.1" then
      "1.2"
    else
      "0.12",
  buildDunePackage,
  bigstringaf,
  cstruct,
  domain-local-await,
  fetchurl,
  fmt,
  hmap,
  lwt-dllist,
  mtime,
  optint,
  psq,
  alcotest,
  crowbar,
  mdx,
}:

let
  param =
    {
      "0.12" = {
        minimalOCamlVersion = "5.0";
        hash = "sha256-2EhHzoX/t4ZBSWrSS+PGq1zCxohc7a1q4lfsrFnZJqA=";
      };
      "1.2" = {
        minimalOCamlVersion = "5.1";
        hash = "sha256-N5LpEr2NSUuy449zCBgl5NISsZcM8sHxspZsqp/WvEA=";
      };
      "1.3" = {
        minimalOCamlVersion = "5.2";
        hash = "sha256-jtXBPmaJ8xyF3KXxJ2LYS4zABCp7B9PkZN9utLcrPfw=";
      };
    }
    ."${version}";
in
buildDunePackage rec {
  pname = "eio";
  inherit version;
  inherit (param) minimalOCamlVersion;

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/${pname}/releases/download/v${version}/${pname}-${version}.tbz";
    inherit (param) hash;
  };

  propagatedBuildInputs = [
    bigstringaf
    cstruct
    domain-local-await
    fmt
    hmap
    lwt-dllist
    mtime
    optint
    psq
  ];

  checkInputs = [
    alcotest
    crowbar
    mdx
  ];

  nativeCheckInputs = [
    mdx.bin
  ];

  meta = {
    homepage = "https://github.com/ocaml-multicore/${pname}";
    changelog = "https://github.com/ocaml-multicore/${pname}/raw/v${version}/CHANGES.md";
    description = "Effects-Based Parallel IO for OCaml";
    license = with lib.licenses; [ isc ];
    maintainers = with lib.maintainers; [ toastal ];
  };
}
