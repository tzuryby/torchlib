--[[ Abstract list. ]]
local List = torch.class('List')

--[[ Constructor. `values` is an optional table used to initialize the list. ]]
function List:__init(values)
  error('not implemented')
end

--[[ Adds `val` to list at index `index`. By defalut `index` defaults to the last element. ]]
function List:add(val, index)
  error('not implemented')
end

--[[ Returns the value at index `index`. Asserts error if `index` is out of bounds. ]]
function List:get(index)
  error('not implemented')
end

--[[ Sets the value at index `index` to `val`. Asserts error if `index` is out of bounds. ]]
function List:set(index, val)
  error('not implemented')
end

--[[ Removes the value at index `index`. Elements after `index` will be shifted to the left by 1. Asserts error if `index` is out of bounds. ]]
function List:remove(index)
  error('not implemented')
end

--[[ Returns whether this list is equal to `another`. Lists are considered equal if their values match at every position. ]]
function List:equals(another)
  error('not implemented')
end

--[[ Swaps the value at `i` with the value at `j`. ]]
function List:swap(i, j)
  error('not implemented')
end

--[[ Returns the list in table form. ]]
function List:totable()
  error('not implemented')
end

--[[ Asserts that `index` is inside the list. ]]
function List:assertValidIndex(index)
    assert(index > 0 and index <= self:size()+1, 'index ' .. index .. ' is out of bounds for array of size ' .. self:size())
end

--[[ Returns the size of the list. ]]
function List:size()
  return self._size
end

--[[ Adds a variable number of items to the list. ]]
function List:addMany(...)
  local args = table.pack(...)
  for k, v in ipairs(args) do
    self:add(v)
  end
  return self
end

--[[ Returns whether `val` is in the list. ]]
function List:contains(val)
  for i = 1, self:size() do
    if self:get(i) == val then
      return true
    end
  end
  return false
end

--[[ Returns a copy of this list. ]]
function List:copy()
  return self.new(self.totable())
end

--[[ Returns whether the list is empty. ]]
function List:isEmpty()
  return self:size() == 0
end

--[[ Returns a new list containing a consecutive run from this list.

Parameters:
- `start`: the start of the run
- `finish` (optional): the end of the run, defaults to the end of the list
]]
function List:sublist(start, finish)
  finish = finish or self:size()
  local sub = self.new()
  self:assertValidIndex(start)
  self:assertValidIndex(finish)
  for i = start, finish do sub:add(self:get(i)) end
  return sub
end

--[[ Sorts the list in place.
  Parameters:
  - `start` (optional): the start of the sort, defaults to 1
  - `finish` (optional): the end of the sort, defaults to the end of the list
]]
function List:sort(start, finish)
  function partition(l, start, finish)
    pivotIndex = math.random(start, finish)
    pivot = self:get(pivotIndex)
    self:swap(pivotIndex, finish)
    write = start
    for i = start, finish-1 do
      if self:get(i) < pivot then
        self:swap(i, write)
        write = write + 1
      end
    end
    self:swap(write, finish)
    return write
  end
  start = start or 1
  finish = finish or self:size()
  if start < finish then
    pivot = partition(self, start, finish)
    self:sort(start, pivot-1)
    self:sort(pivot+1, finish)
  end
end

function List:tostring()
  local s = torch.type(self) .. '['
  local max = 5
  for i = 1, math.min(self:size(), max) do
    s = s .. tostring(self:get(i))
    if i == max then
      s = s .. ', ...'
    elseif i ~= self:size() then
      s = s .. ', '
    end
  end
  s = s .. ']'
  return s
end

torch.getmetatable('List').__tostring__ = List.tostring


--[[ Array implementation of list. ]]
local ArrayList = torch.class('ArrayList', 'List')

function ArrayList:__init(values)
  values = values or {}
  self._arr = Util.tableCopy(values)
  self._size = #self._arr
end

function ArrayList:add(val, index)
  if index == nil then
    table.insert(self._arr, val)
  else
    self:assertValidIndex(index)
    table.insert(self._arr, index, val)
  end
  self._size = self._size + 1
  return self
end

function ArrayList:get(index)
  self:assertValidIndex(index)
  return self._arr[index]
end

function ArrayList:set(index, val)
  self:assertValidIndex(index)
  self._arr[index] = val
  return self
end

function ArrayList:remove(index)
  self:assertValidIndex(index)
  self._size = self._size - 1
  return table.remove(self._arr, index)
end

function ArrayList:equals(another)
  if self:size() ~= another:size() then return false end
  for i = 1, self:size() do
    if self:get(i) ~= another:get(i) then return false end
  end
  return true
end

function ArrayList:swap(i, j)
  self:assertValidIndex(i)
  self:assertValidIndex(j)
  temp = self._arr[i]
  self._arr[i] = self._arr[j]
  self._arr[j] = temp
  return self
end

function ArrayList:totable()
  tab = {}
  for i = 1, self:size() do
    table.insert(tab, self._arr[i])
  end
  return tab
end


--[[ Linked list implementation of list. ]]
local LinkedList = torch.class('LinkedList', 'List')
LinkedList.Node = torch.class('LinkedListNode')

function LinkedList.Node:__init(val)
  self.val = val
  self.next = nil
end

function LinkedList.Node:tostring()
  return 'LinkedListNode(' .. self.val .. ')'
end

torch.getmetatable('LinkedListNode').__tostring__ = LinkedList.Node.tostring

function LinkedList:__init(values)
  self._sentinel = LinkedList.Node.new()
  self._tail = self._sentinel
  self._size = 0
  values = values or {}
  for _, v in ipairs(values) do
    self:add(v)
  end
end

function LinkedList:size()
  return self._size
end

--[[ Returns the head of the linked list. ]]
function LinkedList:head()
  return self._sentinel.next
end

function LinkedList:add(val, index)
  node = LinkedList.Node.new(val)
  if index == nil then
    self._tail.next = node
    self._tail = node
  else
    self:assertValidIndex(index)
    count = 1
    prev = self._sentinel
    curr = self:head()
    while count ~= index do
      prev = curr
      curr = curr.next
      count = count + 1
    end
    prev.next = node
    prev.next.next = curr
  end
  self._size = self._size + 1
  return self
end

function LinkedList:get(index)
  self:assertValidIndex(index)
  count = 1
  curr = self:head()
  while count ~= index do
    curr = curr.next
    count = count + 1
  end
  return curr.val
end

function LinkedList:set(index, val)
  self:assertValidIndex(index)
  count = 1
  curr = self:head()
  while count ~= index do
    curr = curr.next
    count = count + 1
  end
  curr.val = val
  return self
end

function LinkedList:remove(index)
  self:assertValidIndex(index)
  count = 1
  prev = self._sentinel
  curr = self:head()
  while count ~= index do
    prev = curr
    curr = curr.next
    count = count + 1
  end
  prev.next = curr.next
  if curr == self._tail then self._tail = prev end
  self._size = self._size - 1
  return curr.val
end

function LinkedList:swap(i, j)
  self:assertValidIndex(i)
  self:assertValidIndex(j)
  count = 1
  prev = self._sentinel
  curr = self:head()
  while count <= math.max(i, j) do
    if count == i then
      prevI = prev
      currI = curr
    end
    if count == j then
      prevJ = prev
      currJ = curr
    end
    count = count + 1
    prev = curr
    curr = curr.next
  end
  assert(prevI)
  assert(currI)
  assert(prevJ)
  assert(currJ)
  prevI.next = currJ
  prevJ.next = currI
  temp = currI.next
  currI.next = currJ.next
  currJ.next = temp
  return self
end

function LinkedList:equals(another)
  if self:size() ~= another:size() then return false end
  curr = self:head()
  currAnother = another:head()
  while curr ~= nil do
    if curr.val ~= currAnother.val then return false end
    curr = curr.next
    currAnother = currAnother.next
  end
  return true
end

function LinkedList:totable()
  tab = {}
  curr = self:head()
  while curr do
    table.insert(tab, curr.val)
    curr = curr.next
  end
  return tab
end
