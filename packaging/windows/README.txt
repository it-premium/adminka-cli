Adminka portable Windows x64 packaging experiment

NOT A VERIFIED RELEASE. Native Windows execution is pending.
The full RubyInstaller runtime is preserved, including its notices and licenses.
No Rails checkout, system Ruby installation or administrator access is intended.

Extract the ZIP into a folder belonging to your Windows user.
Open PowerShell in that folder. First run this OFFLINE check:
  .\runtime\bin\ruby.exe -EUTF-8:UTF-8 .\smoke.rb
It copies the bundle into a temporary Unicode/spaced path and uses fake credentials
in an isolated temporary config. It never calls the API or reads your saved token.
Send the PASS output or error, plus your Windows version, to the test coordinator.

After the offline check passes, coordinated read-only live test:
  .\adminka.cmd --help
  .\adminka.cmd login --url https://app.it-premium.com.ua
Open the URL printed by the command in your browser and confirm the matching code.
  .\adminka.cmd tickets --my --json
Use your own account. Do not share tokens, config files or ticket content in logs.
No write commands are part of this pilot.

Configuration is outside this bundle: ~/.config/adminka/config.yml unless
XDG_CONFIG_HOME is set. Windows credential file permissions still need validation;
Unix chmod(0600) is not evidence of equivalent Windows ACL protection.

Upgrade experiment: extract a new version into a separate folder and invoke that
folder's launcher. Keep the previous folder for rollback. No PATH changes are made.
Deleting the bundle does not revoke or delete the separately stored credentials.

The manifest records the exact CLI revision and verified runtime archive digest.
Build on macOS/Linux with Python 3 and bsdtar:
  python3 packaging/windows/build.py /absolute/output/directory
