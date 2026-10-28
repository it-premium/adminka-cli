"""Build a macOS script package using the OS-provided Ruby (not bundled)."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def build(destination):
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    inputs = ["bin/adminka", "NOTICES.md", "packaging/macos/adminka",
              "packaging/macos/smoke.rb", "packaging/macos/README.txt",
              "packaging/macos/build.py"]
    for name in inputs:
        committed = subprocess.check_output(["git", "show", f"{revision}:{name}"], cwd=ROOT)
        if (ROOT / name).read_bytes() != committed:
            raise RuntimeError(f"Uncommitted build input: {name}")
    output = Path(destination).resolve()
    output.mkdir(parents=True, exist_ok=True)
    name = f"adminka-macos-{revision[:8]}-experimental"
    archive = output / (name + ".tar.gz")
    if archive.exists():
        raise FileExistsError(archive)
    with tempfile.TemporaryDirectory() as temp:
        bundle = Path(temp) / name
        bundle.mkdir()
        shutil.copy2(ROOT / "bin/adminka", bundle / "adminka.rb")
        shutil.copy2(ROOT / "NOTICES.md", bundle / "NOTICES.md")
        for file in ("adminka", "smoke.rb", "README.txt"):
            shutil.copy2(HERE / file, bundle / file)
        (bundle / "adminka").chmod(0o755)
        manifest = {"status": "experimental", "source_revision": revision,
                    "cli_sha256": hashlib.sha256((bundle / "adminka.rb").read_bytes()).hexdigest(),
                    "runtime": "/usr/bin/ruby supplied by macOS; not bundled",
                    "tested_platform": "See release notes for exact tested environment"}
        (bundle / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
        shutil.make_archive(str(archive)[:-7], "gztar", temp, name)
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_name(archive.name + ".sha256").write_text(f"{digest}  {archive.name}\n")
    print(json.dumps({"archive": str(archive), "sha256": digest, "bytes": archive.stat().st_size}))


if __name__ == "__main__":
    build(sys.argv[1])
