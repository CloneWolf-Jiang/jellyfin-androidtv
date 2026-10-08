#!/usr/bin/env bash
# Verifies the experimental Android 9 / ISRG Root X2 APK. Usage: verify-android9-x2-apk.sh <apk>
set -euo pipefail

APK="${1:?usage: $0 <apk>}"
EXPECTED_PACKAGE="${EXPECTED_PACKAGE:-org.jellyfin.androidtv.debug}"
# Official ISRG Root X2 SHA-256 fingerprint (https://letsencrypt.org/certificates/)
EXPECTED_SHA256="69729B8E15A86EFC177A57AFB7171DFC64ADD28C2FCA8CF1507E34453CCB1470"

[ -s "$APK" ] || { echo "::error::APK missing: $APK"; exit 1; }

BUILD_TOOLS="$(ls -d "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}}"/build-tools/* | sort -V | tail -n1)"
AAPT2="$BUILD_TOOLS/aapt2"

BADGING="$("$AAPT2" dump badging "$APK")"
echo "$BADGING" | head -n 5

PKG="$(echo "$BADGING" | sed -n "s/^package: name='\([^']*\)'.*/\1/p")"
MIN_SDK="$(echo "$BADGING" | sed -n "s/^minSdkVersion:'\([0-9]*\)'.*/\1/p")"
[ "$PKG" = "$EXPECTED_PACKAGE" ] || { echo "::error::Unexpected package $PKG"; exit 1; }
[ -n "$MIN_SDK" ] && [ "$MIN_SDK" -le 28 ] || { echo "::error::minSdk '$MIN_SDK' must be <= 28"; exit 1; }
echo "Package $PKG, minSdk $MIN_SDK: OK"

# ISRG Root X2 inside the APK (res/raw entry, name may be obfuscated by resource shrinking)
TMP="$(mktemp -d)"
unzip -q "$APK" -d "$TMP"
FOUND=0
while IFS= read -r -d '' f; do
	if FP="$(openssl x509 -in "$f" -noout -fingerprint -sha256 2>/dev/null | cut -d= -f2 | tr -d ':')" \
		&& [ "$FP" = "$EXPECTED_SHA256" ]; then
		FOUND=1
		echo "Found ISRG Root X2 in APK: ${f#"$TMP"/}"
	fi
done < <(find "$TMP/res" -type f -print0)
[ "$FOUND" = 1 ] || { echo "::error::ISRG Root X2 with expected fingerprint not found in APK"; exit 1; }

# Source scan for TLS bypasses
if grep -rnE "HostnameVerifier\s*\{\s*_?\w*,?\s*_?\w*\s*->\s*true|ALLOW_ALL_HOSTNAME_VERIFIER|trustAllCerts|TrustAllCerts|AllowAllHostnameVerifier|override fun checkServerTrusted\(.*\)\s*\{\s*\}" \
	app/src playback/src preference/src --include=*.kt --include=*.java; then
	echo "::error::Possible TLS verification bypass found"; exit 1
fi
# The network security config must keep system CAs and must not be removed
grep -q 'src="system"' app/src/main/res/xml/network_security_config.xml
grep -q '@raw/isrg_root_x2' app/src/main/res/xml/network_security_config.xml
echo "All APK checks passed"
