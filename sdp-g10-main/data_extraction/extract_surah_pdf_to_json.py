"""
From PDF to Strict JSON for your Surah schema using Google AI Studio (Gemini).
"""

import os, re, json, time, random
from typing import Any, Dict, List, Tuple

# PDF text (selectable) — fallback only
from pdfminer.high_level import extract_text

# OCR
import fitz  # PyMuPDF
import pytesseract
from PIL import Image, ImageOps, ImageFilter

import google.generativeai as genai

# ---------------- SCHEMA ----------------
TAFSIR_SCHEMA = {
  "type": "object",
  "properties": {
    # Publication details of the source book
    "publication": {
        "type": "object",
        "properties": {
        # Unique identifier of the surah, e.g., "4" for Surah An-Nisa
        "surahID":   {"type": "string"},
        # Name of the surah (Arabic title, e.g., "النساء")
        "surahName": {"type": "string"},
        # Title of the tafsir/book (e.g., "تفسير سورة النساء")
        "bookTitle": {"type": "string"},
        # Author of the tafsir/book (e.g., "الأستاذ الدكتور عبد السلام مقبل المجيدي")
        "author":    {"type": "string"},
        "publisher":      {"type": "string"},  # دار النشر
        "year":           {"type": "integer"}, # سنة النشر
        "location":       {"type": "string"},  # مكان النشر (الدوحة - قطر)
        "isbn":           {"type": "string"},  # الرقم الدولي المعياري للكتاب
        "deposit_number": {"type": "string"}   # رقم الإيداع بدار الكتب القطرية
      },
      "required": ["surahID","surahName","bookTitle","author","publisher","year","location","isbn","deposit_number"]
    },

    # Main thematic units of the surah (المحاور)
    "mahawer": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id":        {"type": "string"},  # unique ID for the محور
          "type":      {"type": "string"},  # e.g., "محور", "مقدمة", "خاتمة"
          "sequence":  {"type": "string"},  # label or order (e.g., "المحور الأول")
          "title":     {"type": "string"},  # title of the محور
          "text":      {"type": "string"},  # description/summary of the محور
          "ayat":     {"type": "array", "items": {"type": "integer"}}, # list of ayah numbers in this محور

          # Boolean flags for مقدمة / خاتمة if applicable
          "isMuqadimah": {"type": "boolean", "nullable": True},
          "isKhatimah":  {"type": "boolean", "nullable": True},

          # Subsections of each محور (e.g., "قسم", "حصن", "بصيرة")
          "sections": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "id":       {"type": "string"},   # unique ID for section
                "type":     {"type": "string"},   # type of section (قسم, حصن, صنف)
                "sequence": {"type": "string"},   # e.g., "القسم الأول"
                "title":    {"type": "string", "nullable": True}, # optional section title
                "text":     {"type": "string"},   # content/summary of the section
                "ayat":     {"type": "array", "items": {"type": "integer"}}, # list of ayah numbers
                "conclusion": {"type": "string", "nullable": True}, # optional concluding remark

                # Deeper nested subSections (e.g., الفصول under الأصناف)
                "subSections": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "id":       {"type": "string"},
                      "type":     {"type": "string"},   # e.g., فصل
                      "sequence": {"type": "string"},
                      "text":     {"type": "string"},
                      "ayat":     {"type": "array", "items": {"type": "integer"}, "nullable": True},

                      # Optional: smaller narrative units inside a فصل (e.g., قضية, مثال)
                      "cases": {
                        "type": "array",
                        "items": {
                          "type": "object",
                          "properties": {
                            "id":       {"type": "string"},
                            "type":     {"type": "string"},   # e.g., قضية
                            "sequence": {"type": "string"},
                            "text":     {"type": "string"}
                          },
                          "required": ["id","type","sequence","text"]
                        },
                        "nullable": True
                      },
                      "conclusion": {"type": "string", "nullable": True}
                    },
                    "required": ["id","type","sequence","text"]
                  },
                  "nullable": True
                }
              },
              "required": ["id","type","sequence","text","ayat"]
            }
          }
        },
        "required": ["id","type","sequence","title","text","ayat","sections"]
      }
    }
  },
}

SYSTEM_INSTRUCTIONS = (
  "أنت مستخرج بيانات من كتاب تفسير.\n"
  "أعِد JSON فقط يطابق المخطط المقدم.\n"
  "مهم جدًا:\n"
  "1) انسخ العناوين والنصوص من PDF **نصًا حرفيًا** دون اختصار أو إعادة صياغة.\n"
  "2) **ممنوع** اختلاق نصوص أو ملء نصوص عامة مثل: \"string\" أو \"Lorem\" أو \"...\".\n"
  "3) إذا لم تجد المعلومة في هذا الجزء، اترك القيم فارغة (أو القوائم فارغة) ولا تكتب نصًا عامًا.\n"
  "4) startAya/endAya أرقام صحيحة فقط إن وُجدت بوضوح.\n"
  "5) sequence: \"المقدمة\" و\"الخاتمة\" كما هما. لغيرهما: \"المحور الأول/الثاني/...\"، "
  "والأقسام: \"القسم الأول/الثاني/...\" أو حسب اللفظ الظاهر (فصل/بصيرة/حصن...).\n"
  "6) تجنّب التكرار؛ لا تُكرر نفس المقدمة/النص.\n"
  "أعد JSON فقط وبدون أي شرح خارج JSON."
)

MODEL_CANDIDATES = [
    "gemini-1.5-flash",      
    "gemini-1.5-flash-001",  
    "gemini-1.5-pro",        
]

MODEL_NAME = "gemini-1.5-flash-001"
CHUNK_SIZE = 7000         # slightly smaller chunks → fewer tokens/request
MAX_CHUNKS = None         # process the whole document

# ---------------- OCR: high-quality page render + preprocessing ----------------
def preprocess_for_ocr(img: Image.Image) -> Image.Image:
    # Convert to grayscale, boost contrast, light denoise, slight sharpen
    g = ImageOps.grayscale(img)
    g = ImageOps.autocontrast(g)
    g = g.filter(ImageFilter.MedianFilter(size=3))
    g = g.filter(ImageFilter.UnsharpMask(radius=1.2, percent=150, threshold=3))
    return g

def read_pdf_text_ocr(path: str) -> str:
    doc = fitz.open(path)
    parts: List[str] = []
    # Render with a scale matrix (~300-360 DPI equivalent)
    scale = 3.0
    mat = fitz.Matrix(scale, scale)
    for page in doc:
        pix = page.get_pixmap(matrix=mat, alpha=False)
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        img = preprocess_for_ocr(img)
        parts.append(pytesseract.image_to_string(img, lang="ara+eng"))
    return "\n".join(parts).strip()

def read_pdf_text_selectable(path: str) -> str:
    try:
        t = extract_text(path) or ""
        return t.strip()
    except Exception:
        return ""

def chunk_text(text: str, size: int) -> List[str]:
    text = re.sub(r"[ \t]+", " ", text)
    return [text[i:i+size] for i in range(0, len(text), size)]

# ---------------- Metadata heuristics (from OCR text) ----------------
PUB_KEYS = ["الناشر", "الناشرين", "دار", "دار النشر", "دار لوسيل", "النشر"]
ISBN_KEYS = ["ISBN", "ردمك", "ر د م ك", "ردم ك"]
DEP_KEYS = ["رقم الإيداع", "الايداع", "الإيداع"]
LOC_KEYS = ["الدوحة", "قطر", "Doha", "Qatar"]
AUTHOR_KEYS = ["المؤلف", "تأليف", "إعداد", "بقلم"]

def extract_top_metadata(text: str) -> Dict[str, Any]:
    meta = {"surahID": "", "surahName": "", "author": "",
            "publication": {"publisher": "", "year": 0, "location": "", "isbn": "", "deposit_number": ""}}
    # Surah name (simple heuristic)
    m = re.search(r"سورة\s+([^\s\:\n]+)", text)
    if m:
        meta["surahName"] = m.group(1)
    # author
    for key in AUTHOR_KEYS:
        m = re.search(rf"{key}\s*[:：]?\s*(.+)", text)
        if m:
            cand = m.group(1).strip()
            cand = cand.split("\n")[0][:120]
            meta["author"] = cand
            break
    # year (first 4-digit 19xx/20xx found)
    y = re.search(r"(19|20)\d{2}", text)
    if y:
        meta["publication"]["year"] = int(y.group(0))
    # publisher
    m = re.search(r"(دار[^\n]{0,40})", text)
    if m:
        meta["publication"]["publisher"] = m.group(1).strip()
    # location
    for key in LOC_KEYS:
        if key in text:
            meta["publication"]["location"] = "الدوحة - قطر" if "دوح" in key or "قطر" in key or "Qatar" in key else key
            break
    # ISBN
    m = re.search(r"(?:ISBN|ردمك|ر د م ك|ردم ك)\s*[:：]?\s*([0-9\-]+)", text, re.IGNORECASE)
    if m:
        meta["publication"]["isbn"] = m.group(1).strip()
    # deposit number
    m = re.search(r"(?:رقم\s*الإيداع|رقم\s*الايداع)\s*[:：]?\s*([0-9\-]+)", text)
    if m:
        meta["publication"]["deposit_number"] = m.group(1).strip()
    return meta

# ---------------- Post-processing helpers ----------------
PLACEHOLDER_PATTERNS = ["string", "String", "عنوان", "Lorem", "…", "..."]

def looks_like_placeholder(v: Any) -> bool:
    if not isinstance(v, str):
        return False
    t = v.strip()
    if not t:
        return False
    return any(p in t for p in PLACEHOLDER_PATTERNS)

def sanitize_placeholders(data: Dict[str, Any]) -> Dict[str, Any]:
    # top-level fields
    for k in ("surahID", "surahName", "author"):
        if looks_like_placeholder(data.get(k, "")):
            data[k] = ""
    pub = data.get("publication", {}) or {}
    for k in ("publisher", "location", "isbn", "deposit_number"):
        if looks_like_placeholder(pub.get(k, "")):
            pub[k] = ""
    if "year" in pub and isinstance(pub["year"], int) and pub["year"] < 1200:  # unrealistic year
        pub["year"] = 0
    data["publication"] = pub

    # mahawer list
    good = []
    seen = set()
    for m in data.get("mahawer", []):
        if looks_like_placeholder(m.get("title", "")) or looks_like_placeholder(m.get("text", "")):
            continue
        sig = (m.get("type",""), m.get("title",""), m.get("text",""))
        if sig in seen:
            continue
        seen.add(sig)

        # clean sections placeholders too
        secs = []
        for s in (m.get("sections") or []):
            if looks_like_placeholder(s.get("title","")) or looks_like_placeholder(s.get("text","")):
                continue
            secs.append(s)
        m["sections"] = secs

        good.append(m)
    data["mahawer"] = good
    return data

def arabic_ordinal(n: int) -> str:
    mapping = {1:"أول",2:"ثاني",3:"ثالث",4:"رابع",5:"خامس",6:"سادس",7:"سابع",8:"ثامن",9:"تاسع",10:"عاشر",11:"حادي عشر",12:"ثاني عشر"}
    return mapping.get(n, str(n))

def set_ids_and_sequences(data: Dict[str, Any]) -> Dict[str, Any]:
    for i, m in enumerate(data.get("mahawer", []), start=1):
        m["id"] = str(i)
        t = (m.get("type") or "").strip()
        if t in {"مقدمة", "خاتمة"}:
            m["sequence"] = t
            if t == "مقدمة": m["isMuqadimah"] = True
            if t == "خاتمة": m["isKhatimah"] = True
        else:
            m["sequence"] = f"{t} {arabic_ordinal(i)}".strip()
        # sections/subsections/cases ids
        for j, s in enumerate(m.get("sections", []) or [], start=1):
            s["id"] = str(j)
            for k, sub in enumerate(s.get("subSections", []) or [], start=1):
                sub["id"] = str(k)
                for r, case in enumerate(sub.get("cases", []) or [], start=1):
                    case["id"] = str(r)
    return data

# ---------------- Gemini call with backoff ----------------
def init_gemini() -> Any:
    key = os.getenv("GOOGLE_API_KEY")
    if not key:
        raise RuntimeError("GOOGLE_API_KEY is not set.")
    genai.configure(api_key=key, transport="rest")

    last_err = None
    for name in MODEL_CANDIDATES:
        try:
            return genai.GenerativeModel(name)
        except Exception as e:
            last_err = e
            continue
    raise RuntimeError(
        f"Couldn’t initialize any Gemini model. Tried: {', '.join(MODEL_CANDIDATES)}. "
        f"Last error: {last_err}"
    )

def call_gemini_json(model: Any, text_chunk: str, part_idx: int, total_parts: int) -> Dict[str, Any]:
    generation_config = {
        "response_mime_type": "application/json",
        "response_schema": SURAH_SCHEMA,
        "temperature": 0.0,
    }
    prompt = (
        f"{SYSTEM_INSTRUCTIONS}\n\n"
        f"(الجزء {part_idx} من {total_parts}) النص:\n{text_chunk}\n"
        f"\n- إذا تعذّر الاستخراج في هذا الجزء، أعِد القوائم فارغة دون نصوص عامة."
    )
    resp = model.generate_content(prompt, generation_config=generation_config)
    raw = resp.text
    try:
        return json.loads(raw)
    except Exception:
        start, end = raw.find("{"), raw.rfind("}")
        if start != -1 and end != -1:
            return json.loads(raw[start:end+1])
        raise

def call_with_backoff(fn, *args, **kwargs):
    delay = 6
    for attempt in range(6):
        try:
            return fn(*args, **kwargs)
        except Exception as e:
            msg = str(e)
            if "ResourceExhausted" not in msg and "429" not in msg:
                raise
            m = re.search(r"retry_delay\s*{\s*seconds:\s*(\d+)", msg)
            wait = int(m.group(1)) if m else delay
            wait += random.uniform(0, 1.5)
            print(f"[rate-limit] sleeping {wait:.1f}s (attempt {attempt+1}/6)...")
            time.sleep(wait)
            delay = min(int(delay * 1.7), 45)
    raise RuntimeError("Rate-limited repeatedly. Try later or enable billing / smaller chunks.")

def deep_merge(acc: Dict[str, Any], piece: Dict[str, Any]) -> Dict[str, Any]:
    if "mahawer" in piece and isinstance(piece["mahawer"], list):
        acc.setdefault("mahawer", [])
        acc["mahawer"].extend(piece["mahawer"])
    for k in ("surahID","surahName","author","publication"):
        if k in piece and (k not in acc or not acc[k]):
            acc[k] = piece[k]
    return acc

# ---------------- Main ----------------
def extract_surah(pdf_path: str, out_path: str = "output.json") -> None:
    # Strong OCR first
    text = read_pdf_text_ocr(pdf_path)
    if not text or len(text) < 30:
        # fallback to selectable text (if PDF isn't scanned)
        text = read_pdf_text_selectable(pdf_path)
    if not text or len(text) < 30:
        raise RuntimeError("لم أستطع استخراج نص كافٍ من PDF. تأكد من Tesseract واللغة العربية.")

    # Heuristic metadata (pre-fill to avoid placeholders)
    meta = extract_top_metadata(text)

    chunks = chunk_text(text, CHUNK_SIZE)
    model = init_gemini()

    result: Dict[str, Any] = {}
    # Start with heuristic meta (so even if the model returns empty top fields, we keep real values)
    result.update({"surahID": meta["surahID"], "surahName": meta["surahName"], "author": meta["author"],
                   "publication": meta["publication"], "mahawer": []})

    for idx, ch in enumerate(chunks, start=1):
        if idx > 1:
            time.sleep(6)  # free-tier friendly throttle
        piece = call_with_backoff(call_gemini_json, model, ch, idx, len(chunks))
        result = deep_merge(result, piece)

    # Clean placeholders, then fix IDs/sequences
    result = sanitize_placeholders(result)
    result = set_ids_and_sequences(result)

    # Final safety: if model still put "string" in any top field, replace with heuristic if available
    for key in ("surahID", "surahName", "author"):
        if not result.get(key):
            result[key] = meta.get(key, "") or ""
    if "publication" not in result or not isinstance(result["publication"], dict):
        result["publication"] = meta["publication"]
    else:
        for k in ("publisher","year","location","isbn","deposit_number"):
            if (k not in result["publication"]) or (not result["publication"][k]) or looks_like_placeholder(result["publication"][k]):
                result["publication"][k] = meta["publication"].get(k, "")

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    print(f"Saved → {out_path}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python extract_surah_pdf_to_json.py <path/to/pdf> [output.json]")
        raise SystemExit(1)
    pdf_path = sys.argv[1]
    out_path = sys.argv[2] if len(sys.argv) > 2 else "output.json"
    extract_surah(pdf_path, out_path)
