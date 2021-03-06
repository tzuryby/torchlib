local Map = require('torchlib').Map
local HashMap = require('torchlib').HashMap

local TestMap = torch.TestSuite()
local tester = torch.Tester()

function TestMap.testAdd()
  local m = HashMap()
  m:add(10, 'hi')
  local t = {}
  t[10] = 'hi'
  tester:assertTableEq(t, m._map)

  m:add(10, 'bye')
  t[10] = 'bye'
  tester:assertTableEq(t, m._map)

  m:add('hi', 1)
  t['hi'] = 1
  tester:assertTableEq(t, m._map)

  local tab = {'foo'}
  m:add(tab, 'bar')
  t[tab] = 'bar'
  tester:assertTableEq(t, m._map)

  t['a'] = 1
  t['b'] = 2
  t['c'] = 3
  m:addMany({a=1, b=2, c=3})
  tester:assertTableEq(t, m._map)
end

function TestMap.testCopy()
  tester:assert(HashMap{a=1, b=2, c=3}:equals(HashMap{a=1, b=2, c=3}) ~= nil)
  tester:assert(not HashMap{a=1, b=2, c=3}:equals(HashMap{a=1, c=3}))
  tester:assert(not HashMap{a=1, b=2, c=3}:equals(HashMap{a=1, b=2, c=3, d=4}))
end

function TestMap.testEquals()
  local m = HashMap{foo=1, bar=2, baz=3}
  local n = HashMap{foo=1, baz=3}
  tester:asserteq(false, m:equals(n))
  n:add('bar', 10)
  tester:asserteq(false, m:equals(n))
  n:add('bar', 2)
  tester:asserteq(true, m:equals(n))
end

function TestMap.testContains()
  local m = HashMap()
  tester:assert(not m:contains('bar'))
  m:add('bar', 'foo')
  tester:assert(m:contains('bar'))
end

function TestMap.testGet()
  local m = HashMap()
  m:add(10, 'hi')
  m:add(20, 'bye')
  tester:asserteq('hi', m:get(10))
  tester:asserteq('bye', m:get(20))

  tester:assertErrorPattern(function() m:get('bad') end, 'Error: key bad not found in HashMap', 'get invalid key should error')
  tester:assert(m:get('bad', true) == nil)
end

function TestMap.testRemove()
  local m = HashMap()
  m:add(10, 20)
  m:add(20, 30)
  m:remove(10)
  local t = {}
  t[20] = 30
  tester:assertTableEq(t, m._map)

  local s, e = pcall(m.remove, m, 'bad')
  tester:assert(string.match(e, 'Error: key bad not found in HashMap') ~= nil)
end

function TestMap.testSize()
  local m = HashMap()
  tester:asserteq(0, m:size())
  m:add(10, 20)
  tester:asserteq(1, m:size())
  m:add(20, 10)
  tester:asserteq(2, m:size())
  m:remove(20)
  tester:asserteq(1, m:size())
end

function TestMap.testToString()
  local m = HashMap()
  tester:asserteq('tl.HashMap{}', tostring(m))
  m:add('foo', 'bar')
  tester:asserteq('tl.HashMap{foo -> bar}', tostring(m))
  m:add(1, 2)
  tostring(m)
end

function TestMap.testToTable()
  local m = HashMap{foo=1, bar=2, baz=3}
  tester:assertTableEq({foo=1, bar=2, baz=3}, m:totable())
end

function TestMap.testAbstractMethods()
  local funcs = {'__init', 'add', 'addMany', 'copy', 'contains', 'get', 'remove', 'keys', 'equals', 'totable'}
  for _, fname in ipairs(funcs) do
    tester:assertErrorPattern(Map[fname], 'not implemented', fname..' should be a virtual method')
  end
end

tester:add(TestMap)
tester:run()
