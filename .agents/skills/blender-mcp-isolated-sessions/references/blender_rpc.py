"""Small CLI client for YOUR task's isolated Blender MCP socket.

Requires the blender_mcp python package (BlenderConnection) importable in the
environment you run this from. Point --port at YOUR session's port only.

    python3 blender_rpc.py --port 9877 scene-info
    python3 blender_rpc.py --port 9877 run-script work/01_foundation.py
    python3 blender_rpc.py --port 9877 code "import bpy; print(len(bpy.data.objects))"
"""

from __future__ import annotations

import argparse
import json
import pathlib

from blender_mcp.server import BlenderConnection


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=9877)
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("scene-info")

    run = sub.add_parser("run-script")
    run.add_argument("path", type=pathlib.Path)

    code = sub.add_parser("code")
    code.add_argument("source")

    args = parser.parse_args()
    connection = BlenderConnection(host="127.0.0.1", port=args.port)

    if args.command == "scene-info":
        result = connection.send_command("get_scene_info", {})
    elif args.command == "run-script":
        path = args.path.expanduser().resolve()
        source = (
            f"exec(compile(open({str(path)!r}, 'r', encoding='utf-8').read(), "
            f"{str(path)!r}, 'exec'), {{'__name__': '__main__'}})"
        )
        result = connection.send_command("execute_code", {"code": source})
    else:
        result = connection.send_command("execute_code", {"code": args.source})

    print(json.dumps(result, indent=2, default=str))


if __name__ == "__main__":
    main()
