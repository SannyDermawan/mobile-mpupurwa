"""Ubah assets/data/koleksi.json menjadi data siap-impor untuk Admin Web.

Admin Web (website-admin-museum-mpu-purwa) menyimpan koleksi di tabel
`collections` (model Prisma `Collection`). Skrip ini memetakan kolomnya:

    nama -> name        era -> era (huruf awal besar)   periode -> period
    asal -> origin      material -> material            ukuran -> dimensions
    sejarah -> meaning  fotoUrl -> photoUrl             videoUrl -> videoUrl
    pdfUrl -> pdfUrl

Keluaran: ml/hasil/koleksi_untuk_admin.json. `photoUrl` masih berupa jalur aset
aplikasi; unggah fotonya lewat halaman Manajemen Koleksi (Vercel Blob) lalu
ganti dengan tautan hasil unggah.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ERA_ADMIN = {"KANJURUHAN": "Kanjuruhan", "TUMAPEL": "Tumapel", "SINGOSARI": "Singosari",
             "MAJAPAHIT": "Majapahit", "PRASASTI": "Prasasti"}


def main() -> None:
    sumber = json.loads((ROOT / "assets/data/koleksi.json").read_text(encoding="utf-8"))
    hasil = []
    for k in sumber:
        era = ERA_ADMIN.get(k["era"].upper())
        if era is None:
            raise SystemExit(f"Era '{k['era']}' ({k['id']}) tidak dikenal Admin Web.")
        hasil.append({
            "kodeAplikasi": k["id"],
            "name": k["nama"], "era": era, "period": k.get("periode"),
            "origin": k.get("asal"), "material": k.get("material"),
            "dimensions": k.get("ukuran"), "meaning": k.get("sejarah"),
            "photoUrl": k.get("fotoUrl"), "videoUrl": k.get("videoUrl"), "pdfUrl": k.get("pdfUrl"),
        })
    out = ROOT / "ml/hasil/koleksi_untuk_admin.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(hasil, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(hasil)} arca -> {out}")


if __name__ == "__main__":
    main()
