Adminka CLI macOS pilot

This package uses /usr/bin/ruby supplied by macOS. Ruby is NOT bundled.
No Rails checkout, gems or administrator installation is required on the tested Mac.
See release notes for the exact tested OS, architecture and remaining limitations.

Extract the archive, open Terminal, and cd into the extracted directory.
Keep all files together; do not copy or symlink only the launcher.

Offline/loopback-only test (fake credentials, no production calls):
  /usr/bin/ruby --disable-gems -EUTF-8:UTF-8 ./smoke.rb

Help:
  ./adminka --help

Login with your own account:
  ./adminka login --url https://app.it-premium.com.ua
Open the printed URL in a browser and confirm the matching code.

Read-only pilot:
  ./adminka tickets --my
  ./adminka tickets --my --json
  ./adminka ticket YOUR_TICKET_ID

Do not share tokens, config files or private ticket content in feedback.
Do not perform ticket mutations as part of this pilot.
Claude/Gemini integrations are not yet verified.

The launcher does not change PATH or replace an existing adminka installation.
Extract future releases into a separate folder. Configuration persists separately
at ~/.config/adminka/config.yml (or under XDG_CONFIG_HOME). Deleting the package
does not delete configuration or revoke its token.

This is an unsigned script archive, not a signed/notarized macOS application.
If macOS blocks it, report the exact message; do not disable system protection.

Build: python3 packaging/macos/build.py /absolute/output/directory
Requires Python 3 only for building; Python is not required to run the package.
