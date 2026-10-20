#!/usr/bin/env python3
"""Add SDKConfigurations/Extractors Swift files to an Xcode pbxproj."""

from __future__ import annotations

import sys
import uuid
from pathlib import Path


def gen_id() -> str:
    return uuid.uuid4().hex[:24].upper()


def main(pbxproj_path: Path) -> None:
    extractors_dir = pbxproj_path.parent.parent / "demosdk/Library/SDKConfigurations/Extractors"
    if not extractors_dir.is_dir():
        print(f"skip (no Extractors dir): {pbxproj_path}")
        return

    swift_files = sorted(f.name for f in extractors_dir.glob("*.swift"))
    if not swift_files:
        print(f"skip (empty Extractors): {pbxproj_path}")
        return

    text = pbxproj_path.read_text()
    if "SelphIDExtractorProvider.swift" in text and "Extractors */" in text:
        print(f"skip (already patched): {pbxproj_path}")
        return

    file_refs = {name: gen_id() for name in swift_files}
    build_files = {name: gen_id() for name in swift_files}
    group_id = gen_id()

    insert_at = text.find("/* End PBXBuildFile section */")
    if insert_at == -1:
        raise SystemExit("PBXBuildFile section not found")

    build_lines = []
    for name in swift_files:
        build_lines.append(
            f"\t\t{build_files[name]} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[name]} /* {name} */; }};"
        )
    text = text[:insert_at] + "\n".join(build_lines) + "\n" + text[insert_at:]

    insert_at = text.find("/* End PBXFileReference section */")
    ref_lines = []
    for name in swift_files:
        ref_lines.append(
            f"\t\t{file_refs[name]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};"
        )
    text = text[:insert_at] + "\n".join(ref_lines) + "\n" + text[insert_at:]

    marker = "/* SDKConfigurations */ = {"
    idx = text.find(marker)
    if idx == -1:
        marker = "path = SDKConfigurations;"
        idx = text.find(marker)
    if idx == -1:
        raise SystemExit("SDKConfigurations group not found")

    children_start = text.find("children = (", idx)
    children_end = text.find(");", children_start)
    group_block = (
        f"\t\t{group_id} /* Extractors */ = {{\n"
        f"\t\t\tisa = PBXGroup;\n"
        f"\t\t\tchildren = (\n"
        + "".join(f"\t\t\t\t{file_refs[name]} /* {name} */,\n" for name in swift_files)
        + f"\t\t\t);\n"
        f"\t\t\tpath = Extractors;\n"
        f"\t\t\tsourceTree = \"<group>\";\n"
        f"\t\t}};\n"
    )
    insert_group_at = text.find("/* End PBXGroup section */")
    text = text[:insert_group_at] + group_block + text[insert_group_at:]

    children_block = text[children_start:children_end]
    if group_id not in children_block:
        text = (
            text[:children_end]
            + f"\n\t\t\t\t{group_id} /* Extractors */,"
            + text[children_end:]
        )

    sources_marker = "13F510B7281937A5001E3CF1 /* Sources */ = {"
    if sources_marker not in text:
        # fallback: first PBXSourcesBuildPhase for demosdk main target
        sources_marker = "isa = PBXSourcesBuildPhase;"
        idx = text.find(sources_marker)
        files_idx = text.find("files = (", idx)
    else:
        files_idx = text.find("files = (", text.find(sources_marker))

    files_end = text.find(");", files_idx)
    source_lines = "".join(
        f"\n\t\t\t\t{build_files[name]} /* {name} in Sources */,"
        for name in swift_files
    )
    text = text[:files_end] + source_lines + text[files_end:]

    pbxproj_path.write_text(text)
    print(f"patched: {pbxproj_path} ({len(swift_files)} files)")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        demos = [
            "sdkmobile-demo-classic-pods",
            "sdkmobile-demo-classic-videorcording.pods",
            "sdkmobile-demo-idv",
            "onboarding-fileuploader.demo",
        ]
        root = Path(__file__).resolve().parents[1]
        for demo in demos:
            main(root / demo / "demosdk.xcodeproj/project.pbxproj")
    else:
        main(Path(sys.argv[1]))
