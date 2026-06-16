local nc = {}
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local sin = math.sin
local char = string.char
local byte = string.byte
local fmt = string.format
local tcat = table.concat
local tunpack = table.unpack
local tick = os.clock
local MOD32 = 2 ^ 32
local _bit32 = type(bit32) == "table" and bit32 or nil
local Hasnativebitwise = _bit32 and type(_bit32.band) == "function" and type(_bit32.bor) == "function" and type(_bit32.bxor) == "function" and type(_bit32.bnot) == "function" and type(_bit32.lshift) == "function" and type(_bit32.rshift) == "function"
--- band
-- @param a type Description
-- @param b type Description
-- @return type Description
local function band(a, b)
	if Hasnativebitwise then
		return _bit32.band(a or 0, b or 0)
	end
	a, b = a or 0, b or 0;
	local r, p = 0, 1
	for _ = 1, 32 do
		if a % 2 == 1 and b % 2 == 1 then
			r = r + p
		end;
		a, b, p = floor(a / 2), floor(b / 2), p * 2
	end
	return r
end
--- bor
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bor(a, b)
	if Hasnativebitwise then
		return _bit32.bor(a or 0, b or 0)
	end
	a, b = a or 0, b or 0;
	local r, p = 0, 1
	for _ = 1, 32 do
		if a % 2 + b % 2 >= 1 then
			r = r + p
		end;
		a, b, p = floor(a / 2), floor(b / 2), p * 2
	end
	return r
end
--- bxor
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bxor(a, b)
	if Hasnativebitwise then
		return _bit32.bxor(a or 0, b or 0)
	end
	a, b = a or 0, b or 0;
	local r, p = 0, 1
	for _ = 1, 32 do
		if a % 2 ~= b % 2 then
			r = r + p
		end;
		a, b, p = floor(a / 2), floor(b / 2), p * 2
	end
	return r
end
--- bnot
-- @param a type Description
-- @return type Description
local function bnot(a)
	if Hasnativebitwise then
		return _bit32.bnot(a or 0)
	end
	return MOD32 - 1 - (a or 0)
end
--- lsh
-- @param a type Description
-- @param n type Description
-- @return type Description
local function lsh(a, n)
	if Hasnativebitwise then
		return _bit32.lshift(a or 0, n or 0) % MOD32
	end
	a, n = a or 0, n or 0
	if n <= 0 then
		return a % MOD32
	end;
	if n >= 32 then
		return 0
	end
	return (a * floor(2 ^ n)) % MOD32
end
--- rsh
-- @param a type Description
-- @param n type Description
-- @return type Description
local function rsh(a, n)
	if Hasnativebitwise then
		return _bit32.rshift(a or 0, n or 0)
	end
	a, n = a or 0, n or 0
	if n <= 0 then
		return a % MOD32
	end;
	if n >= 32 then
		return 0
	end
	return floor((a % MOD32) / floor(2 ^ n))
end
--- rrot
-- @param x type Description
-- @param n type Description
-- @return type Description
local function rrot(x, n)
	x, n = x or 0, n % 32;
	if n == 0 then
		return x % MOD32
	end
	return bor(rsh(x, n), lsh(x, 32 - n))
end
--- rrotl
-- @param x type Description
-- @param n type Description
-- @return type Description
local function rrotl(x, n)
	x, n = x or 0, n % 32;
	if n == 0 then
		return x % MOD32
	end
	return bor(lsh(x, n), rsh(x, 32 - n))
end
--- rot64
-- @param h type Description
-- @param l type Description
-- @param n type Description
-- @return type Description
local function rot64(h, l, n)
	h, l, n = h or 0, l or 0, n or 0;
	n = n % 64
	if n == 0 then
		return h, l
	end;
	if n == 32 then
		return l, h
	end
	if n < 32 then
		return bor(lsh(h, n), rsh(l, 32 - n)) % MOD32, bor(lsh(l, n), rsh(h, 32 - n)) % MOD32
	else
		n = n - 32
		return bor(lsh(l, n), rsh(h, 32 - n)) % MOD32, bor(lsh(h, n), rsh(l, 32 - n)) % MOD32
	end
end
--- not64
-- @param h type Description
-- @param l type Description
-- @return type Description
local function not64(h, l)
	return bnot(h or 0), bnot(l or 0)
end
local Buffer = {};
Buffer.__index = Buffer
--- Buffer.from
-- @param data type Description
-- @param enc type Description
-- @return type Description
function Buffer.from(data, enc)
	local self = setmetatable({
		_b = {}
	}, Buffer)
	enc = enc or "utf8"
	if type(data) == "string" then
		if enc == "hex" then
			for h in data:gmatch("..") do
				self._b[# self._b + 1] = tonumber(h, 16)
			end
		elseif enc == "base64" then
			local T = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
			local lk = {}
			for i = 1, # T do
				lk[T:sub(i, i)] = i - 1
			end
			data = data:gsub("[^" .. T .. "=]", "")
			local pad = (data:match("=*$") or ""):len()
			data = data:gsub("=", "A")
			for i = 1, # data, 4 do
				local v1, v2, v3, v4 = lk[data:sub(i, i)], lk[data:sub(i + 1, i + 1)], lk[data:sub(i + 2, i + 2)], lk[data:sub(i + 3, i + 3)]
				if not v1 or not v2 or not v3 or not v4 then
					break
				end
				local n = v1 * 262144 + v2 * 4096 + v3 * 64 + v4
				self._b[# self._b + 1] = floor(n / 65536) % 256
				if # data - i > 3 or pad < 2 then
					self._b[# self._b + 1] = floor(n / 256) % 256
				end
				if # data - i > 3 or pad < 1 then
					self._b[# self._b + 1] = n % 256
				end
			end
		else
			for i = 1, # data do
				self._b[i] = byte(data, i)
			end
		end
	elseif type(data) == "table" then
		if getmetatable(data) == Buffer then
			for i, v in ipairs(data._b) do
				self._b[i] = v
			end
		else
			for _, v in ipairs(data) do
				self._b[# self._b + 1] = v % 256
			end
		end
	elseif type(data) == "number" then
		for i = 1, data do
			self._b[i] = 0
		end
	end
	self.length = # self._b;
	return self
end
--- Buffer.alloc
-- @param n type Description
-- @param fill type Description
-- @return type Description
function Buffer.alloc(n, fill)
	local t = {};
	for i = 1, n do
		t[i] = fill or 0
	end;
	return Buffer.from(t)
end
--- Buffer.concat
-- @param list type Description
-- @param total type Description
-- @return type Description
function Buffer.concat(list, total)
	local m = {}
	for _, buf in ipairs(list) do
		if type(buf) == "string" then
			for i = 1, # buf do
				m[# m + 1] = byte(buf, i)
			end
		elseif Buffer.isBuffer(buf) then
			for _, b in ipairs(buf._b) do
				m[# m + 1] = b
			end
		end
	end
	if total then
		while # m < total do
			m[# m + 1] = 0
		end
		while # m > total do
			m[# m] = nil
		end
	end
	return Buffer.from(m)
end
--- Buffer.isBuffer
-- @param v type Description
-- @return type Description
function Buffer.isBuffer(v)
	return getmetatable(v) == Buffer
end
--- Buffer:toString
-- @param enc type Description
-- @return type Description
function Buffer:toString(enc)
	enc = enc or "utf8"
	if enc == "hex" then
		local h = {};
		for _, b in ipairs(self._b) do
			h[# h + 1] = fmt("%02x", b)
		end;
		return tcat(h)
	elseif enc == "base64" then
		local T = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		local res, bytes = {}, self._b
		for i = 1, # bytes, 3 do
			local a, b, c = bytes[i] or 0, bytes[i + 1] or 0, bytes[i + 2] or 0
			local n = a * 65536 + b * 256 + c
			res[# res + 1] = T:sub(floor(n / 262144) % 64 + 1, floor(n / 262144) % 64 + 1)
			res[# res + 1] = T:sub(floor(n / 4096) % 64 + 1, floor(n / 4096) % 64 + 1)
			res[# res + 1] = bytes[i + 1] and T:sub(floor(n / 64) % 64 + 1, floor(n / 64) % 64 + 1) or "="
			res[# res + 1] = bytes[i + 2] and T:sub(n % 64 + 1, n % 64 + 1) or "="
		end
		return tcat(res)
	else
		local s = {};
		for _, b in ipairs(self._b) do
			s[# s + 1] = char(b)
		end;
		return tcat(s)
	end
end
--- Buffer:byteAt
-- @param i type Description
-- @return type Description
function Buffer:byteAt(i)
	return self._b[i + 1] or 0
end
--- Buffer:readUInt8
-- @param o type Description
-- @return type Description
function Buffer:readUInt8(o)
	return self._b[(o or 0) + 1] or 0
end
--- Buffer:readInt8
-- @param o type Description
-- @return type Description
function Buffer:readInt8(o)
	local v = self:readUInt8(o);
	return v >= 128 and v - 256 or v
end
--- Buffer:readUInt16LE
-- @param o type Description
-- @return type Description
function Buffer:readUInt16LE(o)
	local i = (o or 0) + 1;
	return (self._b[i] or 0) + (self._b[i + 1] or 0) * 256
end
--- Buffer:readUInt16BE
-- @param o type Description
-- @return type Description
function Buffer:readUInt16BE(o)
	local i = (o or 0) + 1;
	return (self._b[i] or 0) * 256 + (self._b[i + 1] or 0)
end
--- Buffer:readUInt32LE
-- @param o type Description
-- @return type Description
function Buffer:readUInt32LE(o)
	local i = (o or 0) + 1;
	return (self._b[i] or 0) + (self._b[i + 1] or 0) * 256 + (self._b[i + 2] or 0) * 65536 + (self._b[i + 3] or 0) * 16777216
end
--- Buffer:readUInt32BE
-- @param o type Description
-- @return type Description
function Buffer:readUInt32BE(o)
	local i = (o or 0) + 1;
	return (self._b[i] or 0) * 16777216 + (self._b[i + 1] or 0) * 65536 + (self._b[i + 2] or 0) * 256 + (self._b[i + 3] or 0)
end
--- Buffer:readInt32LE
-- @param o type Description
-- @return type Description
function Buffer:readInt32LE(o)
	local v = self:readUInt32LE(o);
	return v >= 0x80000000 and v - 0x100000000 or v
end
--- Buffer:readInt32BE
-- @param o type Description
-- @return type Description
function Buffer:readInt32BE(o)
	local v = self:readUInt32BE(o);
	return v >= 0x80000000 and v - 0x100000000 or v
end
--- Buffer:writeUInt8
-- @param v type Description
-- @param o type Description
-- @return type Description
function Buffer:writeUInt8(v, o)
	self._b[(o or 0) + 1] = v % 256;
	self.length = # self._b
end
--- Buffer:writeInt8
-- @param v type Description
-- @param o type Description
-- @return type Description
function Buffer:writeInt8(v, o)
	self:writeUInt8(v < 0 and v + 256 or v, o)
end
--- Buffer:writeUInt16LE
-- @param v type Description
-- @param o type Description
-- @return type Description
function Buffer:writeUInt16LE(v, o)
	local i = (o or 0) + 1;
	self._b[i] = v % 256;
	self._b[i + 1] = floor(v / 256) % 256;
	self.length = # self._b
end
--- Buffer:writeUInt16BE
-- @param v type Description
-- @param o type Description
-- @return type Description
function Buffer:writeUInt16BE(v, o)
	local i = (o or 0) + 1;
	self._b[i] = floor(v / 256) % 256;
	self._b[i + 1] = v % 256;
	self.length = # self._b
end
--- Buffer:writeUInt32LE
-- @param v type Description
-- @param o type Description
-- @return type Description
function Buffer:writeUInt32LE(v, o)
	local i = (o or 0) + 1;
	self._b[i] = v % 256;
	self._b[i + 1] = floor(v / 256) % 256;
	self._b[i + 2] = floor(v / 65536) % 256;
	self._b[i + 3] = floor(v / 16777216) % 256;
	self.length = # self._b
end
--- Buffer:writeUInt32BE
-- @param v type Description
-- @param o type Description
-- @return type Description
function Buffer:writeUInt32BE(v, o)
	local i = (o or 0) + 1;
	self._b[i] = floor(v / 16777216) % 256;
	self._b[i + 1] = floor(v / 65536) % 256;
	self._b[i + 2] = floor(v / 256) % 256;
	self._b[i + 3] = v % 256;
	self.length = # self._b
end
--- Buffer:writeInt32LE
-- @param v type Description
-- @param o type Description
-- @return type Description
function Buffer:writeInt32LE(v, o)
	self:writeUInt32LE(v < 0 and v + 0x100000000 or v, o)
end
--- Buffer:slice
-- @param s type Description
-- @param e type Description
-- @return type Description
function Buffer:slice(s, e)
	s = (s or 0) + 1;
	e = e or self.length;
	local sub = {}
	for i = s, e do
		sub[# sub + 1] = self._b[i]
	end;
	return Buffer.from(sub)
end
--- Buffer:subarray
-- @param s type Description
-- @param e type Description
-- @return type Description
function Buffer:subarray(s, e)
	return self:slice(s, e)
end
--- Buffer:indexOf
-- @param val type Description
-- @param from type Description
-- @return type Description
function Buffer:indexOf(val, from)
	from = (from or 0) + 1
	if type(val) == "number" then
		for i = from, self.length do
			if self._b[i] == val then
				return i - 1
			end
		end
	elseif type(val) == "string" then
		if # val == 0 then
			return from - 1
		end
		for i = from, self.length - # val + 1 do
			local ok = true
			for j = 1, # val do
				if self._b[i + j - 1] ~= byte(val, j) then
					ok = false;
					break
				end
			end
			if ok then
				return i - 1
			end
		end
	elseif Buffer.isBuffer(val) then
		if val.length == 0 then
			return from - 1
		end
		for i = from, self.length - val.length + 1 do
			local ok = true
			for j = 1, val.length do
				if self._b[i + j - 1] ~= val._b[j] then
					ok = false;
					break
				end
			end
			if ok then
				return i - 1
			end
		end
	end
	return - 1
end
--- Buffer:includes
-- @param val type Description
-- @param from type Description
-- @return type Description
function Buffer:includes(val, from)
	return self:indexOf(val, from) ~= - 1
end
--- Buffer:equals
-- @param other type Description
-- @return type Description
function Buffer:equals(other)
	if self.length ~= other.length then
		return false
	end
	for i = 1, self.length do
		if self._b[i] ~= other._b[i] then
			return false
		end
	end
	return true
end
--- Buffer:fill
-- @param val type Description
-- @param s type Description
-- @param e type Description
-- @return type Description
function Buffer:fill(val, s, e)
	s = (s or 0) + 1;
	e = e or self.length
	for i = s, e do
		self._b[i] = val % 256
	end;
	return self
end
--- Buffer:copy
-- @param target type Description
-- @param tStart type Description
-- @param sStart type Description
-- @param sEnd type Description
-- @return type Description
function Buffer:copy(target, tStart, sStart, sEnd)
	tStart = tStart or 0;
	sStart = sStart or 0;
	sEnd = sEnd or self.length
	for i = sStart, sEnd - 1 do
		target._b[tStart + i - sStart + 1] = self._b[i + 1]
	end
	target.length = # target._b
end
--- Buffer:compare
-- @param other type Description
-- @return type Description
function Buffer:compare(other)
	for i = 1, math.min(self.length, other.length) do
		if self._b[i] < other._b[i] then
			return - 1
		elseif self._b[i] > other._b[i] then
			return 1
		end
	end
	if self.length < other.length then
		return - 1
	elseif self.length > other.length then
		return 1
	else
		return 0
	end
end
--- Buffer:toJSON
-- @return type Description
function Buffer:toJSON()
	return {
		type = "Buffer",
		data = self._b
	}
end
Buffer.__tostring = function(self)
	return "Buffer<" .. self:toString("hex") .. ">"
end
Buffer.__len = function(self)
	return self.length
end
--- cooperativeYield
-- @return type Description
local function cooperativeYield()
	if type(task) == "table" and task.wait then
		task.wait()
	end
end
local BigInt = {};
BigInt.__index = BigInt
local BASE = 10000000;
local BASEDIGITS = 7
--- bigNew
-- @param n type Description
-- @return type Description
local function bigNew(n)
	local self = setmetatable({
		sign = 1,
		d = {}
	}, BigInt)
	if type(n) == "number" then
		if n < 0 then
			self.sign = - 1;
			n = - n
		end
		while n > 0 do
			self.d[# self.d + 1] = n % BASE;
			n = floor(n / BASE)
		end
	elseif type(n) == "string" then
		if n:sub(1, 1) == "-" then
			self.sign = - 1;
			n = n:sub(2)
		else
			self.sign = 1
		end
		for i = # n, 1, - BASEDIGITS do
			local s = math.max(1, i - BASEDIGITS + 1);
			self.d[# self.d + 1] = tonumber(n:sub(s, i))
		end
		while # self.d > 0 and self.d[# self.d] == 0 do
			self.d[# self.d] = nil
		end
	elseif type(n) == "table" and getmetatable(n) == BigInt then
		self.sign = n.sign;
		for i, v in ipairs(n.d) do
			self.d[i] = v
		end
	end
	if # self.d == 0 then
		self.sign = 1
	end;
	return self
end
--- bigIsZero
-- @param a type Description
-- @return type Description
local function bigIsZero(a)
	return # a.d == 0 or (# a.d == 1 and a.d[1] == 0)
end
--- bigTrim
-- @param a type Description
-- @return type Description
local function bigTrim(a)
	while # a.d > 0 and a.d[# a.d] == 0 do
		a.d[# a.d] = nil
	end
	if # a.d == 0 then
		a.sign = 1
	end;
	return a
end
--- bigAbsCmp
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigAbsCmp(a, b)
	if # a.d ~= # b.d then
		return # a.d > # b.d and 1 or - 1
	end
	for i = # a.d, 1, - 1 do
		if a.d[i] ~= b.d[i] then
			return a.d[i] > b.d[i] and 1 or - 1
		end
	end
	return 0
end
--- bigCmp
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigCmp(a, b)
	if a.sign ~= b.sign then
		return a.sign > b.sign and 1 or - 1
	end
	local c = bigAbsCmp(a, b);
	return a.sign == 1 and c or - c
end
--- bigAbsAdd
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigAbsAdd(a, b)
	local r = bigNew(0);
	local carry = 0;
	local len = math.max(# a.d, # b.d)
	for i = 1, len do
		local s = (a.d[i] or 0) + (b.d[i] or 0) + carry
		r.d[i] = s % BASE;
		carry = floor(s / BASE)
	end
	if carry > 0 then
		r.d[len + 1] = carry
	end;
	return r
end
--- bigAbsSub
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigAbsSub(a, b)
	local r = bigNew(0);
	local borrow = 0
	for i = 1, # a.d do
		local s = (a.d[i] or 0) - (b.d[i] or 0) - borrow
		if s < 0 then
			s = s + BASE;
			borrow = 1
		else
			borrow = 0
		end;
		r.d[i] = s
	end
	bigTrim(r);
	return r
end
--- bigAdd
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigAdd(a, b)
	if a.sign == b.sign then
		local r = bigAbsAdd(a, b);
		r.sign = a.sign;
		return bigTrim(r)
	end
	local c = bigAbsCmp(a, b)
	if c == 0 then
		return bigNew(0)
	end
	local r
	if c > 0 then
		r = bigAbsSub(a, b);
		r.sign = a.sign
	else
		r = bigAbsSub(b, a);
		r.sign = b.sign
	end
	return bigTrim(r)
end
--- bigSub
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigSub(a, b)
	local bn = bigNew(b);
	bn.sign = - b.sign
	if bigIsZero(b) then
		bn.sign = 1
	end;
	return bigAdd(a, bn)
end
--- bigMul
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigMul(a, b)
	local r = bigNew(0);
	r.d = {}
	for i = 1, # a.d + # b.d do
		r.d[i] = 0
	end
	for i = 1, # a.d do
		local carry = 0
		for j = 1, # b.d do
			local cur = r.d[i + j - 1] + a.d[i] * b.d[j] + carry
			r.d[i + j - 1] = cur % BASE;
			carry = floor(cur / BASE)
		end
		if carry > 0 then
			r.d[i + # b.d] = (r.d[i + # b.d] or 0) + carry
		end
	end
	r.sign = a.sign * b.sign;
	bigTrim(r);
	return r
end
--- bigDivMod
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigDivMod(a, b)
	if bigIsZero(b) then
		error("[bigint] division by zero")
	end
	local q = bigNew(0);
	local r = bigNew(0)
	q.d = {};
	for i = 1, # a.d do
		q.d[i] = 0
	end
	local bLen = # b.d
	local bTopF = b.d[bLen] + ((bLen >= 2 and b.d[bLen - 1] or 0) / BASE)
	for i = # a.d, 1, - 1 do
		table.insert(r.d, 1, a.d[i]);
		bigTrim(r)
		local rLen = # r.d;
		local qd = 0
		if rLen >= bLen then
			local est
			if rLen > bLen then
				local num = r.d[rLen] * BASE + (r.d[rLen - 1] or 0) + ((r.d[rLen - 2] or 0) / BASE)
				est = math.min(BASE - 1, math.floor(num / bTopF))
			else
				local num = r.d[rLen] + ((r.d[rLen - 1] or 0) / BASE)
				est = math.min(BASE - 1, math.floor(num / bTopF))
			end
			if est < 0 then
				est = 0
			end
			local t = bigMul(b, bigNew(est));
			t.sign = 1
			local guard = 0
			while est > 0 and bigAbsCmp(t, r) > 0 do
				est = est - 1;
				t = bigAbsSub(t, b);
				guard = guard + 1
				if guard > 32 then
					local lo2, hi2 = 0, est
					while lo2 < hi2 do
						local mid = floor((lo2 + hi2 + 1) / 2)
						local tm = bigMul(b, bigNew(mid));
						tm.sign = 1
						if bigAbsCmp(tm, r) <= 0 then
							lo2 = mid
						else
							hi2 = mid - 1
						end
					end
					est = lo2;
					t = bigMul(b, bigNew(lo2));
					t.sign = 1;
					break
				end
			end
			local tnext = bigAbsAdd(t, b)
			while bigAbsCmp(tnext, r) <= 0 do
				est = est + 1;
				t = tnext;
				tnext = bigAbsAdd(t, b)
			end
			qd = est;
			r = bigAbsSub(r, t)
		end
		q.d[i] = qd
	end
	q.sign = a.sign * b.sign;
	r.sign = a.sign
	bigTrim(q);
	bigTrim(r)
	if bigIsZero(r) then
		r.sign = 1
	end;
	return q, r
end
--- bigMod
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigMod(a, b)
	local _, r = bigDivMod(a, b);
	return r
end
--- bigDiv
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigDiv(a, b)
	local q = bigDivMod(a, b);
	return q
end
--- bigModExp
-- @param base type Description
-- @param exp type Description
-- @param mod type Description
-- @return type Description
local function bigModExp(base, exp, mod)
	if bigIsZero(mod) then
		error("[bigint] modexp: mod is zero")
	end
	if bigIsZero(exp) then
		return bigNew(1)
	end
	if bigCmp(mod, bigNew(1)) == 0 then
		return bigNew(0)
	end
	base = bigMod(base, mod)
	local tab = {}
	tab[0] = bigNew(1);
	tab[1] = base
	for i = 2, 15 do
		tab[i] = bigMod(bigMul(tab[i - 1], base), mod)
	end
	local bits = {}
	local e = bigNew(exp);
	e.sign = 1
	local two = bigNew(2)
	while not bigIsZero(e) do
		local _, rem = bigDivMod(e, two)
		bits[# bits + 1] = bigIsZero(rem) and 0 or 1
		e = bigDiv(e, two)
	end
	local nbits = # bits
	local pad = (4 - (nbits % 4)) % 4
	local result = bigNew(1)
	local i = nbits
	local firstGroupSize = 4 - pad
	if firstGroupSize > 0 and firstGroupSize < 4 then
		local val = 0
		for _ = 1, firstGroupSize do
			val = val * 2 + bits[i];
			i = i - 1
		end
		result = tab[val]
	end
	while i >= 4 do
		for _ = 1, 4 do
			result = bigMod(bigMul(result, result), mod)
		end
		local val = 0
		for _ = 1, 4 do
			val = val * 2 + bits[i];
			i = i - 1
		end
		if val > 0 then
			result = bigMod(bigMul(result, tab[val]), mod)
		end
	end
	return result
end
--- bigGcd
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigGcd(a, b)
	a = bigNew(a);
	b = bigNew(b);
	a.sign = 1;
	b.sign = 1
	while not bigIsZero(b) do
		local r = bigMod(a, b);
		a = b;
		b = r
	end;
	return a
end
--- bigExtGcd
-- @param a type Description
-- @param b type Description
-- @return type Description
local function bigExtGcd(a, b)
	if bigIsZero(a) then
		return bigNew(b), bigNew(0), bigNew(1)
	end
	local g, x, y = bigExtGcd(bigMod(b, a), a)
	local qb, _ = bigDivMod(b, a)
	return g, bigSub(y, bigMul(qb, x)), bigNew(x)
end
--- bigModInverse
-- @param a type Description
-- @param m type Description
-- @return type Description
local function bigModInverse(a, m)
	local g, x = bigExtGcd(bigMod(a, m), m)
	if bigCmp(g, bigNew(1)) ~= 0 then
		error("[bigint] modular inverse does not exist")
	end
	local r = bigMod(bigAdd(x, m), m);
	r.sign = 1;
	return r
end
--- bigFromBytes
-- @param buf type Description
-- @return type Description
local function bigFromBytes(buf)
	local n = bigNew(0);
	local bytes = Buffer.isBuffer(buf) and buf._b or buf
	for i = 1, # bytes do
		n = bigAdd(bigMul(n, bigNew(256)), bigNew(bytes[i]))
	end;
	return n
end
--- bigToBytes
-- @param n type Description
-- @param minLen type Description
-- @return type Description
local function bigToBytes(n, minLen)
	n = bigNew(n);
	n.sign = 1;
	local bytes = {};
	local b256 = bigNew(256)
	while not bigIsZero(n) do
		local _, r = bigDivMod(n, b256);
		local rv = 0
		for i = 1, # r.d do
			rv = rv + r.d[i] * (BASE ^ (i - 1))
		end
		table.insert(bytes, 1, floor(rv) % 256);
		n = bigDiv(n, b256)
	end
	if minLen then
		while # bytes < minLen do
			table.insert(bytes, 1, 0)
		end
	end
	if # bytes == 0 then
		bytes = {
			0
		}
	end;
	return bytes
end
--- bigModSmall
-- @param a type Description
-- @param p type Description
-- @return type Description
local function bigModSmall(a, p)
	local r = 0
	for i = # a.d, 1, - 1 do
		r = (r * BASE + a.d[i]) % p
	end
	return r
end
--- bigAddSmall
-- @param a type Description
-- @param k type Description
-- @return type Description
local function bigAddSmall(a, k)
	local r = bigNew(0);
	r.d = {}
	for i = 1, # a.d do
		r.d[i] = a.d[i]
	end
	local carry = k;
	local i = 1
	while carry > 0 do
		local s = (r.d[i] or 0) + carry
		r.d[i] = s % BASE;
		carry = floor(s / BASE);
		i = i + 1
	end
	r.sign = 1;
	return r
end
local SMALL_PRIMES = {}
do
	local limit = 2000
	local isComp = {}
	for n = 3, limit, 2 do
		if not isComp[n] then
			SMALL_PRIMES[# SMALL_PRIMES + 1] = n
			for j = n * n, limit, 2 * n do
				isComp[j] = true
			end
		end
	end
end
--- bigIsPrime
-- @param n type Description
-- @param k type Description
-- @return type Description
local function bigIsPrime(n, k)
	k = k or 8
	local one = bigNew(1);
	local two = bigNew(2);
	local three = bigNew(3)
	if bigCmp(n, two) < 0 then
		return false
	end
	if bigCmp(n, two) == 0 or bigCmp(n, three) == 0 then
		return true
	end
	local _, rem = bigDivMod(n, two);
	if bigIsZero(rem) then
		return false
	end
	local d = bigSub(n, one);
	local r = 0
	local _, dr = bigDivMod(d, two)
	while bigIsZero(dr) do
		d = bigDiv(d, two);
		r = r + 1;
		_, dr = bigDivMod(d, two)
	end
	local nMinus1 = bigSub(n, one)
	local crypto = nc.crypto
	for _ = 1, k do
		local nBytes = # bigToBytes(n) + 1
		local rb = crypto.randomBytes(nBytes)
		local a = bigFromBytes(rb);
		a.sign = 1
		a = bigMod(a, bigSub(n, bigNew(4)));
		a = bigAdd(a, two)
		local x = bigModExp(a, d, n);
		local passed = false
		if bigCmp(x, one) == 0 or bigCmp(x, nMinus1) == 0 then
			passed = true
		else
			for _ = 1, r - 1 do
				x = bigModExp(x, two, n)
				if bigCmp(x, nMinus1) == 0 then
					passed = true;
					break
				end
			end
		end
		if not passed then
			return false
		end
	end
	return true
end
--- bigGenPrime
-- @param bits type Description
-- @return type Description
local function bigGenPrime(bits)
	local byteCount = floor(bits / 8)
	local rb = nc.crypto.randomBytes(byteCount)
	rb._b[1] = bor(rb._b[1] or 0, 0x80);
	rb._b[byteCount] = bor(rb._b[byteCount] or 0, 0x01)
	local candidate = bigFromBytes(rb);
	candidate.sign = 1
	local rems = {}
	for idx = 1, # SMALL_PRIMES do
		rems[idx] = bigModSmall(candidate, SMALL_PRIMES[idx])
	end
	local tries = 0
	while true do
		local good = true
		for idx = 1, # SMALL_PRIMES do
			if rems[idx] == 0 then
				good = false;
				break
			end
		end
		if good then
			cooperativeYield()
			if bigIsPrime(candidate, 8) then
				return candidate
			end
		end
		candidate = bigAddSmall(candidate, 2)
		for idx = 1, # SMALL_PRIMES do
			local p = SMALL_PRIMES[idx];
			rems[idx] = (rems[idx] + 2) % p
		end
		tries = tries + 1
		if tries % 64 == 0 then
			cooperativeYield()
		end
	end
end
--- constantTimeCompare
-- @param a type Description
-- @param b type Description
-- @return type Description
local function constantTimeCompare(a, b)
	if type(a) == "string" and type(b) == "string" then
		if # a ~= # b then
			local dummy = 0;
			for i = 1, # a do
				dummy = bor(dummy, bxor(byte(a, i), byte(a, i)))
			end;
			return false
		end
		local result = 0;
		for i = 1, # a do
			result = bor(result, bxor(byte(a, i), byte(b, i)))
		end;
		return result == 0
	elseif Buffer.isBuffer(a) and Buffer.isBuffer(b) then
		if a.length ~= b.length then
			local dummy = 0;
			for i = 1, a.length do
				dummy = bor(dummy, bxor(a._b[i], a._b[i]))
			end;
			return false
		end
		local result = 0;
		for i = 1, a.length do
			result = bor(result, bxor(a._b[i], b._b[i]))
		end;
		return result == 0
	end
	return false
end
--- wrapError
-- @param fn type Description
-- @param name type Description
-- @return type Description
local function wrapError(fn, name)
	return function(...)
		local results = table.pack(pcall(fn, ...))
		if not results[1] then
			error(("[crypto.%s] %s"):format(name, tostring(results[2])), 2)
		end
		return table.unpack(results, 2, results.n)
	end
end
--- asyncRun
-- @param fn type Description
-- @param cb type Description
-- @return type Description
local function asyncRun(fn, cb)
	local co = coroutine.create(function()
		local ok, r = pcall(fn)
		if cb then
			local errArg, resArg
			if ok then
				errArg, resArg = nil, r
			else
				errArg, resArg = r, nil
			end
			if type(task) == "table" and task.defer then
				task.defer(function()
					cb(errArg, resArg)
				end)
			else
				cb(errArg, resArg)
			end
		end
	end)
	coroutine.resume(co)
end
local crypto = {};
nc.crypto = crypto
--- tostr
-- @param d type Description
-- @return type Description
local function tostr(d)
	if Buffer.isBuffer(d) then
		return d:toString("utf8")
	end;
	return tostring(d)
end
--- hexToRaw
-- @param h type Description
-- @return type Description
local function hexToRaw(h)
	local t = {};
	for i = 1, # h, 2 do
		t[# t + 1] = char(tonumber(h:sub(i, i + 1), 16))
	end;
	return tcat(t)
end
--- sha1raw
-- @param msg type Description
-- @return type Description
local function sha1raw(msg)
	msg = tostring(msg)
	local h0, h1, h2, h3, h4 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0
	local bits = # msg * 8;
	msg = msg .. "\x80"
	while # msg % 64 ~= 56 do
		msg = msg .. "\x00"
	end
	for i = 7, 0, - 1 do
		msg = msg .. char(floor(bits / (2 ^ (8 * i))) % 256)
	end
	for chunk = 0, # msg / 64 - 1 do
		local W = {}
		for i = 0, 15 do
			local o = chunk * 64 + i * 4 + 1
			W[i] = byte(msg, o) * 16777216 + byte(msg, o + 1) * 65536 + byte(msg, o + 2) * 256 + byte(msg, o + 3)
		end
		for i = 16, 79 do
			local v = bxor(bxor(bxor(W[i - 3], W[i - 8]), W[i - 14]), W[i - 16])
			W[i] = (lsh(v, 1) + rsh(v, 31)) % MOD32
		end
		local a, b, c, d, e = h0, h1, h2, h3, h4
		for i = 0, 79 do
			local f, k
			if i < 20 then
				f = bor(band(b, c), band(bnot(b), d));
				k = 0x5A827999
			elseif i < 40 then
				f = bxor(bxor(b, c), d);
				k = 0x6ED9EBA1
			elseif i < 60 then
				f = bor(bor(band(b, c), band(b, d)), band(c, d));
				k = 0x8F1BBCDC
			else
				f = bxor(bxor(b, c), d);
				k = 0xCA62C1D6
			end
			local t2 = (lsh(a, 5) + rsh(a, 27) + f + e + k + W[i]) % MOD32
			e = d;
			d = c;
			c = (lsh(b, 30) + rsh(b, 2)) % MOD32;
			b = a;
			a = t2
		end
		h0 = (h0 + a) % MOD32;
		h1 = (h1 + b) % MOD32;
		h2 = (h2 + c) % MOD32;
		h3 = (h3 + d) % MOD32;
		h4 = (h4 + e) % MOD32
	end
	return fmt("%08x%08x%08x%08x%08x", h0, h1, h2, h3, h4)
end
local SHA256_K = {
	0x428a2f98,
	0x71374491,
	0xb5c0fbcf,
	0xe9b5dba5,
	0x3956c25b,
	0x59f111f1,
	0x923f82a4,
	0xab1c5ed5,
	0xd807aa98,
	0x12835b01,
	0x243185be,
	0x550c7dc3,
	0x72be5d74,
	0x80deb1fe,
	0x9bdc06a7,
	0xc19bf174,
	0xe49b69c1,
	0xefbe4786,
	0x0fc19dc6,
	0x240ca1cc,
	0x2de92c6f,
	0x4a7484aa,
	0x5cb0a9dc,
	0x76f988da,
	0x983e5152,
	0xa831c66d,
	0xb00327c8,
	0xbf597fc7,
	0xc6e00bf3,
	0xd5a79147,
	0x06ca6351,
	0x14292967,
	0x27b70a85,
	0x2e1b2138,
	0x4d2c6dfc,
	0x53380d13,
	0x650a7354,
	0x766a0abb,
	0x81c2c92e,
	0x92722c85,
	0xa2bfe8a1,
	0xa81a664b,
	0xc24b8b70,
	0xc76c51a3,
	0xd192e819,
	0xd6990624,
	0xf40e3585,
	0x106aa070,
	0x19a4c116,
	0x1e376c08,
	0x2748774c,
	0x34b0bcb5,
	0x391c0cb3,
	0x4ed8aa4a,
	0x5b9cca4f,
	0x682e6ff3,
	0x748f82ee,
	0x78a5636f,
	0x84c87814,
	0x8cc70208,
	0x90befffa,
	0xa4506ceb,
	0xbef9a3f7,
	0xc67178f2,
}
--- sha256raw
-- @param msg type Description
-- @return type Description
local function sha256raw(msg)
	msg = tostring(msg)
	local H = {
		0x6a09e667,
		0xbb67ae85,
		0x3c6ef372,
		0xa54ff53a,
		0x510e527f,
		0x9b05688c,
		0x1f83d9ab,
		0x5be0cd19
	}
	local bits = # msg * 8;
	msg = msg .. "\x80"
	while # msg % 64 ~= 56 do
		msg = msg .. "\x00"
	end
	msg = msg .. "\x00\x00\x00\x00"
	for i = 3, 0, - 1 do
		msg = msg .. char(floor(bits / (256 ^ i)) % 256)
	end
	for chunk = 0, # msg / 64 - 1 do
		local W = {}
		for i = 0, 15 do
			local o = chunk * 64 + i * 4 + 1
			W[i] = byte(msg, o) * 16777216 + byte(msg, o + 1) * 65536 + byte(msg, o + 2) * 256 + byte(msg, o + 3)
		end
		for i = 16, 63 do
			local s0 = bxor(bxor(rrot(W[i - 15], 7), rrot(W[i - 15], 18)), rsh(W[i - 15], 3))
			local s1 = bxor(bxor(rrot(W[i - 2], 17), rrot(W[i - 2], 19)), rsh(W[i - 2], 10))
			W[i] = (W[i - 16] + s0 + W[i - 7] + s1) % MOD32
		end
		local a, b, c, d, e, f, g, h = tunpack(H)
		for i = 0, 63 do
			local S1 = bxor(bxor(rrot(e, 6), rrot(e, 11)), rrot(e, 25))
			local ch = bxor(band(e, f), band(bnot(e), g))
			local t1 = (h + S1 + ch + SHA256_K[i + 1] + W[i]) % MOD32
			local S0 = bxor(bxor(rrot(a, 2), rrot(a, 13)), rrot(a, 22))
			local maj = bxor(bxor(band(a, b), band(a, c)), band(b, c))
			local t2 = (S0 + maj) % MOD32
			h = g;
			g = f;
			f = e;
			e = (d + t1) % MOD32;
			d = c;
			c = b;
			b = a;
			a = (t1 + t2) % MOD32
		end
		H[1] = (H[1] + a) % MOD32;
		H[2] = (H[2] + b) % MOD32;
		H[3] = (H[3] + c) % MOD32;
		H[4] = (H[4] + d) % MOD32
		H[5] = (H[5] + e) % MOD32;
		H[6] = (H[6] + f) % MOD32;
		H[7] = (H[7] + g) % MOD32;
		H[8] = (H[8] + h) % MOD32
	end
	local hex = {};
	for _, v in ipairs(H) do
		hex[# hex + 1] = fmt("%08x", v)
	end;
	return tcat(hex)
end
local _entropyPool = nil
local _entropyBlockCtr = 0
--- entropySample
-- @return type Description
local function entropySample()
	local parts = {}
	parts[1] = tostring(tick())
	parts[2] = tostring({})
	parts[3] = tostring(entropySample)
	do
		local ok, heapInfo = pcall(function()
			if gcinfo then
				return gcinfo()
			end
			if collectgarbage then
				return collectgarbage("count")
			end
			return tick()
		end)
		parts[4] = tostring(ok and heapInfo or tick())
	end
	parts[5] = tostring(coroutine.create(function()
	end))
	return tcat(parts)
end
--- entropyPoolInit
-- @return type Description
local function entropyPoolInit()
	local seed = {}
	for i = 1, 8 do
		seed[# seed + 1] = entropySample()
	end
	_entropyPool = hexToRaw(sha256raw(tcat(seed)))
end
--- getSecureRandom
-- @param n type Description
-- @return type Description
local function getSecureRandom(n)
	if not _entropyPool then
		entropyPoolInit()
	end
	_entropyPool = hexToRaw(sha256raw(_entropyPool .. entropySample()))
	local out = {}
	local produced = 0
	while produced < n do
		_entropyBlockCtr = _entropyBlockCtr + 1
		local ctrStr = tostring(_entropyBlockCtr)
		local block = hexToRaw(sha256raw(_entropyPool .. "out" .. ctrStr))
		out[# out + 1] = block
		_entropyPool = hexToRaw(sha256raw(_entropyPool .. "ratchet" .. ctrStr))
		produced = produced + # block
	end
	local raw = tcat(out):sub(1, n)
	local bytes = {};
	for i = 1, n do
		bytes[i] = byte(raw, i)
	end
	return Buffer.from(bytes)
end
local MD5_T = {}
for i = 1, 64 do
	MD5_T[i] = floor(abs(sin(i)) * MOD32) % MOD32
end
local MD5_S = {
	7,
	12,
	17,
	22,
	7,
	12,
	17,
	22,
	7,
	12,
	17,
	22,
	7,
	12,
	17,
	22,
	5,
	9,
	14,
	20,
	5,
	9,
	14,
	20,
	5,
	9,
	14,
	20,
	5,
	9,
	14,
	20,
	4,
	11,
	16,
	23,
	4,
	11,
	16,
	23,
	4,
	11,
	16,
	23,
	4,
	11,
	16,
	23,
	6,
	10,
	15,
	21,
	6,
	10,
	15,
	21,
	6,
	10,
	15,
	21,
	6,
	10,
	15,
	21
}
--- md5raw
-- @param msg type Description
-- @return type Description
local function md5raw(msg)
	msg = tostring(msg);
	local olen = # msg * 8;
	msg = msg .. "\x80"
	while # msg % 64 ~= 56 do
		msg = msg .. "\x00"
	end
	for i = 0, 7 do
		msg = msg .. char(floor(olen / (2 ^ (8 * i))) % 256)
	end
	local a0, b0, c0, d0 = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
	for chunk = 0, # msg / 64 - 1 do
		local M = {}
		for i = 0, 15 do
			local o = chunk * 64 + i * 4 + 1
			M[i] = byte(msg, o) + byte(msg, o + 1) * 256 + byte(msg, o + 2) * 65536 + byte(msg, o + 3) * 16777216
		end
		local A, B, C, D = a0, b0, c0, d0
		for i = 0, 63 do
			local F, g2
			if i < 16 then
				F = bor(band(B, C), band(bnot(B), D));
				g2 = i
			elseif i < 32 then
				F = bor(band(D, B), band(bnot(D), C));
				g2 = (5 * i + 1) % 16
			elseif i < 48 then
				F = bxor(bxor(B, C), D);
				g2 = (3 * i + 5) % 16
			else
				F = bxor(C, bor(B, bnot(D)));
				g2 = (7 * i) % 16
			end
			F = (F + A + MD5_T[i + 1] + M[g2]) % MOD32;
			A = D;
			D = C;
			C = B
			B = (B + bor(lsh(F, MD5_S[i + 1]), rsh(F, 32 - MD5_S[i + 1]))) % MOD32
		end
		a0 = (a0 + A) % MOD32;
		b0 = (b0 + B) % MOD32;
		c0 = (c0 + C) % MOD32;
		d0 = (d0 + D) % MOD32
	end
--- le
-- @param n type Description
-- @return type Description
	local function le(n)
		return fmt("%02x%02x%02x%02x", n % 256, floor(n / 256) % 256, floor(n / 65536) % 256, floor(n / 16777216) % 256)
	end
	return le(a0) .. le(b0) .. le(c0) .. le(d0)
end
local SHA256_IV = {
	0x6a09e667,
	0xbb67ae85,
	0x3c6ef372,
	0xa54ff53a,
	0x510e527f,
	0x9b05688c,
	0x1f83d9ab,
	0x5be0cd19
}
local SHA1_IV = {
	0x67452301,
	0xEFCDAB89,
	0x98BADCFE,
	0x10325476,
	0xC3D2E1F0
}
local MD5_IV = {
	0x67452301,
	0xefcdab89,
	0x98badcfe,
	0x10325476
}
--- sha256_compress
-- @param H type Description
-- @param block type Description
-- @return type Description
local function sha256_compress(H, block)
	local W = {}
	for i = 0, 15 do
		local o = i * 4 + 1
		W[i] = byte(block, o) * 16777216 + byte(block, o + 1) * 65536 + byte(block, o + 2) * 256 + byte(block, o + 3)
	end
	for i = 16, 63 do
		local s0 = bxor(bxor(rrot(W[i - 15], 7), rrot(W[i - 15], 18)), rsh(W[i - 15], 3))
		local s1 = bxor(bxor(rrot(W[i - 2], 17), rrot(W[i - 2], 19)), rsh(W[i - 2], 10))
		W[i] = (W[i - 16] + s0 + W[i - 7] + s1) % MOD32
	end
	local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
	for i = 0, 63 do
		local S1 = bxor(bxor(rrot(e, 6), rrot(e, 11)), rrot(e, 25))
		local ch = bxor(band(e, f), band(bnot(e), g))
		local t1 = (h + S1 + ch + SHA256_K[i + 1] + W[i]) % MOD32
		local S0 = bxor(bxor(rrot(a, 2), rrot(a, 13)), rrot(a, 22))
		local maj = bxor(bxor(band(a, b), band(a, c)), band(b, c))
		local t2 = (S0 + maj) % MOD32
		h = g;
		g = f;
		f = e;
		e = (d + t1) % MOD32;
		d = c;
		c = b;
		b = a;
		a = (t1 + t2) % MOD32
	end
	return {
		(H[1] + a) % MOD32,
		(H[2] + b) % MOD32,
		(H[3] + c) % MOD32,
		(H[4] + d) % MOD32,
		(H[5] + e) % MOD32,
		(H[6] + f) % MOD32,
		(H[7] + g) % MOD32,
		(H[8] + h) % MOD32
	}
end
--- sha1_compress
-- @param H type Description
-- @param block type Description
-- @return type Description
local function sha1_compress(H, block)
	local W = {}
	for i = 0, 15 do
		local o = i * 4 + 1
		W[i] = byte(block, o) * 16777216 + byte(block, o + 1) * 65536 + byte(block, o + 2) * 256 + byte(block, o + 3)
	end
	for i = 16, 79 do
		local v = bxor(bxor(bxor(W[i - 3], W[i - 8]), W[i - 14]), W[i - 16])
		W[i] = (lsh(v, 1) + rsh(v, 31)) % MOD32
	end
	local a, b, c, d, e = H[1], H[2], H[3], H[4], H[5]
	for i = 0, 79 do
		local f, k
		if i < 20 then
			f = bor(band(b, c), band(bnot(b), d));
			k = 0x5A827999
		elseif i < 40 then
			f = bxor(bxor(b, c), d);
			k = 0x6ED9EBA1
		elseif i < 60 then
			f = bor(bor(band(b, c), band(b, d)), band(c, d));
			k = 0x8F1BBCDC
		else
			f = bxor(bxor(b, c), d);
			k = 0xCA62C1D6
		end
		local t2 = (lsh(a, 5) + rsh(a, 27) + f + e + k + W[i]) % MOD32
		e = d;
		d = c;
		c = (lsh(b, 30) + rsh(b, 2)) % MOD32;
		b = a;
		a = t2
	end
	return {
		(H[1] + a) % MOD32,
		(H[2] + b) % MOD32,
		(H[3] + c) % MOD32,
		(H[4] + d) % MOD32,
		(H[5] + e) % MOD32
	}
end
--- md5_compress
-- @param H type Description
-- @param block type Description
-- @return type Description
local function md5_compress(H, block)
	local M = {}
	for i = 0, 15 do
		local o = i * 4 + 1
		M[i] = byte(block, o) + byte(block, o + 1) * 256 + byte(block, o + 2) * 65536 + byte(block, o + 3) * 16777216
	end
	local A, B, C, D = H[1], H[2], H[3], H[4]
	for i = 0, 63 do
		local F, g2
		if i < 16 then
			F = bor(band(B, C), band(bnot(B), D));
			g2 = i
		elseif i < 32 then
			F = bor(band(D, B), band(bnot(D), C));
			g2 = (5 * i + 1) % 16
		elseif i < 48 then
			F = bxor(bxor(B, C), D);
			g2 = (3 * i + 5) % 16
		else
			F = bxor(C, bor(B, bnot(D)));
			g2 = (7 * i) % 16
		end
		F = (F + A + MD5_T[i + 1] + M[g2]) % MOD32;
		A = D;
		D = C;
		C = B
		B = (B + bor(lsh(F, MD5_S[i + 1]), rsh(F, 32 - MD5_S[i + 1]))) % MOD32
	end
	return {
		(H[1] + A) % MOD32,
		(H[2] + B) % MOD32,
		(H[3] + C) % MOD32,
		(H[4] + D) % MOD32
	}
end
--- words32ToBytesBE
-- @param H type Description
-- @return type Description
local function words32ToBytesBE(H)
	local out = {}
	for j = 1, # H do
		local v = H[j]
		out[j] = char(floor(v / 16777216) % 256, floor(v / 65536) % 256, floor(v / 256) % 256, v % 256)
	end
	return tcat(out)
end
--- words32ToBytesLE
-- @param H type Description
-- @return type Description
local function words32ToBytesLE(H)
	local out = {}
	for j = 1, # H do
		local v = H[j]
		out[j] = char(v % 256, floor(v / 256) % 256, floor(v / 65536) % 256, floor(v / 16777216) % 256)
	end
	return tcat(out)
end
--- padBlock64BE
-- @param data type Description
-- @param priorBlocks type Description
-- @return type Description
local function padBlock64BE(data, priorBlocks)
	local dataLen = # data;
	local bits = (priorBlocks * 64 + dataLen) * 8
	local t = {
		data,
		"\x80"
	}
	for _ = 1, 55 - dataLen do
		t[# t + 1] = "\x00"
	end
	for i = 7, 0, - 1 do
		t[# t + 1] = char(floor(bits / (2 ^ (8 * i))) % 256)
	end
	return tcat(t)
end
--- padBlock64LE
-- @param data type Description
-- @param priorBlocks type Description
-- @return type Description
local function padBlock64LE(data, priorBlocks)
	local dataLen = # data;
	local bits = (priorBlocks * 64 + dataLen) * 8
	local t = {
		data,
		"\x80"
	}
	for _ = 1, 55 - dataLen do
		t[# t + 1] = "\x00"
	end
	for i = 0, 7 do
		t[# t + 1] = char(floor(bits / (2 ^ (8 * i))) % 256)
	end
	return tcat(t)
end
local KECCAK_ROT = {
	0,
	1,
	62,
	28,
	27,
	36,
	44,
	6,
	55,
	20,
	3,
	10,
	43,
	25,
	39,
	41,
	45,
	15,
	21,
	8,
	18,
	2,
	61,
	56,
	14
}
local KECCAK_RC = {
	{
		0x00000000,
		0x00000001
	},
	{
		0x00000000,
		0x00008082
	},
	{
		0x80000000,
		0x0000808A
	},
	{
		0x80000000,
		0x80008000
	},
	{
		0x00000000,
		0x0000808B
	},
	{
		0x00000000,
		0x80000001
	},
	{
		0x80000000,
		0x80008081
	},
	{
		0x80000000,
		0x00008009
	},
	{
		0x00000000,
		0x0000008A
	},
	{
		0x00000000,
		0x00000088
	},
	{
		0x00000000,
		0x80008009
	},
	{
		0x00000000,
		0x8000000A
	},
	{
		0x00000000,
		0x8000808B
	},
	{
		0x80000000,
		0x0000008B
	},
	{
		0x80000000,
		0x00008089
	},
	{
		0x80000000,
		0x00008003
	},
	{
		0x80000000,
		0x00008002
	},
	{
		0x80000000,
		0x00000080
	},
	{
		0x00000000,
		0x0000800A
	},
	{
		0x80000000,
		0x8000000A
	},
	{
		0x80000000,
		0x80008081
	},
	{
		0x80000000,
		0x00008080
	},
	{
		0x00000000,
		0x80000001
	},
	{
		0x80000000,
		0x80008008
	},
}
--- keccakF
-- @param s type Description
-- @return type Description
local function keccakF(s)
	for rnd = 1, 24 do
		local Ch, Cl = {}, {}
		for x = 0, 4 do
			local h, l = 0, 0
			for y = 0, 4 do
				local lane = s[x + 5 * y + 1];
				h = bxor(h, lane[1]);
				l = bxor(l, lane[2])
			end
			Ch[x], Cl[x] = h, l
		end
		local Dh, Dl = {}, {}
		for x = 0, 4 do
			local rh, rl = rot64(Ch[(x + 1) % 5], Cl[(x + 1) % 5], 1)
			Dh[x] = bxor(Ch[(x + 4) % 5], rh);
			Dl[x] = bxor(Cl[(x + 4) % 5], rl)
		end
		for y = 0, 4 do
			for x = 0, 4 do
				local idx = x + 5 * y + 1;
				s[idx] = {
					bxor(s[idx][1], Dh[x]),
					bxor(s[idx][2], Dl[x])
				}
			end
		end
		local B = {};
		for i = 1, 25 do
			B[i] = {
				0,
				0
			}
		end
		for x = 0, 4 do
			for y = 0, 4 do
				local src = x + 5 * y + 1;
				local rh, rl = rot64(s[src][1], s[src][2], KECCAK_ROT[src])
				local dst = y + 5 * ((2 * x + 3 * y) % 5) + 1;
				B[dst] = {
					rh,
					rl
				}
			end
		end
		for y = 0, 4 do
			for x = 0, 4 do
				local i = x + 5 * y + 1;
				local b1 = B[(x + 1) % 5 + 5 * y + 1];
				local b2 = B[(x + 2) % 5 + 5 * y + 1]
				local nh, nl = not64(b1[1], b1[2])
				s[i] = {
					bxor(B[i][1], band(nh, b2[1])),
					bxor(B[i][2], band(nl, b2[2]))
				}
			end
		end
		s[1] = {
			bxor(s[1][1], KECCAK_RC[rnd][1]),
			bxor(s[1][2], KECCAK_RC[rnd][2])
		}
	end
end
--- keccakAbsorbByte
-- @param s type Description
-- @param i type Description
-- @param b type Description
-- @return type Description
local function keccakAbsorbByte(s, i, b)
	local lane = floor(i / 8);
	local laneIdx = lane + 1;
	local byteOff = i % 8
	if byteOff < 4 then
		s[laneIdx][2] = bxor(s[laneIdx][2], lsh(b, byteOff * 8))
	else
		s[laneIdx][1] = bxor(s[laneIdx][1], lsh(b, (byteOff - 4) * 8))
	end
end
--- keccakSponge
-- @param msg type Description
-- @param rate type Description
-- @param outLen type Description
-- @param dsByte type Description
-- @return type Description
local function keccakSponge(msg, rate, outLen, dsByte)
	local inp = {};
	for i = 1, # msg do
		inp[i] = byte(msg, i)
	end
	inp[# inp + 1] = dsByte
	while # inp % rate ~= 0 do
		inp[# inp + 1] = 0
	end
	inp[# inp] = bxor(inp[# inp], 0x80)
	local s = {};
	for i = 1, 25 do
		s[i] = {
			0,
			0
		}
	end
	for blk = 0, # inp / rate - 1 do
		for i = 0, rate - 1 do
			keccakAbsorbByte(s, i, inp[blk * rate + i + 1] or 0)
		end;
		keccakF(s)
	end
	local out = {};
	local need = outLen
	while need > 0 do
		for i = 0, rate - 1 do
			if need <= 0 then
				break
			end
			local lane = floor(i / 8);
			local lIdx = lane + 1;
			local byteOff = i % 8
			local b2
			if byteOff < 4 then
				b2 = rsh(s[lIdx][2], byteOff * 8) % 256
			else
				b2 = rsh(s[lIdx][1], (byteOff - 4) * 8) % 256
			end
			out[# out + 1] = fmt("%02x", b2);
			need = need - 1
		end
		if need > 0 then
			keccakF(s)
		end
	end
	return tcat(out)
end
--- sha3_224
-- @param msg type Description
-- @return type Description
local function sha3_224(msg)
	return keccakSponge(msg, 144, 28, 0x06)
end
--- sha3_256
-- @param msg type Description
-- @return type Description
local function sha3_256(msg)
	return keccakSponge(msg, 136, 32, 0x06)
end
--- sha3_384
-- @param msg type Description
-- @return type Description
local function sha3_384(msg)
	return keccakSponge(msg, 104, 48, 0x06)
end
--- sha3_512
-- @param msg type Description
-- @return type Description
local function sha3_512(msg)
	return keccakSponge(msg, 72, 64, 0x06)
end
--- keccak256
-- @param msg type Description
-- @return type Description
local function keccak256(msg)
	return keccakSponge(msg, 136, 32, 0x01)
end
--- shake128
-- @param msg type Description
-- @param n type Description
-- @return type Description
local function shake128(msg, n)
	return keccakSponge(msg, 168, n or 32, 0x1F)
end
--- shake256
-- @param msg type Description
-- @param n type Description
-- @return type Description
local function shake256(msg, n)
	return keccakSponge(msg, 136, n or 64, 0x1F)
end
--- hmacRaw
-- @param hashFn type Description
-- @param blockSize type Description
-- @param key type Description
-- @param msg type Description
-- @return type Description
local function hmacRaw(hashFn, blockSize, key, msg)
	if # key > blockSize then
		key = hexToRaw(hashFn(key))
	end
	while # key < blockSize do
		key = key .. "\x00"
	end
	local ipadT, opadT = {}, {}
	for i = 1, blockSize do
		ipadT[i] = char(bxor(byte(key, i), 0x36));
		opadT[i] = char(bxor(byte(key, i), 0x5c))
	end
	local ipad = tcat(ipadT);
	local opad = tcat(opadT)
	return hashFn(opad .. hexToRaw(hashFn(ipad .. msg)))
end
local AES_S = {
	0x63,
	0x7c,
	0x77,
	0x7b,
	0xf2,
	0x6b,
	0x6f,
	0xc5,
	0x30,
	0x01,
	0x67,
	0x2b,
	0xfe,
	0xd7,
	0xab,
	0x76,
	0xca,
	0x82,
	0xc9,
	0x7d,
	0xfa,
	0x59,
	0x47,
	0xf0,
	0xad,
	0xd4,
	0xa2,
	0xaf,
	0x9c,
	0xa4,
	0x72,
	0xc0,
	0xb7,
	0xfd,
	0x93,
	0x26,
	0x36,
	0x3f,
	0xf7,
	0xcc,
	0x34,
	0xa5,
	0xe5,
	0xf1,
	0x71,
	0xd8,
	0x31,
	0x15,
	0x04,
	0xc7,
	0x23,
	0xc3,
	0x18,
	0x96,
	0x05,
	0x9a,
	0x07,
	0x12,
	0x80,
	0xe2,
	0xeb,
	0x27,
	0xb2,
	0x75,
	0x09,
	0x83,
	0x2c,
	0x1a,
	0x1b,
	0x6e,
	0x5a,
	0xa0,
	0x52,
	0x3b,
	0xd6,
	0xb3,
	0x29,
	0xe3,
	0x2f,
	0x84,
	0x53,
	0xd1,
	0x00,
	0xed,
	0x20,
	0xfc,
	0xb1,
	0x5b,
	0x6a,
	0xcb,
	0xbe,
	0x39,
	0x4a,
	0x4c,
	0x58,
	0xcf,
	0xd0,
	0xef,
	0xaa,
	0xfb,
	0x43,
	0x4d,
	0x33,
	0x85,
	0x45,
	0xf9,
	0x02,
	0x7f,
	0x50,
	0x3c,
	0x9f,
	0xa8,
	0x51,
	0xa3,
	0x40,
	0x8f,
	0x92,
	0x9d,
	0x38,
	0xf5,
	0xbc,
	0xb6,
	0xda,
	0x21,
	0x10,
	0xff,
	0xf3,
	0xd2,
	0xcd,
	0x0c,
	0x13,
	0xec,
	0x5f,
	0x97,
	0x44,
	0x17,
	0xc4,
	0xa7,
	0x7e,
	0x3d,
	0x64,
	0x5d,
	0x19,
	0x73,
	0x60,
	0x81,
	0x4f,
	0xdc,
	0x22,
	0x2a,
	0x90,
	0x88,
	0x46,
	0xee,
	0xb8,
	0x14,
	0xde,
	0x5e,
	0x0b,
	0xdb,
	0xe0,
	0x32,
	0x3a,
	0x0a,
	0x49,
	0x06,
	0x24,
	0x5c,
	0xc2,
	0xd3,
	0xac,
	0x62,
	0x91,
	0x95,
	0xe4,
	0x79,
	0xe7,
	0xc8,
	0x37,
	0x6d,
	0x8d,
	0xd5,
	0x4e,
	0xa9,
	0x6c,
	0x56,
	0xf4,
	0xea,
	0x65,
	0x7a,
	0xae,
	0x08,
	0xba,
	0x78,
	0x25,
	0x2e,
	0x1c,
	0xa6,
	0xb4,
	0xc6,
	0xe8,
	0xdd,
	0x74,
	0x1f,
	0x4b,
	0xbd,
	0x8b,
	0x8a,
	0x70,
	0x3e,
	0xb5,
	0x66,
	0x48,
	0x03,
	0xf6,
	0x0e,
	0x61,
	0x35,
	0x57,
	0xb9,
	0x86,
	0xc1,
	0x1d,
	0x9e,
	0xe1,
	0xf8,
	0x98,
	0x11,
	0x69,
	0xd9,
	0x8e,
	0x94,
	0x9b,
	0x1e,
	0x87,
	0xe9,
	0xce,
	0x55,
	0x28,
	0xdf,
	0x8c,
	0xa1,
	0x89,
	0x0d,
	0xbf,
	0xe6,
	0x42,
	0x68,
	0x41,
	0x99,
	0x2d,
	0x0f,
	0xb0,
	0x54,
	0xbb,
	0x16,
}
local AES_INV_S = {}
for i = 0, 255 do
	AES_INV_S[AES_S[i + 1]] = i
end
local AES_RCON = {
	0x01,
	0x02,
	0x04,
	0x08,
	0x10,
	0x20,
	0x40,
	0x80,
	0x1b,
	0x36
}
local AES_MUL2 = {}
local AES_MUL3 = {}
local AES_MUL9 = {}
local AES_MUL11 = {}
local AES_MUL13 = {}
local AES_MUL14 = {}
for i = 0, 255 do
	AES_MUL2[i] = i < 128 and i * 2 or bxor(i * 2, 0x11b)
end
for i = 0, 255 do
	AES_MUL3[i] = bxor(AES_MUL2[i], i)
	AES_MUL9[i] = bxor(AES_MUL2[AES_MUL2[AES_MUL2[i]]], i)
	AES_MUL11[i] = bxor(AES_MUL2[AES_MUL2[AES_MUL2[i]]], bxor(AES_MUL2[i], i))
	AES_MUL13[i] = bxor(AES_MUL2[AES_MUL2[AES_MUL2[i]]], bxor(AES_MUL2[AES_MUL2[i]], i))
	AES_MUL14[i] = bxor(bxor(AES_MUL2[AES_MUL2[AES_MUL2[i]]], AES_MUL2[AES_MUL2[i]]), AES_MUL2[i])
end
--- aesKeyExpand
-- @param key type Description
-- @param Nk type Description
-- @param Nr type Description
-- @return type Description
local function aesKeyExpand(key, Nk, Nr)
	local W = {};
	local NK = Nk or 4;
	local NR = Nr or 10
	for i = 0, NK - 1 do
		W[i] = {
			key[i * 4 + 1] or 0,
			key[i * 4 + 2] or 0,
			key[i * 4 + 3] or 0,
			key[i * 4 + 4] or 0
		}
	end
	for i = NK, 4 * (NR + 1) - 1 do
		local t = {
			W[i - 1][1],
			W[i - 1][2],
			W[i - 1][3],
			W[i - 1][4]
		}
		if i % NK == 0 then
			t = {
				t[2],
				t[3],
				t[4],
				t[1]
			}
			for j = 1, 4 do
				t[j] = AES_S[t[j] + 1]
			end
			t[1] = bxor(t[1], AES_RCON[floor(i / NK)])
		elseif NK > 6 and i % NK == 4 then
			for j = 1, 4 do
				t[j] = AES_S[t[j] + 1]
			end
		end
		W[i] = {
			bxor(W[i - NK][1], t[1]),
			bxor(W[i - NK][2], t[2]),
			bxor(W[i - NK][3], t[3]),
			bxor(W[i - NK][4], t[4])
		}
	end
	return W, NR
end
--- aesEncRound
-- @param state type Description
-- @param W type Description
-- @param round type Description
-- @param last type Description
-- @return type Description
local function aesEncRound(state, W, round, last)
	for r = 1, 4 do
		for c = 1, 4 do
			state[r][c] = AES_S[state[r][c] + 1]
		end
	end
	for r = 2, 4 do
		local s = r - 1;
		local row = {
			tunpack(state[r])
		}
		for c = 1, 4 do
			state[r][c] = row[(c - 1 + s) % 4 + 1]
		end
	end
	if not last then
		for c = 1, 4 do
			local s0, s1, s2, s3 = state[1][c], state[2][c], state[3][c], state[4][c]
			state[1][c] = bxor(bxor(bxor(AES_MUL2[s0], AES_MUL3[s1]), s2), s3)
			state[2][c] = bxor(bxor(bxor(s0, AES_MUL2[s1]), AES_MUL3[s2]), s3)
			state[3][c] = bxor(bxor(bxor(s0, s1), AES_MUL2[s2]), AES_MUL3[s3])
			state[4][c] = bxor(bxor(bxor(AES_MUL3[s0], s1), s2), AES_MUL2[s3])
		end
	end
	for c = 0, 3 do
		for r = 0, 3 do
			state[r + 1][c + 1] = bxor(state[r + 1][c + 1], W[round * 4 + c][r + 1])
		end
	end
end
--- aesDecRound
-- @param state type Description
-- @param W type Description
-- @param round type Description
-- @param last type Description
-- @return type Description
local function aesDecRound(state, W, round, last)
	for r = 2, 4 do
		local s = r - 1;
		local row = {
			tunpack(state[r])
		}
		for c = 1, 4 do
			state[r][c] = row[(c - 1 - s) % 4 + 1]
		end
	end
	for r = 1, 4 do
		for c = 1, 4 do
			state[r][c] = AES_INV_S[state[r][c]]
		end
	end
	for c = 0, 3 do
		for r = 0, 3 do
			state[r + 1][c + 1] = bxor(state[r + 1][c + 1], W[round * 4 + c][r + 1])
		end
	end
	if not last then
		for c = 1, 4 do
			local s0, s1, s2, s3 = state[1][c], state[2][c], state[3][c], state[4][c]
			state[1][c] = bxor(bxor(bxor(AES_MUL14[s0], AES_MUL11[s1]), AES_MUL13[s2]), AES_MUL9[s3])
			state[2][c] = bxor(bxor(bxor(AES_MUL9[s0], AES_MUL14[s1]), AES_MUL11[s2]), AES_MUL13[s3])
			state[3][c] = bxor(bxor(bxor(AES_MUL13[s0], AES_MUL9[s1]), AES_MUL14[s2]), AES_MUL11[s3])
			state[4][c] = bxor(bxor(bxor(AES_MUL11[s0], AES_MUL13[s1]), AES_MUL9[s2]), AES_MUL14[s3])
		end
	end
end
--- aesEncBlock
-- @param block type Description
-- @param W type Description
-- @param NR type Description
-- @return type Description
local function aesEncBlock(block, W, NR)
	local st = {}
	for r = 0, 3 do
		st[r + 1] = {};
		for c = 0, 3 do
			st[r + 1][c + 1] = block[c * 4 + r + 1]
		end
	end
	for c = 0, 3 do
		for r = 0, 3 do
			st[r + 1][c + 1] = bxor(st[r + 1][c + 1], W[c][r + 1])
		end
	end
	for rnd = 1, NR - 1 do
		aesEncRound(st, W, rnd, false)
	end
	aesEncRound(st, W, NR, true)
	local out = {};
	for c = 0, 3 do
		for r = 0, 3 do
			out[c * 4 + r + 1] = st[r + 1][c + 1]
		end
	end;
	return out
end
--- aesDecBlock
-- @param block type Description
-- @param W type Description
-- @param NR type Description
-- @return type Description
local function aesDecBlock(block, W, NR)
	local st = {}
	for r = 0, 3 do
		st[r + 1] = {};
		for c = 0, 3 do
			st[r + 1][c + 1] = block[c * 4 + r + 1]
		end
	end
	for c = 0, 3 do
		for r = 0, 3 do
			st[r + 1][c + 1] = bxor(st[r + 1][c + 1], W[NR * 4 + c][r + 1])
		end
	end
	for rnd = NR - 1, 1, - 1 do
		aesDecRound(st, W, rnd, false)
	end
	aesDecRound(st, W, 0, true)
	local out = {};
	for c = 0, 3 do
		for r = 0, 3 do
			out[c * 4 + r + 1] = st[r + 1][c + 1]
		end
	end;
	return out
end
--- pkcs7pad
-- @param data type Description
-- @param block type Description
-- @return type Description
local function pkcs7pad(data, block)
	local pad = block - (# data % block);
	if pad == 0 then
		pad = block
	end
	local out = {};
	for i = 1, # data do
		out[i] = data[i]
	end
	for _ = 1, pad do
		out[# out + 1] = pad
	end;
	return out
end
--- pkcs7unpad
-- @param data type Description
-- @return type Description
local function pkcs7unpad(data)
	if # data == 0 then
		return data
	end
	local pad = data[# data] or 0
	if pad < 1 or pad > 16 then
		return data
	end
	for i = # data - pad + 1, # data do
		if data[i] ~= pad then
			return data
		end
	end
	local out = {};
	for i = 1, # data - pad do
		out[i] = data[i]
	end;
	return out
end
local AES_CONFIG = {
	["aes-128-cbc"] = {
		Nk = 4,
		Nr = 10
	},
	["aes-128-ecb"] = {
		Nk = 4,
		Nr = 10
	},
	["aes-192-cbc"] = {
		Nk = 6,
		Nr = 12
	},
	["aes-192-ecb"] = {
		Nk = 6,
		Nr = 12
	},
	["aes-256-cbc"] = {
		Nk = 8,
		Nr = 14
	},
	["aes-256-ecb"] = {
		Nk = 8,
		Nr = 14
	},
}
--- aesEncrypt
-- @param algo type Description
-- @param keyBuf type Description
-- @param ivBuf type Description
-- @param plainBuf type Description
-- @return type Description
local function aesEncrypt(algo, keyBuf, ivBuf, plainBuf)
	local cfg = AES_CONFIG[algo];
	local key = {}
	for i = 1, cfg.Nk * 4 do
		key[i] = keyBuf._b[i] or 0
	end
	local W, NR = aesKeyExpand(key, cfg.Nk, cfg.Nr)
	if algo:find("cbc") then
		local iv = {};
		for i = 1, 16 do
			iv[i] = (ivBuf and ivBuf._b[i]) or 0
		end
		local padded = pkcs7pad(plainBuf._b, 16);
		local out = {};
		local prev = iv
		for blk = 0, # padded / 16 - 1 do
			local b = {};
			for i = 1, 16 do
				b[i] = bxor(padded[blk * 16 + i], prev[i])
			end
			prev = aesEncBlock(b, W, NR);
			for _, v in ipairs(prev) do
				out[# out + 1] = v
			end
		end
		return Buffer.from(out)
	else
		local padded = pkcs7pad(plainBuf._b, 16);
		local out = {}
		for blk = 0, # padded / 16 - 1 do
			local b = {};
			for i = 1, 16 do
				b[i] = padded[blk * 16 + i]
			end
			for _, v in ipairs(aesEncBlock(b, W, NR)) do
				out[# out + 1] = v
			end
		end
		return Buffer.from(out)
	end
end
--- aesDecrypt
-- @param algo type Description
-- @param keyBuf type Description
-- @param ivBuf type Description
-- @param cipherBuf type Description
-- @return type Description
local function aesDecrypt(algo, keyBuf, ivBuf, cipherBuf)
	local cfg = AES_CONFIG[algo];
	local key = {}
	for i = 1, cfg.Nk * 4 do
		key[i] = keyBuf._b[i] or 0
	end
	local W, NR = aesKeyExpand(key, cfg.Nk, cfg.Nr)
	if algo:find("cbc") then
		local iv = {};
		for i = 1, 16 do
			iv[i] = (ivBuf and ivBuf._b[i]) or 0
		end
		local out = {};
		local prev = iv
		for blk = 0, # cipherBuf._b / 16 - 1 do
			local b = {};
			for i = 1, 16 do
				b[i] = cipherBuf._b[blk * 16 + i]
			end
			local decrypted = aesDecBlock(b, W, NR)
			for i = 1, 16 do
				out[# out + 1] = bxor(decrypted[i], prev[i])
			end;
			prev = b
		end
		return Buffer.from(pkcs7unpad(out))
	else
		local out = {}
		for blk = 0, # cipherBuf._b / 16 - 1 do
			local b = {};
			for i = 1, 16 do
				b[i] = cipherBuf._b[blk * 16 + i]
			end
			for _, v in ipairs(aesDecBlock(b, W, NR)) do
				out[# out + 1] = v
			end
		end
		return Buffer.from(pkcs7unpad(out))
	end
end
--- xorCipher
-- @param key type Description
-- @param data type Description
-- @return type Description
local function xorCipher(key, data)
	local kb
	if type(key) == "string" then
		kb = {};
		for i = 1, # key do
			kb[i] = byte(key, i)
		end
	else
		kb = key._b
	end
	if Buffer.isBuffer(data) then
		local out = {};
		for i, b in ipairs(data._b) do
			out[i] = bxor(b, kb[(i - 1) % # kb + 1])
		end;
		return Buffer.from(out)
	else
		local out = {};
		for i = 1, # data do
			out[i] = char(bxor(byte(data, i), kb[(i - 1) % # kb + 1]))
		end;
		return tcat(out)
	end
end
local PBKDF2_FAST = {
	sha256 = {
		compress = sha256_compress,
		iv = SHA256_IV,
		hlen = 32,
		pad = padBlock64BE,
		towords = words32ToBytesBE
	},
	sha1 = {
		compress = sha1_compress,
		iv = SHA1_IV,
		hlen = 20,
		pad = padBlock64BE,
		towords = words32ToBytesBE
	},
	md5 = {
		compress = md5_compress,
		iv = MD5_IV,
		hlen = 16,
		pad = padBlock64LE,
		towords = words32ToBytesLE
	},
}
--- pbkdf2Fast
-- @param cfg type Description
-- @param password type Description
-- @param salt type Description
-- @param iters type Description
-- @param keylen type Description
-- @return type Description
local function pbkdf2Fast(cfg, password, salt, iters, keylen)
	local blockSize = 64
	local key = password
	if # key > blockSize then
		local H = cfg.iv
		local full = floor(# key / 64)
		for b = 0, full - 1 do
			H = cfg.compress(H, key:sub(b * 64 + 1, b * 64 + 64))
		end
		H = cfg.compress(H, cfg.pad(key:sub(full * 64 + 1), full))
		key = cfg.towords(H)
	end
	if # key < blockSize then
		key = key .. string.rep("\x00", blockSize - # key)
	end
	local ipadB, opadB = {}, {}
	for i = 1, blockSize do
		ipadB[i] = char(bxor(byte(key, i), 0x36));
		opadB[i] = char(bxor(byte(key, i), 0x5c))
	end
	local Hipad = cfg.compress(cfg.iv, tcat(ipadB))
	local Hopad = cfg.compress(cfg.iv, tcat(opadB))
	local result = {};
	local blockNum = 1
	while # result < keylen do
		local saltBlock = salt .. char(
            floor(blockNum / 16777216) % 256, floor(blockNum / 65536) % 256, floor(blockNum / 256) % 256, blockNum % 256)
		local Hcur = Hipad;
		local sdlen = # saltBlock;
		local nfull = floor(sdlen / 64)
		for b = 0, nfull - 1 do
			Hcur = cfg.compress(Hcur, saltBlock:sub(b * 64 + 1, b * 64 + 64))
		end
		local Hinner = cfg.compress(Hcur, cfg.pad(saltBlock:sub(nfull * 64 + 1), 1 + nfull))
		local innerBytes = cfg.towords(Hinner)
		local Hout = cfg.compress(Hopad, cfg.pad(innerBytes, 1))
		local Tbytes = cfg.towords(Hout)
		local t = {}
		for i = 1, # Tbytes do
			t[i] = byte(Tbytes, i)
		end
		local prevBytes = Tbytes
		for iter = 2, iters do
			local Hi2 = cfg.compress(Hipad, cfg.pad(prevBytes, 1))
			local innerB2 = cfg.towords(Hi2)
			local Ho2 = cfg.compress(Hopad, cfg.pad(innerB2, 1))
			local Tb2 = cfg.towords(Ho2)
			for i = 1, # Tb2 do
				t[i] = bxor(t[i], byte(Tb2, i))
			end
			prevBytes = Tb2
			if iter % 1000 == 0 then
				cooperativeYield()
			end
		end
		for _, bv in ipairs(t) do
			result[# result + 1] = bv
		end;
		blockNum = blockNum + 1
	end
	while # result > keylen do
		result[# result] = nil
	end;
	return Buffer.from(result)
end
--- pbkdf2
-- @param password type Description
-- @param salt type Description
-- @param iters type Description
-- @param keylen type Description
-- @param digest type Description
-- @return type Description
local function pbkdf2(password, salt, iters, keylen, digest)
	digest = digest or "sha256"
	local fastCfg = PBKDF2_FAST[digest]
	if fastCfg then
		return pbkdf2Fast(fastCfg, password, salt, iters, keylen)
	end
	local hashFn, blockSize
	if digest == "sha3-256" then
		hashFn = sha3_256;
		blockSize = 136
	elseif digest == "sha3-512" then
		hashFn = sha3_512;
		blockSize = 72
	elseif digest == "keccak256" then
		hashFn = keccak256;
		blockSize = 136
	else
		error("[crypto] pbkdf2: unknown digest " .. digest)
	end
	local key = password
	if # key > blockSize then
		key = hexToRaw(hashFn(key))
	end
	while # key < blockSize do
		key = key .. "\x00"
	end
	local ipadT, opadT = {}, {}
	for i = 1, blockSize do
		ipadT[i] = char(bxor(byte(key, i), 0x36));
		opadT[i] = char(bxor(byte(key, i), 0x5c))
	end
	local ipadStr = tcat(ipadT);
	local opadStr = tcat(opadT)
--- hmacFast
-- @param msgStr type Description
-- @return type Description
	local function hmacFast(msgStr)
		return hashFn(opadStr .. hexToRaw(hashFn(ipadStr .. msgStr)))
	end
	local result = {};
	local blockNum = 1
	while # result < keylen do
		local saltBlock = salt .. char(
            floor(blockNum / 16777216) % 256, floor(blockNum / 65536) % 256, floor(blockNum / 256) % 256, blockNum % 256)
		local u_hex = hmacFast(saltBlock)
		local t = {}
		for i = 1, # u_hex, 2 do
			t[# t + 1] = tonumber(u_hex:sub(i, i + 1), 16)
		end
		local prevT = {};
		for j = 1, # t do
			prevT[j] = char(t[j])
		end;
		local prevStr = tcat(prevT)
		for iter = 2, iters do
			u_hex = hmacFast(prevStr);
			prevT = {}
			for i = 1, # u_hex, 2 do
				local ub = tonumber(u_hex:sub(i, i + 1), 16)
				local j = floor((i + 1) / 2)
				t[j] = bxor(t[j], ub);
				prevT[j] = char(ub)
			end
			prevStr = tcat(prevT)
			if iter % 1000 == 0 then
				cooperativeYield()
			end
		end
		for _, bv in ipairs(t) do
			result[# result + 1] = bv
		end;
		blockNum = blockNum + 1
	end
	while # result > keylen do
		result[# result] = nil
	end;
	return Buffer.from(result)
end
--- digestBuild
-- @param hex type Description
-- @param enc type Description
-- @return type Description
local function digestBuild(hex, enc)
	if enc == "buffer" then
		local bytes = {};
		for i = 1, # hex, 2 do
			bytes[# bytes + 1] = tonumber(hex:sub(i, i + 1), 16)
		end
		return Buffer.from(bytes)
	elseif enc == "base64" then
		local bytes = {};
		for i = 1, # hex, 2 do
			bytes[# bytes + 1] = tonumber(hex:sub(i, i + 1), 16)
		end
		return Buffer.from(bytes):toString("base64")
	end
	return hex
end
--- rsaGenKeyPair
-- @param keySize type Description
-- @return type Description
local function rsaGenKeyPair(keySize)
	keySize = keySize or 2048;
	local halfBits = floor(keySize / 2)
	local p = bigGenPrime(halfBits);
	local q = bigGenPrime(halfBits)
	while bigCmp(p, q) == 0 do
		q = bigGenPrime(halfBits)
	end
	local n = bigMul(p, q);
	local p1 = bigSub(p, bigNew(1));
	local q1 = bigSub(q, bigNew(1))
	local phi = bigMul(p1, q1);
	local e = bigNew(65537)
	local g = bigGcd(e, phi)
	if bigCmp(g, bigNew(1)) ~= 0 then
		error("[crypto] RSA: gcd(e,phi)!=1")
	end
	local d = bigModInverse(e, phi)
	local dp = bigMod(d, p1);
	local dq = bigMod(d, q1);
	local qinv = bigModInverse(q, p)
	return {
		publicKey = {
			n = n,
			e = e,
			size = keySize
		},
		privateKey = {
			n = n,
			d = d,
			p = p,
			q = q,
			dp = dp,
			dq = dq,
			qinv = qinv,
			size = keySize
		}
	}
end
--- rsaCRTModExp
-- @param m type Description
-- @param privKey type Description
-- @return type Description
local function rsaCRTModExp(m, privKey)
	local p, q = privKey.p, privKey.q
	local dp = privKey.dp;
	local dq = privKey.dq;
	local qinv = privKey.qinv
	local m1 = bigModExp(bigMod(m, p), dp, p)
	local m2 = bigModExp(bigMod(m, q), dq, q)
	local diff = bigSub(m1, m2)
	if diff.sign == - 1 then
		diff = bigAdd(diff, p)
	end;
	diff.sign = 1
	local h = bigMod(bigMul(qinv, diff), p);
	h.sign = 1
	local result = bigAdd(m2, bigMul(h, q));
	result.sign = 1;
	return result
end
--- mgf1
-- @param seed type Description
-- @param length type Description
-- @param hashFn type Description
-- @return type Description
local function mgf1(seed, length, hashFn)
	local t = {};
	local i = 0
	while # t * 1 < length do
		local C = char(floor(i / 16777216) % 256, floor(i / 65536) % 256, floor(i / 256) % 256, i % 256)
		local h = hexToRaw(hashFn(seed .. C))
		for j = 1, # h do
			t[# t + 1] = h:sub(j, j)
		end;
		i = i + 1
	end
	return tcat(t):sub(1, length)
end
--- oaepEncode
-- @param msg type Description
-- @param nLen type Description
-- @param label type Description
-- @param hashFn type Description
-- @param hashLen type Description
-- @return type Description
local function oaepEncode(msg, nLen, label, hashFn, hashLen)
	label = label or "";
	hashLen = hashLen or 32
	local lHash = hexToRaw(hashFn(label));
	local mLen = # msg
	if mLen > nLen - 2 * hashLen - 2 then
		error("[crypto] RSA-OAEP: message too long")
	end
	local PS = string.rep("\x00", nLen - mLen - 2 * hashLen - 2)
	local DB = lHash .. PS .. "\x01" .. msg
	local seed = getSecureRandom(hashLen):toString("utf8")
	local dbMask = mgf1(seed, nLen - hashLen - 1, hashFn)
	local maskedDB = {}
	for i = 1, # DB do
		maskedDB[i] = char(bxor(byte(DB, i), byte(dbMask, i)))
	end
	maskedDB = tcat(maskedDB)
	local seedMask = mgf1(maskedDB, hashLen, hashFn)
	local maskedSeed = {}
	for i = 1, # seed do
		maskedSeed[i] = char(bxor(byte(seed, i), byte(seedMask, i)))
	end
	return "\x00" .. tcat(maskedSeed) .. maskedDB
end
--- oaepDecode
-- @param em type Description
-- @param nLen type Description
-- @param label type Description
-- @param hashFn type Description
-- @param hashLen type Description
-- @return type Description
local function oaepDecode(em, nLen, label, hashFn, hashLen)
	label = label or "";
	hashLen = hashLen or 32
	local lHash = hexToRaw(hashFn(label))
	if # em ~= nLen then
		error("[crypto] RSA-OAEP: decryption error (length)")
	end
	local maskedSeed = em:sub(2, hashLen + 1);
	local maskedDB = em:sub(hashLen + 2)
	local seedMask = mgf1(maskedDB, hashLen, hashFn)
	local seedT = {}
	for i = 1, # maskedSeed do
		seedT[i] = char(bxor(byte(maskedSeed, i), byte(seedMask, i)))
	end
	local seed = tcat(seedT)
	local dbMask = mgf1(seed, nLen - hashLen - 1, hashFn)
	local DBT = {}
	for i = 1, # maskedDB do
		DBT[i] = char(bxor(byte(maskedDB, i), byte(dbMask, i)))
	end
	local DB = tcat(DBT)
	local lHashCheck = DB:sub(1, hashLen)
	if not constantTimeCompare(lHash, lHashCheck) then
		error("[crypto] RSA-OAEP: decryption error (hash)")
	end
	local rest = DB:sub(hashLen + 1);
	local i = 1
	while i <= # rest do
		local c = byte(rest, i)
		if c == 0x01 then
			return rest:sub(i + 1)
		elseif c ~= 0x00 then
			error("[crypto] RSA-OAEP: decryption error (padding)")
		end
		i = i + 1
	end
	error("[crypto] RSA-OAEP: decryption error (no separator)")
end
--- rsaEncrypt
-- @param msg type Description
-- @param pubKey type Description
-- @param useOAEP type Description
-- @return type Description
local function rsaEncrypt(msg, pubKey, useOAEP)
	local nLen = floor(pubKey.size / 8);
	local em
	if useOAEP ~= false then
		if type(msg) == "string" then
			em = oaepEncode(msg, nLen, nil, sha256raw, 32)
		elseif Buffer.isBuffer(msg) then
			em = oaepEncode(msg:toString("utf8"), nLen, nil, sha256raw, 32)
		else
			em = tostring(msg)
		end
	else
		if type(msg) == "string" then
			em = msg
		elseif Buffer.isBuffer(msg) then
			em = msg:toString("utf8")
		else
			em = tostring(msg)
		end
	end
	local mBytes = {};
	for i = 1, # em do
		mBytes[# mBytes + 1] = byte(em, i)
	end
	local m = bigFromBytes(mBytes)
	if bigCmp(m, pubKey.n) >= 0 then
		error("[crypto] RSA: message >= modulus")
	end
	local c = bigModExp(m, pubKey.e, pubKey.n)
	return Buffer.from(bigToBytes(c, nLen))
end
--- rsaDecrypt
-- @param cipherBuf type Description
-- @param privKey type Description
-- @param useOAEP type Description
-- @return type Description
local function rsaDecrypt(cipherBuf, privKey, useOAEP)
	local nLen = floor(privKey.size / 8)
	local bytes = Buffer.isBuffer(cipherBuf) and cipherBuf._b or cipherBuf
	local c = bigFromBytes(bytes)
	local m
	if privKey.dp and privKey.dq and privKey.qinv then
		m = rsaCRTModExp(c, privKey)
	else
		m = bigModExp(c, privKey.d, privKey.n)
	end
	local emT = {}
	for _, b in ipairs(bigToBytes(m, nLen)) do
		emT[# emT + 1] = char(b or 0)
	end
	local em = tcat(emT)
	if useOAEP ~= false then
		return oaepDecode(em, nLen, nil, sha256raw, 32)
	end
	return em
end
--- rsaSign
-- @param msg type Description
-- @param privKey type Description
-- @return type Description
local function rsaSign(msg, privKey)
	local nLen = floor(privKey.size / 8)
	local msgStr = type(msg) == "string" and msg or (Buffer.isBuffer(msg) and msg:toString("utf8") or tostring(msg))
	local hash = hexToRaw(sha256raw(msgStr))
	local PS = string.rep("\xff", nLen - # hash - 3)
	local em = "\x00\x01" .. PS .. "\x00" .. hash
	local mBytes = {};
	for i = 1, # em do
		mBytes[# mBytes + 1] = byte(em, i)
	end
	local m = bigFromBytes(mBytes)
	local s
	if privKey.dp and privKey.dq and privKey.qinv then
		s = rsaCRTModExp(m, privKey)
	else
		s = bigModExp(m, privKey.d, privKey.n)
	end
	return Buffer.from(bigToBytes(s, nLen))
end
--- rsaVerify
-- @param msg type Description
-- @param sigBuf type Description
-- @param pubKey type Description
-- @return type Description
local function rsaVerify(msg, sigBuf, pubKey)
	local nLen = floor(pubKey.size / 8)
	local bytes = Buffer.isBuffer(sigBuf) and sigBuf._b or sigBuf
	local s = bigFromBytes(bytes);
	local m = bigModExp(s, pubKey.e, pubKey.n)
	local emT = {};
	for _, b in ipairs(bigToBytes(m, nLen)) do
		emT[# emT + 1] = char(b or 0)
	end;
	local em = tcat(emT)
	local msgStr = type(msg) == "string" and msg or (Buffer.isBuffer(msg) and msg:toString("utf8") or tostring(msg))
	local hash = hexToRaw(sha256raw(msgStr))
	return constantTimeCompare(hash, em:sub(# em - # hash + 1))
end
local P256_P = bigNew("115792089210356248762697446949407573530086143415290314195533631308867097853951")
local P256_N = bigNew("115792089210356248762697446949407573529996955224135760342422259061068512044369")
local P256_GX = bigNew("48439561293906451759052585252797914202762949526041747995844080717082404635286")
local P256_GY = bigNew("36134250956749795798585127919587881956611106672985015071877198253568414405109")
--- fp_add
-- @param a type Description
-- @param b type Description
-- @return type Description
local function fp_add(a, b)
	local r = bigAdd(a, b);
	if bigCmp(r, P256_P) >= 0 then
		r = bigSub(r, P256_P)
	end;
	return r
end
--- fp_sub
-- @param a type Description
-- @param b type Description
-- @return type Description
local function fp_sub(a, b)
	local r = bigSub(a, b);
	if r.sign == - 1 then
		r = bigAdd(r, P256_P)
	end;
	return r
end
--- fp_mul
-- @param a type Description
-- @param b type Description
-- @return type Description
local function fp_mul(a, b)
	return bigMod(bigMul(a, b), P256_P)
end
--- fp_dbl
-- @param a type Description
-- @return type Description
local function fp_dbl(a)
	local r = bigAdd(a, a);
	if bigCmp(r, P256_P) >= 0 then
		r = bigSub(r, P256_P)
	end;
	return r
end
--- fp_mul3
-- @param a type Description
-- @return type Description
local function fp_mul3(a)
	return fp_add(fp_dbl(a), a)
end
--- fp_mul4
-- @param a type Description
-- @return type Description
local function fp_mul4(a)
	return fp_dbl(fp_dbl(a))
end
--- fp_mul8
-- @param a type Description
-- @return type Description
local function fp_mul8(a)
	return fp_dbl(fp_dbl(fp_dbl(a)))
end
--- jacDouble
-- @param X type Description
-- @param Y type Description
-- @param Z type Description
-- @return type Description
local function jacDouble(X, Y, Z)
	if bigIsZero(Z) then
		return X, Y, Z
	end
	local XX = fp_mul(X, X);
	local YY = fp_mul(Y, Y)
	local ZZ = fp_mul(Z, Z);
	local YYYY = fp_mul(YY, YY)
	local S = fp_mul4(fp_mul(X, YY))
	local ZZ2 = fp_mul(ZZ, ZZ)
	local M = fp_mul3(fp_sub(XX, ZZ2))
	local T = fp_sub(fp_mul(M, M), fp_dbl(S))
	local Y3 = fp_sub(fp_mul(M, fp_sub(S, T)), fp_mul8(YYYY))
	local Z3 = fp_dbl(fp_mul(Y, Z))
	return T, Y3, Z3
end
--- jacAdd
-- @param X1 type Description
-- @param Y1 type Description
-- @param Z1 type Description
-- @param X2 type Description
-- @param Y2 type Description
-- @param Z2 type Description
-- @return type Description
local function jacAdd(X1, Y1, Z1, X2, Y2, Z2)
	if bigIsZero(Z1) then
		return X2, Y2, Z2
	end
	if bigIsZero(Z2) then
		return X1, Y1, Z1
	end
	local Z1sq = fp_mul(Z1, Z1);
	local Z2sq = fp_mul(Z2, Z2)
	local U1 = fp_mul(X1, Z2sq);
	local U2 = fp_mul(X2, Z1sq)
	local S1 = fp_mul(fp_mul(Y1, Z2), Z2sq);
	local S2 = fp_mul(fp_mul(Y2, Z1), Z1sq)
	local H = fp_sub(U2, U1);
	local R = fp_sub(S2, S1)
	if bigIsZero(H) then
		if bigIsZero(R) then
			return jacDouble(X1, Y1, Z1)
		end
		return bigNew(1), bigNew(1), bigNew(0)
	end
	local H2 = fp_mul(H, H);
	local H3 = fp_mul(H, H2);
	local U1H2 = fp_mul(U1, H2)
	local X3 = fp_sub(fp_sub(fp_mul(R, R), H3), fp_dbl(U1H2))
	local Y3 = fp_sub(fp_mul(R, fp_sub(U1H2, X3)), fp_mul(S1, H3))
	local Z3 = fp_mul(fp_mul(H, Z1), Z2)
	return X3, Y3, Z3
end
--- p256JacScalarMul
-- @param k type Description
-- @param px type Description
-- @param py type Description
-- @return type Description
local function p256JacScalarMul(k, px, py)
	local RX, RY, RZ = bigNew(0), bigNew(0), bigNew(0)
	local QX, QY, QZ = px, py, bigNew(1)
	local kCopy = bigNew(k);
	kCopy.sign = 1;
	local two = bigNew(2)
	while not bigIsZero(kCopy) do
		local _, rem = bigDivMod(kCopy, two)
		if not bigIsZero(rem) then
			RX, RY, RZ = jacAdd(RX, RY, RZ, QX, QY, QZ)
		end
		QX, QY, QZ = jacDouble(QX, QY, QZ);
		kCopy = bigDiv(kCopy, two)
	end
	if bigIsZero(RZ) then
		return nil, nil
	end
	local Zinv = bigModInverse(RZ, P256_P)
	local Zinv2 = fp_mul(Zinv, Zinv);
	local Zinv3 = fp_mul(Zinv2, Zinv)
	return fp_mul(RX, Zinv2), fp_mul(RY, Zinv3)
end
--- ecdhGenKeyPair
-- @return type Description
local function ecdhGenKeyPair()
	local private = bigNew(0)
	while bigIsZero(private) do
		local rb = nc.crypto.randomBytes(# bigToBytes(P256_N) + 1)
		private = bigFromBytes(rb);
		private.sign = 1
		private = bigMod(private, bigSub(P256_N, bigNew(1)))
		if bigIsZero(private) then
			private = bigNew(0)
		end
	end
	local pubX, pubY = p256JacScalarMul(private, P256_GX, P256_GY)
	return {
		private = private,
		publicKey = {
			x = pubX,
			y = pubY
		}
	}
end
--- ecdhComputeSharedSecret
-- @param privateKey type Description
-- @param publicKey type Description
-- @return type Description
local function ecdhComputeSharedSecret(privateKey, publicKey)
	local sx, _ = p256JacScalarMul(privateKey, publicKey.x, publicKey.y)
	if sx == nil then
		error("[crypto] ECDH: invalid shared secret")
	end
	local xBytes = bigToBytes(sx, 32);
	local rawT = {}
	for _, b in ipairs(xBytes) do
		rawT[# rawT + 1] = char(b)
	end
	local hashRaw = hexToRaw(sha256raw(tcat(rawT)))
	local out = {};
	for i = 1, # hashRaw do
		out[i] = byte(hashRaw, i)
	end
	return Buffer.from(out)
end
--- jacToAffine
-- @param X type Description
-- @param Y type Description
-- @param Z type Description
-- @return type Description
local function jacToAffine(X, Y, Z)
	if bigIsZero(Z) then
		return nil, nil
	end
	local Zinv = bigModInverse(Z, P256_P)
	local Zinv2 = fp_mul(Zinv, Zinv);
	local Zinv3 = fp_mul(Zinv2, Zinv)
	return fp_mul(X, Zinv2), fp_mul(Y, Zinv3)
end
--- p256ScalarMulJac
-- @param k type Description
-- @param px type Description
-- @param py type Description
-- @return type Description
local function p256ScalarMulJac(k, px, py)
	local RX, RY, RZ = bigNew(0), bigNew(0), bigNew(0)
	local QX, QY, QZ = px, py, bigNew(1)
	local kCopy = bigNew(k);
	kCopy.sign = 1;
	local two = bigNew(2)
	while not bigIsZero(kCopy) do
		local _, rem = bigDivMod(kCopy, two)
		if not bigIsZero(rem) then
			RX, RY, RZ = jacAdd(RX, RY, RZ, QX, QY, QZ)
		end
		QX, QY, QZ = jacDouble(QX, QY, QZ);
		kCopy = bigDiv(kCopy, two)
	end
	return RX, RY, RZ
end
--- ecdsaSign
-- @param msgHash type Description
-- @param privKey type Description
-- @return type Description
local function ecdsaSign(msgHash, privKey)
	local hashBytes = Buffer.isBuffer(msgHash) and msgHash._b or msgHash
	local e = bigFromBytes(hashBytes);
	e = bigMod(e, P256_N)
	local nMinus1 = bigSub(P256_N, bigNew(1))
	while true do
		local rb = nc.crypto.randomBytes(33)
		local k = bigFromBytes(rb);
		k.sign = 1
		k = bigMod(k, nMinus1);
		k = bigAdd(k, bigNew(1))
		local x1, _ = p256JacScalarMul(k, P256_GX, P256_GY)
		local r = bigMod(x1, P256_N)
		if not bigIsZero(r) then
			local kinv = bigModInverse(k, P256_N)
			local rd = bigMod(bigMul(r, privKey.d or privKey.private), P256_N)
			local s = bigMod(bigMul(kinv, bigMod(bigAdd(e, rd), P256_N)), P256_N)
			if not bigIsZero(s) then
				return Buffer.from(bigToBytes(r, 32)), Buffer.from(bigToBytes(s, 32))
			end
		end
	end
end
--- ecdsaVerify
-- @param msgHash type Description
-- @param sigR type Description
-- @param sigS type Description
-- @param pubKey type Description
-- @return type Description
local function ecdsaVerify(msgHash, sigR, sigS, pubKey)
	local hashBytes = Buffer.isBuffer(msgHash) and msgHash._b or msgHash
	local r = Buffer.isBuffer(sigR) and bigFromBytes(sigR._b) or bigNew(sigR)
	local s = Buffer.isBuffer(sigS) and bigFromBytes(sigS._b) or bigNew(sigS)
	if bigCmp(r, bigNew(0)) <= 0 or bigCmp(r, P256_N) >= 0 then
		return false
	end
	if bigCmp(s, bigNew(0)) <= 0 or bigCmp(s, P256_N) >= 0 then
		return false
	end
	local e = bigFromBytes(hashBytes);
	e = bigMod(e, P256_N)
	local w = bigModInverse(s, P256_N)
	local u1 = bigMod(bigMul(e, w), P256_N)
	local u2 = bigMod(bigMul(r, w), P256_N)
	local X1, Y1, Z1 = p256ScalarMulJac(u1, P256_GX, P256_GY)
	local X2, Y2, Z2 = p256ScalarMulJac(u2, pubKey.x, pubKey.y)
	local X3, Y3, Z3 = jacAdd(X1, Y1, Z1, X2, Y2, Z2)
	if bigIsZero(Z3) then
		return false
	end
	local x, _ = jacToAffine(X3, Y3, Z3)
	return bigCmp(bigMod(x, P256_N), r) == 0
end
--- aesEncryptSingleBlock
-- @param keyBuf type Description
-- @param blockBytes type Description
-- @return type Description
local function aesEncryptSingleBlock(keyBuf, blockBytes)
	local cfg = AES_CONFIG["aes-" .. (keyBuf.length * 8) .. "-ecb"]
	if not cfg then
		error("[crypto] AES-CTR/GCM: key must be 16, 24, or 32 bytes")
	end
	local key = {};
	for i = 1, cfg.Nk * 4 do
		key[i] = keyBuf._b[i] or 0
	end
	local W, NR = aesKeyExpand(key, cfg.Nk, cfg.Nr)
	return aesEncBlock(blockBytes, W, NR)
end
--- ctrIncrement
-- @param ctrStr type Description
-- @return type Description
local function ctrIncrement(ctrStr)
	local b = {};
	for i = 1, 16 do
		b[i] = byte(ctrStr, i)
	end
	for i = 16, 13, - 1 do
		b[i] = (b[i] + 1) % 256
		if b[i] ~= 0 then
			break
		end
	end
	local out = {};
	for i = 1, 16 do
		out[i] = char(b[i])
	end
	return tcat(out)
end
--- aesCTRCrypt
-- @param keyBuf type Description
-- @param icb type Description
-- @param data type Description
-- @return type Description
local function aesCTRCrypt(keyBuf, icb, data)
	if # data == 0 then
		return ""
	end
	local out = {};
	local n = # data;
	local nblocks = ceil(n / 16)
	local counter = icb
	for blk = 0, nblocks - 1 do
		local ctrBytes = {};
		for i = 1, 16 do
			ctrBytes[i] = byte(counter, i)
		end
		local ks = aesEncryptSingleBlock(keyBuf, ctrBytes)
		local chunkLen = math.min(16, n - blk * 16)
		for i = 1, chunkLen do
			out[# out + 1] = char(bxor(byte(data, blk * 16 + i), ks[i]))
		end
		if blk < nblocks - 1 then
			counter = ctrIncrement(counter)
		end
	end
	return tcat(out)
end
--- ghashMul
-- @param Xw type Description
-- @param Hw type Description
-- @return type Description
local function ghashMul(Xw, Hw)
	local Z1, Z2, Z3, Z4 = 0, 0, 0, 0
	local V1, V2, V3, V4 = Hw[1], Hw[2], Hw[3], Hw[4]
	for i = 0, 127 do
		local wordIdx = floor(i / 32) + 1
		local bitPos = 31 - (i % 32)
		local Xi
		if wordIdx == 1 then
			Xi = band(rsh(Xw[1], bitPos), 1)
		elseif wordIdx == 2 then
			Xi = band(rsh(Xw[2], bitPos), 1)
		elseif wordIdx == 3 then
			Xi = band(rsh(Xw[3], bitPos), 1)
		else
			Xi = band(rsh(Xw[4], bitPos), 1)
		end
		if Xi == 1 then
			Z1 = bxor(Z1, V1);
			Z2 = bxor(Z2, V2);
			Z3 = bxor(Z3, V3);
			Z4 = bxor(Z4, V4)
		end
		local lsb = band(V4, 1)
		V4 = bor(rsh(V4, 1), lsh(band(V3, 1), 31))
		V3 = bor(rsh(V3, 1), lsh(band(V2, 1), 31))
		V2 = bor(rsh(V2, 1), lsh(band(V1, 1), 31))
		V1 = rsh(V1, 1)
		if lsb == 1 then
			V1 = bxor(V1, 0xE1000000)
		end
	end
	return {
		Z1,
		Z2,
		Z3,
		Z4
	}
end
--- ghashBytesToWords
-- @param b type Description
-- @return type Description
local function ghashBytesToWords(b)
	local w = {}
	for i = 1, 4 do
		local o = (i - 1) * 4 + 1
		w[i] = byte(b, o) * 16777216 + byte(b, o + 1) * 65536 + byte(b, o + 2) * 256 + byte(b, o + 3)
	end
	return w
end
--- ghashWordsToBytes
-- @param w type Description
-- @return type Description
local function ghashWordsToBytes(w)
	local out = {}
	for i = 1, 4 do
		local v = w[i]
		out[i] = char(floor(v / 16777216) % 256, floor(v / 65536) % 256, floor(v / 256) % 256, v % 256)
	end
	return tcat(out)
end
--- ghashCompute
-- @param Hw type Description
-- @param data type Description
-- @return type Description
local function ghashCompute(Hw, data)
	local Y = {
		0,
		0,
		0,
		0
	}
	for b = 0, # data / 16 - 1 do
		local Xw = ghashBytesToWords(data:sub(b * 16 + 1, b * 16 + 16))
		Y = {
			bxor(Y[1], Xw[1]),
			bxor(Y[2], Xw[2]),
			bxor(Y[3], Xw[3]),
			bxor(Y[4], Xw[4])
		}
		Y = ghashMul(Y, Hw)
	end
	return Y
end
--- pad16
-- @param s type Description
-- @return type Description
local function pad16(s)
	local r = # s % 16;
	if r == 0 then
		return s
	end;
	return s .. string.rep("\x00", 16 - r)
end
--- be64
-- @param n type Description
-- @return type Description
local function be64(n)
	local out = {};
	for i = 7, 0, - 1 do
		out[# out + 1] = char(floor(n / (2 ^ (8 * i))) % 256)
	end;
	return tcat(out)
end
--- gcmDeriveJ0
-- @param keyBuf type Description
-- @param iv type Description
-- @return type Description
local function gcmDeriveJ0(keyBuf, iv)
	local zero16 = {};
	for i = 1, 16 do
		zero16[i] = 0
	end
	local Hbytes = aesEncryptSingleBlock(keyBuf, zero16)
	local Hstr = {};
	for i = 1, 16 do
		Hstr[i] = char(Hbytes[i])
	end
	local Hw = ghashBytesToWords(tcat(Hstr))
	local J0
	if # iv == 12 then
		J0 = iv .. "\x00\x00\x00\x01"
	else
		local ivPadded = pad16(iv)
		local lenBlock = be64(0) .. be64(# iv * 8)
		local j0w = ghashCompute(Hw, ivPadded .. lenBlock)
		J0 = ghashWordsToBytes(j0w)
	end
	return Hw, J0
end
--- gcmTag
-- @param Hw type Description
-- @param J0 type Description
-- @param keyBuf type Description
-- @param aad type Description
-- @param ciphertext type Description
-- @return type Description
local function gcmTag(Hw, J0, keyBuf, aad, ciphertext)
	local ghashInput = pad16(aad) .. pad16(ciphertext) .. be64(# aad * 8) .. be64(# ciphertext * 8)
	local S = ghashCompute(Hw, ghashInput)
	local Sbytes = ghashWordsToBytes(S)
	local J0bytes = {};
	for i = 1, 16 do
		J0bytes[i] = byte(J0, i)
	end
	local EJ0 = aesEncryptSingleBlock(keyBuf, J0bytes)
	local tag = {}
	for i = 1, 16 do
		tag[i] = char(bxor(byte(Sbytes, i), EJ0[i]))
	end
	return tcat(tag)
end
--- aesGCMEncrypt
-- @param keyBuf type Description
-- @param iv type Description
-- @param plainBuf type Description
-- @param aad type Description
-- @return type Description
local function aesGCMEncrypt(keyBuf, iv, plainBuf, aad)
	aad = aad or ""
	local Hw, J0 = gcmDeriveJ0(keyBuf, iv)
	local ctrStart = ctrIncrement(J0)
	local plainStr = Buffer.isBuffer(plainBuf) and plainBuf:toString("utf8") or plainBuf
	local ciphertext = aesCTRCrypt(keyBuf, ctrStart, plainStr)
	local tag = gcmTag(Hw, J0, keyBuf, aad, ciphertext)
	local ctBytes = {};
	for i = 1, # ciphertext do
		ctBytes[i] = byte(ciphertext, i)
	end
	local tagBytes = {};
	for i = 1, # tag do
		tagBytes[i] = byte(tag, i)
	end
	return Buffer.from(ctBytes), Buffer.from(tagBytes)
end
--- aesGCMDecrypt
-- @param keyBuf type Description
-- @param iv type Description
-- @param cipherBuf type Description
-- @param aad type Description
-- @param tagBuf type Description
-- @return type Description
local function aesGCMDecrypt(keyBuf, iv, cipherBuf, aad, tagBuf)
	aad = aad or ""
	local Hw, J0 = gcmDeriveJ0(keyBuf, iv)
	local cipherStr = Buffer.isBuffer(cipherBuf) and cipherBuf:toString("utf8") or cipherBuf
	local tagStr = Buffer.isBuffer(tagBuf) and tagBuf:toString("utf8") or tagBuf
	local expectedTag = gcmTag(Hw, J0, keyBuf, aad, cipherStr)
	if not constantTimeCompare(expectedTag, tagStr) then
		error("[crypto] AES-GCM: authentication tag mismatch (data may be tampered)")
	end
	local ctrStart = ctrIncrement(J0)
	local plaintext = aesCTRCrypt(keyBuf, ctrStart, cipherStr)
	local out = {};
	for i = 1, # plaintext do
		out[i] = byte(plaintext, i)
	end
	return Buffer.from(out)
end
local CHACHA_CONST = {
	0x61707865,
	0x3320646e,
	0x79622d32,
	0x6b206574
}
--- chacha20QR
-- @param s type Description
-- @param a type Description
-- @param b type Description
-- @param c type Description
-- @param d type Description
-- @return type Description
local function chacha20QR(s, a, b, c, d)
	s[a] = (s[a] + s[b]) % MOD32;
	s[d] = bxor(s[d], s[a]);
	s[d] = rrotl(s[d], 16)
	s[c] = (s[c] + s[d]) % MOD32;
	s[b] = bxor(s[b], s[c]);
	s[b] = rrotl(s[b], 12)
	s[a] = (s[a] + s[b]) % MOD32;
	s[d] = bxor(s[d], s[a]);
	s[d] = rrotl(s[d], 8)
	s[c] = (s[c] + s[d]) % MOD32;
	s[b] = bxor(s[b], s[c]);
	s[b] = rrotl(s[b], 7)
end
--- chacha20Block
-- @param key type Description
-- @param nonce type Description
-- @param counter type Description
-- @return type Description
local function chacha20Block(key, nonce, counter)
	local state = {}
	for i = 1, 4 do
		state[i] = CHACHA_CONST[i]
	end
	for i = 1, 8 do
		local o = (i - 1) * 4 + 1
		state[4 + i] = byte(key, o) + byte(key, o + 1) * 256 + byte(key, o + 2) * 65536 + byte(key, o + 3) * 16777216
	end
	state[13] = counter
	for i = 1, 3 do
		local o = (i - 1) * 4 + 1
		state[13 + i] = byte(nonce, o) + byte(nonce, o + 1) * 256 + byte(nonce, o + 2) * 65536 + byte(nonce, o + 3) * 16777216
	end
	local w = {};
	for i = 1, 16 do
		w[i] = state[i]
	end
	for _ = 1, 10 do
		chacha20QR(w, 1, 5, 9, 13);
		chacha20QR(w, 2, 6, 10, 14);
		chacha20QR(w, 3, 7, 11, 15);
		chacha20QR(w, 4, 8, 12, 16)
		chacha20QR(w, 1, 6, 11, 16);
		chacha20QR(w, 2, 7, 12, 13);
		chacha20QR(w, 3, 8, 9, 14);
		chacha20QR(w, 4, 5, 10, 15)
	end
	local out = {}
	for i = 1, 16 do
		local v = (w[i] + state[i]) % MOD32
		out[i] = char(v % 256, floor(v / 256) % 256, floor(v / 65536) % 256, floor(v / 16777216) % 256)
	end
	return tcat(out)
end
--- chacha20Crypt
-- @param key type Description
-- @param nonce type Description
-- @param counter type Description
-- @param data type Description
-- @return type Description
local function chacha20Crypt(key, nonce, counter, data)
	if # data == 0 then
		return ""
	end
	local out = {};
	local n = # data;
	local nblocks = ceil(n / 64)
	for b = 0, nblocks - 1 do
		local ks = chacha20Block(key, nonce, counter + b)
		local chunkLen = math.min(64, n - b * 64)
		for i = 1, chunkLen do
			out[# out + 1] = char(bxor(byte(data, b * 64 + i), byte(ks, i)))
		end
	end
	return tcat(out)
end
local POLY1305_P
do
	local p = bigNew(1)
	for _ = 1, 130 do
		p = bigAdd(p, p)
	end
	POLY1305_P = bigSub(p, bigNew(5))
end
local POLY1305_MOD128
do
	local m = bigNew(1)
	for _ = 1, 128 do
		m = bigAdd(m, m)
	end
	POLY1305_MOD128 = m
end
--- leBytesToBig
-- @param data type Description
-- @return type Description
local function leBytesToBig(data)
	local n = bigNew(0)
	for i = # data, 1, - 1 do
		n = bigAdd(bigMul(n, bigNew(256)), bigNew(byte(data, i)))
	end
	return n
end
--- poly1305MAC
-- @param key type Description
-- @param msg type Description
-- @return type Description
local function poly1305MAC(key, msg)
	local rBytes = {}
	for i = 1, 16 do
		rBytes[i] = byte(key, i)
	end
	rBytes[4] = band(rBytes[4], 15);
	rBytes[8] = band(rBytes[8], 15);
	rBytes[12] = band(rBytes[12], 15);
	rBytes[16] = band(rBytes[16], 15)
	rBytes[5] = band(rBytes[5], 252);
	rBytes[9] = band(rBytes[9], 252);
	rBytes[13] = band(rBytes[13], 252)
	local rStr = {};
	for i = 1, 16 do
		rStr[i] = char(rBytes[i])
	end
	local r = leBytesToBig(tcat(rStr))
	local s = leBytesToBig(key:sub(17, 32))
	local a = bigNew(0)
	local n = # msg;
	local nblocks = ceil(n / 16)
	for b = 0, nblocks - 1 do
		local blockLen = math.min(16, n - b * 16)
		local chunk = msg:sub(b * 16 + 1, b * 16 + blockLen)
		local blockVal = leBytesToBig(chunk .. "\x01")
		a = bigAdd(a, blockVal)
		a = bigMod(bigMul(a, r), POLY1305_P)
	end
	a = bigAdd(a, s)
	a = bigMod(a, POLY1305_MOD128)
	local bytes = bigToBytes(a, 16)
	local out = {};
	for i = 16, 1, - 1 do
		out[# out + 1] = char(bytes[i])
	end
	return tcat(out)
end
--- leU64
-- @param n type Description
-- @return type Description
local function leU64(n)
	local out = {};
	for i = 0, 7 do
		out[# out + 1] = char(floor(n / (2 ^ (8 * i))) % 256)
	end;
	return tcat(out)
end
--- chacha20poly1305Encrypt
-- @param keyBuf type Description
-- @param nonceBuf type Description
-- @param plainBuf type Description
-- @param aad type Description
-- @return type Description
local function chacha20poly1305Encrypt(keyBuf, nonceBuf, plainBuf, aad)
	aad = aad or ""
	local key = Buffer.isBuffer(keyBuf) and keyBuf:toString("utf8") or keyBuf
	local nonce = Buffer.isBuffer(nonceBuf) and nonceBuf:toString("utf8") or nonceBuf
	local plainStr = Buffer.isBuffer(plainBuf) and plainBuf:toString("utf8") or plainBuf
	local otk = chacha20Block(key, nonce, 0):sub(1, 32)
	local ct = chacha20Crypt(key, nonce, 1, plainStr)
	local macData = pad16(aad) .. pad16(ct) .. leU64(# aad) .. leU64(# ct)
	local tag = poly1305MAC(otk, macData)
	local ctBytes = {};
	for i = 1, # ct do
		ctBytes[i] = byte(ct, i)
	end
	local tagBytes = {};
	for i = 1, # tag do
		tagBytes[i] = byte(tag, i)
	end
	return Buffer.from(ctBytes), Buffer.from(tagBytes)
end
--- chacha20poly1305Decrypt
-- @param keyBuf type Description
-- @param nonceBuf type Description
-- @param cipherBuf type Description
-- @param aad type Description
-- @param tagBuf type Description
-- @return type Description
local function chacha20poly1305Decrypt(keyBuf, nonceBuf, cipherBuf, aad, tagBuf)
	aad = aad or ""
	local key = Buffer.isBuffer(keyBuf) and keyBuf:toString("utf8") or keyBuf
	local nonce = Buffer.isBuffer(nonceBuf) and nonceBuf:toString("utf8") or nonceBuf
	local cipherStr = Buffer.isBuffer(cipherBuf) and cipherBuf:toString("utf8") or cipherBuf
	local tagStr = Buffer.isBuffer(tagBuf) and tagBuf:toString("utf8") or tagBuf
	local otk = chacha20Block(key, nonce, 0):sub(1, 32)
	local macData = pad16(aad) .. pad16(cipherStr) .. leU64(# aad) .. leU64(# cipherStr)
	local expectedTag = poly1305MAC(otk, macData)
	if not constantTimeCompare(expectedTag, tagStr) then
		error("[crypto] ChaCha20-Poly1305: authentication tag mismatch (data may be tampered)")
	end
	local pt = chacha20Crypt(key, nonce, 1, cipherStr)
	local out = {};
	for i = 1, # pt do
		out[i] = byte(pt, i)
	end
	return Buffer.from(out)
end
local HKDF_HLEN = {
	sha256 = 32,
	sha1 = 20,
	md5 = 16,
	["sha3-256"] = 32,
	["sha3-512"] = 64
}
--- hkdfExtract
-- @param salt type Description
-- @param ikm type Description
-- @param digest type Description
-- @return type Description
local function hkdfExtract(salt, ikm, digest)
	digest = digest or "sha256"
	if salt == nil or salt == "" then
		salt = string.rep("\x00", HKDF_HLEN[digest] or 32)
	end
	return crypto.createHmac(digest, salt):update(ikm):digest("buffer")
end
--- hkdfExpand
-- @param prk type Description
-- @param info type Description
-- @param length type Description
-- @param digest type Description
-- @return type Description
local function hkdfExpand(prk, info, length, digest)
	digest = digest or "sha256"
	local hlen = HKDF_HLEN[digest] or 32
	local n = ceil(length / hlen)
	if n > 255 then
		error("[crypto] HKDF: requested length too large")
	end
	local prkStr = Buffer.isBuffer(prk) and prk:toString("utf8") or prk
	local prev = "";
	local okm = {}
	for i = 1, n do
		local hmac = crypto.createHmac(digest, prkStr)
		hmac:update(prev);
		hmac:update(info);
		hmac:update(char(i))
		local t_i = hmac:digest("buffer"):toString("utf8")
		okm[# okm + 1] = t_i;
		prev = t_i
	end
	local out = tcat(okm):sub(1, length)
	local bytes = {};
	for i = 1, # out do
		bytes[i] = byte(out, i)
	end
	return Buffer.from(bytes)
end
--- hkdf
-- @param ikm type Description
-- @param salt type Description
-- @param info type Description
-- @param length type Description
-- @param digest type Description
-- @return type Description
local function hkdf(ikm, salt, info, length, digest)
	local prk = hkdfExtract(salt, ikm, digest)
	return hkdfExpand(prk, info, length, digest)
end
--- hotpGenerate
-- @param secret type Description
-- @param counter type Description
-- @param digits type Description
-- @param digest type Description
-- @return type Description
local function hotpGenerate(secret, counter, digits, digest)
	digits = digits or 6;
	digest = digest or "sha1"
	local counterBytes = {}
	for i = 7, 0, - 1 do
		counterBytes[# counterBytes + 1] = char(floor(counter / (2 ^ (8 * i))) % 256)
	end
	local msg = tcat(counterBytes)
	local hmacResult = crypto.createHmac(digest, secret):update(msg):digest("buffer")
	local offset = hmacResult:byteAt(hmacResult.length - 1) % 16
	local p = hmacResult:readUInt32BE(offset)
	p = p % (2 ^ 31)
	local code = p % (10 ^ digits)
	return fmt("%0" .. digits .. "d", code)
end
--- totpGenerate
-- @param secret type Description
-- @param opts type Description
-- @return type Description
local function totpGenerate(secret, opts)
	opts = opts or {}
	local step = opts.step or 30
	local digits = opts.digits or 6
	local digest = opts.digest or "sha1"
	local time = opts.timestamp or os.time()
	local counter = floor(time / step)
	return hotpGenerate(secret, counter, digits, digest)
end
--- totpVerify
-- @param token type Description
-- @param secret type Description
-- @param opts type Description
-- @return type Description
local function totpVerify(token, secret, opts)
	opts = opts or {}
	local step = opts.step or 30
	local digits = opts.digits or 6
	local digest = opts.digest or "sha1"
	local time = opts.timestamp or os.time()
	local window = opts.window or 1
	local counter = floor(time / step)
	for delta = - window, window do
		local code = hotpGenerate(secret, counter + delta, digits, digest)
		if constantTimeCompare(code, token) then
			return true
		end
	end
	return false
end
local B32_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
local B32_LOOKUP = {}
for i = 1, # B32_ALPHABET do
	B32_LOOKUP[B32_ALPHABET:sub(i, i)] = i - 1
end
--- base32Encode
-- @param data type Description
-- @return type Description
local function base32Encode(data)
	local out = {};
	local bits = 0;
	local val = 0
	for i = 1, # data do
		val = val * 256 + byte(data, i);
		bits = bits + 8
		while bits >= 5 do
			bits = bits - 5
			local idx = floor(val / (2 ^ bits)) % 32
			out[# out + 1] = B32_ALPHABET:sub(idx + 1, idx + 1)
			val = val % (2 ^ bits)
		end
	end
	if bits > 0 then
		local idx = (val * (2 ^ (5 - bits))) % 32
		out[# out + 1] = B32_ALPHABET:sub(idx + 1, idx + 1)
	end
	local s = tcat(out)
	while # s % 8 ~= 0 do
		s = s .. "="
	end
	return s
end
--- base32Decode
-- @param s type Description
-- @return type Description
local function base32Decode(s)
	s = s:gsub("=", ""):upper()
	local out = {};
	local bits = 0;
	local val = 0
	for i = 1, # s do
		local c = B32_LOOKUP[s:sub(i, i)]
		if c then
			val = val * 32 + c;
			bits = bits + 5
			if bits >= 8 then
				bits = bits - 8
				out[# out + 1] = char(floor(val / (2 ^ bits)) % 256)
				val = val % (2 ^ bits)
			end
		end
	end
	return tcat(out)
end
local CRC32_TABLE = {}
do
	for i = 0, 255 do
		local c = i
		for _ = 1, 8 do
			if c % 2 == 1 then
				c = bxor(rsh(c, 1), 0xEDB88320)
			else
				c = rsh(c, 1)
			end
		end
		CRC32_TABLE[i] = c
	end
end
--- crc32Compute
-- @param data type Description
-- @return type Description
local function crc32Compute(data)
	local crc = 0xFFFFFFFF
	for i = 1, # data do
		crc = bxor(rsh(crc, 8), CRC32_TABLE[bxor(band(crc, 0xFF), byte(data, i))])
	end
	return bxor(crc, 0xFFFFFFFF)
end
local ALGOS = {
	sha1 = {
		fn = sha1raw,
		block = 64
	},
	sha256 = {
		fn = sha256raw,
		block = 64
	},
	md5 = {
		fn = md5raw,
		block = 64
	},
	["sha3-224"] = {
		fn = sha3_224,
		block = 144
	},
	["sha3-256"] = {
		fn = sha3_256,
		block = 136
	},
	["sha3-384"] = {
		fn = sha3_384,
		block = 104
	},
	["sha3-512"] = {
		fn = sha3_512,
		block = 72
	},
	keccak256 = {
		fn = keccak256,
		block = 136
	},
}
--- crypto.createHash
-- @param algo type Description
-- @return type Description
function crypto.createHash(algo)
	algo = algo:lower();
	local a = ALGOS[algo]
	if not a then
		error("[crypto] unknown hash: " .. algo)
	end
	local obj = {
		_buf = "",
		_algo = algo
	}
--- obj:update
-- @param d type Description
-- @return type Description
	function obj:update(d)
		self._buf = self._buf .. tostr(d);
		return self
	end
--- obj:digest
-- @param enc type Description
-- @return type Description
	function obj:digest(enc)
		return digestBuild(a.fn(self._buf), enc)
	end
	return obj
end
--- crypto.createHmac
-- @param algo type Description
-- @param key type Description
-- @return type Description
function crypto.createHmac(algo, key)
	algo = algo:lower();
	local a = ALGOS[algo]
	if not a then
		error("[crypto] unknown hmac algo: " .. algo)
	end
	if Buffer.isBuffer(key) then
		key = key:toString("utf8")
	end
	local obj = {
		_buf = "",
		_key = key
	}
--- obj:update
-- @param d type Description
-- @return type Description
	function obj:update(d)
		self._buf = self._buf .. tostr(d);
		return self
	end
--- obj:digest
-- @param enc type Description
-- @return type Description
	function obj:digest(enc)
		return digestBuild(hmacRaw(a.fn, a.block, self._key, self._buf), enc)
	end
	return obj
end
--- crypto.randomBytes
-- @param n type Description
-- @return type Description
function crypto.randomBytes(n)
	if type(n) ~= "number" or n < 1 then
		error("[crypto] randomBytes: n must be positive number")
	end
	return getSecureRandom(floor(n))
end
--- crypto.randomUUID
-- @return type Description
function crypto.randomUUID()
	local bytes = getSecureRandom(16);
	local b = bytes._b
	b[7] = bor(band(b[7] or 0, 0x0F), 0x40);
	b[9] = bor(band(b[9] or 0, 0x3F), 0x80)
	return fmt("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", b[1] or 0, b[2] or 0, b[3] or 0, b[4] or 0, b[5] or 0, b[6] or 0, b[7] or 0, b[8] or 0, b[9] or 0, b[10] or 0, b[11] or 0, b[12] or 0, b[13] or 0, b[14] or 0, b[15] or 0, b[16] or 0)
end
crypto.randomUUIDv4 = crypto.randomUUID
--- crypto.randomUUIDv1
-- @return type Description
function crypto.randomUUIDv1()
	local t = tick();
	local timeHex = fmt("%015x", floor(t * 1e7))
	local b = getSecureRandom(8)
	local node = fmt("%02x%02x%02x%02x%02x%02x", b._b[1], b._b[2], b._b[3], b._b[4], b._b[5], b._b[6])
	local clockSeq = fmt("%04x", bor(band(b._b[7] * 256 + b._b[8], 0x3FFF), 0x8000))
	local timeLow = timeHex:sub(8, 15);
	local timeMid = timeHex:sub(4, 7)
	local timeHigh = bor(tonumber(timeHex:sub(1, 3), 16), 0x1000)
	return fmt("%s-%s-%04x-%s-%s", timeLow, timeMid, timeHigh, clockSeq, node)
end
--- crypto.randomUUIDv3
-- @param namespace type Description
-- @param name type Description
-- @return type Description
function crypto.randomUUIDv3(namespace, name)
	namespace = namespace or "6ba7b810-9dad-11d1-80b4-00c04fd430c8";
	name = name or tostring(tick())
	local raw = namespace:gsub("-", "") .. name;
	local hash = md5raw(raw);
	local b = {}
	for hex in hash:gmatch("%x%x") do
		b[# b + 1] = tonumber(hex, 16) or 0
	end
	b[7] = bor(band(b[7] or 0, 0x0F), 0x30);
	b[9] = bor(band(b[9] or 0, 0x3F), 0x80)
	return fmt("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", b[1] or 0, b[2] or 0, b[3] or 0, b[4] or 0, b[5] or 0, b[6] or 0, b[7] or 0, b[8] or 0, b[9] or 0, b[10] or 0, b[11] or 0, b[12] or 0, b[13] or 0, b[14] or 0, b[15] or 0, b[16] or 0)
end
--- crypto.randomUUIDv5
-- @param namespace type Description
-- @param name type Description
-- @return type Description
function crypto.randomUUIDv5(namespace, name)
	namespace = namespace or "6ba7b810-9dad-11d1-80b4-00c04fd430c8";
	name = name or tostring(tick())
	local raw = namespace:gsub("-", "") .. name;
	local hash = sha1raw(raw);
	local b = {}
	for hex in hash:gmatch("%x%x") do
		b[# b + 1] = tonumber(hex, 16) or 0
	end
	b[7] = bor(band(b[7] or 0, 0x0F), 0x50);
	b[9] = bor(band(b[9] or 0, 0x3F), 0x80)
	return fmt("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", b[1] or 0, b[2] or 0, b[3] or 0, b[4] or 0, b[5] or 0, b[6] or 0, b[7] or 0, b[8] or 0, b[9] or 0, b[10] or 0, b[11] or 0, b[12] or 0, b[13] or 0, b[14] or 0, b[15] or 0, b[16] or 0)
end
--- crypto.createCipheriv
-- @param algo type Description
-- @param key type Description
-- @param iv type Description
-- @return type Description
function crypto.createCipheriv(algo, key, iv)
	if type(key) == "string" then
		key = Buffer.from(key)
	end
	if type(iv) == "string" then
		iv = Buffer.from(iv)
	end
	local a = algo:lower()
	if a == "xor" then
		return {
			update = function(_, data)
				return xorCipher(key, data)
			end,
			final = function()
				return ""
			end
		}
	end
	local cfg = AES_CONFIG[a]
	if not cfg then
		error("[crypto] supported: aes-128/192/256-cbc/ecb, xor (got " .. a .. ")")
	end
	return {
		update = function(_, data)
			if type(data) == "string" then
				data = Buffer.from(data)
			end
			return aesEncrypt(a, key, iv, data)
		end,
		final = function(_)
			return Buffer.alloc(0)
		end
	}
end
--- crypto.createDecipheriv
-- @param algo type Description
-- @param key type Description
-- @param iv type Description
-- @return type Description
function crypto.createDecipheriv(algo, key, iv)
	if type(key) == "string" then
		key = Buffer.from(key)
	end
	if type(iv) == "string" then
		iv = Buffer.from(iv)
	end
	local a = algo:lower()
	if a == "xor" then
		return {
			update = function(_, data)
				return xorCipher(key, data)
			end,
			final = function()
				return ""
			end
		}
	end
	local cfg = AES_CONFIG[a]
	if not cfg then
		error("[crypto] supported: aes-128/192/256-cbc/ecb, xor (got " .. a .. ")")
	end
	return {
		update = function(_, data)
			if type(data) == "string" then
				data = Buffer.from(data)
			end
			if not Buffer.isBuffer(data) or data.length == 0 then
				return Buffer.alloc(0)
			end
			return aesDecrypt(a, key, iv, data)
		end,
		final = function(_)
			return Buffer.alloc(0)
		end
	}
end
crypto.pbkdf2Sync = function(password, salt, iters, keylen, digest)
	return wrapError(function()
		return pbkdf2(tostr(password), tostr(salt), iters, keylen, digest)
	end, "pbkdf2Sync")()
end
--- crypto.pbkdf2
-- @param password type Description
-- @param salt type Description
-- @param iters type Description
-- @param keylen type Description
-- @param digest type Description
-- @param cb type Description
-- @return type Description
function crypto.pbkdf2(password, salt, iters, keylen, digest, cb)
	asyncRun(function()
		return pbkdf2(tostr(password), tostr(salt), iters, keylen, digest)
	end, cb)
end
crypto.sha1 = function(msg, enc)
	return digestBuild(sha1raw(tostr(msg)), enc)
end
crypto.sha256 = function(msg, enc)
	return digestBuild(sha256raw(tostr(msg)), enc)
end
crypto.md5 = function(msg, enc)
	return digestBuild(md5raw(tostr(msg)), enc)
end
crypto.sha3_224 = function(msg, enc)
	return digestBuild(sha3_224(tostr(msg)), enc)
end
crypto.sha3_256 = function(msg, enc)
	return digestBuild(sha3_256(tostr(msg)), enc)
end
crypto.sha3_384 = function(msg, enc)
	return digestBuild(sha3_384(tostr(msg)), enc)
end
crypto.sha3_512 = function(msg, enc)
	return digestBuild(sha3_512(tostr(msg)), enc)
end
crypto.keccak256 = function(msg, enc)
	return digestBuild(keccak256(tostr(msg)), enc)
end
crypto.shake128 = function(msg, n)
	return shake128(tostr(msg), n)
end
crypto.shake256 = function(msg, n)
	return shake256(tostr(msg), n)
end
crypto.base64encode = function(d)
	if type(d) == "string" then
		d = Buffer.from(d)
	end;
	return d:toString("base64")
end
crypto.base64decode = function(s)
	return Buffer.from(s, "base64")
end
crypto.constantTimeCompare = constantTimeCompare
--- crypto.rsaGenerateKeyPair
-- @param keySize type Description
-- @return type Description
function crypto.rsaGenerateKeyPair(keySize)
	return wrapError(rsaGenKeyPair, "rsaGenerateKeyPair")(keySize)
end
--- crypto.rsaEncrypt
-- @param msg type Description
-- @param pubKey type Description
-- @param useOAEP type Description
-- @return type Description
function crypto.rsaEncrypt(msg, pubKey, useOAEP)
	return wrapError(rsaEncrypt, "rsaEncrypt")(msg, pubKey, useOAEP)
end
--- crypto.rsaDecrypt
-- @param cipher type Description
-- @param privKey type Description
-- @param useOAEP type Description
-- @return type Description
function crypto.rsaDecrypt(cipher, privKey, useOAEP)
	return wrapError(rsaDecrypt, "rsaDecrypt")(cipher, privKey, useOAEP)
end
--- crypto.rsaSign
-- @param msg type Description
-- @param privKey type Description
-- @return type Description
function crypto.rsaSign(msg, privKey)
	return wrapError(rsaSign, "rsaSign")(msg, privKey)
end
--- crypto.rsaVerify
-- @param msg type Description
-- @param sig type Description
-- @param pubKey type Description
-- @return type Description
function crypto.rsaVerify(msg, sig, pubKey)
	return wrapError(rsaVerify, "rsaVerify")(msg, sig, pubKey)
end
--- crypto.ecdhGenerateKeyPair
-- @return type Description
function crypto.ecdhGenerateKeyPair()
	return wrapError(ecdhGenKeyPair, "ecdhGenerateKeyPair")()
end
--- crypto.ecdhComputeSharedSecret
-- @param pk type Description
-- @param pub type Description
-- @return type Description
function crypto.ecdhComputeSharedSecret(pk, pub)
	return wrapError(ecdhComputeSharedSecret, "ecdhComputeSharedSecret")(pk, pub)
end
--- crypto.rsaGenerateKeyPairAsync
-- @param keySize type Description
-- @param cb type Description
-- @return type Description
function crypto.rsaGenerateKeyPairAsync(keySize, cb)
	asyncRun(function()
		return rsaGenKeyPair(keySize)
	end, cb)
end
--- crypto.ecdhGenerateKeyPairAsync
-- @param cb type Description
-- @return type Description
function crypto.ecdhGenerateKeyPairAsync(cb)
	asyncRun(ecdhGenKeyPair, cb)
end
--- crypto.ecdsaSign
-- @param msgHash type Description
-- @param privKey type Description
-- @return type Description
function crypto.ecdsaSign(msgHash, privKey)
	return wrapError(ecdsaSign, "ecdsaSign")(msgHash, privKey)
end
--- crypto.ecdsaVerify
-- @param msgHash type Description
-- @param sigR type Description
-- @param sigS type Description
-- @param pubKey type Description
-- @return type Description
function crypto.ecdsaVerify(msgHash, sigR, sigS, pubKey)
	return wrapError(ecdsaVerify, "ecdsaVerify")(msgHash, sigR, sigS, pubKey)
end
--- crypto.aesGCMEncrypt
-- @param key type Description
-- @param iv type Description
-- @param plaintext type Description
-- @param aad type Description
-- @return type Description
function crypto.aesGCMEncrypt(key, iv, plaintext, aad)
	if type(key) == "string" then
		key = Buffer.from(key)
	end
	if Buffer.isBuffer(iv) then
		iv = iv:toString("utf8")
	end
	if Buffer.isBuffer(aad) then
		aad = aad:toString("utf8")
	end
	return wrapError(aesGCMEncrypt, "aesGCMEncrypt")(key, iv, plaintext, aad)
end
--- crypto.aesGCMDecrypt
-- @param key type Description
-- @param iv type Description
-- @param ciphertext type Description
-- @param aad type Description
-- @param tag type Description
-- @return type Description
function crypto.aesGCMDecrypt(key, iv, ciphertext, aad, tag)
	if type(key) == "string" then
		key = Buffer.from(key)
	end
	if Buffer.isBuffer(iv) then
		iv = iv:toString("utf8")
	end
	if Buffer.isBuffer(aad) then
		aad = aad:toString("utf8")
	end
	return wrapError(aesGCMDecrypt, "aesGCMDecrypt")(key, iv, ciphertext, aad, tag)
end
--- crypto.aesCTR
-- @param key type Description
-- @param icb type Description
-- @param data type Description
-- @return type Description
function crypto.aesCTR(key, icb, data)
	if type(key) == "string" then
		key = Buffer.from(key)
	end
	if type(icb) == "string" then
		icb = Buffer.from(icb)
	end
	local icbStr = icb:toString("utf8")
	local dataStr = Buffer.isBuffer(data) and data:toString("utf8") or data
	local out = aesCTRCrypt(key, icbStr, dataStr)
	local bytes = {};
	for i = 1, # out do
		bytes[i] = byte(out, i)
	end
	return Buffer.from(bytes)
end
--- crypto.chacha20poly1305Encrypt
-- @param key type Description
-- @param nonce type Description
-- @param plaintext type Description
-- @param aad type Description
-- @return type Description
function crypto.chacha20poly1305Encrypt(key, nonce, plaintext, aad)
	if type(key) == "string" and # key ~= 32 then
		key = Buffer.from(key)
	end
	if type(nonce) == "string" and # nonce ~= 12 then
		nonce = Buffer.from(nonce)
	end
	return wrapError(chacha20poly1305Encrypt, "chacha20poly1305Encrypt")(key, nonce, plaintext, aad)
end
--- crypto.chacha20poly1305Decrypt
-- @param key type Description
-- @param nonce type Description
-- @param ciphertext type Description
-- @param aad type Description
-- @param tag type Description
-- @return type Description
function crypto.chacha20poly1305Decrypt(key, nonce, ciphertext, aad, tag)
	if type(key) == "string" and # key ~= 32 then
		key = Buffer.from(key)
	end
	if type(nonce) == "string" and # nonce ~= 12 then
		nonce = Buffer.from(nonce)
	end
	return wrapError(chacha20poly1305Decrypt, "chacha20poly1305Decrypt")(key, nonce, ciphertext, aad, tag)
end
--- crypto.chacha20
-- @param key type Description
-- @param nonce type Description
-- @param counter type Description
-- @param data type Description
-- @return type Description
function crypto.chacha20(key, nonce, counter, data)
	local keyStr = Buffer.isBuffer(key) and key:toString("utf8") or key
	local nonceStr = Buffer.isBuffer(nonce) and nonce:toString("utf8") or nonce
	local dataStr = Buffer.isBuffer(data) and data:toString("utf8") or data
	local out = wrapError(chacha20Crypt, "chacha20")(keyStr, nonceStr, counter, dataStr)
	local bytes = {};
	for i = 1, # out do
		bytes[i] = byte(out, i)
	end
	return Buffer.from(bytes)
end
--- crypto.hkdf
-- @param ikm type Description
-- @param salt type Description
-- @param info type Description
-- @param length type Description
-- @param digest type Description
-- @return type Description
function crypto.hkdf(ikm, salt, info, length, digest)
	return wrapError(hkdf, "hkdf")(ikm, salt, info, length, digest)
end
--- crypto.hkdfExtract
-- @param salt type Description
-- @param ikm type Description
-- @param digest type Description
-- @return type Description
function crypto.hkdfExtract(salt, ikm, digest)
	return wrapError(hkdfExtract, "hkdfExtract")(salt, ikm, digest)
end
--- crypto.hkdfExpand
-- @param prk type Description
-- @param info type Description
-- @param length type Description
-- @param digest type Description
-- @return type Description
function crypto.hkdfExpand(prk, info, length, digest)
	return wrapError(hkdfExpand, "hkdfExpand")(prk, info, length, digest)
end
--- crypto.hotp
-- @param secret type Description
-- @param counter type Description
-- @param digits type Description
-- @param digest type Description
-- @return type Description
function crypto.hotp(secret, counter, digits, digest)
	return wrapError(hotpGenerate, "hotp")(secret, counter, digits, digest)
end
--- crypto.totp
-- @param secret type Description
-- @param opts type Description
-- @return type Description
function crypto.totp(secret, opts)
	return wrapError(totpGenerate, "totp")(secret, opts)
end
--- crypto.totpVerify
-- @param token type Description
-- @param secret type Description
-- @param opts type Description
-- @return type Description
function crypto.totpVerify(token, secret, opts)
	return wrapError(totpVerify, "totpVerify")(token, secret, opts)
end
crypto.base32encode = function(d)
	if Buffer.isBuffer(d) then
		d = d:toString("utf8")
	end;
	return base32Encode(d)
end
crypto.base32decode = function(s)
	local raw = base32Decode(s)
	local bytes = {};
	for i = 1, # raw do
		bytes[i] = byte(raw, i)
	end
	return Buffer.from(bytes)
end
crypto.crc32 = function(d)
	if Buffer.isBuffer(d) then
		d = d:toString("utf8")
	end;
	return crc32Compute(tostr(d))
end
--- runTests
-- @return type Description
local function runTests()
	print("crypto lib test")
	local msg = "Hello World 12345"
	print("input message: '" .. msg .. "'\n")
    print("hash functions (hex)")
    local sha256_result = crypto.sha256(msg, "hex")
    local sha256_expected = "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e"
    local sha256_valid = sha256_result == sha256_expected
    print(string.format("  sha256: %s", sha256_result))
    print(string.format("    expected: %s", sha256_expected))
    print(string.format("    result: %s", sha256_valid and "ok" or "fail"))

    local sha1_result = crypto.sha1(msg, "hex")
    local sha1_expected = "8ad8757baa8562b6c3a2b8b1f31da3bc8d096172"
    local sha1_valid = sha1_result == sha1_expected
    print(string.format("  sha1: %s", sha1_result))
    print(string.format("    expected: %s", sha1_expected))
    print(string.format("    result: %s", sha1_valid and "ok" or "fail"))

    local md5_result = crypto.md5(msg, "hex")
    local md5_expected = "b5e7aa77b79beffb440a2fa5a45cdd78"
    local md5_valid = md5_result == md5_expected
    print(string.format("  md5: %s", md5_result))
    print(string.format("    expected: %s", md5_expected))
    print(string.format("    result: %s", md5_valid and "ok" or "fail"))

    local sha3_224_result = crypto.sha3_224(msg, "hex")
    local sha3_224_expected = "b87b88b847e65a5c7f6e177a1f754d166b947b194fa3641c0816f9c0"
    local sha3_224_valid = sha3_224_result == sha3_224_expected
    print(string.format("  sha3-224: %s", sha3_224_result))
    print(string.format("    expected: %s", sha3_224_expected))
    print(string.format("    result: %s", sha3_224_valid and "ok" or "fail"))

    local sha3_256_result = crypto.sha3_256(msg, "hex")
    local sha3_256_expected = "e167f68d6563d75bb25f3aa49c29ef612d413fdcbffb8fa67e322e0c2bd682ef"
    local sha3_256_valid = sha3_256_result == sha3_256_expected
    print(string.format("  sha3-256: %s", sha3_256_result))
    print(string.format("    expected: %s", sha3_256_expected))
    print(string.format("    result: %s", sha3_256_valid and "ok" or "fail"))

    local sha3_384_result = crypto.sha3_384(msg, "hex")
    local sha3_384_expected = "6e06a65517116448f28fec1e9eac6d7abe6ddffa50de9d3ac613a7edac78a9cfee386f479d9b0cf0c1bfe5b481bb021d"
    local sha3_384_valid = sha3_384_result == sha3_384_expected
    print(string.format("  sha3-384: %s", sha3_384_result))
    print(string.format("    expected: %s", sha3_384_expected))
    print(string.format("    result: %s", sha3_384_valid and "ok" or "fail"))

    local sha3_512_result = crypto.sha3_512(msg, "hex")
    local sha3_512_expected = "5b8e071c9518d3593d21bbc4ea6f17c47373e15997bd4d1a7ca7cf093ab5ff972f3e8b418d66fe300b3505604a35ec283fea27a0c1b2ec55157dd761b127bafc"
    local sha3_512_valid = sha3_512_result == sha3_512_expected
    print(string.format("  sha3-512: %s", sha3_512_result))
    print(string.format("    expected: %s", sha3_512_expected))
    print(string.format("    result: %s", sha3_512_valid and "ok" or "fail"))

    local keccak256_result = crypto.keccak256(msg, "hex")
    local keccak256_expected = "cd9fb1e148ccd8442e5aa74904cc73bf6fb54d1d54d333bd596aa9bb4bb4e961"
    local keccak256_valid = keccak256_result == keccak256_expected
    print(string.format("  keccak256: %s", keccak256_result))
    print(string.format("    expected: %s", keccak256_expected))
    print(string.format("    result: %s", keccak256_valid and "ok" or "fail"))

    local shake128_result = crypto.shake128(msg, 32)
    local shake128_expected = "f06c397ea1b6b7570a35abf192fe725b95b58f8addc20d145b3efe5b4f0bc8e4"
    local shake128_valid = shake128_result == shake128_expected
    print(string.format("  shake128 (32 bytes): %s", shake128_result))
    print(string.format("    expected: %s", shake128_expected))
    print(string.format("    result: %s", shake128_valid and "ok" or "fail"))

    local shake256_result = crypto.shake256(msg, 32)
    local shake256_expected = "3d6b8aff8c815bcc2566a9c2ab231e1992a93caab8d68c9d4a6005b06a7f5bb0"
    local shake256_valid = shake256_result == shake256_expected
    print(string.format("  shake256 (32 bytes): %s", shake256_result))
    print(string.format("    expected: %s", shake256_expected))
    print(string.format("    result: %s", shake256_valid and "ok" or "fail"))
	print("\nhmac (hex)")
	local hmac_sha256 = crypto.createHmac("sha256", "secret_key"):update(msg):digest("hex")
	print(string.format("  hmac-sha256: %s %s", hmac_sha256, # hmac_sha256 == 64 and "ok" or "fail"))
	print("\nbuffer operations")
	local buf = Buffer.from(msg)
	local roundtrip = buf:toString("utf8")
	print(string.format("  buffer.from / tostring: %s", roundtrip == msg and "ok" or "fail"))
	local b64 = buf:toString("base64")
	local b64dec = Buffer.from(b64, "base64"):toString("utf8")
	print(string.format("  base64 encode/decode: %s -> %s", b64, b64dec))
	print(string.format("    result: %s", b64dec == msg and "ok" or "fail"))
	local hexenc = buf:toString("hex")
	local hexdec = Buffer.from(hexenc, "hex"):toString("utf8")
	print(string.format("  hex encode/decode: %s -> %s", hexenc, hexdec))
	print(string.format("    result: %s", hexdec == msg and "ok" or "fail"))
	local sliced = buf:slice(0, 5):toString("utf8")
	print(string.format("  slice first 5 chars: '%s' %s", sliced, sliced == "Hello" and "ok" or "fail"))
	print("\nrandom generation (length check only)")
	local r16 = crypto.randomBytes(16)
	print(string.format("  randombytes(16): len=%d %s", r16.length, r16.length == 16 and "ok" or "fail"))
	local r32 = crypto.randomBytes(32)
	print(string.format("  randombytes(32): len=%d %s", r32.length, r32.length == 32 and "ok" or "fail"))
	local uuid4 = crypto.randomUUID()
	print(string.format("  uuid v4: %s %s", uuid4, (# uuid4 == 36 and uuid4:sub(15, 15) == "4") and "ok" or "fail"))
	local uuid1 = crypto.randomUUIDv1()
	print(string.format("  uuid v1: %s %s", uuid1, # uuid1 == 36 and "ok" or "fail"))
	print("\nsymmetric encryption (xor, aes-cbc, aes-ecb, aes-ctr)")
	local xor_cipher = crypto.createCipheriv("xor", "key123", "")
    local enc_xor = xor_cipher:update(msg)
    local xor_decipher = crypto.createDecipheriv("xor", "key123", "")
    local dec_xor = xor_decipher:update(enc_xor)
    local dec_xor_str = type(dec_xor) == "string" and dec_xor or dec_xor:toString("utf8")

    local enc_hex = ""
    if type(enc_xor) == "string" then
        local bytes = {}
        for i = 1, #enc_xor do
            bytes[i] = string.format("%02x", string.byte(enc_xor, i))
        end
        enc_hex = table.concat(bytes)
    else
        enc_hex = enc_xor:toString("hex")
    end
    print(string.format("  xor cipher: enc=%s", enc_hex))
    print(string.format("    decrypted: '%s' %s", dec_xor_str, dec_xor_str == msg and "ok" or "fail"))
	local aes128_key = crypto.randomBytes(16)
	local aes128_iv = crypto.randomBytes(16)
	local a128c = crypto.createCipheriv("aes-128-cbc", aes128_key, aes128_iv)
	local enc128 = a128c:update(Buffer.from(msg))
	local enc128_f = a128c:final()
	local enc128_full = Buffer.concat({
		enc128,
		enc128_f
	})
	local a128d = crypto.createDecipheriv("aes-128-cbc", aes128_key, aes128_iv)
	local dec128 = a128d:update(enc128_full)
	local dec128_f = a128d:final()
	local dec128_str = Buffer.concat({
		dec128,
		dec128_f
	}):toString("utf8")
	print(string.format("  aes-128-cbc: enc=%s", enc128_full:toString("hex")))
	print(string.format("    decrypted: '%s' %s", dec128_str, dec128_str == msg and "ok" or "fail"))
	local aes256_key = crypto.randomBytes(32)
	local aes256_iv = crypto.randomBytes(16)
	local a256c = crypto.createCipheriv("aes-256-cbc", aes256_key, aes256_iv)
	local enc256 = a256c:update(Buffer.from(msg))
	local enc256_f = a256c:final()
	local enc256_full = Buffer.concat({
		enc256,
		enc256_f
	})
	local a256d = crypto.createDecipheriv("aes-256-cbc", aes256_key, aes256_iv)
	local dec256 = a256d:update(enc256_full)
	local dec256_f = a256d:final()
	local dec256_str = Buffer.concat({
		dec256,
		dec256_f
	}):toString("utf8")
	print(string.format("  aes-256-cbc: enc=%s", enc256_full:toString("hex")))
	print(string.format("    decrypted: '%s' %s", dec256_str, dec256_str == msg and "ok" or "fail"))
	local aes128_ecb_key = crypto.randomBytes(16)
	local ecb_cipher = crypto.createCipheriv("aes-128-ecb", aes128_ecb_key, Buffer.from(""))
	local enc_ecb = ecb_cipher:update(Buffer.from(msg))
	local enc_ecb_f = ecb_cipher:final()
	local enc_ecb_full = Buffer.concat({
		enc_ecb,
		enc_ecb_f
	})
	local ecb_decipher = crypto.createDecipheriv("aes-128-ecb", aes128_ecb_key, Buffer.from(""))
	local dec_ecb = ecb_decipher:update(enc_ecb_full)
	local dec_ecb_f = ecb_decipher:final()
	local dec_ecb_str = Buffer.concat({
		dec_ecb,
		dec_ecb_f
	}):toString("utf8")
	print(string.format("  aes-128-ecb: enc=%s", enc_ecb_full:toString("hex")))
	print(string.format("    decrypted: '%s' %s", dec_ecb_str, dec_ecb_str == msg and "ok" or "fail"))
	local ctr_key = crypto.randomBytes(32)
	local ctr_iv = crypto.randomBytes(16)
	local plain_ctr = "AES-CTR streaming test"
	local ctr_cipher = crypto.aesCTR(ctr_key, ctr_iv, plain_ctr)
	local ctr_dec = crypto.aesCTR(ctr_key, ctr_iv, ctr_cipher)
	local ctr_dec_str = ctr_dec:toString("utf8")
	print(string.format("  aes-256-ctr: enc=%s", ctr_cipher:toString("hex")))
	print(string.format("    decrypted: '%s' %s", ctr_dec_str, ctr_dec_str == plain_ctr and "ok" or "fail"))
	print("\naes-gcm (authenticated encryption)")
	local gcm_key = crypto.randomBytes(32)
	local gcm_iv = crypto.randomBytes(12)
	local gcm_ct, gcm_tag = crypto.aesGCMEncrypt(gcm_key, gcm_iv, msg, "aad data")
	local gcm_pt = crypto.aesGCMDecrypt(gcm_key, gcm_iv, gcm_ct, "aad data", gcm_tag)
	local gcm_pt_str = gcm_pt:toString("utf8")
	print(string.format("  aes-256-gcm: enc=%s, tag=%s", gcm_ct:toString("hex"), gcm_tag:toString("hex")))
	print(string.format("    decrypted: '%s' %s", gcm_pt_str, gcm_pt_str == msg and "ok" or "fail"))
    local tampered = Buffer.from(gcm_ct._b)
    if tampered.length > 0 then
        
        tampered._b[1] = bxor(tampered._b[1] or 0, 1)
        local ok, err = pcall(crypto.aesGCMDecrypt, gcm_key, gcm_iv, tampered, "aad data", gcm_tag)
        print(string.format("    tamper detection: %s", not ok and "ok (rejected)" or "fail (should reject)"))
    end
	print("\nchacha20-poly1305")
	local chacha_key = crypto.randomBytes(32)
	local chacha_nonce = crypto.randomBytes(12)
	local chacha_ct, chacha_tag = crypto.chacha20poly1305Encrypt(chacha_key, chacha_nonce, msg, "aad")
	local chacha_pt = crypto.chacha20poly1305Decrypt(chacha_key, chacha_nonce, chacha_ct, "aad", chacha_tag)
	local chacha_pt_str = chacha_pt:toString("utf8")
	print(string.format("  chacha20-poly1305: enc=%s, tag=%s", chacha_ct:toString("hex"), chacha_tag:toString("hex")))
	print(string.format("    decrypted: '%s' %s", chacha_pt_str, chacha_pt_str == msg and "ok" or "fail"))
	print("\nchacha20 stream cipher")
	local chacha20_key = crypto.randomBytes(32)
	local chacha20_nonce = crypto.randomBytes(12)
	local chacha20_plain = "ChaCha20 stream example"
	local chacha20_cipher = crypto.chacha20(chacha20_key, chacha20_nonce, 1, chacha20_plain)
	local chacha20_dec = crypto.chacha20(chacha20_key, chacha20_nonce, 1, chacha20_cipher)
	local chacha20_dec_str = chacha20_dec:toString("utf8")
	print(string.format("  chacha20: enc=%s", chacha20_cipher:toString("hex")))
	print(string.format("    decrypted: '%s' %s", chacha20_dec_str, chacha20_dec_str == chacha20_plain and "ok" or "fail"))
    print("\necdh & ecdsa")
    local alice = crypto.ecdhGenerateKeyPair()
    local bob = crypto.ecdhGenerateKeyPair()
    local secret_a = crypto.ecdhComputeSharedSecret(alice.private, bob.publicKey)
    local secret_b = crypto.ecdhComputeSharedSecret(bob.private, alice.publicKey)
    local secret_match = secret_a:toString("hex") == secret_b:toString("hex")
    print(string.format("  ecdh shared secret: %s", secret_match and "match ok" or "mismatch fail"))
    print(string.format("    alice: %s", secret_a:toString("hex")))
    print(string.format("    bob:   %s", secret_b:toString("hex")))
    print("\necdsa (using separate key pair)")
    local ecdsa_keys = crypto.ecdhGenerateKeyPair()
    local hash_for_sig = crypto.sha256(msg, "buffer")


    local ecdsa_priv = { d = ecdsa_keys.private }
    local sig_r, sig_s = crypto.ecdsaSign(hash_for_sig, ecdsa_priv)
    local ecdsa_ok = crypto.ecdsaVerify(hash_for_sig, sig_r, sig_s, ecdsa_keys.publicKey)
    print(string.format("  ecdsa verify: %s", ecdsa_ok and "ok" or "fail"))
    print(string.format("    signature r=%s, s=%s", sig_r:toString("hex"), sig_s:toString("hex")))
	print("\nbase32 & crc32")
	local b32_in = "test123"
	local b32_enc = crypto.base32encode(b32_in)
	local b32_dec = crypto.base32decode(b32_enc):toString("utf8")
	print(string.format("  base32: '%s' -> '%s' -> '%s' %s", b32_in, b32_enc, b32_dec, b32_dec == b32_in and "ok" or "fail"))
	local crc = crypto.crc32("the quick brown fox")
	print(string.format("  crc32: 0x%08x", crc))
	print("\nconstant time compare")
	local ct_eq = crypto.constantTimeCompare("a", "a")
	local ct_neq = not crypto.constantTimeCompare("a", "b")
	print(string.format("  compare equal: %s", ct_eq and "ok" or "fail"))
	print(string.format("  compare different: %s", ct_neq and "ok" or "fail"))
	print("\ndone")
end
runTests()
return nc