{
  lib,
  stdenv,
  fetchFromGitea,
  fetchYarnDeps,
  writableTmpDirAsHomeHook,
  fixup-yarn-lock,
  yarn,
  nodejs,
  git,
  python3,
  pkg-config,
  libsass,
  nix-update-script,
  xcbuild,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "admin-fe";
  version = "2.3.0-2-unstable-2024-04-27";

  src = fetchFromGitea {
    domain = "akkoma.dev";
    owner = "AkkomaGang";
    repo = "admin-fe";
    rev = "7e16abcbaab10efa6c2c4589660cf99f820a718d";
    hash = "sha256-W/2Ay2dNeVQk88lgkyTzKwCNw0kLkfI6+Azlbp0oMm4=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-acF+YuWXlMZMipD5+XJS+K9vVFRz3wB2fZqc3Hd0Bjc=";
  };

  nativeBuildInputs = [
    fixup-yarn-lock
    writableTmpDirAsHomeHook
    yarn
    nodejs
    pkg-config
    python3
    git
    libsass
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin xcbuild;

  configurePhase = ''
    runHook preConfigure

    yarn config --offline set yarn-offline-mirror ${lib.escapeShellArg finalAttrs.offlineCache}
    fixup-yarn-lock yarn.lock
    substituteInPlace yarn.lock \
      --replace-fail '"git://github.com/adobe-webplatform/eve.git#eef80ed"' '"https://github.com/adobe-webplatform/eve.git#eef80ed"'

    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules/cross-env

    mkdir -p "$HOME/.node-gyp/${nodejs.version}"
    echo 9 >"$HOME/.node-gyp/${nodejs.version}/installVersion"
    ln -sfv "${nodejs}/include" "$HOME/.node-gyp/${nodejs.version}"
    export npm_config_nodedir=${nodejs}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    pushd node_modules/node-sass
    LIBSASS_EXT=auto yarn run build --offline
    popd

    export NODE_OPTIONS="--openssl-legacy-provider"
    yarn run build:prod --offline

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -R -v dist $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=stable" ];
  };

  meta = {
    description = "Admin interface for Akkoma";
    homepage = "https://akkoma.dev/AkkomaGang/akkoma-fe/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ mvs ];
  };
})
