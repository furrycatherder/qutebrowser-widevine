{ stdenv, lib, pkgs }:

let
  version = "18.0.0.233";

  mkrpath = p: "${lib.makeSearchPathOutput "lib" "lib64" p}:${lib.makeLibraryPath p}";
in
  stdenv.mkDerivation {
    name = "widevine-${version}";

    src = builtins.fetchurl {
      url = "http://li.nux.ro/download/nux/dextop/el7/x86_64/chromium-widevinecdm-plugin-${version}-1.el7.nux.x86_64.rpm";
      sha256 = "0v33fnv9iaiqy9rgjryi6k663qnspis4qcmaz8xkdn204da6jg60";
    };

    nativeBuildInputs = with pkgs; [ busybox patchelfUnstable ];

    phases = [ "unpackPhase" "patchPhase" "installPhase" "checkPhase" ];

    unpackPhase = ''
      rpm2cpio $src | cpio -i -d
    '';

    PATCH_RPATH = mkrpath (with pkgs; [ stdenv.cc.cc glib nspr nss ]);

    patchPhase = ''
      patchelf --set-rpath "$PATCH_RPATH" usr/lib64/chromium/libwidevinecdm.so
      patchelf --set-rpath "$out/usr/lib/qt/plugins/ppapi:$PATCH_RPATH" usr/lib64/chromium/libwidevinecdmadapter.so
    '';


    installPhase = ''
      install -Dm755 usr/lib64/chromium/libwidevinecdm.so -t "$out/usr/lib/qt/plugins/ppapi/"
      install -Dm755 usr/lib64/chromium/libwidevinecdmadapter.so -t "$out/usr/lib/qt/plugins/ppapi/"
    '';

    doCheck = true;
    checkPhase = ''
      ! find -iname '*.so' -exec ldd {} + | grep 'not found'
    '';
  }
