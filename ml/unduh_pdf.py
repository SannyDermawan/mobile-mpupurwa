"""Unduh PDF penjelasan tiap arca ke ml/data/pdf/ dari tautan di assets/data/koleksi.json.

PDF tidak ikut Git (lihat .gitignore), jadi jalankan ini setelah clone:
    python ml/unduh_pdf.py
Hanya mengunduh tautan Google Drive yang dapat dibuka tanpa login.
"""
import json
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    tujuan = ROOT / "ml/data/pdf"
    tujuan.mkdir(parents=True, exist_ok=True)
    for item in json.loads((ROOT / "assets/data/koleksi.json").read_text(encoding="utf-8")):
        url, nama = item.get("pdfUrl") or "", item.get("pdfFile")
        m = re.search(r"/d/([^/]+)", url)
        if not (m and nama):
            print(f"lewati {item['id']}: tidak ada tautan Drive")
            continue
        berkas = tujuan / nama
        if berkas.exists():
            print(f"sudah ada {nama}")
            continue
        req = urllib.request.Request(
            f"https://drive.google.com/uc?export=download&id={m.group(1)}",
            headers={"User-Agent": "Mozilla/5.0"},
        )
        data = urllib.request.urlopen(req, timeout=60).read()
        if data[:5] != b"%PDF-":
            print(f"gagal {nama}: bukan PDF (mungkin butuh login)")
            continue
        berkas.write_bytes(data)
        print(f"unduh {nama} ({len(data) // 1024} KB)")


if __name__ == "__main__":
    main()
