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

### Imperative (per-user, not tied to a config file)

```bash
# Install to your profile
nix profile install github:rohanp2051/yt2xml

# Or run directly without installing
nix run github:rohanp2051/yt2xml -- "https://youtu.be/dQw4w9WgXcQ"

# Local build from checkout
nix build .
./result/bin/yt2xml --version
```

### Declarative (pinned in your system or home-manager flake)

Add yt2xml as a flake input:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    yt2xml.url = "github:rohanp2051/yt2xml";
  };
}
```

Then include the package:

```nix
# NixOS (configuration.nix)
environment.systemPackages = [ inputs.yt2xml.packages.${system}.default ];

# Or home-manager (home.nix)
home.packages = [ inputs.yt2xml.packages.${system}.default ];
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

### Per-URL Overrides

Append colon-separated flags to any URL to override global settings for that specific video. The `:--` delimiter is used because it never appears in real URLs.

| Per-URL Flag | Description |
|---|---|
| `--no-desc` | Omit description for this URL |
| `--no-channel` | Omit channel for this URL |
| `--url` | Include URL attribute for this URL |
| `--desc` | Keep description (override global `--no-desc`) |
| `--channel` | Keep channel (override global `--no-channel`) |
| `--no-url` | Hide URL attribute (override global `--url`) |
| `--lang=CODES` | Override subtitle language for this URL |

Multiple flags are comma-separated: `URL:--no-desc,--no-channel`

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

# Per-URL: omit description for first video only
yt2xml "https://youtu.be/vid1:--no-desc" "https://youtu.be/vid2"

# Global --no-desc, but second video keeps its description
yt2xml --no-desc "https://youtu.be/vid1" "https://youtu.be/vid2:--desc"

# Different subtitle languages per video
yt2xml "https://youtu.be/vid1:--lang=es" "https://youtu.be/vid2:--lang=en"

# Multiple per-URL flags
yt2xml "https://youtu.be/vid1:--no-desc,--no-channel"
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

## AI Assistant Integration

yt2xml is designed to pipe video transcripts directly into LLM context windows. The compact XML format minimizes token usage while preserving structure.

```bash
# Feed a video transcript to an LLM via stdin
yt2xml "https://youtu.be/dQw4w9WgXcQ" | llm "Summarize this video"

# Save context for a multi-video research session
yt2xml --no-desc --no-channel \
  "https://youtu.be/vid1" \
  "https://youtu.be/vid2:--lang=es" \
  -o context.xml
```

Per-URL overrides let you tailor each video's metadata to your prompt needs — keep descriptions for videos you want summarized, omit them for videos you only need transcripts from.
