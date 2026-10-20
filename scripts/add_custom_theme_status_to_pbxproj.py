#!/usr/bin/env python3
"""Add demosdk/Themes/CustomThemeStatus.swift to an Xcode pbxproj."""

from __future__ import annotations

import sys
import uuid
from pathlib import Path

FILE_NAME = "CustomThemeStatus.swift"


def gen_id() -> str:
    return uuid.uuid4().hex[:24].upper()


def main(pbxproj_path: Path) -> None:
    theme_file = pbxproj_path.parent.parent / f"demosdk/Themes/{FILE_NAME}"
    if not theme_file.is_file():
        print(f"skip (missing {theme_file})")
        return

    text = pbxproj_path.read_text()
    if FILE_NAME in text:
        print(f"skip (already in project): {pbxproj_path}")
        return

    file_ref = gen_id()
    build_file = gen_id()
    themes_group = gen_id()

    insert_at = text.find("/* End PBXBuildFile section */")
    text = (
        text[:insert_at]
        + f"\t\t{build_file} /* {FILE_NAME} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {FILE_NAME} */; }};\n"
        + text[insert_at:]
    )

    insert_at = text.find("/* End PBXFileReference section */")
    text = (
        text[:insert_at]
        + f"\t\t{file_ref} /* {FILE_NAME} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {FILE_NAME}; sourceTree = \"<group>\"; }};\n"
        + text[insert_at:]
    )

    group_block = (
        f"\t\t{themes_group} /* Themes */ = {{\n"
        f"\t\t\tisa = PBXGroup;\n"
        f"\t\t\tchildren = (\n"
        f"\t\t\t\t{file_ref} /* {FILE_NAME} */,\n"
        f"\t\t\t);\n"
        f"\t\t\tpath = Themes;\n"
        f"\t\t\tsourceTree = \"<group>\";\n"
        f"\t\t}};\n"
    )
    insert_group_at = text.find("/* End PBXGroup section */")
    text = text[:insert_group_at] + group_block + text[insert_group_at:]

    marker = "/* demosdk */ = {"
    idx = text.find(marker)
    if idx == -1:
        marker = "path = demosdk;"
        idx = text.find(marker)
    if idx == -1:
        raise SystemExit("demosdk group not found")

    children_start = text.find("children = (", idx)
    children_end = text.find(");", children_start)
    text = (
        text[:children_end]
        + f"\n\t\t\t\t{themes_group} /* Themes */,"
        + text[children_end:]
    )

    sources_marker = "/* Sources */ = {"
    sidx = text.find(sources_marker)
    if sidx == -1:
        raise SystemExit("Sources build phase not found")
    files_start = text.find("files = (", sidx)
    files_end = text.find(");", files_start)
    text = (
        text[:files_end]
        + f"\n\t\t\t\t{build_file} /* {FILE_NAME} in Sources */,"
        + text[files_end:]
    )

    pbxproj_path.write_text(text)
    print(f"patched: {pbxproj_path}")


if __name__ == "__main__":
    for arg in sys.argv[1:] or []:
        main(Path(arg))
    if len(sys.argv) == 1:
        root = Path(__file__).resolve().parents[1]
        for pbx in sorted(root.glob("*/demosdk.xcodeproj/project.pbxproj")):
            main(pbx)
