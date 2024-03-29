{ lib
, stdenvNoCC
, fetchFromGitHub
, gitUpdater
, gtk3
, hicolor-icon-theme
, jdupes
, schemeVariants ? []
, colorVariants ? [] # default is blue
}:

let
  pname = "colloid-pastel-icon-theme";

in
lib.checkListOfEnum "${pname}: scheme variants" [ "default" "nord" "dracula" "all" ] schemeVariants
lib.checkListOfEnum "${pname}: color variants" [ "default" "purple" "pink" "red" "orange" "yellow" "green" "teal" "grey" "all" ] colorVariants

stdenvNoCC.mkDerivation rec {
  inherit pname;
  version = "66cda7051f6482006635388e6c4f18c6944f0853";

  src = fetchFromGitHub {
    owner = "SueDonham";
    repo = pname;
    rev = version;
    hash = "sha256-19i43bkcc5a3dkd505hgfnv6fifmidw0a54finriv135wrqibwd7";
  };

  nativeBuildInputs = [
    gtk3
    jdupes
  ];

  propagatedBuildInputs = [
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;

  # These fixup steps are slow and unnecessary for this package.
  # Package may install almost 400 000 small files.
  dontPatchELF = true;
  dontRewriteSymlinks = true;

  postPatch = ''
    patchShebangs install.sh
  '';

  installPhase = ''
    runHook preInstall

    name= ./install.sh \
      ${lib.optionalString (schemeVariants != []) ("--scheme " + builtins.toString schemeVariants)} \
      ${lib.optionalString (colorVariants != []) ("--theme " + builtins.toString colorVariants)} \
      --dest $out/share/icons

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    description = "Colloid Pastel icon theme";
    homepage = "https://github.com/SueDonham/Colloid-pastel-icons";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ starlightsys ];
  };
}
