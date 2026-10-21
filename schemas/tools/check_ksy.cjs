// Compiles every schemas/*.ksy with the Kaitai Struct compiler to prove the binary layouts are
// well-formed (DESIGN.md §9.5). CI-only tool; nothing generated here is committed or shipped.
// Usage: node schemas/tools/check_ksy.cjs   (needs kaitai-struct-compiler@0.11.0 and js-yaml@5.5.0)
'use strict';
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const compiler = require('kaitai-struct-compiler');

const dir = path.join(__dirname, '..');
const files = fs.readdirSync(dir).filter((f) => f.endsWith('.ksy')).sort();
if (files.length === 0) {
  console.error('FAIL no .ksy files found');
  process.exit(1);
}
(async () => {
  let failed = false;
  for (const file of files) {
    try {
      const spec = yaml.load(fs.readFileSync(path.join(dir, file), 'utf8'));
      const out = await compiler.compile('python', spec, null, false);
      console.log(`ok   ${file} (${Object.keys(out).length} generated file(s))`);
    } catch (e) {
      failed = true;
      console.error(`FAIL ${file}: ${e && e.message ? e.message : e}`);
    }
  }
  process.exit(failed ? 1 : 0);
})();
