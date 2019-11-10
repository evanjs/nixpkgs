
{ stdenv, libXcomposite, libgnome-keyring, udev, curl, alsaLib
, libXfixes, atk, gtk3, libXrender, pango, gnome3, cairo, freetype, fontconfig
, libX11, libXi, libxcb, libXext, libXcursor, glib, libXScrnSaver, libxkbfile, libXtst
, nss, nspr, cups, fetchurl, fetchzip, expat, gdk-pixbuf, libXdamage, libXrandr, dbus
, dpkg, makeDesktopItem, openssl, wrapGAppsHook, at-spi2-atk, libuuid
, e2fsprogs, krb5
, Security, libiconv
, enableSystemd ? stdenv.isLinux && !stdenv.hostPlatform.isMusl
}:

with stdenv.lib;

let
  version = "6.3.1";

  sources = let
    base = "https://release.axocdn.com";
  in {
    x86_64-linux = fetchurl {
      url = "${base}/linux/GitKraken-v${version}.tar.gz";
      sha256 = "1p1z93w8x84slnv02cp4nhxg00fsz5g6sa29sycbmqqa7znsqyjh";
    };
    x86_64-darwin = fetchzip {
      url = "${base}/darwin/GitKraken-v${version}.zip";
      sha256 = "0b5fsdrgqrbcz3mkwi1i4a9siir4v30ndbcx097437fp9dwxrzzm";
    };
  };

  curlWithGnuTls = curl.override { gnutlsSupport = true; sslSupport = false; };
in
stdenv.mkDerivation rec {
  pname = "gitkraken";
  inherit version;

  src = sources.${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  buildInputs = [ ]
    ++ optionals enableSystemd [ dbus udev ]
    ++ optionals stdenv.isDarwin [ Security libiconv ]
    ++ optionals stdenv.isLinux [ 
      alsaLib
      at-spi2-atk
      atk
      cairo
      cups
      curlWithGnuTls
      e2fsprogs
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gnome3.adwaita-icon-theme
      gtk3
      krb5
      libX11
      libXScrnSaver
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXtst
      libgnome-keyring
      libuuid
      libxcb
      libxkbfile
      nspr
      nss
      openssl
      pango
      stdenv.cc.cc.lib
  ];


  desktopItem = makeDesktopItem {
    name = "gitkraken";
    exec = "gitkraken";
    icon = "gitkraken";
    desktopName = "GitKraken";
    genericName = "Git Client";
    categories = "Application;Development;";
    comment = "Graphical Git client from Axosoft";
  };

  nativeBuildInputs = [ wrapGAppsHook ];

  installPhase = if stdenv.isDarwin
    then ''
      runHook preInstall
      mkdir -p $out/bin/GitKraken.app
      ls
      cp -rav Contents $out/bin/Gitkraken.app/
      runHook postInstall
    ''
    else ''
      runHook preInstall
      mkdir $out
      pushd usr
      pushd share
      substituteInPlace applications/gitkraken.desktop \
        --replace /usr/share/gitkraken $out/bin
      popd
      rm -rf bin/gitkraken share/lintian
      cp -av share bin $out/
      popd

      ln -s $out/share/gitkraken/gitkraken $out/bin/gitkraken
      runHook postInstall
  '';

  postFixup = if stdenv.isLinux then ''
    pushd $out/share/gitkraken
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" gitkraken

    for file in $(find . -type f \( -name \*.node -o -name gitkraken -o -name \*.so\* \) ); do
      patchelf --set-rpath "${stdenv.lib.makeLibraryPath buildInputs}:$ORIGIN $file
    done
    popd
  '' else ''
'';

  meta = {
    homepage = https://www.gitkraken.com/;
    description = "The downright luxurious and most popular Git client for Windows, Mac & Linux";
    license = licenses.unfree;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ xnwdd evanjs ];
  };
}
