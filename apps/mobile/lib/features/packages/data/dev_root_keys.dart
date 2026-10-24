/// The root keys this binary trusts on the `dev` and `lab` channels: the dev
/// key set `tools/gsctl/keys/dev/root-keys.json` (§15 D62, D85), byte for
/// byte (a test keeps them equal). Beta and production embed the S27
/// ceremony keys instead; until then they have no embedded root and do not
/// sync.
const String devRootKeysJson = '''
{
  "scheme": "ed25519",
  "threshold": 2,
  "keys": [
    {
      "name": "root-1",
      "keyId": "7efee8296fba8f167f8786d903c37ceeeaf2a984a66783631ab19245f36808a1",
      "public": "7e22c7813774f70bd0bd08fe4e80b4fa619a72abc97471f0421eedf58af22a07"
    },
    {
      "name": "root-2",
      "keyId": "467b963bf8760633248856e98f3efe25b6d9ed30733c46e2560fb2128a77905b",
      "public": "7148d7cf94d5a05bb4e25df611520bc1d31aeee671109585a570a5878e9ae8bb"
    },
    {
      "name": "root-3",
      "keyId": "ec9d6f6646350b50e24e167e376cf3c2ec54f08675b17f038a10d38d8b68d9d1",
      "public": "1e102d946e3b035d2b4facd78cb99e3e18bf399c527208ccf42b5abafd5f679e"
    }
  ]
}
''';
