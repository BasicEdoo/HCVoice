const fs = require('fs');
const path = require('path');

// Optional directory lets the same suite check the extracted release package.
const root = path.resolve(process.argv[2] || path.join(__dirname, '..'));
const deps = process.env.HCV_TEST_DEPS;
const load = name => require(deps ? path.join(deps, name) : name);
const parser = load('luaparse');
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = load('fengari');
const files = fs.readFileSync(path.join(root, 'HCVoice.toc'), 'utf8')
  .split(/\r?\n/)
  .map(line => line.trim())
  .filter(line => line && !line.startsWith('#'));

if (!files.length || files.some(file => !file.endsWith('.lua'))) {
  throw new Error('Expected a nonempty Lua runtime list in HCVoice.toc');
}

for (const file of files) {
  parser.parse(fs.readFileSync(path.join(root, file), 'utf8'), { luaVersion: '5.1' });
  console.log('Lua 5.1 syntax:', file);
}

const state = lauxlib.luaL_newstate();
lualib.luaL_openlibs(state);
const luaRoot = root.replaceAll('\\', '/').replaceAll("'", "\\'");
const prefix = `ROOT = '${luaRoot}'\nFILES = {${files.map(file => JSON.stringify(file)).join(',')}}\n`;
const program = prefix
  + fs.readFileSync(path.join(__dirname, 'behavior.lua'), 'utf8')
  + '\n'
  + fs.readFileSync(path.join(__dirname, 'refinement_combat.lua'), 'utf8')
  + '\n'
  + fs.readFileSync(path.join(__dirname, 'refinement_social.lua'), 'utf8')
  + '\n'
  + fs.readFileSync(path.join(__dirname, 'refinement_profiles.lua'), 'utf8')
  + '\n'
  + fs.readFileSync(path.join(__dirname, 'bosses.lua'), 'utf8');

try {
  if (lauxlib.luaL_dostring(state, to_luastring(program)) !== lua.LUA_OK) {
    console.error(to_jsstring(lua.lua_tostring(state, -1)));
    process.exitCode = 1;
  }
} finally {
  lua.lua_close(state);
}
