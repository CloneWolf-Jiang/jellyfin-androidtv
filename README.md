<h1 align="center">Jellyfin for Android TV</h1>
<h3 align="center">Part of the <a href="https://jellyfin.org">Jellyfin Project</a></h3>

---

<p align="center">
<img alt="Logo banner" src="https://raw.githubusercontent.com/jellyfin/jellyfin-ux/master/branding/SVG/banner-logo-solid.svg?sanitize=true"/>
<br/><br/>
<a href="https://github.com/jellyfin/jellyfin-androidtv">
<img alt="GPL 2.0 License" src="https://img.shields.io/github/license/jellyfin/jellyfin-androidtv.svg"/>
</a>
<a href="https://github.com/jellyfin/jellyfin-androidtv/releases">
<img alt="Current Release" src="https://img.shields.io/github/release/jellyfin/jellyfin-androidtv.svg"/>
</a>
<a href="https://translate.jellyfin.org/projects/jellyfin-android/jellyfin-androidtv/">
<img alt="Translation Status" src="https://translate.jellyfin.org/widgets/jellyfin-android/-/jellyfin-androidtv/svg-badge.svg"/>
</a>
<br/>
<a href="https://opencollective.com/jellyfin">
<img alt="Donate" src="https://img.shields.io/opencollective/all/jellyfin.svg?label=backers"/>
</a>
<a href="https://features.jellyfin.org">
<img alt="Feature Requests" src="https://img.shields.io/badge/fider-vote%20on%20features-success.svg"/>
</a>
<a href="https://matrix.to/#/+jellyfin:matrix.org">
<img alt="Chat on Matrix" src="https://img.shields.io/matrix/jellyfin:matrix.org.svg?logo=matrix"/>
</a>
<br/>
<a href="https://play.google.com/store/apps/details?id=org.jellyfin.androidtv">
<img width="153" alt="Jellyfin on Google Play" src="https://jellyfin.org/images/store-icons/google-play.png"/>
</a>
<a href="https://www.amazon.com/gp/aw/d/B07TX7Z725">
<img width="153" alt="Jellyfin on Amazon Appstore" src="https://jellyfin.org/images/store-icons/amazon.png"/>
</a>
<a href="https://f-droid.org/en/packages/org.jellyfin.androidtv/">
<img width="153" alt="Jellyfin on F-Droid" src="https://jellyfin.org/images/store-icons/fdroid.png"/>
</a>
<br/>
<a href="https://repo.jellyfin.org/releases/client/androidtv/">Download archive</a>
</p>

Jellyfin for Android TV is a Jellyfin client for Android TV, Nvidia Shield, and Amazon Fire TV devices. We welcome all contributions and pull
requests! If you have a larger feature in mind please open an issue so we can discuss the implementation before you start. 

## Building

The app uses Gradle and requires the Android SDK. We recommend using Android Studio, which includes all required dependencies, for
development and building. For manual building without Android Studio make sure a compatible JDK and Android SDK are installed and in your
PATH, then use the Gradle wrapper (`./gradlew`) to build the project with the `assembleDebug` Gradle task to generate an apk file:

```shell
./gradlew assembleDebug
```

The task will create an APK file in the `/app/build/outputs/apk/debug` directory. This APK file uses a different app-id from our stable
builds and can be manually installed to your device.

## Branching

The `master` branch is the primary development branch and the target for all pull requests. It is **unstable** and may contain breaking
changes or unresolved bugs. For production deployments and forks, always use the latest `release-x.y.z` branch. Do not base production work
or long-lived forks on `master`.

Release branches are created at the start of a beta cycle and are kept up to date with each published release. Maintainers will cherry-pick
selected changes into release branches as needed for backports. These branches are reused for subsequent patch releases.

## Translating

Translations can be improved very easily from our [Weblate](https://translate.jellyfin.org/projects/jellyfin-android/jellyfin-androidtv)
instance. Look through the following graphic to see if your native language could use some work! We cannot accept changes to translation
files via pull requests.

<p align="center">
<a href="https://translate.jellyfin.org/engage/jellyfin-android/">
<img alt="Detailed Translation Status" src="https://translate.jellyfin.org/widgets/jellyfin-android/-/jellyfin-androidtv/multi-auto.svg"/>
</a>
</p>

## Android 9 / ISRG Root X2 Compatibility Test

### English

**Experimental build – not an official Jellyfin release.** This fork adds the *ISRG Root X2* certificate as an explicit, additional trust anchor so Let's Encrypt ECDSA chains (leaf issued by *Let's Encrypt YE2*) can be tested on Android 9 (API 28) devices such as TV projectors.

- Networking stack: the Jellyfin SDK uses **OkHttp** (`OkHttpFactory`, also Coil/Media3), which relies on the Android platform trust manager and therefore on the **Network Security Configuration** (`app/src/main/res/xml/network_security_config.xml`, referenced from `AndroidManifest.xml`).
- Trust anchors: `system` CAs + user CAs (unchanged) + `@raw/isrg_root_x2` (new). No TrustManager / HostnameVerifier is replaced; chain, expiry, signature and hostname/SAN verification stay active.
- minSdk is 23 (≤ 28), so the APK installs on Android 9. The build uses JDK 21 (`.tools-versions`) and Gradle 9.8.0 (wrapper).
- Certificate (`app/src/main/res/raw/isrg_root_x2.pem`, source: https://letsencrypt.org/certificates/ ; copy verified against the official fingerprint):
  - Subject / Issuer: `C=US, O=Internet Security Research Group, CN=ISRG Root X2` (self-signed)
  - Serial: `41:D2:9D:D1:72:EA:EE:A7:80:C1:2C:6C:E9:2F:87:52`
  - SHA-256: `69:72:9B:8E:15:A8:6E:FC:17:7A:57:AF:B7:17:1D:FC:64:AD:D2:8C:2F:CA:8C:F1:50:7E:34:45:3C:CB:14:70`
  - Valid: 2020-09-04 – 2040-09-17
- Test server: `https://nas.jellyfin.test:5002` (leaf `nas.jellyfin.test`, ECDSA, issuer Let's Encrypt YE2).
**Build locally:** `./gradlew :app:testDebugUnitTest :app:assembleDebug -Pjellyfin.version=1.0.0-android9-x2-test` (APK in `app/build/outputs/apk/debug/`, package `org.jellyfin.androidtv.debug`).

**Build with GitHub Actions:** Actions → *App / Android 9 X2 Test Build* → Run workflow. The APK artifact is `jellyfin-androidtv-android9-isrg-root-x2-test.apk`. The workflow runs unit tests and `.github/scripts/verify-android9-x2-apk.sh` (APK parses, minSdk ≤ 28, package name, ISRG Root X2 fingerprint inside the APK, no trust-all patterns).

**Create a release:** `git tag android9-x2-v1.0.0 && git push origin android9-x2-v1.0.0`. The *App / Android 9 X2 Test Release* workflow builds, verifies and publishes the APK to GitHub Releases (only if all checks pass).

**Install:** download the APK from the Release page, then `adb connect <tv-ip>` and `adb install -r jellyfin-androidtv-android9-isrg-root-x2-test.apk` (or use a USB drive / file manager). **Uninstall:** `adb uninstall org.jellyfin.androidtv.debug` or via Settings → Apps.

**TLS verification checks** (manual, on device or with `openssl s_client -verify_hostname nas.jellyfin.test -connect nas.jellyfin.test:5002`):
1. Valid certificate + correct host → must connect.
2. Expired certificate → must fail.
3. Unknown CA → must fail.
4. Certificate for another host (e.g. `example.com`) → must fail.
5. Tampered / invalid certificate → must fail.

Automated unit tests (`IsrgRootX2Tests`) verify the bundled certificate fingerprint and that the config keeps system CAs. Cases 2–5 require test servers and cannot be run automatically in CI here.

**Report results:** open an issue with device model, Android version, the server URL tested, and the outcome of each case above.

### 中文

**实验版本 —— 不是 Jellyfin 官方发行版。** 本 Fork 将 *ISRG Root X2* 作为显式的额外可信根加入应用，用于在 Android 9（API 28）设备（如电视投影仪）上测试 Let's Encrypt ECDSA 证书链（叶子证书由 *Let's Encrypt YE2* 签发）。

- 网络栈：Jellyfin SDK 使用 **OkHttp**（Coil / Media3 同样基于 OkHttp），使用 Android 平台 TrustManager，因此由 **Network Security Configuration**（`app/src/main/res/xml/network_security_config.xml`，在 `AndroidManifest.xml` 中引用）决定信任根。
- 信任根：系统 CA + 用户 CA（保持不变）+ `@raw/isrg_root_x2`（新增）。没有替换任何 TrustManager / HostnameVerifier，证书链、有效期、签名和域名/SAN 验证全部保持开启。
- minSdk 为 23（≤ 28），可安装于 Android 9。构建使用 JDK 21（`.tools-versions`）和 Gradle 9.8.0（wrapper）。
- 证书（`app/src/main/res/raw/isrg_root_x2.pem`，来源 https://letsencrypt.org/certificates/，已与官方指纹核对）：
  - 主体 / 颁发者：`C=US, O=Internet Security Research Group, CN=ISRG Root X2`（自签名）
  - 序列号：`41:D2:9D:D1:72:EA:EE:A7:80:C1:2C:6C:E9:2F:87:52`
  - SHA-256：`69:72:9B:8E:15:A8:6E:FC:17:7A:57:AF:B7:17:1D:FC:64:AD:D2:8C:2F:CA:8C:F1:50:7E:34:45:3C:CB:14:70`
  - 有效期：2020-09-04 至 2040-09-17
- 测试服务器：`https://nas.jellyfin.test:5002`（叶子证书 `nas.jellyfin.test`，ECDSA，签发者 Let's Encrypt YE2）。

**本地编译：** `./gradlew :app:testDebugUnitTest :app:assembleDebug -Pjellyfin.version=1.0.0-android9-x2-test`（APK 位于 `app/build/outputs/apk/debug/`，包名 `org.jellyfin.androidtv.debug`）。

**通过 GitHub Actions 编译：** Actions → *App / Android 9 X2 Test Build* → Run workflow。产物为 `jellyfin-androidtv-android9-isrg-root-x2-test.apk`。流程会运行单元测试和 `.github/scripts/verify-android9-x2-apk.sh`（APK 可解析、minSdk ≤ 28、包名、APK 内 ISRG Root X2 指纹、无 trust-all 代码）。

**创建 Release：** `git tag android9-x2-v1.0.0 && git push origin android9-x2-v1.0.0`，*App / Android 9 X2 Test Release* 工作流会构建、检查并发布 APK（任何检查失败则不发布）。

**下载与安装：** 在 Release 页面下载 APK，然后 `adb connect <电视IP>` 并执行 `adb install -r jellyfin-androidtv-android9-isrg-root-x2-test.apk`（或使用 U 盘/文件管理器）。**卸载：** `adb uninstall org.jellyfin.androidtv.debug`，或在 设置 → 应用 中卸载。

**TLS 验证测试**（设备上手动测试，或 `openssl s_client -verify_hostname nas.jellyfin.test -connect nas.jellyfin.test:5002`）：
1. 正确证书 + 正确域名 → 必须连接成功。
2. 证书过期 → 必须失败。
3. 未知 CA → 必须失败。
4. 域名不匹配（如 `example.com`）→ 必须失败。
5. 篡改/无效证书 → 必须失败。

单元测试（`IsrgRootX2Tests`）自动校验证书指纹及配置保留系统 CA；第 2–5 项需要测试服务器，无法在 CI 中自动完成。

**反馈结果：** 提交 issue，附上设备型号、Android 版本、测试的服务器地址及以上各项结果。
