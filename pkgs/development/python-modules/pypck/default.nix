{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pypck";
  version = "0.8.10";
  pyproject = true;

  disabled = pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "alengwenus";
    repo = "pypck";
    tag = version;
    hash = "sha256-0wwFkkIBQiRIdkMHsNHvqf1i5bzBNV7eP8uCWOk89oc=";
  };

  postPatch = ''
    echo "${version}" > VERSION
  '';

  build-system = [ setuptools ];

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
  ];

  pytestFlags = [ "--asyncio-mode=auto" ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [ "test_connection_lost" ];

  __darwinAllowLocalNetworking = true;

  pythonImportsCheck = [ "pypck" ];

  meta = with lib; {
    description = "LCN-PCK library written in Python";
    homepage = "https://github.com/alengwenus/pypck";
    changelog = "https://github.com/alengwenus/pypck/releases/tag/${src.tag}";
    license = licenses.epl20;
    maintainers = with maintainers; [ fab ];
  };
}
