{ lib
, stdenv
, cmake
, fetchFromGitHub
, wrapQtAppsHook
, qscintilla
, qtnetworkauth
, qtmultimedia
, qttools
, qtscript
, qtdeclarative
, qtbase
, autogen
, automake
, makeWrapper
, catch2
, nodejs
, libpulseaudio
, openssl
, rsync
, typescript
, breakpad
}:

stdenv.mkDerivation rec {
  pname = "imgbrd-grabber";
  version = "7.6.2";

  src = fetchFromGitHub {
    owner = "Bionus";
    repo = "imgbrd-grabber";
    rev = "v${version}";
    sha256 = "06vgkwpk951fywwfcsw6p3nqsaa7yiaxfi5nrbd6z9y0vifgln90";
    fetchSubmodules = true;
  };

  buildInputs = [
    openssl
    makeWrapper
    libpulseaudio
    typescript
    breakpad
  ];

  nativeBuildInputs = [
    qscintilla
    qtnetworkauth
    qtmultimedia
    qtbase
    qtdeclarative
    qttools
    nodejs
    cmake
    wrapQtAppsHook
  ];

  extraOutputsToLink = [ "doc" ];

  patches = [
    ./variableToString-instantiation.patch
    ./cmake-threads.patch # TODO: remove when upstream fixes gui/CMakeLists.txt
  ];

  postPatch = ''
    # the npm build step only runs typescript
    # run this step directly so it doesn't try and fail to download the unnecessary node_modules, etc.
    substituteInPlace ./sites/CMakeLists.txt --replace "npm install" "npm run build"

    sed "s;\''${BREAKPAD}/src/client/linux;\${breakpad}/lib;" -i ./gui/CMakeLists.txt
    sed "s;\''${BREAKPAD}/src;${breakpad}/include/breakpad;" -i ./gui/CMakeLists.txt
    substituteInPlace ./gui/CMakeLists.txt --replace 'set(BREAKPAD "~/Programmation/google-breakpad")' 'set(BREAKPAD "${breakpad}")'

    # remove the vendored catch2
    rm -rf tests/src/vendor/catch

    # link the catch2 sources from nixpkgs
    ln -sf ${catch2.src} tests/src/vendor/catch
  '';

  postInstall = ''
    # move the binaries to the share/Grabber folder so
    # some relative links can be resolved (e.g. settings.ini)
    mv $out/bin/* $out/share/Grabber/

    cd ../..
    # run the package.sh with $out/share/Grabber as the $APP_DIR
    sh ./scripts/package.sh $out/share/Grabber

    # add symlinks for the binaries to $out/bin
    ln -s $out/share/Grabber/Grabber $out/bin/Grabber
    ln -s $out/share/Grabber/Grabber-cli $out/bin/Grabber-cli
  '';

  sourceRoot = "source/src";

  meta = with lib; {
    description = "Very customizable imageboard/booru downloader with powerful filenaming features";
    license = licenses.asl20;
    homepage = "https://bionus.github.io/imgbrd-grabber/";
    maintainers = with maintainers; [ evanjs interruptinuse ];
  };
}
