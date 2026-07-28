from __future__ import annotations

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[4]
CONFIGURE_SCRIPT = REPOSITORY_ROOT / "images/windrose-native/windrose-configure.py"
REPORT_SCRIPT = REPOSITORY_ROOT / "images/windrose-native/windrose-report.py"


class ConfigureTests(unittest.TestCase):
    def run_configure(self, root: Path, extra_env: dict[str, str] | None = None):
        env = os.environ.copy()
        env.update(
            {
                "WINDROSE_SERVER_ROOT": str(root),
                "WINDROSE_CONFIG_PATH": str(root / "R5/ServerDescription.json"),
                "SERVER_NAME": "Test Server",
                "PASSWORD": "secret",
                "MAX_PLAYER_COUNT": "8",
                "USER_SELECTED_REGION": "EU",
                "P2P_PROXY_ADDRESS": "127.0.0.1",
                "USE_DIRECT_CONNECTION": "1",
                "SERVER_PORT": "28050",
                "AUTO_LOAD_LATEST_BACKUP_IF_HAS_BROKEN": "1",
            }
        )
        if extra_env:
            env.update(extra_env)
        return subprocess.run(
            ["python3", str(CONFIGURE_SCRIPT)], env=env, text=True, capture_output=True, check=False
        )

    def test_fresh_config_and_stable_identity(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / ".windrose-deployment-id").write_text(
                "0.10.0.8.10-dd411cfd\n", encoding="utf-8"
            )
            first = self.run_configure(root)
            self.assertEqual(first.returncode, 0, first.stderr)
            config_path = root / "R5/ServerDescription.json"
            config = json.loads(config_path.read_text(encoding="utf-8"))
            persistent = config["ServerDescription_Persistent"]
            identity = persistent["PersistentServerId"]
            self.assertRegex(identity, r"^[0-9A-F]{32}$")
            self.assertEqual(config["DeploymentId"], "0.10.0.8.10-dd411cfd")
            self.assertEqual(persistent["DirectConnectionServerPort"], 28050)
            self.assertTrue(persistent["IsPasswordProtected"])

            second = self.run_configure(root)
            self.assertEqual(second.returncode, 0, second.stderr)
            updated = json.loads(config_path.read_text(encoding="utf-8"))
            self.assertEqual(
                updated["ServerDescription_Persistent"]["PersistentServerId"], identity
            )

    def test_preserves_generated_invite_and_world_when_variables_are_empty(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "R5/ServerDescription.json"
            path.parent.mkdir(parents=True)
            path.write_text(
                json.dumps(
                    {
                        "Version": 1,
                        "DeploymentId": "current",
                        "ServerDescription_Persistent": {
                            "PersistentServerId": "A" * 32,
                            "InviteCode": "Existing1",
                            "WorldIslandId": "WORLD123",
                        },
                    }
                ),
                encoding="utf-8",
            )
            result = self.run_configure(root, {"INVITE_CODE": "", "WORLD_ISLAND_ID": ""})
            self.assertEqual(result.returncode, 0, result.stderr)
            persistent = json.loads(path.read_text(encoding="utf-8"))[
                "ServerDescription_Persistent"
            ]
            self.assertEqual(persistent["InviteCode"], "Existing1")
            self.assertEqual(persistent["WorldIslandId"], "WORLD123")

    def test_non_empty_variables_override_generated_values(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "R5/ServerDescription.json"
            path.parent.mkdir(parents=True)
            path.write_text(
                json.dumps(
                    {
                        "Version": 1,
                        "ServerDescription_Persistent": {
                            "PersistentServerId": "A" * 32,
                            "InviteCode": "Generated1",
                            "WorldIslandId": "GENERATED_WORLD",
                        },
                    }
                ),
                encoding="utf-8",
            )
            result = self.run_configure(
                root,
                {"INVITE_CODE": "Imported1", "WORLD_ISLAND_ID": "IMPORTED_WORLD"},
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            persistent = json.loads(path.read_text(encoding="utf-8"))[
                "ServerDescription_Persistent"
            ]
            self.assertEqual(persistent["InviteCode"], "Imported1")
            self.assertEqual(persistent["WorldIslandId"], "IMPORTED_WORLD")

    def test_report_writes_effective_values(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            config_path = root / "R5/ServerDescription.json"
            config_path.parent.mkdir(parents=True)
            config_path.write_text(
                json.dumps(
                    {
                        "DeploymentId": "deployment",
                        "ServerDescription_Persistent": {
                            "PersistentServerId": "A" * 32,
                            "InviteCode": "Invite123",
                            "WorldIslandId": "WORLD123",
                        },
                    }
                ),
                encoding="utf-8",
            )
            output_path = root / "R5/GeneratedServerValues.txt"
            env = os.environ.copy()
            env.update(
                {
                    "WINDROSE_SERVER_ROOT": str(root),
                    "WINDROSE_CONFIG_PATH": str(config_path),
                    "WINDROSE_VALUES_PATH": str(output_path),
                    "WINDROSE_UPSTREAM_DIGEST": "sha256:test",
                    "INVITE_CODE": "",
                    "WORLD_ISLAND_ID": "",
                }
            )
            result = subprocess.run(
                ["python3", str(REPORT_SCRIPT)],
                env=env,
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            content = output_path.read_text(encoding="utf-8")
            self.assertIn("INVITE_CODE=Invite123", content)
            self.assertIn("WORLD_ISLAND_ID=WORLD123", content)
            self.assertIn("WINDROSE_UPSTREAM_DIGEST=sha256:test", content)
            self.assertIn("generated/preserved config", result.stdout)

    def test_invalid_json_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = root / "R5/ServerDescription.json"
            path.parent.mkdir(parents=True)
            path.write_text("{invalid", encoding="utf-8")
            result = self.run_configure(root)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(path.read_text(encoding="utf-8"), "{invalid")


if __name__ == "__main__":
    unittest.main()
