"""Build an experimental portable Windows ZIP; requires Python 3 and bsdtar."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import urllib.request

VERSION = "3.4.12-1"
SHA256 = "3806f164377824bcb17e1cf39b17d967e2bdc01e8547ce0254cd786dbe2cfe13"
URL = f"https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-{VERSION}/rubyinstaller-{VERSION}-x64.7z"
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def build(destination):
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    cli = ROOT / "bin/adminka"
    expected = subprocess.check_output(["git", "show", f"{revision}:bin/adminka"], cwd=ROOT)
    if cli.read_bytes() != expected:
        raise RuntimeError("CLI differs from recorded revision")
    output = Path(destination).resolve()
    output.mkdir(parents=True, exist_ok=True)
    name = f"adminka-windows-x64-{revision[:8]}-experimental"
    archive = output / (name + ".zip")
    if archive.exists():
        raise FileExistsError(archive)
    with tempfile.TemporaryDirectory() as temp:
        temp = Path(temp)
        download = temp / "ruby.7z"
        urllib.request.urlretrieve(URL, download)
        if hashlib.sha256(download.read_bytes()).hexdigest() != SHA256:
            raise RuntimeError("Ruby archive SHA-256 mismatch")
        subprocess.run(["bsdtar", "-xf", str(download), "-C", str(temp)], check=True)
        bundle = temp / name
        bundle.mkdir()
        shutil.move(str(temp / f"rubyinstaller-{VERSION}-x64"), bundle / "runtime")
        shutil.copy2(cli, bundle / "adminka.rb")
        for file in ("adminka.cmd", "smoke.rb", "README.txt"):
            shutil.copy2(HERE / file, bundle / file)
        manifest = {"status": "experimental; Windows execution unverified", "source_revision": revision,
                    "cli_sha256": hashlib.sha256(expected).hexdigest(), "runtime_url": URL,
                    "runtime_sha256": SHA256, "runtime_version": VERSION}
        (bundle / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
        shutil.make_archive(str(archive.with_suffix("")), "zip", temp, name)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{digest}  {archive.name}\n")
    print(json.dumps({"archive": str(archive), "sha256": digest, "bytes": archive.stat().st_size}))


if __name__ == "__main__":
    build(sys.argv[1])
