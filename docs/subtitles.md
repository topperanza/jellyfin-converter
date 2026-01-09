# Subtitle Policy & Configuration

This document outlines how the Jellyfin Converter handles subtitle selection, merging, and sidecar discovery.

## Sidecar Naming & Discovery
The converter automatically discovers external subtitle files located in the same directory as the video.

Supported sidecar formats:
- Text: `.srt`, `.ass`, `.ssa`, `.vtt`
- Bitmap (only when `KEEP_BITMAP_SUBS=1`): `.sup`, `.idx`+`.sub` pairs

### Strict Matching Rules
1.  **Exact Stem Match**: The subtitle filename must start exactly with the video filename (minus extension).
2.  **Required Tags in Suffix**: If the subtitle file has a suffix (characters between the stem and extension), that suffix **MUST** contain at least one recognized tag (e.g., language like `eng`, `ita`, or flag like `forced`, `sdh`, `default`).
    - Video: `Movie.mkv`
    - Match: `Movie.eng.srt`
    - Match: `Movie.srt` (Exact match without suffix)
    - No Match: `Movie - Sequel.srt` (Suffix " - Sequel" contains no recognized tags)
3.  **Ambiguity Protection**: Files that look like they belong to another video (e.g., different year or part number appended without a clear separator) are skipped.
4.  **Why this is safer**: This prevents false positives where a similarly named file (like a sequel or extra) is mistakenly treated as a subtitle for the main video. It ensures that any deviation from the exact filename is intentional and descriptive.

### Tag Parsing
Tags are detected from the filename suffix:
- **Language**: `en`, `eng`, `english` -> `eng`
- **Forced**: `forced`, `forzato` -> Sets forced flag.
- **SDH**: `sdh`, `cc`, `hearing_impaired` -> Sets SDH flag.
- **Commentary**: `commentary`, `director` -> Sets commentary flag.

Example: `Movie.Name.1999.ita.forced.sdh.srt` -> Language: `ita`, Forced: Yes, SDH: Yes.

## Debugging

If you are unsure why a subtitle is being selected or ignored, use the `--print-subtitles` flag. This will output a machine-readable inventory of all discovered subtitles (internal and external) and the final selection plan without modifying any files.

```bash
./scripts/jellyfin_converter.sh --print-subtitles /path/to/video.mkv
```

Output format (pipe-separated):
```
DEBUG: Subtitle Inventory & Plan
Source: /path/to/video.mkv
----------------------------------------
Internal Subtitles (Raw Probe):
  0|hdmv_pgs_subtitle|eng|English|0|0|0
----------------------------------------
External Subtitles (Discovered):
  /path/to/video.en.srt|eng|0|0|0|srt
----------------------------------------
Selection Plan:
  ext|/path/to/video.en.srt|eng|0|srt|1
  int|0|eng|0|hdmv_pgs_subtitle|0
```

## Deterministic Selection & Scoring

The converter uses a strict scoring system to rank subtitle candidates. Lower scores are better.

### Scoring Factors

1.  **Language Match**: 
    - Preferred language (first in `SUB_LANGS`): Score + 0
    - Other allowed languages: Score + 10
2.  **Source & Codec**:
    - **External Subtitles**:
        - If `PREFER_EXTERNAL_SUBS=1` (Default): Score + 0
        - If `PREFER_EXTERNAL_SUBS=0`: Score + 100
        - Bitmap sidecars (`.sup`, `.idx`): Score + 200 (and ignored when `KEEP_BITMAP_SUBS=0`)
    - **Internal Subtitles**:
        - Text Codec (SRT, ASS, VTT): Score + 100
        - Bitmap Codec (PGS, VOBSUB): Score + 200
3.  **Attributes**:
    - Forced: Score - 5 (Bonus)
    - Default: Score - 2 (Bonus)
    - SDH (if `PREFER_SDH=0`): Score + 20 (Penalty)

### Tie-Breaking

If two subtitles have the same score (e.g., an external SRT and an internal SRT when `PREFER_EXTERNAL_SUBS=0`), the tie is broken deterministically:
1.  **Source Rank**: Internal (0) wins over External (1).
2.  **ID/Filename**:
    - Internal: Stream index (e.g., `00003`).
    - External: Filename (lexicographically sorted).

This ensures that repeated runs always produce the exact same selection order, regardless of filesystem listing order.

## Configuration Toggles

You can control subtitle behavior using environment variables.

| Variable | Default | Description |
| :--- | :--- | :--- |
| `SUB_LANGS` | `eng,ita` | Comma-separated list of languages to keep. All others (except commentary) are discarded. |
| `PREFER_EXTERNAL_SUBS` | `1` | If `1`, external subtitles are prioritized (Score +0). If `0`, they are treated similarly to internal text subs (Score +100), with internal winning ties. |
| `KEEP_BITMAP_SUBS` | `0` | If `1`, bitmap subtitles are kept (internal PGS/VobSub and external `.sup`, `.idx`+`.sub`). If `0`, they are removed/ignored (useful for ensuring Direct Play). |
| `PREFER_SDH` | `0` | If `1`, SDH/Hearing Impaired subtitles are preferred. If `0`, standard subtitles are preferred. |
| `MARK_NORMAL_SUB_DEFAULT` | `1` | If `1`, the best normal subtitle track is flagged as `default`. |

## Sidecar Deletion Safety

When `DELETE=1` (APPLY mode) is enabled, the script can optionally delete external sidecar files that were successfully merged into the output MKV.

**By default, sidecar files are NEVER deleted (`DELETE_SIDECARS=0`).**

To enable deletion, set `DELETE_SIDECARS=1`. Even when enabled, a strict safety check is performed:
1.  **Uniqueness Check**: A sidecar file will only be deleted if it is uniquely anchored to the video being processed.
2.  **Ambiguity Protection**: If a sidecar file matches multiple videos in the same directory (e.g., `movie.srt` matching both `movie.mp4` and `movie.mkv`), it will be preserved to prevent data loss.
3.  **Shared Files**: Files that appear to be shared or ambiguous are skipped with a warning.

## Examples

### Example 1: Basic English & Italian

**Input:**
- `movie.mkv` (Internal: Eng PGS, Ita PGS)
- `movie.eng.srt` (External)
- `movie.ita.forced.srt` (External)

**Config:** Defaults (`SUB_LANGS=eng,ita`, `PREFER_EXTERNAL_SUBS=1`)

**Outcome:**
1.  `movie.eng.srt` -> Kept (External Text > Internal Bitmap). Marked `default`.
2.  `movie.ita.forced.srt` -> Kept (External Forced). Dispositions: `forced`.
3.  Internal PGS tracks -> Discarded (lower rank than external text).

### Example 2: Filtering Languages

**Input:**
- `show.mkv` (Internal: Eng, Spa, Rus, Fra)

**Config:** `SUB_LANGS=eng,spa`

**Outcome:**
1.  Eng -> Kept. Marked `default`.
2.  Spa -> Kept.
3.  Rus -> Removed (not in `SUB_LANGS`).
4.  Fra -> Removed (not in `SUB_LANGS`).

### Example 3: Removing Bitmap Subs

**Input:**
- `film.mkv` (Internal: Eng PGS [Bitmap], Eng SRT [Text])

**Config:** `KEEP_BITMAP_SUBS=0`

**Outcome:**
1.  Eng SRT -> Kept. Marked `default`.
2.  Eng PGS -> Removed.
