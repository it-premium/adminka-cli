# Adminka CLI

Command-line client for IT-Premium service management. This public repository contains the CLI and packaging tools; the Rails application is maintained separately.

## Experimental Windows x64 pilot

**Windows execution has not yet been verified.** This is a portable packaging experiment, not a production-ready Windows release.

Download the ZIP and checksum from [the experimental release](https://github.com/it-premium/adminka-cli/releases/tag/windows-pilot-2026.10.28.1). Extract the ZIP into your own user folder. Ruby is included; no Rails checkout or separate Ruby installation is intended.

Open PowerShell in the extracted folder containing `adminka.cmd` and run the offline test first:

```powershell
.\runtime\bin\ruby.exe -EUTF-8:UTF-8 .\smoke.rb
```

The test uses fake credentials in an isolated temporary directory, makes no API calls, and checks help, config persistence and relocation into a Unicode path containing spaces. Send the result and Windows version to your pilot coordinator. No successful Windows test is claimed yet.

After that passes, coordinate live login and read-only testing:

```powershell
.\adminka.cmd login --url https://app.it-premium.com.ua
.\adminka.cmd tickets --my
```

Open the URL printed during login and approve the matching code using your own account. Do not share tokens or configuration files. The pilot does not include ticket mutations. API permissions remain those of the authenticated account.

[Ukrainian pilot instructions in IT-Premium Writebook](https://writebook.it-expert.com.ua/4/adminka/94/adminka-cli-windows) (organizational access may be required).

## What is verified

The initial ZIP was built on macOS. Runtime archive SHA-256, ZIP CRC integrity, bundled CLI digest and smoke-test syntax passed. Native Windows execution, live HTTPS/browser login/API access, Windows credential-file ACLs, upgrade/rollback and Claude/Gemini integration remain unverified.

Deleting the extracted folder does not delete credentials stored separately under `~/.config/adminka` (or `XDG_CONFIG_HOME`) or revoke the token.

## Provenance

The initial CLI is an exact copy from application revision `e096212f3b770409f48f3163272ccd5229d62a1b`. `manifest.json` records the CLI digest and RubyInstaller archive provenance. This repository has its own Git history; no Rails repository history is included.

Packaging code is in `packaging/windows/`. Build from a clean committed checkout with Python 3 and `bsdtar`:

```sh
python3 packaging/windows/build.py /absolute/output/directory
```

New builds record this distribution repository’s current commit as `source_revision`; the initial artifact records the application revision above. ZIP byte-for-byte reproducibility is not claimed.

## Licensing

See [NOTICES.md](NOTICES.md). Public availability is not an additional open-source license grant for the Adminka code.
