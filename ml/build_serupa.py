"""Membuat daftar "Koleksi Serupa" untuk aplikasi Museum Mpu Purwa.

Alur:
  1. Baca data koleksi dari ``assets/data/koleksi.json``.
  2. Ambil teks tiap arca: PDF penjelasan detail (``ml/data/pdf``), atau berkas
     teks (``ml/data/teks/<id>.txt``), atau data singkat di JSON bila keduanya
     belum ada.
  3. Ubah teks menjadi vektor (TF-IDF, dan embedding bila paketnya terpasang).
  4. Hitung kemiripan kosinus antar-arca, lalu simpan ``top-k`` tetangga
     terdekat tiap arca ke ``assets/data/koleksi_serupa.json``.
  5. Evaluasi: seberapa sering tetangga terdekat satu era dengan arca asal.

Contoh:
  python ml/build_serupa.py                 # model terbaik yang tersedia
  python ml/build_serupa.py --model tfidf   # paksa TF-IDF
  python ml/build_serupa.py --top 3 --model embedding
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
EMBEDDING_MODEL = "paraphrase-multilingual-MiniLM-L12-v2"

STOPWORDS = set(
    """
    yang dan di ke dari untuk pada dengan ini itu adalah juga atau sebagai oleh
    dalam akan telah sudah para sebuah suatu ada tidak serta karena sehingga
    dapat bisa agar saat ketika hingga antara tersebut merupakan memiliki
    """.split()
)


def baca_pdf(path: Path) -> str:
    from pypdf import PdfReader

    reader = PdfReader(str(path))
    return "\n".join((page.extract_text() or "") for page in reader.pages)


def potong_identitas(teks: str) -> str:
    """Buang blok "Identitas" (alamat, pemilik, dst.) yang sama di semua PDF,
    supaya kemiripan dihitung dari isi deskripsinya saja."""
    i = teks.lower().find("deskripsi")
    return teks[i:] if i >= 0 else teks


def bersihkan(teks: str) -> str:
    teks = teks.lower()
    teks = re.sub(r"[^a-z\s]", " ", teks)
    kata = [k for k in teks.split() if len(k) > 2 and k not in STOPWORDS]
    return " ".join(kata)


def ambil_teks(item: dict, pdf_dir: Path, teks_dir: Path) -> tuple[str, str]:
    """Mengembalikan (dokumen, sumber). Metadata selalu ikut sebagai konteks."""
    meta = " ".join(
        str(item.get(k) or "")
        for k in ("nama", "era", "asal", "periode", "material", "sejarah")
    )
    pdf_file = item.get("pdfFile")
    pdf_kosong = False
    if pdf_file and (pdf_dir / pdf_file).exists():
        isi = potong_identitas(baca_pdf(pdf_dir / pdf_file))
        if len(isi.strip()) > 80:
            return f"{meta} {isi}", "pdf"
        pdf_kosong = True  # hasil scan: coba berkas teks hasil transkripsi
    txt = teks_dir / f"{item['id']}.txt"
    if txt.exists():
        sumber = "txt (PDF hasil scan, ditranskripsi manual)" if pdf_kosong else "txt"
        return f"{meta} {txt.read_text(encoding='utf-8')}", sumber
    if pdf_kosong:
        return meta, "pdf-kosong (mungkin hasil scan, perlu OCR)"
    return meta, "metadata"


def vektor_tfidf(dokumen: list[str]) -> np.ndarray:
    from sklearn.feature_extraction.text import TfidfVectorizer

    vec = TfidfVectorizer(ngram_range=(1, 2), sublinear_tf=True, min_df=1)
    return vec.fit_transform(dokumen).toarray()


def vektor_embedding(dokumen: list[str]) -> np.ndarray:
    from sentence_transformers import SentenceTransformer

    model = SentenceTransformer(EMBEDDING_MODEL)
    return model.encode(dokumen, normalize_embeddings=True)


def kemiripan(vektor: np.ndarray) -> np.ndarray:
    norma = np.linalg.norm(vektor, axis=1, keepdims=True)
    norma[norma == 0] = 1
    v = vektor / norma
    sim = v @ v.T
    np.fill_diagonal(sim, -1)  # arca tidak mirip dengan dirinya sendiri
    return sim


def top_k(sim: np.ndarray, ids: list[str], k: int) -> dict[str, list[dict]]:
    hasil = {}
    for i, id_ in enumerate(ids):
        urut = np.argsort(-sim[i])[:k]
        hasil[id_] = [
            {"id": ids[j], "skor": round(float(max(sim[i, j], 0.0)), 4)} for j in urut
        ]
    return hasil


def evaluasi(sim: np.ndarray, label: list[str], k: int) -> dict:
    """Precision@k: porsi tetangga yang satu era dengan arca asal."""
    skor = []
    for i in range(len(label)):
        urut = np.argsort(-sim[i])[:k]
        skor.append(np.mean([label[j] == label[i] for j in urut]))
    # pembanding acak: peluang memilih arca satu era secara acak
    acak = []
    for i in range(len(label)):
        lain = [label[j] for j in range(len(label)) if j != i]
        acak.append(np.mean([x == label[i] for x in lain]) if lain else 0.0)
    return {"precision_at_k": round(float(np.mean(skor)), 4), "acak": round(float(np.mean(acak)), 4)}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--koleksi", default=str(ROOT / "assets/data/koleksi.json"))
    ap.add_argument("--pdf-dir", default=str(ROOT / "ml/data/pdf"))
    ap.add_argument("--teks-dir", default=str(ROOT / "ml/data/teks"))
    ap.add_argument("--out", default=str(ROOT / "assets/data/koleksi_serupa.json"))
    ap.add_argument("--hasil-dir", default=str(ROOT / "ml/hasil"))
    ap.add_argument("--model", choices=["auto", "tfidf", "embedding"], default="auto")
    ap.add_argument("--top", type=int, default=3)
    args = ap.parse_args()

    koleksi = json.loads(Path(args.koleksi).read_text(encoding="utf-8"))
    if len(koleksi) < 3:
        print("Minimal 3 koleksi diperlukan.", file=sys.stderr)
        return 1
    ids = [str(k["id"]) for k in koleksi]
    label = [str(k.get("era", "")) for k in koleksi]

    mentah, sumber = [], {}
    for item in koleksi:
        dokumen, asal = ambil_teks(item, Path(args.pdf_dir), Path(args.teks_dir))
        mentah.append(dokumen)
        sumber[str(item["id"])] = asal
    dokumen = [bersihkan(t) for t in mentah]

    print("Sumber teks per arca:")
    for item in koleksi:
        print(f"  [{item['id']:>2}] {item['nama']:<28} {sumber[str(item['id'])]:<12} {len(dokumen[ids.index(str(item['id']))].split())} kata")

    sim_per_model = {}
    sim_per_model["tfidf"] = kemiripan(vektor_tfidf(dokumen))
    try:
        sim_per_model["embedding"] = kemiripan(vektor_embedding(mentah))
    except ImportError:
        if args.model == "embedding":
            print("Paket sentence-transformers belum terpasang.", file=sys.stderr)
            return 1

    print("\nEvaluasi (precision@%d, tetangga satu era):" % args.top)
    ringkasan = {}
    for nama, sim in sim_per_model.items():
        ringkasan[nama] = evaluasi(sim, label, args.top)
        print(f"  {nama:<10} {ringkasan[nama]['precision_at_k']:.2f}  (acak {ringkasan[nama]['acak']:.2f})")

    terpilih = args.model
    if terpilih == "auto":
        terpilih = "embedding" if "embedding" in sim_per_model else "tfidf"
    sim = sim_per_model[terpilih]
    print(f"\nModel dipakai untuk aplikasi: {terpilih}")

    out = {
        "model": EMBEDDING_MODEL if terpilih == "embedding" else "tfidf-cosine",
        "diperbarui": date.today().isoformat(),
        "serupa": top_k(sim, ids, args.top),
    }
    Path(args.out).write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    hasil = Path(args.hasil_dir)
    hasil.mkdir(parents=True, exist_ok=True)
    (hasil / "evaluasi.json").write_text(
        json.dumps({"jumlah_arca": len(koleksi), "k": args.top, "model": ringkasan, "sumber_teks": sumber}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Tersimpan: {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
