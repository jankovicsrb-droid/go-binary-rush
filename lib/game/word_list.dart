// Words grouped by length for progressive difficulty.
// All lowercase — display layer handles uppercase.

const kWordList = [
  // 3–4 letters
  'bit', 'bus', 'cpu', 'hex', 'ram', 'run', 'key', 'map', 'net',
  'log', 'bug', 'fix', 'add', 'set', 'pop', 'cat', 'dog', 'sun',
  'sea', 'sky', 'ice', 'art', 'war', 'joy', 'code', 'data', 'file',
  'flag', 'fork', 'hash', 'list', 'loop', 'node', 'null', 'port',
  'root', 'sort', 'swap', 'tree', 'type', 'void', 'byte', 'base',
  'fire', 'wind', 'rain', 'snow', 'bird', 'fish', 'star', 'moon',
  'wave', 'cave', 'road', 'gate', 'mine', 'rock', 'leaf', 'seed',

  // 5–7 letters
  'array', 'cache', 'class', 'queue', 'stack', 'tuple', 'yield',
  'debug', 'error', 'proxy', 'query', 'regex', 'token', 'patch',
  'pixel', 'frame', 'scene', 'tiger', 'eagle', 'river', 'ocean',
  'storm', 'stone', 'light', 'night', 'music', 'dance', 'dream',
  'world', 'north', 'south', 'green', 'black', 'white', 'brave',
  'swift', 'sharp', 'quiet', 'magic', 'lucky', 'happy', 'proud',
  'binary', 'buffer', 'cursor', 'daemon', 'decode', 'encode',
  'kernel', 'memory', 'module', 'packet', 'parser', 'output',
  'signal', 'socket', 'syntax', 'vector', 'thread', 'server',
  'forest', 'bridge', 'castle', 'flower', 'mirror', 'planet',
  'silver', 'shadow', 'winter', 'autumn', 'spring', 'summer',
  'friend', 'family', 'legend', 'travel', 'harbor', 'beacon',

  // 8–10 letters
  'compiler', 'database', 'debugger', 'function', 'instance',
  'iterator', 'keyboard', 'listener', 'markdown', 'overflow',
  'pipeline', 'platform', 'register', 'renderer', 'selector',
  'template', 'terminal', 'variable', 'callback', 'argument',
  'document', 'password', 'mountain', 'together', 'champion',
  'treasure', 'panorama', 'calendar', 'absolute', 'creative',
  'fragment', 'gradient', 'northern', 'southern', 'thousand',
  'universe', 'wildfire', 'sunlight', 'midnight', 'symphony',
  'internet', 'airplane', 'notebook', 'blackout', 'feedback',
  'algorithm', 'framework', 'interface', 'parameter', 'recursion',
  'exception', 'prototype', 'singleton', 'debugging', 'namespace',
  'benchmark', 'clipboard', 'directory', 'multicast', 'operation',
];
