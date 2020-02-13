{ stdenv, lib, fetchFromGitHub, kernel }:

with lib;

let modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtlwifi/rtl8188eu";

in stdenv.mkDerivation rec {
  name = "rtl8188eu-${kernel.version}-${version}";
  version = "4.1.8_9499";

  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtl8188eu";
    rev = "v${version}";
    sha256 = "1bxpd1kan37zsdfwj9fb7fcpzxwyzynxqkcmcp3sflkq5gbgcgg5";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [ "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace Makefile --replace 'all: test modules' 'all: modules'
  '';

  installPhase = ''
    mkdir -p ${modDestDir}
    find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
    find ${modDestDir} -name '*.ko' -exec xz -f {} \;
  '';

  meta = {
    description = "Realtek rtl8188eu driver";
    homepage = https://github.com/lwfinger/rtl8188eu;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with maintainers; [ evanjs ];
  };
}
