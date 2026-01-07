# Subtitle Policy & Configuration

This document outlines how the Jellyfin Converter handles subtitle selection, merging, and sidecar discovery.

## Sidecar Naming & Discovery
The converter automatically discovers external subtitle files located in the same directory as the video.

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

## Configuration Toggles

You can control subtitle behavior using environment variables.

| Variable | Default | Description |
| :--- | :--- | :--- |
| `SUB_LANGS` | `eng,ita` | Comma-separated list of languages to keep. All others (except commentary) are discarded. |
| `PREFER_EXTERNAL_SUBS` | `1` | If `1`, external subtitles are ranked higher than internal ones. If `0`, they are treated equally (quality/codec decides). |
| `KEEP_BITMAP_SUBS` | `1` | If `1`, bitmap subtitles (PGS, VOBSUB) are kept. If `0`, they are removed (useful for ensuring Direct Play). |
| `PREFER_SDH` | `0` | If `1`, SDH/Hearing Impaired subtitles are preferred. If `0`, standard subtitles are preferred. |
| `MARK_NORMAL_SUB_DEFAULT` | `1` | If `1`, the best normal subtitle track is flagged as `default`. |

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
2.  Eng PGS -> Removed (Bitmap subtitles disabled).

## Behavior Guarantees

### Deterministic Selection
For a given set of input streams and sidecar files, the converter **ALWAYS** selects the same set of subtitles in the same order. This ensures reproducibility and stability across runs.

### Sidecar Priority
External sidecar files (e.g., `.srt`) that match the strict naming rules **ALWAYS** supersede internal subtitles for the same language and type (Normal/Forced) if they are considered "better" (e.g., Text > Bitmap).

### Forced Track Preservation
At least one **forced** track per allowed language is preserved if available. This ensures that foreign language segments in a movie are always covered.

### Safety Mechanisms
- **Read-Only Discovery**: The subtitle discovery phase never modifies files.
- **Dry Run Default**: `DRY_RUN=1` is the default. It prints the plan but touches nothing.
- **Atomic Writes**: Conversion writes to a temporary file (or separate output directory) and only moves/replaces if successful.

### Best-Effort Behaviors
- **Language Detection**: Relies on `ffprobe` metadata. Missing, empty, or unknown language tags are normalized to `und` (Undefined). `und` tracks are generally preserved as fallback unless specific language filtering excludes them.
- **Commentary Detection**: Relies on "commentary" or "director" keywords in the track title. If these are missing, a commentary track might be treated as a normal audio/subtitle track (and potentially removed if the language doesn't match).
