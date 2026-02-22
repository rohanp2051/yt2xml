# yt2xml

Fetch video transcripts via [yt-dlp](https://github.com/yt-dlp/yt-dlp) and output clean XML. Works with any site yt-dlp supports (YouTube, Vimeo, etc.).

## Requirements

- **yt-dlp** >= 2022.02.04 (for `--print-to-file` support)

```bash
brew install yt-dlp
# or
pip install yt-dlp
```

## Installation

```bash
# Install to your profile
nix profile install github:rohanp2051/yt2xml

# Or run directly without installing
nix run github:rohanp2051/yt2xml -- "https://youtu.be/dQw4w9WgXcQ"

# Local build from checkout
nix build .
./result/bin/yt2xml --version
```

## Usage

```
yt2xml [OPTIONS] URL [URL...]
```

### Options

| Flag | Description |
|------|-------------|
| `-o, --output FILE` | Write XML to FILE (atomic write via temp file + mv) |
| `-v, --verbose` | Show full yt-dlp output on stderr |
| `-l, --lang CODES` | Comma-separated subtitle language codes (default: `en`) |
| `--no-desc` | Omit `<d>` description element |
| `--no-channel` | Omit `channel` attribute |
| `--url` | Include `url` attribute in `<t>` elements |
| `-h, --help` | Show help message |
| `--version` | Print version |

### Examples

```bash
# Basic: print transcript XML to stdout
yt2xml "https://youtu.be/dQw4w9WgXcQ"

# Save to a file
yt2xml -o context.xml "https://youtu.be/dQw4w9WgXcQ"

# Multiple videos
yt2xml "https://youtu.be/vid1" "https://youtu.be/vid2"

# Spanish subtitles, falling back to English
yt2xml --lang es,en "https://youtu.be/vid1"

# Minimal output (no description, no channel)
yt2xml --no-desc --no-channel "https://youtu.be/vid1"

# Include source URL in output
yt2xml --url "https://youtu.be/vid1"

# Verbose mode for debugging
yt2xml -v "https://youtu.be/vid1"
```

## Output Format

### Single video

```xml
<t title="Video Title" id="dQw4w9WgXcQ" channel="Channel Name">
<d>Video description text here.</d>
Transcript text as a single paragraph...
</t>
```

### Multiple videos

```xml
<ts>
<t title="First Video" id="abc123" channel="Channel A">
<d>Description of first video.</d>
First transcript text...
</t>
<t title="Second Video" id="def456" channel="Channel B">
<d>Description of second video.</d>
Second transcript text...
</t>
</ts>
```

Failed videos are included as XML comments:

```xml
<!-- Failed: https://youtu.be/bad_id - no subtitles available -->
```

## How It Works

1. Calls yt-dlp to download subtitles (VTT preferred, SRT fallback) and metadata
2. Cleans subtitle files: strips timestamps, VTT/SRT formatting, HTML tags, and deduplicates lines
3. Collapses the transcript into a single paragraph
4. Wraps everything in compact XML with video metadata as attributes

Duplicate URLs are automatically detected and skipped.
