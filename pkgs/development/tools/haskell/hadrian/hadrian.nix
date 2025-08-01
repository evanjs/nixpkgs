# See also ./make-hadria.nix
{
  mkDerivation,
  base,
  bytestring,
  Cabal,
  containers,
  directory,
  extra,
  filepath,
  lib,
  mtl,
  parsec,
  shake,
  text,
  transformers,
  unordered-containers,
  cryptohash-sha256,
  base16-bytestring,
  writeText,
  # Dependencies that are not on Hackage and only used in certain Hadrian versions
  ghc-platform ? null,
  ghc-toolchain ? null,
  # GHC source tree to build hadrian from
  ghcSrc,
  ghcVersion,
  # Customization
  userSettings ? null,
}:

mkDerivation {
  pname = "hadrian";
  version = ghcVersion;
  src = ghcSrc;
  postUnpack = ''
    sourceRoot="$sourceRoot/hadrian"
  '';
  # Overwrite UserSettings.hs with a provided custom one
  postPatch = lib.optionalString (userSettings != null) ''
    install -m644 "${writeText "UserSettings.hs" userSettings}" src/UserSettings.hs
  '';
  configureFlags = [
    # avoid QuickCheck dep which needs shared libs / TH
    "-f-selftest"
    # Building hadrian with -O1 takes quite some time with little benefit.
    # Additionally we need to recompile it on every change of UserSettings.hs.
    # See https://gitlab.haskell.org/ghc/ghc/-/merge_requests/1190
    "-O0"
  ];
  jailbreak =
    # Ignore lower bound on directory. Upstream uses this to avoid a race condition
    # that only seems to affect Windows. We never build GHC natively on Windows.
    # https://gitlab.haskell.org/ghc/ghc/-/issues/24382
    # https://gitlab.haskell.org/ghc/ghc/-/commit/a2c033cf82635c83f3107706634bebee43297b99
    (lib.versionAtLeast ghcVersion "9.6.7" && lib.versionOlder ghcVersion "9.7")
    || (lib.versionAtLeast ghcVersion "9.12" && lib.versionOlder ghcVersion "9.15");
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base
    bytestring
    Cabal
    containers
    directory
    extra
    filepath
    mtl
    parsec
    shake
    text
    transformers
    unordered-containers
  ]
  ++ lib.optionals (lib.versionAtLeast ghcVersion "9.7") [
    cryptohash-sha256
    base16-bytestring
  ]
  ++ lib.optionals (lib.versionAtLeast ghcVersion "9.9") [
    ghc-platform
    ghc-toolchain
  ];
  passthru = {
    # Expose »private« dependencies if any
    inherit ghc-platform ghc-toolchain;
  };
  description = "GHC build system";
  license = lib.licenses.bsd3;
}
