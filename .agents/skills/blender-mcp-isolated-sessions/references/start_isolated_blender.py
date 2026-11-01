"""Start a session-owned Blender MCP socket on a non-default port.

Run inside a FRESH Blender process started with --factory-startup, so it
cannot alter any already-running Blender session:

    blender --factory-startup --python work/start_isolated_blender.py

Replace ADDON_PATH and PORT for your task. The blender_mcp addon lives in the
user addons directory of the machine's main Blender install; factory startup
does not load it, so we import it by file path.
"""

from __future__ import annotations

import importlib.util
import pathlib
import sys

import bpy

ADDON_PATH = pathlib.Path(
    "/path/to/user/Library/Application Support/Blender/<version>/scripts/addons/blender_mcp.py"
)
PORT = 9877  # default addon port is 9876; pick 9876 + task index


def load_addon():
    spec = importlib.util.spec_from_file_location("isolated_blender_mcp", ADDON_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load Blender MCP addon: {ADDON_PATH}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


addon = load_addon()

# The addon normally auto-starts on 9876 during register(). Temporarily suppress
# that one call, then start our own server explicitly on the isolated port.
real_start = addon.BlenderMCPServer.start
addon.BlenderMCPServer.start = lambda self: None
addon.register()
addon.BlenderMCPServer.start = real_start

if hasattr(bpy.types, "blendermcp_server"):
    del bpy.types.blendermcp_server

bpy.context.scene.blendermcp_port = PORT
bpy.types.blendermcp_server = addon.BlenderMCPServer(port=PORT)
bpy.types.blendermcp_server.start()
bpy.context.scene.blendermcp_server_running = True
bpy.context.scene["session_owner"] = "your-task-name"
bpy.context.scene["mcp_port"] = PORT
print(f"SESSION_OWNED_BLENDER_MCP_READY port={PORT}")
