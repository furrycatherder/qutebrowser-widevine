self: super:

{
  qutebrowser = super.runCommand "qutebrowser-widevine" {
    buildInputs = with super; [ makeWrapper ];
  } ''
    makeWrapper ${super.qutebrowser}/bin/qutebrowser $out/bin/qutebrowser --add-flags \
      "--set qt.args [ppapi-widevine-path="${self.widevine}/usr/lib/qt/plugins/ppapi/libwidevinecdmadapter.so"]"
  '';

  widevine = super.callPackage ./widevine.nix {};
}

