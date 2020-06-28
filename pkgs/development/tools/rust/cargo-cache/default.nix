{ stdenv, lib, rustPlatform, rust, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "cargo-cache";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "matthiaskrgr";
    repo = pname;
    rev = "${version}";
    sha256 = "0xhm7jlqq9nl1r8plx51x7aisza665f28d9h649b62904mx2ad7k";
  };

  cargoSha256 = "09vsalxh07bk1d48iyl0ncyzsscxlnf0dn96a2vbb1lin2qa2axm";

  # Some tests fail due the target directory not being under target/debug or target/release
  # These tests currently fail:
  #   library::libtests::test_CargoCachePaths_paths \
  #   library::libtests::test_CargoCachePaths_print
  # Disable tests until this is addressed upstream, or a better solution is found
  # See https://github.com/matthiaskrgr/cargo-cache/issues/84 for more information
  #
  # Note: do we need to give the "offline_tests" flag once we do enable tests?
  doCheck = false;

  meta = with lib; {
    description = "manage cargo cache (\${CARGO_HOME}, ~/.cargo/), print sizes of dirs and remove dirs selectively";
    homepage = "https://github.com/matthiaskrgr/cargo-cache";
    license = with licenses; [ asl20 /* or */ mit];
    platforms = platforms.all;
    maintainers = with maintainers; [ evanjs ];
  };
}
