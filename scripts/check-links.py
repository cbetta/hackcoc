#!/usr/bin/env python3
"""Checks that every local link and asset in the site resolves the way the
image's nginx (nginx.conf) resolves it: the file itself or the same path plus
.html, and for a path ending in / its index.html or the .html it redirects
to. Links to other sites are not fetched.

    check-links.py <site dir> [--known <file>] [own hostname ...]

Absolute links to the site's own hostnames count as local. Targets listed in
the --known file (one path per line, # for comments) were already broken when
the site came off Netlify and are reported as a count only. Exits 1 if
anything else is broken."""
import argparse
import os
import sys
from collections import defaultdict
from html.parser import HTMLParser
from urllib.parse import unquote, urljoin, urlsplit

args = argparse.ArgumentParser()
args.add_argument("site")
args.add_argument("--known")
args.add_argument("hosts", nargs="*")
args = args.parse_args()

root = os.path.abspath(args.site)
own = set(args.hosts)
known = set()
if args.known:
    with open(args.known, encoding="utf-8") as f:
        known = {line.strip() for line in f if line.strip() and not line.startswith("#")}


class Refs(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.refs = []

    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if not value:
                continue
            if name in ("href", "src"):
                self.refs.append(value.strip())
            elif name == "srcset":
                self.refs += [c.split()[0] for c in value.split(",") if c.strip()]


def resolves(path):
    full = os.path.normpath(root + path)
    if full != root and not full.startswith(root + os.sep):
        return False
    if path.endswith("/"):
        return os.path.isfile(os.path.join(full, "index.html")) or os.path.isfile(full + ".html")
    return os.path.isfile(full) or os.path.isfile(full + ".html")


broken = defaultdict(set)
pages = 0
for dirpath, _, files in os.walk(root):
    for name in files:
        if not name.endswith(".html"):
            continue
        pages += 1
        file = os.path.join(dirpath, name)
        page = "/" + os.path.relpath(file, root).replace(os.sep, "/")
        parser = Refs()
        with open(file, encoding="utf-8", errors="replace") as f:
            parser.feed(f.read())
        for ref in parser.refs:
            url = urlsplit(urljoin("http://site" + page, ref))
            if url.scheme not in ("http", "https"):
                continue
            if url.netloc != "site" and url.netloc not in own:
                continue
            path = unquote(url.path) or "/"
            if not resolves(path):
                broken[path].add(page)

new = {p: pages_ for p, pages_ in broken.items() if p not in known}
old = len(broken) - len(new)
print(f"{pages} pages checked, {len(broken)} broken local targets ({old} already broken on Netlify).")
for path in sorted(new):
    refs = sorted(new[path])
    print(f"  {path}  <- {refs[0]}" + (f" and {len(refs) - 1} more" if len(refs) > 1 else ""))
sys.exit(1 if new else 0)
