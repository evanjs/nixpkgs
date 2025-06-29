_handleCmdOutput(){
    local command=("$1" "$2")
    local versionOutput

    local envArgs=()
    if [[ "$3" != "*" ]]; then
      envArgs+=("--ignore-environment")
      for var in $3; do
        envArgs+=("$var=${!var}")
      done
    fi

    versionOutput="$(env \
        --chdir=/ \
        --argv0="$(basename "${command[0]}")" \
        "${envArgs[@]}" \
        "${command[@]}" 2>&1 \
        | sed -e 's|@storeDir@/[^/ ]*/|{{storeDir}}/|g' \
        || true)"
    if [[ "$versionOutput" =~ "$version" ]]; then
        echoPrefix="Successfully managed to"
    else
        echoPrefix="Did not"
    fi
    # The return value of this function is this variable:
    echo "$echoPrefix"
    # And in anycase we want these to be printed in the build log, useful for
    # debugging, so we print these to stderr.
    echo "$echoPrefix" find version "$version" in the output of the command \
        "${command[@]}" >&2
    echo "$versionOutput" >&2
}
versionCheckHook(){
    runHook preVersionCheck
    echo Executing versionCheckPhase

    # Don't keep any environment variables by default
    : "${versionCheckKeepEnvironment:=}"

    local cmdProgram cmdArg echoPrefix
    if [[ -z "${versionCheckProgram-}" ]]; then
        if [[ -z "${pname-}" ]]; then
            echo "both \$pname and \$versionCheckProgram are empty, so" \
                "we don't know which program to run the versionCheckPhase" \
                "upon" >&2
            exit 2
        else
            cmdProgram="${!outputBin}/bin/$pname"
        fi
    else
        cmdProgram="$versionCheckProgram"
    fi
    if [[ ! -x "$cmdProgram" ]]; then
        echo "versionCheckHook: $cmdProgram was not found, or is not an executable" >&2
        exit 2
    fi
    if [[ -z "${versionCheckProgramArg}" ]]; then
        for cmdArg in "--help" "--version"; do
            echoPrefix="$(_handleCmdOutput "$cmdProgram" "$cmdArg" "$versionCheckKeepEnvironment")"
            if [[ "$echoPrefix" == "Successfully managed to" ]]; then
                break
            fi
        done
    else
        cmdArg="$versionCheckProgramArg"
        echoPrefix="$(_handleCmdOutput "$cmdProgram" "$cmdArg" "$versionCheckKeepEnvironment")"
    fi
    if [[ "$echoPrefix" == "Did not" ]]; then
        exit 2
    fi

    runHook postVersionCheck
    echo Finished versionCheckPhase
}

if [[ -z "${dontVersionCheck-}" ]]; then
    echo "Using versionCheckHook"
    preInstallCheckHooks+=(versionCheckHook)
fi
