{ stdenv, lib, fetchzip, kernel, unzip, bc }:

with lib;

let modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtl8188eu";

in stdenv.mkDerivation rec {
  name = "rtl8188eu-${kernel.version}-${version}";
  version = "2018-05-21-unstable";

  src = fetchzip {
    url = https://static.tp-link.com/2018/201805/20180521/TP-Link_Driver_Linux_series7_beta.zip;
    sha256 = "1r2bf08cjmldpsxdir42jndrifjzarmq1fp2cnzd9ja6r6s27rxr";
    stripRoot = false;
  };

  hardeningDisable = [ "pic" ];

  buildInputs = [ unzip bc ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [ "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  enableParallelBuilding = true;

  postUnpack = ''
    unzip $src/rtl8188EUS_linux_v5.2.2.4_25483.20171222.zip
    mv rtl8188EUS_linux_v5.2.2.4_25483.20171222/* source/
  '';

  postPatch = ''
    substituteInPlace core/rtw_debug.c \
      --replace 'RTW_PRINT_SEL(sel, "build time: %s %s\n", __DATE__, __TIME__)' ""
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
