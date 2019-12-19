{ lib, buildPythonPackage, fetchPypi
, lxml,  six }:

buildPythonPackage rec {
  version = "2.4.0";
  pname = "translate-toolkit";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0zqy6j1ki3wxjak0vh26ymhi3n6xdann50l66cciwiz16vixlfa0";
  };

  propagatedBuildInputs = [
    lxml
    six
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "http://toolkit.translatehouse.org/";
    license = licenses.gpl2Plus;
    description = "Useful localization tools with Python API for building localization & translation systems";
    maintainers = [ ];
  };
}
