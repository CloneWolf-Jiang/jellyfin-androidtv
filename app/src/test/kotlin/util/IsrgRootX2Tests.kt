package org.jellyfin.androidtv.util

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import java.io.File
import java.security.MessageDigest
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate

/**
 * Verifies the bundled ISRG Root X2 certificate (res/raw/isrg_root_x2.pem) is the official one.
 * The certificate is only added as an extra trust anchor in network_security_config.xml, no
 * verification (chain, expiry, hostname) is disabled.
 */
class IsrgRootX2Tests : FunSpec({
	val officialSha256 = "69729B8E15A86EFC177A57AFB7171DFC64ADD28C2FCA8CF1507E34453CCB1470"

	fun load() = File("src/main/res/raw/isrg_root_x2.pem").inputStream().use {
		CertificateFactory.getInstance("X.509").generateCertificate(it) as X509Certificate
	}

	test("fingerprint matches the official ISRG Root X2") {
		val digest = MessageDigest.getInstance("SHA-256").digest(load().encoded)
		digest.joinToString("") { "%02X".format(it) } shouldBe officialSha256
	}

	test("is a self-signed root with the expected subject") {
		val cert = load()
		cert.subjectX500Principal.name shouldBe cert.issuerX500Principal.name
		cert.subjectX500Principal.name.contains("CN=ISRG Root X2") shouldBe true
		cert.verify(cert.publicKey)
		cert.checkValidity()
	}

	test("network security config references the certificate and keeps system CAs") {
		val config = File("src/main/res/xml/network_security_config.xml").readText()
		config.contains("src=\"@raw/isrg_root_x2\"") shouldBe true
		config.contains("src=\"system\"") shouldBe true
	}
})
