{ stdenv
, fetchFromGitHub
, pythonOlder
, pythonPackages
, buildPythonPackage
, writeTextFile
, libcaca
}:
buildPythonPackage rec {
  pname = "sclack";
  version = "unstable-2020-09-23";
  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "haskellcamargo";
    repo = "sclack";
    rev = "89838551f314dc9fd754923b9afad1b7660740c0";
    sha256 = "1f2y6pfi9xb0z0d4lrbq7i3lmdjd7q8kxkkbagql0dql1wrhd51z";
  };

  propagatedBuildInputs = with pythonPackages; [
    libcaca
    pyperclip
    requests
    slackclient
    urwid
    urwid-readline
  ];

  patchPhase = ''
    substituteInPlace app.py --replace "'./config.json'" "'$out/bin/config.json'"
    substituteInPlace setup.py --replace  "'asyncio'," ' '
  '';

  postInstall = ''
    mv $out/bin/app.py $out/bin/sclack
    cp config.json $out/bin/
  '';


  meta = with stdenv.lib; {
    description = "The best CLI client for Slack, because everything is terrible!";
    license = licenses.gpl3;
    platforms = platforms.all;
    homepage = https://github.com/haskellcamargo/sclack/;
    maintainers = with maintainers; [ evanjs ];
  };
}
