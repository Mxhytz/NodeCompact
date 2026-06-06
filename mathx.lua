local nc     = {}
local mathx  = {}
local floor = math.floor; local ceil  = math.ceil; local sqrt  = math.sqrt
local abs   = math.abs;   local sin   = math.sin;  local cos   = math.cos
local tan   = math.tan;   local exp   = math.exp;  local log   = math.log
local pi    = math.pi;    local huge  = math.huge;  local rand  = math.random
local fmt   = string.format; local tcat = table.concat
local ins   = table.insert;  local rem  = table.remove
local unpack = table.unpack or unpack
local EPS   = 1e-12
local TArray = {}; TArray.__index = TArray
function TArray.new(n, fillVal)
    local self = setmetatable({}, TArray)
    self.n = n
    local b = {}
    fillVal = fillVal or 0
    
    if fillVal == 0 then
        local i = 1
        while i + 31 <= n do
            b[i] = 0; b[i+1] = 0; b[i+2] = 0; b[i+3] = 0
            b[i+4] = 0; b[i+5] = 0; b[i+6] = 0; b[i+7] = 0
            b[i+8] = 0; b[i+9] = 0; b[i+10] = 0; b[i+11] = 0
            b[i+12] = 0; b[i+13] = 0; b[i+14] = 0; b[i+15] = 0
            b[i+16] = 0; b[i+17] = 0; b[i+18] = 0; b[i+19] = 0
            b[i+20] = 0; b[i+21] = 0; b[i+22] = 0; b[i+23] = 0
            b[i+24] = 0; b[i+25] = 0; b[i+26] = 0; b[i+27] = 0
            b[i+28] = 0; b[i+29] = 0; b[i+30] = 0; b[i+31] = 0
            i = i + 32
        end
        while i <= n do
            b[i] = 0
            i = i + 1
        end
    else
        local i = 1
        while i + 31 <= n do
            b[i] = fillVal; b[i+1] = fillVal; b[i+2] = fillVal; b[i+3] = fillVal
            b[i+4] = fillVal; b[i+5] = fillVal; b[i+6] = fillVal; b[i+7] = fillVal
            b[i+8] = fillVal; b[i+9] = fillVal; b[i+10] = fillVal; b[i+11] = fillVal
            b[i+12] = fillVal; b[i+13] = fillVal; b[i+14] = fillVal; b[i+15] = fillVal
            b[i+16] = fillVal; b[i+17] = fillVal; b[i+18] = fillVal; b[i+19] = fillVal
            b[i+20] = fillVal; b[i+21] = fillVal; b[i+22] = fillVal; b[i+23] = fillVal
            b[i+24] = fillVal; b[i+25] = fillVal; b[i+26] = fillVal; b[i+27] = fillVal
            b[i+28] = fillVal; b[i+29] = fillVal; b[i+30] = fillVal; b[i+31] = fillVal
            i = i + 32
        end
        while i <= n do
            b[i] = fillVal
            i = i + 1
        end
    end
    
    self._b = b
    return self
end
function TArray.fromTable(t)
    local n = #t; local a = TArray.new(n)
    for i = 1, n do a._b[i] = t[i] or 0 end; return a
end
function TArray:get(i)    return self._b[i] or 0 end
function TArray:set(i, v) self._b[i] = v end
function TArray:clone()
    local n = self.n
    local new = TArray.new(n)
    local src = self._b
    local dst = new._b
    
        local i = 1
    while i + 15 <= n do
        dst[i]   = src[i]
        dst[i+1] = src[i+1]
        dst[i+2] = src[i+2]
        dst[i+3] = src[i+3]
        dst[i+4] = src[i+4]
        dst[i+5] = src[i+5]
        dst[i+6] = src[i+6]
        dst[i+7] = src[i+7]
        dst[i+8] = src[i+8]
        dst[i+9] = src[i+9]
        dst[i+10] = src[i+10]
        dst[i+11] = src[i+11]
        dst[i+12] = src[i+12]
        dst[i+13] = src[i+13]
        dst[i+14] = src[i+14]
        dst[i+15] = src[i+15]
        i = i + 16
    end
    
        while i <= n do
        dst[i] = src[i]
        i = i + 1
    end
    
    return new
end
function TArray:toTable()
    local t = {}
    for i = 1, self.n do t[i] = self._b[i] end; return t
end
function TArray:rawPair()
    local b = self._b
    return function(i) return b[i] end,
           function(i, v) b[i] = v end
end
mathx.TArray = TArray
local Pool = {}; Pool.__index = Pool
function Pool.new()
    local self = setmetatable({}, Pool)
    self._arrays = {}
    self._mats   = {}
    return self
end
function Pool:acquireArray(n, fill)
    local bucket = self._arrays[n]
    if bucket and #bucket > 0 then
        local a = rem(bucket)
        if fill then for i=1,n do a:set(i, fill) end end
        return a
    end
    return TArray.new(n, fill or 0)
end
function Pool:releaseArray(a)
    local n = a.n
    if not self._arrays[n] then self._arrays[n] = {} end
    ins(self._arrays[n], a)
end
function Pool:acquireMat(r, c, fill)
    local key = r..","..c
    local bucket = self._mats[key]
    local n = r * c
    if bucket and #bucket > 0 then
        local a = rem(bucket)
        if fill then for i=1,n do a:set(i,fill) end end
        return a
    end
    return TArray.new(n, fill or 0)
end
function Pool:releaseMat(a, r, c)
    local key = r..","..c
    if not self._mats[key] then self._mats[key] = {} end
    ins(self._mats[key], a)
end
local defaultPool = Pool.new()
mathx.Pool = Pool
mathx.pool = defaultPool
local function newRC()   return {v=1} end
local function incRC(rc) rc.v = rc.v + 1 end
local function decRC(rc) rc.v = rc.v - 1; return rc.v end
local function isShared(rc) return rc.v > 1 end
local Vec = {}; Vec.__index = Vec
Vec.__gc = function(self)
    if self._rc then
        decRC(self._rc)
        self._rc = nil
    end
end
function Vec._wrap(ta, rc)
    return setmetatable({_d=ta, n=ta.n, _rc=rc or newRC()}, Vec)
end
function Vec.new(n, fill)
    return Vec._wrap(TArray.new(n, fill or 0))
end
function Vec.fromTable(t)
    return Vec._wrap(TArray.fromTable(t))
end
function Vec.zeros(n)   return Vec.new(n, 0) end
function Vec.ones(n)    return Vec.new(n, 1) end
function Vec.from(...)
    local a = {...}
    if type(a[1]) == "table" and not getmetatable(a[1]) then return Vec.fromTable(a[1]) end
    return Vec.fromTable(a)
end
function Vec.linspace(a, b, n)
    local v = Vec.new(n)
    for i = 1, n do v._d:set(i, a+(b-a)*(i-1)/(n-1)) end; return v
end
function Vec.rand(n)
    local v = Vec.new(n)
    for i = 1, n do v._d:set(i, rand()) end; return v
end
function Vec.randn(n, mu, sig)
    mu = mu or 0; sig = sig or 1; local v = Vec.new(n)
    for i = 1, n do v._d:set(i, mu + sig*sqrt(-2*log(rand()))*cos(2*pi*rand())) end
    return v
end
function Vec.basis(n, k)
    local v = Vec.new(n); v._d:set(k, 1); return v
end
function Vec:_cow()
    if isShared(self._rc) then
        decRC(self._rc)
                local old_d = self._d._b
        local n = self.n
        local new_ta = TArray.new(n)
        local new_d = new_ta._b
        
                local i = 1
        while i + 15 <= n do
            new_d[i] = old_d[i]
            new_d[i+1] = old_d[i+1]
            new_d[i+2] = old_d[i+2]
            new_d[i+3] = old_d[i+3]
            new_d[i+4] = old_d[i+4]
            new_d[i+5] = old_d[i+5]
            new_d[i+6] = old_d[i+6]
            new_d[i+7] = old_d[i+7]
            new_d[i+8] = old_d[i+8]
            new_d[i+9] = old_d[i+9]
            new_d[i+10] = old_d[i+10]
            new_d[i+11] = old_d[i+11]
            new_d[i+12] = old_d[i+12]
            new_d[i+13] = old_d[i+13]
            new_d[i+14] = old_d[i+14]
            new_d[i+15] = old_d[i+15]
            i = i + 16
        end
        while i <= n do
            new_d[i] = old_d[i]
            i = i + 1
        end
        
        self._d = new_ta
        self._rc = newRC()
    end
    return self
end
function Vec:alias()
    incRC(self._rc)
    return setmetatable({_d=self._d, n=self.n, _rc=self._rc}, Vec)
end
function Vec:clone()
    local new_d = TArray.new(self.n)
    local src = self._d._b
    local dst = new_d._b
    local n = self.n
    local i = 1
    while i + 31 <= n do
        dst[i] = src[i]
        dst[i+1] = src[i+1]
        dst[i+2] = src[i+2]
        dst[i+3] = src[i+3]
        dst[i+4] = src[i+4]
        dst[i+5] = src[i+5]
        dst[i+6] = src[i+6]
        dst[i+7] = src[i+7]
        dst[i+8] = src[i+8]
        dst[i+9] = src[i+9]
        dst[i+10] = src[i+10]
        dst[i+11] = src[i+11]
        dst[i+12] = src[i+12]
        dst[i+13] = src[i+13]
        dst[i+14] = src[i+14]
        dst[i+15] = src[i+15]
        dst[i+16] = src[i+16]
        dst[i+17] = src[i+17]
        dst[i+18] = src[i+18]
        dst[i+19] = src[i+19]
        dst[i+20] = src[i+20]
        dst[i+21] = src[i+21]
        dst[i+22] = src[i+22]
        dst[i+23] = src[i+23]
        dst[i+24] = src[i+24]
        dst[i+25] = src[i+25]
        dst[i+26] = src[i+26]
        dst[i+27] = src[i+27]
        dst[i+28] = src[i+28]
        dst[i+29] = src[i+29]
        dst[i+30] = src[i+30]
        dst[i+31] = src[i+31]
        i = i + 32
    end
    while i <= n do
        dst[i] = src[i]
        i = i + 1
  end
    return Vec._wrap(new_d)
end
function Vec:get(i)   return self._d:get(i) end
function Vec:set(i,v) self:_cow(); self._d:set(i,v); return self end
function Vec:toTable() return self._d:toTable() end
function Vec:add_(b)
    self:_cow()
    local d = self._d._b
    local n = self.n
    if type(b) == "number" then
        local i = 1
        while i + 15 <= n do
            d[i] = d[i] + b
            d[i+1] = d[i+1] + b
            d[i+2] = d[i+2] + b
            d[i+3] = d[i+3] + b
            d[i+4] = d[i+4] + b
            d[i+5] = d[i+5] + b
            d[i+6] = d[i+6] + b
            d[i+7] = d[i+7] + b
            d[i+8] = d[i+8] + b
            d[i+9] = d[i+9] + b
            d[i+10] = d[i+10] + b
            d[i+11] = d[i+11] + b
            d[i+12] = d[i+12] + b
            d[i+13] = d[i+13] + b
            d[i+14] = d[i+14] + b
            d[i+15] = d[i+15] + b
            i = i + 16
        end
        while i <= n do
            d[i] = d[i] + b
            i = i + 1
        end
    else
        local bd = b._d._b
        local i = 1
        while i + 15 <= n do
            d[i] = d[i] + bd[i]
            d[i+1] = d[i+1] + bd[i+1]
            d[i+2] = d[i+2] + bd[i+2]
            d[i+3] = d[i+3] + bd[i+3]
            d[i+4] = d[i+4] + bd[i+4]
            d[i+5] = d[i+5] + bd[i+5]
            d[i+6] = d[i+6] + bd[i+6]
            d[i+7] = d[i+7] + bd[i+7]
            d[i+8] = d[i+8] + bd[i+8]
            d[i+9] = d[i+9] + bd[i+9]
            d[i+10] = d[i+10] + bd[i+10]
            d[i+11] = d[i+11] + bd[i+11]
            d[i+12] = d[i+12] + bd[i+12]
            d[i+13] = d[i+13] + bd[i+13]
            d[i+14] = d[i+14] + bd[i+14]
            d[i+15] = d[i+15] + bd[i+15]
            i = i + 16
        end
        while i <= n do
            d[i] = d[i] + bd[i]
            i = i + 1
        end
    end
    return self
end

function Vec:sub_(b)
    self:_cow()
    if type(b) == "number" then
        for i=1,self.n do self._d:set(i, self._d:get(i)-b) end
    else
        for i=1,self.n do self._d:set(i, self._d:get(i)-b._d:get(i)) end
    end; return self
end
function Vec:scale_(s)
    self:_cow()
    for i=1,self.n do
        local v = self._d:get(i) * s
        if v ~= v then
            v = 0
        elseif v == huge then
            v = 1e150
        elseif v == -huge then
            v = -1e150
        end
        self._d:set(i, v)
    end
    return self
end
function Vec:neg_()   return self:scale_(-1) end
function Vec:map_(f)
    self:_cow()
    for i=1,self.n do self._d:set(i, f(self._d:get(i), i)) end; return self
end
function Vec:clamp_(lo, hi)
    self:_cow()
    for i=1,self.n do
        local v = self._d:get(i)
        self._d:set(i, v<lo and lo or v>hi and hi or v)
    end; return self
end
function Vec:release()
    if self._rc then
        decRC(self._rc)
        self._rc = nil
    end
    return self
end
function Vec:add(b)
    local n = self.n
    
        if type(b) == "number" then
        local new_d = TArray.new(n)
        local src = self._d._b
        local dst = new_d._b
        local i = 1
        while i + 31 <= n do
            dst[i] = src[i] + b
            dst[i+1] = src[i+1] + b
            dst[i+2] = src[i+2] + b
            dst[i+3] = src[i+3] + b
            dst[i+4] = src[i+4] + b
            dst[i+5] = src[i+5] + b
            dst[i+6] = src[i+6] + b
            dst[i+7] = src[i+7] + b
            dst[i+8] = src[i+8] + b
            dst[i+9] = src[i+9] + b
            dst[i+10] = src[i+10] + b
            dst[i+11] = src[i+11] + b
            dst[i+12] = src[i+12] + b
            dst[i+13] = src[i+13] + b
            dst[i+14] = src[i+14] + b
            dst[i+15] = src[i+15] + b
            dst[i+16] = src[i+16] + b
            dst[i+17] = src[i+17] + b
            dst[i+18] = src[i+18] + b
            dst[i+19] = src[i+19] + b
            dst[i+20] = src[i+20] + b
            dst[i+21] = src[i+21] + b
            dst[i+22] = src[i+22] + b
            dst[i+23] = src[i+23] + b
            dst[i+24] = src[i+24] + b
            dst[i+25] = src[i+25] + b
            dst[i+26] = src[i+26] + b
            dst[i+27] = src[i+27] + b
            dst[i+28] = src[i+28] + b
            dst[i+29] = src[i+29] + b
            dst[i+30] = src[i+30] + b
            dst[i+31] = src[i+31] + b
            i = i + 32
        end
        while i <= n do
            dst[i] = src[i] + b
            i = i + 1
        end
        local ta = setmetatable({}, TArray)
        ta.n = n
        ta._b = dst
        return Vec._wrap(ta)
    end
    
        local src1 = self._d._b
    local src2 = b._d._b
    local dst = {}
    
    local i = 1
    while i + 31 <= n do
        dst[i] = src1[i] + src2[i]
        dst[i+1] = src1[i+1] + src2[i+1]
        dst[i+2] = src1[i+2] + src2[i+2]
        dst[i+3] = src1[i+3] + src2[i+3]
        dst[i+4] = src1[i+4] + src2[i+4]
        dst[i+5] = src1[i+5] + src2[i+5]
        dst[i+6] = src1[i+6] + src2[i+6]
        dst[i+7] = src1[i+7] + src2[i+7]
        dst[i+8] = src1[i+8] + src2[i+8]
        dst[i+9] = src1[i+9] + src2[i+9]
        dst[i+10] = src1[i+10] + src2[i+10]
        dst[i+11] = src1[i+11] + src2[i+11]
        dst[i+12] = src1[i+12] + src2[i+12]
        dst[i+13] = src1[i+13] + src2[i+13]
        dst[i+14] = src1[i+14] + src2[i+14]
        dst[i+15] = src1[i+15] + src2[i+15]
        dst[i+16] = src1[i+16] + src2[i+16]
        dst[i+17] = src1[i+17] + src2[i+17]
        dst[i+18] = src1[i+18] + src2[i+18]
        dst[i+19] = src1[i+19] + src2[i+19]
        dst[i+20] = src1[i+20] + src2[i+20]
        dst[i+21] = src1[i+21] + src2[i+21]
        dst[i+22] = src1[i+22] + src2[i+22]
        dst[i+23] = src1[i+23] + src2[i+23]
        dst[i+24] = src1[i+24] + src2[i+24]
        dst[i+25] = src1[i+25] + src2[i+25]
        dst[i+26] = src1[i+26] + src2[i+26]
        dst[i+27] = src1[i+27] + src2[i+27]
        dst[i+28] = src1[i+28] + src2[i+28]
        dst[i+29] = src1[i+29] + src2[i+29]
        dst[i+30] = src1[i+30] + src2[i+30]
        dst[i+31] = src1[i+31] + src2[i+31]
        i = i + 32
    end
    
    while i <= n do
        dst[i] = src1[i] + src2[i]
        i = i + 1
    end
    
    local ta = setmetatable({}, TArray)
    ta.n = n
    ta._b = dst
    
    return Vec._wrap(ta)
end
function Vec:sub(b)   return self:clone():sub_(b) end
function Vec:scale(s) return self:clone():scale_(s) end
function Vec:neg()    return self:clone():scale_(-1) end
function Vec:map(f)   return self:clone():map_(f) end
function Vec:hadamard(b)
    local v = Vec.new(self.n)
    for i=1,self.n do v._d:set(i, self._d:get(i)*b._d:get(i)) end; return v
end
function Vec:dot(b)
    local a = self._d._b
    local bd = b._d._b
    local n = self.n
    local s1, s2, s3, s4 = 0.0, 0.0, 0.0, 0.0
    local i = 1
    
        while i + 15 <= n do
        s1 = s1 + a[i] * bd[i] + a[i+1] * bd[i+1] + a[i+2] * bd[i+2] + a[i+3] * bd[i+3]
        s2 = s2 + a[i+4] * bd[i+4] + a[i+5] * bd[i+5] + a[i+6] * bd[i+6] + a[i+7] * bd[i+7]
        s3 = s3 + a[i+8] * bd[i+8] + a[i+9] * bd[i+9] + a[i+10] * bd[i+10] + a[i+11] * bd[i+11]
        s4 = s4 + a[i+12] * bd[i+12] + a[i+13] * bd[i+13] + a[i+14] * bd[i+14] + a[i+15] * bd[i+15]
        i = i + 16
    end
    
    local s = s1 + s2 + s3 + s4
    
    while i <= n do
        s = s + a[i] * bd[i]
        i = i + 1
    end
    
    return s
end
function Vec:norm(p)
    p = p or 2
    if p == huge then
        local m = 0; for i=1,self.n do m = math.max(m, abs(self._d:get(i))) end; return m
    end
    local s = 0; for i=1,self.n do s = s + abs(self._d:get(i))^p end; return s^(1/p)
end
function Vec:norm2()
    local d = self._d._b
    local n = self.n
    local s1, s2, s3, s4 = 0.0, 0.0, 0.0, 0.0
    local s5, s6, s7, s8 = 0.0, 0.0, 0.0, 0.0
    local i = 1
    
        while i + 31 <= n do
        s1 = s1 + d[i] * d[i]
        s2 = s2 + d[i+1] * d[i+1]
        s3 = s3 + d[i+2] * d[i+2]
        s4 = s4 + d[i+3] * d[i+3]
        s5 = s5 + d[i+4] * d[i+4]
        s6 = s6 + d[i+5] * d[i+5]
        s7 = s7 + d[i+6] * d[i+6]
        s8 = s8 + d[i+7] * d[i+7]
        
        s1 = s1 + d[i+8] * d[i+8]
        s2 = s2 + d[i+9] * d[i+9]
        s3 = s3 + d[i+10] * d[i+10]
        s4 = s4 + d[i+11] * d[i+11]
        s5 = s5 + d[i+12] * d[i+12]
        s6 = s6 + d[i+13] * d[i+13]
        s7 = s7 + d[i+14] * d[i+14]
        s8 = s8 + d[i+15] * d[i+15]
        
        s1 = s1 + d[i+16] * d[i+16]
        s2 = s2 + d[i+17] * d[i+17]
        s3 = s3 + d[i+18] * d[i+18]
        s4 = s4 + d[i+19] * d[i+19]
        s5 = s5 + d[i+20] * d[i+20]
        s6 = s6 + d[i+21] * d[i+21]
        s7 = s7 + d[i+22] * d[i+22]
        s8 = s8 + d[i+23] * d[i+23]
        
        s1 = s1 + d[i+24] * d[i+24]
        s2 = s2 + d[i+25] * d[i+25]
        s3 = s3 + d[i+26] * d[i+26]
        s4 = s4 + d[i+27] * d[i+27]
        s5 = s5 + d[i+28] * d[i+28]
        s6 = s6 + d[i+29] * d[i+29]
        s7 = s7 + d[i+30] * d[i+30]
        s8 = s8 + d[i+31] * d[i+31]
        
        i = i + 32
    end
    
    local s = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8
    
        while i <= n do
        local v = d[i]
        s = s + v * v
        i = i + 1
    end
    
    return sqrt(s)
end
function Vec:normalize() local n=self:norm2(); return n<EPS and self:clone() or self:scale(1/n) end
function Vec:normalize_() local n=self:norm2(); if n>=EPS then self:scale_(1/n) end; return self end
function Vec:dist(b)   return self:sub(b):norm2() end
function Vec:cross(b)
    return Vec.from(self._d:get(2)*b._d:get(3)-self._d:get(3)*b._d:get(2),
                    self._d:get(3)*b._d:get(1)-self._d:get(1)*b._d:get(3),
                    self._d:get(1)*b._d:get(2)-self._d:get(2)*b._d:get(1))
end
function Vec:angle(b)
    local d = self:dot(b)/(self:norm2()*b:norm2())
    return math.acos(d<-1 and -1 or d>1 and 1 or d)
end
function Vec:project(b) return b:scale(self:dot(b)/b:dot(b)) end
function Vec:reject(b)  return self:sub(self:project(b)) end
function Vec:lerp(b,t)  return self:scale(1-t):add_(b:scale(t)) end
function Vec:sum()
    local d = self._d._b
    local n = self.n
    local s1, s2, s3, s4 = 0.0, 0.0, 0.0, 0.0
    local s5, s6, s7, s8 = 0.0, 0.0, 0.0, 0.0
    local i = 1
    
        while i + 31 <= n do
        s1 = s1 + d[i]
        s2 = s2 + d[i+1]
        s3 = s3 + d[i+2]
        s4 = s4 + d[i+3]
        s5 = s5 + d[i+4]
        s6 = s6 + d[i+5]
        s7 = s7 + d[i+6]
        s8 = s8 + d[i+7]
        
        s1 = s1 + d[i+8]
        s2 = s2 + d[i+9]
        s3 = s3 + d[i+10]
        s4 = s4 + d[i+11]
        s5 = s5 + d[i+12]
        s6 = s6 + d[i+13]
        s7 = s7 + d[i+14]
        s8 = s8 + d[i+15]
        
        s1 = s1 + d[i+16]
        s2 = s2 + d[i+17]
        s3 = s3 + d[i+18]
        s4 = s4 + d[i+19]
        s5 = s5 + d[i+20]
        s6 = s6 + d[i+21]
        s7 = s7 + d[i+22]
        s8 = s8 + d[i+23]
        
        s1 = s1 + d[i+24]
        s2 = s2 + d[i+25]
        s3 = s3 + d[i+26]
        s4 = s4 + d[i+27]
        s5 = s5 + d[i+28]
        s6 = s6 + d[i+29]
        s7 = s7 + d[i+30]
        s8 = s8 + d[i+31]
        
        i = i + 32
    end
    
    local s = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8
    
        while i <= n do
        s = s + d[i]
        i = i + 1
    end
    
    return s
end
function Vec:prod()  local s=1; for i=1,self.n do s=s*self._d:get(i) end; return s end
function Vec:mean()  return self:sum()/self.n end
function Vec:var()   local mu=self:mean(); local s=0; for i=1,self.n do local d=self._d:get(i)-mu; s=s+d*d end; return s/self.n end
function Vec:std()   return sqrt(self:var()) end
function Vec:min()   local m=self._d:get(1); for i=2,self.n do local v=self._d:get(i); if v<m then m=v end end; return m end
function Vec:max()   local m=self._d:get(1); for i=2,self.n do local v=self._d:get(i); if v>m then m=v end end; return m end
function Vec:argmin() local m,mi=self._d:get(1),1; for i=2,self.n do local v=self._d:get(i); if v<m then m=v;mi=i end end; return mi end
function Vec:argmax() local m,mi=self._d:get(1),1; for i=2,self.n do local v=self._d:get(i); if v>m then m=v;mi=i end end; return mi end
function Vec:abs()   return self:map(function(v) return v<0 and -v or v end) end
function Vec:abs_()  return self:map_(function(v) return v<0 and -v or v end) end
function Vec:cumsum()
    local v=Vec.new(self.n); local s=0
    for i=1,self.n do s=s+self._d:get(i); v._d:set(i,s) end; return v
end
function Vec:slice(a,b)
    a=a or 1; b=b or self.n; local v=Vec.new(b-a+1)
    for i=a,b do v._d:set(i-a+1, self._d:get(i)) end; return v
end
function Vec:concat(b)
    local v=Vec.new(self.n+b.n)
    for i=1,self.n do v._d:set(i, self._d:get(i)) end
    for i=1,b.n   do v._d:set(self.n+i, b._d:get(i)) end; return v
end
function Vec:sort(f)
    local t=self:toTable(); table.sort(t,f); return Vec.fromTable(t)
end
function Vec:eq(b,eps)
    eps=eps or EPS; if self.n~=b.n then return false end
    for i=1,self.n do if abs(self._d:get(i)-b._d:get(i))>eps then return false end end; return true
end
function Vec:__tostring()
    local p={}; for i=1,self.n do p[i]=fmt("%.6g", self._d:get(i)) end
    return "Vec("..tcat(p,", ")..")"
end
Vec.__add = function(a,b) if type(a)=="number" then return b:add(a) end; return a:add(b) end
Vec.__sub = function(a,b) return a:sub(b) end
Vec.__mul = function(a,b)
    if type(a)=="number" then return b:scale(a) end
    if type(b)=="number" then return a:scale(b) end
    return a:dot(b)
end
Vec.__unm = function(a) return a:neg() end
Vec.__len = function(a) return a.n end
Vec.__eq  = function(a,b) return a:eq(b) end
function Vec:zscore()
    local mu=self:mean(); local s=self:std()
    if s<EPS then return self:clone() end
    return self:map(function(v) return (v-mu)/s end)
end
function Vec:softmax()
    local mx=self:max(); local ev=self:map(function(v) return math.exp(v-mx) end)
    return ev:scale(1/ev:sum())
end
function Vec:sigmoid()
    return self:map(function(v) return 1/(1+math.exp(-v)) end)
end
function Vec:relu()
    return self:map(function(v) return v>0 and v or 0 end)
end
function Vec:relu_()
    return self:map_(function(v) return v>0 and v or 0 end)
end
function Vec:linspace_(a,b)
    for i=1,self.n do self._d:set(i,a+(b-a)*(i-1)/(self.n-1)) end; return self
end
function Vec:quantile(p)
    local s=self:sort():toTable(); local h=(#s-1)*p+1
    local lo,hi=math.floor(h),math.ceil(h)
    return s[lo]+(s[hi]-s[lo])*(h-lo)
end
function Vec:median()  return self:quantile(0.5) end
function Vec:iqr()     return self:quantile(0.75)-self:quantile(0.25) end
function Vec:cosineSim(b) return self:dot(b)/(self:norm2()*b:norm2()+EPS) end
function Vec:toMat(rows, cols)
    local t = {}
    local n2 = rows * cols
    for i = 1, rows do
        t[i] = {}
        for j = 1, cols do
            t[i][j] = self._d:get((i - 1) * cols + j) or 0
        end
    end
    return mathx.Mat.fromTable(t)  end
mathx.Vec = Vec
function mathx.vec(...) return Vec.from(...) end
local Mat = {}; Mat.__index = Mat
Mat.__gc = function(self)
    if self._rc then
        decRC(self._rc)
        self._rc = nil
    end
end
function Mat._wrap(ta, rows, cols, rc)
    return setmetatable({_d=ta, rows=rows, cols=cols, _rc=rc or newRC()}, Mat)
end
function Mat.new(rows, cols, fill)
    return Mat._wrap(TArray.new(rows*cols, fill or 0), rows, cols)
end
function Mat.fromTable(data)
    local r=#data; local c=#data[1]; local m=Mat.new(r,c)
    for i=1,r do for j=1,c do m._d:set((i-1)*c+j, data[i][j] or 0) end end; return m
end
function Mat.identity(n)
    local m=Mat.new(n,n); for i=1,n do m._d:set((i-1)*n+i, 1) end; return m
end
function Mat.zeros(r,c)  return Mat.new(r,c,0) end
function Mat.ones(r,c)   return Mat.new(r,c,1) end
function Mat.rand(r,c)
    local m=Mat.new(r,c); local n=r*c
    for i=1,n do m._d:set(i,rand()) end; return m
end
function Mat.randn(r,c,mu,sig)
    mu=mu or 0; sig=sig or 1; local m=Mat.new(r,c); local n=r*c
    for i=1,n do m._d:set(i, mu+sig*sqrt(-2*log(rand()))*cos(2*pi*rand())) end; return m
end
function Mat.diag(v)
    local n
    local data
    
        if getmetatable(v) == Vec then
        n = v.n
        data = v._d._b      else
                n = #v
        data = v
    end
    
        local m = Mat.new(n, n)
    local m_data = m._d._b      local stride = n
    
        local i = 1
    while i + 7 <= n do
        local off1 = (i-1) * stride + i
        local off2 = i * stride + (i+1)
        local off3 = (i+1) * stride + (i+2)
        local off4 = (i+2) * stride + (i+3)
        local off5 = (i+3) * stride + (i+4)
        local off6 = (i+4) * stride + (i+5)
        local off7 = (i+5) * stride + (i+6)
        local off8 = (i+6) * stride + (i+7)
        
        m_data[off1] = data[i]
        m_data[off2] = data[i+1]
        m_data[off3] = data[i+2]
        m_data[off4] = data[i+3]
        m_data[off5] = data[i+4]
        m_data[off6] = data[i+5]
        m_data[off7] = data[i+6]
        m_data[off8] = data[i+7]
        
        i = i + 8
    end
    
        while i <= n do
        m_data[(i-1) * stride + i] = data[i]
        i = i + 1
    end
    
    return m
end
function Mat:_cow()
    if isShared(self._rc) then
        decRC(self._rc)
        self._d = self._d:clone()
        self._rc = newRC()
    end
    return self
end
function Mat:alias()
    incRC(self._rc)
    return setmetatable({_d=self._d, rows=self.rows, cols=self.cols, _rc=self._rc}, Mat)
end
function Mat:clone()
    return Mat._wrap(self._d:clone(), self.rows, self.cols)
end
function Mat:release()
    if self._rc then
        decRC(self._rc)
        self._rc = nil
    end
    return self
end
function Mat:idx(i,j)  return (i-1)*self.cols+j end
function Mat:get(i,j)  return self._d:get((i-1)*self.cols+j) end
function Mat:set(i,j,v) self:_cow(); self._d:set((i-1)*self.cols+j, v); return self end
function Mat:add_(b)
    self:_cow(); local n=self.rows*self.cols
    if type(b)=="number" then
        for i=1,n do self._d:set(i, self._d:get(i)+b) end
    else
        for i=1,n do self._d:set(i, self._d:get(i)+b._d:get(i)) end
    end; return self
end
function Mat:sub_(b)
    self:_cow(); local n=self.rows*self.cols
    if type(b)=="number" then
        for i=1,n do self._d:set(i, self._d:get(i)-b) end
    else
        for i=1,n do self._d:set(i, self._d:get(i)-b._d:get(i)) end
    end; return self
end
function Mat:scale_(s)
    self:_cow(); local n=self.rows*self.cols
    for i=1,n do self._d:set(i, self._d:get(i)*s) end; return self
end
function Mat:neg_()  return self:scale_(-1) end
function Mat:map_(f)
    self:_cow()
    for i=1,self.rows do for j=1,self.cols do
        self._d:set((i-1)*self.cols+j, f(self._d:get((i-1)*self.cols+j),i,j))
    end end; return self
end
function Mat:add(b)   return self:clone():add_(b) end
function Mat:sub(b)   return self:clone():sub_(b) end
function Mat:scale(s) return self:clone():scale_(s) end
function Mat:neg()    return self:clone():scale_(-1) end
function Mat:map(f)   return self:clone():map_(f) end
function Mat:hadamard(b)
    local m=self:clone(); local n=self.rows*self.cols
    for i=1,n do m._d:set(i, m._d:get(i)*b._d:get(i)) end; return m
end
function Mat:T()
    local m=Mat.new(self.cols, self.rows)
    for i=1,self.rows do for j=1,self.cols do
        m._d:set((j-1)*self.rows+i, self._d:get((i-1)*self.cols+j))
    end end; return m
end
function Mat:row(i)
    local v=Vec.new(self.cols)
    for j=1,self.cols do v._d:set(j, self._d:get((i-1)*self.cols+j)) end; return v
end
function Mat:col(j)
    local v=Vec.new(self.rows)
    for i=1,self.rows do v._d:set(i, self._d:get((i-1)*self.cols+j)) end; return v
end
function Mat:setRow(i,v)
    self:_cow()
    for j=1,self.cols do self._d:set((i-1)*self.cols+j, v._d:get(j)) end; return self
end
function Mat:setCol(j,v)
    self:_cow()
    for i=1,self.rows do self._d:set((i-1)*self.cols+j, v._d:get(i)) end; return self
end
function Mat:submat(r1,r2,c1,c2)
    local m=Mat.new(r2-r1+1, c2-c1+1)
    for i=r1,r2 do for j=c1,c2 do
        m._d:set((i-r1)*m.cols+(j-c1+1), self._d:get((i-1)*self.cols+j))
    end end; return m
end
function Mat:reshape(r,c)
    local m=Mat._wrap(self._d, r, c, self._rc); incRC(self._rc); return m
end
function Mat:flatten()
    local n2=self.rows*self.cols
    local ta=TArray.new(n2)
    for i=1,n2 do ta:set(i,self._d:get(i)) end
    return Vec._wrap(ta)
end
function Mat:toTable()
    local r={}
    for i=1,self.rows do r[i]={}
        for j=1,self.cols do r[i][j]=self._d:get((i-1)*self.cols+j) end end; return r
end
function Mat:trace()
    local s=0; local mn=math.min(self.rows,self.cols)
    for i=1,mn do s=s+self._d:get((i-1)*self.cols+i) end; return s
end
function Mat:frobenius()
    local s=0; local n=self.rows*self.cols
    for i=1,n do local v=self._d:get(i); s=s+v*v end; return sqrt(s)
end
function Mat:sum()   local s=0; local n=self.rows*self.cols; for i=1,n do s=s+self._d:get(i) end; return s end
function Mat:rowSums() local v=Vec.new(self.rows); for i=1,self.rows do v._d:set(i, self:row(i):sum()) end; return v end
function Mat:colSums() local v=Vec.new(self.cols); for j=1,self.cols do v._d:set(j, self:col(j):sum()) end; return v end
function Mat:eq(b,eps)
    eps=eps or EPS
    if self.rows~=b.rows or self.cols~=b.cols then return false end
    local n=self.rows*self.cols
    for i=1,n do if abs(self._d:get(i)-b._d:get(i))>eps then return false end end; return true
end
function Mat:__tostring()
    local lines={}
    for i=1,self.rows do local row={}
        for j=1,self.cols do row[j]=fmt("%10.5g", self:get(i,j)) end
        lines[i]="[ "..tcat(row,"  ").." ]"
    end; return tcat(lines,"\n")
end
Mat.__add=function(a,b) if type(a)=="number" then return b:add(a) end; return a:add(b) end
Mat.__sub=function(a,b) return a:sub(b) end
Mat.__mul=function(a,b) if type(a)=="number" then return b:scale(a) end; return a:mul(b) end
Mat.__unm=function(a)   return a:neg() end
Mat.__eq =function(a,b) return a:eq(b) end
function Mat.fromRows(vs)
    local m=Mat.new(#vs, vs[1].n)
    for i,v in ipairs(vs) do for j=1,v.n do m:set(i,j,v._d:get(j)) end end; return m
end
function Mat.fromCols(vs)
    local m=Mat.new(vs[1].n, #vs)
    for j,v in ipairs(vs) do for i=1,v.n do m:set(i,j,v._d:get(i)) end end; return m
end
function Mat:pow(p)
    assert(self.rows==self.cols,"Mat:pow requires square")
    if p==0 then return Mat.identity(self.rows) end
    if p==1 then return self:clone() end
    if p%2==0 then local h=self:pow(math.floor(p/2)); return h:mul(h) end
    return self:mul(self:pow(p-1))
end
function Mat:isSymmetric(eps)
    eps=eps or EPS
    if self.rows~=self.cols then return false end
    for i=1,self.rows do for j=i+1,self.cols do
        if abs(self:get(i,j)-self:get(j,i))>eps then return false end end end
    return true
end
function Mat:isDiag(eps)
    eps=eps or EPS
    for i=1,self.rows do for j=1,self.cols do
        if i~=j and abs(self:get(i,j))>eps then return false end end end
    return true
end
function Mat:colNormalize()
    local m=self:clone()
    for j=1,m.cols do local col=m:col(j); local n2=col:norm2()
        if n2>EPS then for i=1,m.rows do m:set(i,j,m:get(i,j)/n2) end end end
    return m
end
mathx.Mat = Mat
function mathx.mat(t) return Mat.fromTable(t) end
local blas = {}

function blas.dscal(x, alpha)
    local d = x._d._b
    local n = x.n
    for i = 1, n do
        d[i] = d[i] * alpha
    end
    return x
end

function blas.daxpy(x, alpha, y)
    local xd = x._d._b
    local yd = y._d._b
    local n = x.n
    for i = 1, n do
        yd[i] = alpha * xd[i] + yd[i]
    end
    return y
end

function blas.dcopy(x, y)
    y = y or Vec.new(x.n)
    local xd = x._d._b
    local yd = y._d._b
    local n = x.n
    for i = 1, n do
        yd[i] = xd[i]
    end
    return y
end

function blas.dswap(x, y)
    local xd = x._d._b
    local yd = y._d._b
    local n = x.n
    for i = 1, n do
        local t = xd[i]
        xd[i] = yd[i]
        yd[i] = t
    end
end

function blas.ddot(x, y)
    local xd = x._d._b
    local yd = y._d._b
    local n = x.n
    local s = 0.0
    for i = 1, n do
        s = s + xd[i] * yd[i]
    end
    return s
end

function blas.dnrm2(x)
    local xd = x._d._b
    local n = x.n
    local s = 0.0
    for i = 1, n do
        local v = xd[i]
        s = s + v * v
    end
    return sqrt(s)
end

function blas.dasum(x)
    local xd = x._d._b
    local n = x.n
    local s = 0.0
    for i = 1, n do
        s = s + abs(xd[i])
    end
    return s
end

function blas.idamax(x)
    local xd = x._d._b
    local n = x.n
    local m = abs(xd[1])
    local mi = 1
    for i = 2, n do
        local v = abs(xd[i])
        if v > m then
            m = v
            mi = i
        end
    end
    return mi
end

function blas.drot(x, y, c, s)
    local xd = x._d._b
    local yd = y._d._b
    local n = x.n
    for i = 1, n do
        local xi = xd[i]
        local yi = yd[i]
        xd[i] = c * xi + s * yi
        yd[i] = -s * xi + c * yi
    end
end

function blas.dgemv(A, x, y, alpha, beta)
    alpha = alpha or 1
    beta = beta or 0
    local m = A.rows
    local n = A.cols
    if not y then
        y = Vec.new(m)
    end
    local a = A._d._b
    local xd = x._d._b
    local yd = y._d._b
    local stride = n
    for i = 1, m do
        local rowOff = (i - 1) * stride
        local sum = 0.0
                local j = 1
        while j + 3 <= n do
            sum = sum + a[rowOff + j] * xd[j]
            sum = sum + a[rowOff + j + 1] * xd[j + 1]
            sum = sum + a[rowOff + j + 2] * xd[j + 2]
            sum = sum + a[rowOff + j + 3] * xd[j + 3]
            j = j + 4
        end
        while j <= n do
            sum = sum + a[rowOff + j] * xd[j]
            j = j + 1
        end
        yd[i] = alpha * sum + beta * yd[i]
    end
    return y
end

function blas.dger(A, x, y, alpha)
    alpha = alpha or 1
    local m = A.rows
    local n = A.cols
    local a = A._d._b
    local xd = x._d._b
    local yd = y._d._b
    local stride = n
    for i = 1, m do
        local xi = alpha * xd[i]
        local rowOff = (i - 1) * stride
        for j = 1, n do
            a[rowOff + j] = a[rowOff + j] + xi * yd[j]
        end
    end
    return A
end

function blas.dsymv(A, x, y, alpha, beta)
    alpha = alpha or 1
    beta = beta or 0
    local n = A.rows
    if not y then
        y = Vec.new(n)
    end
    local a = A._d._b
    local xd = x._d._b
    local yd = y._d._b
    local stride = n
    for i = 1, n do
        local sum = 0.0
        local rowOff = (i - 1) * stride
        for j = 1, n do
            local av
            if i <= j then
                av = a[rowOff + j]
            else
                av = a[(j - 1) * stride + i]
            end
            sum = sum + av * xd[j]
        end
        yd[i] = alpha * sum + beta * yd[i]
    end
    return y
end

function blas.dtrsv(T, b, lower, unit)
    local n = T.rows
    
        local x
    if b._rc and isShared(b._rc) then
        x = b:clone()
    else
        x = b
        x:_cow()      end
    
    local t = T._d._b
    local xd = x._d._b
    local stride = n
    
    if lower then
                for i = 1, n do
            local rowOff = (i - 1) * stride
            local s = xd[i]
            
                        local j = 1
            while j + 3 <= i - 1 do
                s = s - t[rowOff + j] * xd[j]
                s = s - t[rowOff + j + 1] * xd[j + 1]
                s = s - t[rowOff + j + 2] * xd[j + 2]
                s = s - t[rowOff + j + 3] * xd[j + 3]
                j = j + 4
            end
                        while j <= i - 1 do
                s = s - t[rowOff + j] * xd[j]
                j = j + 1
            end
            
            if not unit then
                s = s / t[rowOff + i]
            end
            xd[i] = s
        end
    else
                for i = n, 1, -1 do
            local rowOff = (i - 1) * stride
            local s = xd[i]
            
                        local j = i + 1
            while j + 3 <= n do
                s = s - t[rowOff + j] * xd[j]
                s = s - t[rowOff + j + 1] * xd[j + 1]
                s = s - t[rowOff + j + 2] * xd[j + 2]
                s = s - t[rowOff + j + 3] * xd[j + 3]
                j = j + 4
            end
            while j <= n do
                s = s - t[rowOff + j] * xd[j]
                j = j + 1
            end
            
            if not unit then
                s = s / t[rowOff + i]
            end
            xd[i] = s
        end
    end
    return x
end

local BLOCK = 32
local UNROLL = 4

function blas.dgemm(A, B, C, alpha, beta)
    alpha = alpha or 1
    beta = beta or 0
    local m = A.rows
    local k = A.cols
    local n = B.cols
    
    if not C then
        C = Mat.new(m, n, 0)
    elseif beta ~= 1 then
        C:scale_(beta)
    end
    
    local a = A._d._b
    local b = B._d._b
    local c = C._d._b
    local lda = k
    local ldb = n
    local ldc = n
    
    for ib = 1, m, BLOCK do
        local iEnd = math.min(ib + BLOCK - 1, m)
        for jb = 1, n, BLOCK do
            local jEnd = math.min(jb + BLOCK - 1, n)
            for kb = 1, k, BLOCK do
                local kEnd = math.min(kb + BLOCK - 1, k)
                
                for i = ib, iEnd do
                    local rowA = (i - 1) * lda
                    local rowC = (i - 1) * ldc
                    for j = jb, jEnd do
                        local sum = 0.0
                        local p = kb
                        while p + UNROLL - 1 <= kEnd do
                            sum = sum + a[rowA + p] * b[(p - 1) * ldb + j]
                            sum = sum + a[rowA + p + 1] * b[p * ldb + j]
                            sum = sum + a[rowA + p + 2] * b[(p + 1) * ldb + j]
                            sum = sum + a[rowA + p + 3] * b[(p + 2) * ldb + j]
                            p = p + UNROLL
                        end
                        while p <= kEnd do
                            sum = sum + a[rowA + p] * b[(p - 1) * ldb + j]
                            p = p + 1
                        end
                        c[rowC + j] = c[rowC + j] + alpha * sum
                    end
                end
            end
        end
    end
    return C
end

function blas.dtrsm(A, B, lower)
    local n = A.rows
    local nrhs = B.cols
    
        if nrhs == 1 then
        local x = B:col(1)
        local result = blas.dtrsv(A, x, lower, false)
        local X = Mat.new(n, 1)
        for i = 1, n do
            X:set(i, 1, result:get(i))
        end
        return X
    end
    
        local X = B:clone()
    local a = A._d._b
    local xd = X._d._b
    local lda = n
    local ldx = nrhs
    
    if lower then
        for j = 1, nrhs do
            for i = 1, n do
                local rowOff = (i - 1) * lda
                local s = xd[(i - 1) * ldx + j]
                local k = 1
                while k + 3 <= i - 1 do
                    s = s - a[rowOff + k]     * xd[(k-1) * ldx + j]
                    s = s - a[rowOff + k + 1] * xd[k * ldx + j]
                    s = s - a[rowOff + k + 2] * xd[(k+1) * ldx + j]
                    s = s - a[rowOff + k + 3] * xd[(k+2) * ldx + j]
                    k = k + 4
                end
                while k <= i - 1 do
                    s = s - a[rowOff + k] * xd[(k-1) * ldx + j]
                    k = k + 1
                end
                xd[(i - 1) * ldx + j] = s / a[rowOff + i]
            end
        end
    else
        for j = 1, nrhs do
            for i = n, 1, -1 do
                local rowOff = (i - 1) * lda
                local s = xd[(i - 1) * ldx + j]
                local k = i + 1
                while k + 3 <= n do
                    s = s - a[rowOff + k]     * xd[(k-1) * ldx + j]
                    s = s - a[rowOff + k + 1] * xd[k * ldx + j]
                    s = s - a[rowOff + k + 2] * xd[(k+1) * ldx + j]
                    s = s - a[rowOff + k + 3] * xd[(k+2) * ldx + j]
                    k = k + 4
                end
                while k <= n do
                    s = s - a[rowOff + k] * xd[(k-1) * ldx + j]
                    k = k + 1
                end
                xd[(i - 1) * ldx + j] = s / a[rowOff + i]
            end
        end
    end
    
    return X
end

function blas.dsyrk(A, C, alpha, beta)
    alpha = alpha or 1
    beta = beta or 0
    local m = A.rows
    local k = A.cols
    if not C then
        C = Mat.new(m, m, 0)
    elseif beta ~= 1 then
        C:scale_(beta)
    end
    local a = A._d._b
    local c = C._d._b
    local lda = k
    local ldc = m
    for i = 1, m do
        local rowAi = (i - 1) * lda
        local rowCi = (i - 1) * ldc
        for j = i, m do
            local rowAj = (j - 1) * lda
            local sum = 0.0
            for p = 1, k do
                sum = sum + a[rowAi + p] * a[rowAj + p]
            end
            local val = c[rowCi + j] + alpha * sum
            c[rowCi + j] = val
            if i ~= j then
                c[(j - 1) * ldc + i] = val
            end
        end
    end
    return C
end

function Mat:mul(b)
    if type(b) == "number" then
        return self:clone():scale_(b)
    end
    if getmetatable(b) == Vec then
        return blas.dgemv(self, b)
    end
    
    local m, k, n = self.rows, self.cols, b.cols
    local C = Mat.new(m, n, 0)
    
    local a = self._d._b
    local bd = b._d._b
    local c = C._d._b
    
        if m <= 64 and k <= 64 and n <= 64 then
        for i = 1, m do
            local rowA = (i - 1) * k
            local rowC = (i - 1) * n
            for j = 1, n do
                local sum = 0
                local p = 1
                                while p + 7 <= k do
                    sum = sum + a[rowA + p]     * bd[(p-1)*n + j]
                    sum = sum + a[rowA + p + 1] * bd[p*n + j]
                    sum = sum + a[rowA + p + 2] * bd[(p+1)*n + j]
                    sum = sum + a[rowA + p + 3] * bd[(p+2)*n + j]
                    sum = sum + a[rowA + p + 4] * bd[(p+3)*n + j]
                    sum = sum + a[rowA + p + 5] * bd[(p+4)*n + j]
                    sum = sum + a[rowA + p + 6] * bd[(p+5)*n + j]
                    sum = sum + a[rowA + p + 7] * bd[(p+6)*n + j]
                    p = p + 8
                end
                                while p <= k do
                    sum = sum + a[rowA + p] * bd[(p-1)*n + j]
                    p = p + 1
                end
                c[rowC + j] = sum
            end
        end
    else
                local BLOCK = 32
        for ib = 1, m, BLOCK do
            local iEnd = math.min(ib + BLOCK - 1, m)
            for jb = 1, n, BLOCK do
                local jEnd = math.min(jb + BLOCK - 1, n)
                for kb = 1, k, BLOCK do
                    local kEnd = math.min(kb + BLOCK - 1, k)
                    for i = ib, iEnd do
                        local rowA = (i - 1) * k
                        local rowC = (i - 1) * n
                        for j = jb, jEnd do
                            local sum = 0
                            local p = kb
                            while p + 3 <= kEnd do
                                sum = sum + a[rowA + p]     * bd[(p-1)*n + j]
                                sum = sum + a[rowA + p + 1] * bd[p*n + j]
                                sum = sum + a[rowA + p + 2] * bd[(p+1)*n + j]
                                sum = sum + a[rowA + p + 3] * bd[(p+2)*n + j]
                                p = p + 4
                            end
                            while p <= kEnd do
                                sum = sum + a[rowA + p] * bd[(p-1)*n + j]
                                p = p + 1
                            end
                            c[rowC + j] = c[rowC + j] + sum
                        end
                    end
                end
            end
        end
    end
    
    return C
end

mathx.blas = blas
local function matAdd(A,B) return A:add(B) end
local function matSub(A,B) return A:sub(B) end
local function padPow2(M)
    local function np2(n) local p=1; while p<n do p=p*2 end; return p end
    local pr=np2(M.rows); local pc=np2(M.cols)
    local n=math.max(pr,pc)
    if n==M.rows and n==M.cols then return M,M.rows,M.cols end
    local P=Mat.new(n,n,0)
    for i=1,M.rows do for j=1,M.cols do P:set(i,j,M:get(i,j)) end end
    return P,M.rows,M.cols
end
local function unpad(M,r,c) return M:submat(1,r,1,c) end
local function splitMat(M)
    local h=math.floor(M.rows/2)
    return M:submat(1,h,1,h), M:submat(1,h,h+1,M.cols),
           M:submat(h+1,M.rows,1,h), M:submat(h+1,M.rows,h+1,M.cols)
end
local function joinMat(C11,C12,C21,C22)
    local h=C11.rows; local n=h*2; local C=Mat.new(n,n)
    for i=1,h do for j=1,h do
        C:set(i,j,C11:get(i,j)); C:set(i,j+h,C12:get(i,j))
        C:set(i+h,j,C21:get(i,j)); C:set(i+h,j+h,C22:get(i,j))
    end end; return C
end
local STRASSEN_THRESH = 64
local function strassenRec(A,B)
    local n=A.rows
    if n<=STRASSEN_THRESH then return blas.dgemm(A,B) end
    local A11,A12,A21,A22=splitMat(A)
    local B11,B12,B21,B22=splitMat(B)
    local M1=strassenRec(matAdd(A11,A22), matAdd(B11,B22))
    local M2=strassenRec(matAdd(A21,A22), B11)
    local M3=strassenRec(A11,             matSub(B12,B22))
    local M4=strassenRec(A22,             matSub(B21,B11))
    local M5=strassenRec(matAdd(A11,A12), B22)
    local M6=strassenRec(matSub(A21,A11), matAdd(B11,B12))
    local M7=strassenRec(matSub(A12,A22), matAdd(B21,B22))
    local C11=matAdd(matSub(matAdd(M1,M4),M5),M7)
    local C12=matAdd(M3,M5)
    local C21=matAdd(M2,M4)
    local C22=matAdd(matSub(matAdd(M1,M3),M2),M6)
    return joinMat(C11,C12,C21,C22)
end
function blas.strassen(A,B)
    local Ap,origR,origC=padPow2(A); local Bp=padPow2(B)
    local Cp=strassenRec(Ap,Bp); return unpad(Cp,origR,B.cols)
end
function blas.winograd(A, B)
    local m, k, n = A.rows, A.cols, B.cols
    
            local WINOGRAIN_MIN = 32      
    if m < WINOGRAIN_MIN or k < WINOGRAIN_MIN or n < WINOGRAIN_MIN then
        return blas.dgemm(A, B)
    end
    
        local a = A._d._b
    local b = B._d._b
    local C = Mat.new(m, n, 0)
    local c = C._d._b
    
        local ra = {}
    local k_half = math.floor(k / 2)
    
    for i = 1, m do
        local rowOff = (i - 1) * k
        local sum = 0
        for p = 1, k_half * 2, 2 do
            sum = sum + a[rowOff + p] * a[rowOff + p + 1]
        end
        ra[i] = sum
    end
    
        local cb = {}
    for j = 1, n do
        local sum = 0
        for p = 1, k_half * 2, 2 do
            sum = sum + b[(p-1)*n + j] * b[p*n + j]
        end
        cb[j] = sum
    end
    
        for i = 1, m do
        local rowC = (i - 1) * n
        for j = 1, n do
            local s = -ra[i] - cb[j]
            for p = 1, k_half do
                local p2 = p * 2
                s = s + (a[(i-1)*k + p2 - 1] + b[(p2-2)*n + j]) * 
                         (a[(i-1)*k + p2]     + b[(p2-1)*n + j])
            end
            if k % 2 == 1 then
                s = s + a[(i-1)*k + k] * b[(k-1)*n + j]
            end
            c[rowC + j] = s
        end
    end
    
    return C
end
local lapack = {}
function lapack.dgetrf(A)
    local n=A.rows; local U=A:clone(); local L=Mat.identity(n)
    local P={}; local sgn=1
    for k=1,n do P[k]=k end
    for k=1,n do
        local maxv,maxr=abs(U:get(k,k)),k
        for i=k+1,n do local v=abs(U:get(i,k)); if v>maxv then maxv=v;maxr=i end end
        if maxr~=k then sgn=-sgn; P[k],P[maxr]=P[maxr],P[k]
            for j=1,n do local t=U._d:get((k-1)*n+j);U._d:set((k-1)*n+j,U._d:get((maxr-1)*n+j));U._d:set((maxr-1)*n+j,t) end
            for j=1,k-1 do local t=L._d:get((k-1)*n+j);L._d:set((k-1)*n+j,L._d:get((maxr-1)*n+j));L._d:set((maxr-1)*n+j,t) end
        end
        for i=k+1,n do local f=U:get(i,k)/U:get(k,k); L:set(i,k,f)
            for j=k,n do U:set(i,j,U:get(i,j)-f*U:get(k,j)) end end
    end; return L,U,P,sgn
end
function lapack.dgetrs(L,U,P,b)
    local n=#P; local pb=Vec.new(n)
    for i=1,n do pb._d:set(i, b._d:get(P[i])) end
    return blas.dtrsv(U, blas.dtrsv(L,pb,true,true), false)
end
function lapack.det(A)
    local _,U,_,sgn=lapack.dgetrf(A); local d=sgn
    for i=1,U.rows do d=d*U:get(i,i) end; return d
end
function lapack.inv(A)
    local L,U,P=lapack.dgetrf(A); local n=A.rows; local X=Mat.new(n,n)
    for j=1,n do local ej=Vec.new(n); ej._d:set(j,1)
        local col=lapack.dgetrs(L,U,P,ej)
        for i=1,n do X:set(i,j,col._d:get(i)) end
    end; return X
end
function lapack.dgeqrf(A)
    local m,n=A.rows,A.cols
    local Q=Mat.new(m,n); local R=Mat.new(n,n); local qs={}
    for j=1,n do
        local v=A:col(j)
        for i=1,j-1 do local rij=blas.ddot(qs[i],v); R:set(i,j,rij); blas.daxpy(qs[i],-rij,v) end
        local nrm=blas.dnrm2(v); R:set(j,j,nrm)
        qs[j]=nrm>EPS and v:scale(1/nrm) or Vec.new(m)
        for i=1,m do Q:set(i,j,qs[j]._d:get(i)) end
    end; return Q,R
end
function lapack.dsyev(A)
    local n = A.rows
    local maxIt = 100
    
        if n <= 20 then
                local V = A:clone()
        local vals = Vec.new(n)
        
                for iter = 1, 100 do
            local maxOff = 0
            local p, q = 1, 2
            
                        for i = 1, n do
                for j = i + 1, n do
                    local off = math.abs(V:get(i, j))
                    if off > maxOff then
                        maxOff = off
                        p, q = i, j
                    end
                end
            end
            
            if maxOff < 1e-12 then break end
            
                        local app = V:get(p, p)
            local aqq = V:get(q, q)
            local apq = V:get(p, q)
            
            local tau = (aqq - app) / (2 * apq)
            local t = 1 / (math.abs(tau) + math.sqrt(1 + tau * tau))
            if tau < 0 then t = -t end
            local c = 1 / math.sqrt(1 + t * t)
            local s = t * c
            
                        for i = 1, n do
                if i ~= p and i ~= q then
                    local vip = V:get(i, p)
                    local viq = V:get(i, q)
                    V:set(i, p, c * vip - s * viq)
                    V:set(i, q, s * vip + c * viq)
                end
            end
            
            for j = 1, n do
                if j ~= p and j ~= q then
                    local vpj = V:get(p, j)
                    local vqj = V:get(q, j)
                    V:set(p, j, c * vpj - s * vqj)
                    V:set(q, j, s * vpj + c * vqj)
                end
            end
            
                        local app_new = c * c * app + s * s * aqq - 2 * s * c * apq
            local aqq_new = s * s * app + c * c * aqq + 2 * s * c * apq
            V:set(p, p, app_new)
            V:set(q, q, aqq_new)
            V:set(p, q, (c * c - s * s) * apq + s * c * (app - aqq))
            V:set(q, p, V:get(p, q))
        end
        
                for i = 1, n do
            vals._d:set(i, V:get(i, i))
        end
        
                local idx = {}
        for i = 1, n do idx[i] = i end
        table.sort(idx, function(a, b) return vals._d:get(a) > vals._d:get(b) end)
        
        local vals_sorted = Vec.new(n)
        local V_sorted = Mat.new(n, n)
        
        for j = 1, n do
            local pos = idx[j]
            vals_sorted._d:set(j, vals._d:get(pos))
            for i = 1, n do
                V_sorted:set(i, j, V:get(i, pos))
            end
        end
        
        return vals_sorted, V_sorted
    end
    
        
        local V = Mat.identity(n)
    local H = A:clone()
    
    for k = 1, n - 2 do
                local x = Vec.new(n - k)
        local xd = x._d._b
        for i = k + 1, n do
            xd[i - k] = H:get(i, k)
        end
        
        local sigma = blas.dnrm2(x)
        if sigma > 1e-12 then
            if xd[1] < 0 then sigma = -sigma end
            xd[1] = xd[1] + sigma
            local beta = 1 / (sigma * xd[1])
            
                        for j = k, n do
                local dot = 0
                for i = k + 1, n do
                    dot = dot + xd[i - k] * H:get(i, j)
                end
                dot = dot * beta
                for i = k + 1, n do
                    H:set(i, j, H:get(i, j) - dot * xd[i - k])
                end
            end
            
                        for i = 1, n do
                local dot = 0
                for j = k + 1, n do
                    dot = dot + H:get(i, j) * xd[j - k]
                end
                dot = dot * beta
                for j = k + 1, n do
                    H:set(i, j, H:get(i, j) - dot * xd[j - k])
                end
            end
            
                        for i = 1, n do
                local dot = 0
                for j = k + 1, n do
                    dot = dot + V:get(i, j) * xd[j - k]
                end
                dot = dot * beta
                for j = k + 1, n do
                    V:set(i, j, V:get(i, j) - dot * xd[j - k])
                end
            end
        end
    end
    
        local d = Vec.new(n)
    local e = Vec.new(n - 1)
    for i = 1, n do
        d._d:set(i, H:get(i, i))
        if i < n then
            e._d:set(i, H:get(i + 1, i))
        end
    end
    
        for iter = 1, maxIt * n do
        local m = n
        while m > 1 do
            local tst = math.abs(e._d:get(m - 1))
            if tst <= 1e-12 * (math.abs(d._d:get(m)) + math.abs(d._d:get(m - 1))) then
                break
            end
            m = m - 1
        end
        
        if m == 1 then break end
        
                local shift = d._d:get(n)
        
                local x = d._d:get(1) - shift
        local z = e._d:get(1)
        
        for k = 1, n - 1 do
            local r = math.sqrt(x * x + z * z)
            local c = x / r
            local s_rot = z / r
            
                        local dk = d._d:get(k)
            local dk1 = d._d:get(k + 1)
            local ek = e._d:get(k)
            
            d._d:set(k, c * dk + s_rot * ek)
            e._d:set(k, c * ek - s_rot * dk)
            
            if k < n - 1 then
                local ek1 = e._d:get(k + 1)
                e._d:set(k + 1, c * ek1)
            end
            
            d._d:set(k + 1, c * dk1 + s_rot * ek)
            
            x = -s_rot * d._d:get(k + 1)
            z = e._d:get(k + 1)
            
                        for i = 1, n do
                local vik = V:get(i, k)
                local vik1 = V:get(i, k + 1)
                V:set(i, k, c * vik + s_rot * vik1)
                V:set(i, k + 1, c * vik1 - s_rot * vik)
            end
        end
    end
    
        local idx = {}
    for i = 1, n do idx[i] = i end
    table.sort(idx, function(a, b) return d._d:get(a) > d._d:get(b) end)
    
    local vals_sorted = Vec.new(n)
    local V_sorted = Mat.new(n, n)
    
    for j = 1, n do
        local pos = idx[j]
        vals_sorted._d:set(j, d._d:get(pos))
        for i = 1, n do
            V_sorted:set(i, j, V:get(i, pos))
        end
    end
    
    return vals_sorted, V_sorted
end
function lapack.dgesvd(A)
    local m, n = A.rows, A.cols
    local sm = math.min(m, n)
    
        if sm <= 20 then
                local S = Vec.new(sm)
        local U = Mat.identity(m)
        local V = Mat.identity(n)
        local B = A:clone()
        
        for iter = 1, 50 do
            local maxOff = 0
            local p, q = 1, 2
            
                        for i = 1, sm do
                for j = i + 1, sm do
                    local off = math.abs(B:get(i, j))
                    if off > maxOff then
                        maxOff = off
                        p, q = i, j
                    end
                end
            end
            
            if maxOff < 1e-12 then break end
            
                        local app = B:get(p, p)
            local aqq = B:get(q, q)
            local apq = B:get(p, q)
            
            local tau = (aqq - app) / (2 * apq)
            local t = 1 / (math.abs(tau) + math.sqrt(1 + tau * tau))
            if tau < 0 then t = -t end
            local c = 1 / math.sqrt(1 + t * t)
            local s = t * c
            
                        for i = 1, sm do
                local bip = B:get(i, p)
                local biq = B:get(i, q)
                B:set(i, p, c * bip - s * biq)
                B:set(i, q, s * bip + c * biq)
            end
            
                        for j = 1, sm do
                local bpj = B:get(p, j)
                local bqj = B:get(q, j)
                B:set(p, j, c * bpj - s * bqj)
                B:set(q, j, s * bpj + c * bqj)
            end
            
                        for i = 1, m do
                local uip = U:get(i, p)
                local uiq = U:get(i, q)
                U:set(i, p, c * uip - s * uiq)
                U:set(i, q, s * uip + c * uiq)
            end
            
                        for i = 1, n do
                local vip = V:get(p, i)
                local viq = V:get(q, i)
                V:set(p, i, c * vip - s * viq)
                V:set(q, i, s * vip + c * viq)
            end
        end
        
                for i = 1, sm do
            local val = B:get(i, i)
            S._d:set(i, math.abs(val))
            if val < 0 then
                for j = 1, m do
                    U:set(j, i, -U:get(j, i))
                end
            end
        end
        
                local idx = {}
        for i = 1, sm do idx[i] = i end
        table.sort(idx, function(a, b) return S._d:get(a) > S._d:get(b) end)
        
        local Sout = Vec.new(sm)
        local Uout = Mat.new(m, sm)
        local Vout = Mat.new(n, sm)
        
        for j = 1, sm do
            local pos = idx[j]
            Sout._d:set(j, S._d:get(pos))
            for i = 1, m do
                Uout:set(i, j, U:get(i, pos))
            end
            for i = 1, n do
                Vout:set(i, j, V:get(pos, i))
            end
        end
        
        return Uout, Sout, Vout
    end
    
        
        if m < n then
        local U2, S2, V2 = lapack.dgesvd(A:T())
        return V2, S2, U2
    end
    
        local B = A:clone()
    local U = Mat.identity(m)
    local V = Mat.identity(n)
    
    for k = 1, n do
                local x = Vec.new(m - k + 1)
        local xd = x._d._b
        for i = k, m do
            xd[i - k + 1] = B:get(i, k)
        end
        local sigma = blas.dnrm2(x)
        if sigma > 1e-12 then
            if xd[1] < 0 then sigma = -sigma end
            xd[1] = xd[1] + sigma
            local beta = 1 / (sigma * xd[1])
            
            for j = k, n do
                local dot = 0
                for i = k, m do
                    dot = dot + xd[i - k + 1] * B:get(i, j)
                end
                dot = dot * beta
                for i = k, m do
                    B:set(i, j, B:get(i, j) - dot * xd[i - k + 1])
                end
            end
            
            for i = 1, m do
                local dot = 0
                for j2 = k, m do
                    dot = dot + U:get(i, j2) * xd[j2 - k + 1]
                end
                dot = dot * beta
                for j2 = k, m do
                    U:set(i, j2, U:get(i, j2) - dot * xd[j2 - k + 1])
                end
            end
        end
        
        if k < n then
                        local y = Vec.new(n - k)
            local yd = y._d._b
            for j = k + 1, n do
                yd[j - k] = B:get(k, j)
            end
            sigma = blas.dnrm2(y)
            if sigma > 1e-12 then
                if yd[1] < 0 then sigma = -sigma end
                yd[1] = yd[1] + sigma
                local beta = 1 / (sigma * yd[1])
                
                for i = k, m do
                    local dot = 0
                    for j = k + 1, n do
                        dot = dot + yd[j - k] * B:get(i, j)
                    end
                    dot = dot * beta
                    for j = k + 1, n do
                        B:set(i, j, B:get(i, j) - dot * yd[j - k])
                    end
                end
                
                for i = 1, n do
                    local dot = 0
                    for j = k + 1, n do
                        dot = dot + V:get(j, i) * yd[j - k]
                    end
                    dot = dot * beta
                    for j = k + 1, n do
                        V:set(j, i, V:get(j, i) - dot * yd[j - k])
                    end
                end
            end
        end
    end
    
        local d = Vec.new(n)
    local e = Vec.new(n - 1)
    for i = 1, n do
        d._d:set(i, B:get(i, i))
        if i < n then
            e._d:set(i, B:get(i, i + 1))
        end
    end
    
        local maxIter = 30 * n
    for iter = 1, maxIter do
        local p = n
        while p > 1 and math.abs(e._d:get(p - 1)) <= 1e-12 * (math.abs(d._d:get(p)) + math.abs(d._d:get(p - 1))) do
            p = p - 1
        end
        
        if p == 1 then break end
        
                local mu = d._d:get(p)
        local z = d._d:get(p - 1)
        local s = math.abs(mu) + math.abs(z)
        mu = mu / s
        z = z / s
        local shift = s * math.sqrt(mu * mu + z * z)
        if mu < 0 then shift = -shift end
        
                local f = (d._d:get(1) - shift) * (d._d:get(1) + shift) + e._d:get(1) * e._d:get(1)
        local g = e._d:get(1) * (d._d:get(1) + d._d:get(2) - shift)
        
        for k = 1, p - 1 do
                        local r = math.sqrt(f * f + g * g)
            local c = f / r
            local s_rot = g / r
            
                        f = d._d:get(k) - shift
            d._d:set(k, f * c + e._d:get(k) * s_rot)
            e._d:set(k, e._d:get(k) * c - f * s_rot)
            
            f = e._d:get(k)
            g = d._d:get(k + 1) * s_rot
            d._d:set(k + 1, d._d:get(k + 1) * c)
            
                        for i = 1, n do
                local vi = V:get(k, i)
                local vj = V:get(k + 1, i)
                V:set(k, i, vi * c + vj * s_rot)
                V:set(k + 1, i, vj * c - vi * s_rot)
            end
            
            r = math.sqrt(f * f + g * g)
            c = f / r
            s_rot = g / r
            
            f = c * e._d:get(k) + s_rot * d._d:get(k + 1)
            d._d:set(k + 1, d._d:get(k + 1) * c - e._d:get(k) * s_rot)
            e._d:set(k, f)
            
            g = s_rot * e._d:get(k + 1)
            e._d:set(k + 1, e._d:get(k + 1) * c)
            
                        for i = 1, m do
                local ui = U:get(i, k)
                local uj = U:get(i, k + 1)
                U:set(i, k, ui * c + uj * s_rot)
                U:set(i, k + 1, uj * c - ui * s_rot)
            end
        end
    end
    
        local idx = {}
    for i = 1, n do idx[i] = i end
    table.sort(idx, function(a, b) return math.abs(d._d:get(a)) > math.abs(d._d:get(b)) end)
    
    local S = Vec.new(n)
    local Uout = Mat.new(m, n)
    local Vout = Mat.new(n, n)
    
    for j = 1, n do
        local pos = idx[j]
        S._d:set(j, math.abs(d._d:get(pos)))
        local sign = d._d:get(pos) >= 0 and 1 or -1
        for i = 1, m do
            Uout:set(i, j, U:get(i, pos) * sign)
        end
        for i = 1, n do
            Vout:set(i, j, V:get(pos, i))
        end
    end
    
    return Uout, S, Vout
end
function lapack.dpotrf(A)
    local n=A.rows; local L=Mat.new(n,n)
    for i=1,n do for j=1,i do
        local s=A:get(i,j)
        for p=1,j-1 do s=s-L:get(i,p)*L:get(j,p) end
        if i==j then L:set(i,j,sqrt(math.max(0,s)))
        else local ljj=L:get(j,j); L:set(i,j, ljj>EPS and s/ljj or 0) end
    end end; return L
end
function lapack.pinv(A,tol)
    local U,S,V=lapack.dgesvd(A); tol=tol or EPS; local k=S.n
    local VD=Mat.new(A.cols,k)
    for i=1,A.cols do for j=1,k do
        VD:set(i,j, V:get(i,j)*(S._d:get(j)>tol and 1/S._d:get(j) or 0))
    end end
    return blas.dgemm(VD,U:T())
end
function lapack.lstsq(A,b) return lapack.pinv(A):mul(b) end
function lapack.cond(A)    local _,S=lapack.dgesvd(A); return S._d:get(1)/(S._d:get(S.n)+EPS) end
function lapack.rank(A,tol)
    tol=tol or EPS; local _,S=lapack.dgesvd(A); local r=0
    for i=1,S.n do if S._d:get(i)>tol then r=r+1 end end; return r
end
function lapack.hessenberg(A)
    local n = A.rows
    
        if n <= 10 then
        return A:clone(), Mat.identity(n)
    end
    
    local H = A:clone()
    local Q = Mat.identity(n)
    
    for k = 1, n - 2 do
                local x = Vec.new(n - k)
        local xd = x._d._b
        
                local h_data = H._d._b
        local stride = n
        
                for i = k + 1, n do
            xd[i - k] = h_data[(i - 1) * stride + k]
        end
        
                local sigma_sq = 0
        for i = 1, n - k do
            local v = xd[i]
            sigma_sq = sigma_sq + v * v
        end
        local sigma = math.sqrt(sigma_sq)
        
        if sigma > 1e-12 then
            if xd[1] < 0 then sigma = -sigma end
            xd[1] = xd[1] + sigma
            local beta = 1 / (sigma * xd[1])
            
                                    for j = k, n do
                local dot = 0
                                local i = 1
                while i + 3 <= n - k do
                    dot = dot + xd[i]     * h_data[(k + i - 1) * stride + j]
                    dot = dot + xd[i + 1] * h_data[(k + i) * stride + j]
                    dot = dot + xd[i + 2] * h_data[(k + i + 1) * stride + j]
                    dot = dot + xd[i + 3] * h_data[(k + i + 2) * stride + j]
                    i = i + 4
                end
                while i <= n - k do
                    dot = dot + xd[i] * h_data[(k + i - 1) * stride + j]
                    i = i + 1
                end
                dot = dot * beta
                
                i = 1
                while i + 3 <= n - k do
                    h_data[(k + i - 1) * stride + j] = h_data[(k + i - 1) * stride + j] - dot * xd[i]
                    h_data[(k + i) * stride + j]     = h_data[(k + i) * stride + j]     - dot * xd[i + 1]
                    h_data[(k + i + 1) * stride + j] = h_data[(k + i + 1) * stride + j] - dot * xd[i + 2]
                    h_data[(k + i + 2) * stride + j] = h_data[(k + i + 2) * stride + j] - dot * xd[i + 3]
                    i = i + 4
                end
                while i <= n - k do
                    h_data[(k + i - 1) * stride + j] = h_data[(k + i - 1) * stride + j] - dot * xd[i]
                    i = i + 1
                end
            end
            
                        for i = 1, n do
                local dot = 0
                                local j = 1
                while j + 3 <= n - k do
                    dot = dot + h_data[(i - 1) * stride + (k + j - 1)] * xd[j]
                    dot = dot + h_data[(i - 1) * stride + (k + j)]     * xd[j + 1]
                    dot = dot + h_data[(i - 1) * stride + (k + j + 1)] * xd[j + 2]
                    dot = dot + h_data[(i - 1) * stride + (k + j + 2)] * xd[j + 3]
                    j = j + 4
                end
                while j <= n - k do
                    dot = dot + h_data[(i - 1) * stride + (k + j - 1)] * xd[j]
                    j = j + 1
                end
                dot = dot * beta
                
                j = 1
                while j + 3 <= n - k do
                    h_data[(i - 1) * stride + (k + j - 1)] = h_data[(i - 1) * stride + (k + j - 1)] - dot * xd[j]
                    h_data[(i - 1) * stride + (k + j)]     = h_data[(i - 1) * stride + (k + j)]     - dot * xd[j + 1]
                    h_data[(i - 1) * stride + (k + j + 1)] = h_data[(i - 1) * stride + (k + j + 1)] - dot * xd[j + 2]
                    h_data[(i - 1) * stride + (k + j + 2)] = h_data[(i - 1) * stride + (k + j + 2)] - dot * xd[j + 3]
                    j = j + 4
                end
                while j <= n - k do
                    h_data[(i - 1) * stride + (k + j - 1)] = h_data[(i - 1) * stride + (k + j - 1)] - dot * xd[j]
                    j = j + 1
                end
            end
            
                        local q_data = Q._d._b
            for i = 1, n do
                local dot = 0
                local j = 1
                while j + 3 <= n - k do
                    dot = dot + q_data[(i - 1) * stride + (k + j - 1)] * xd[j]
                    dot = dot + q_data[(i - 1) * stride + (k + j)]     * xd[j + 1]
                    dot = dot + q_data[(i - 1) * stride + (k + j + 1)] * xd[j + 2]
                    dot = dot + q_data[(i - 1) * stride + (k + j + 2)] * xd[j + 3]
                    j = j + 4
                end
                while j <= n - k do
                    dot = dot + q_data[(i - 1) * stride + (k + j - 1)] * xd[j]
                    j = j + 1
                end
                dot = dot * beta
                
                j = 1
                while j + 3 <= n - k do
                    q_data[(i - 1) * stride + (k + j - 1)] = q_data[(i - 1) * stride + (k + j - 1)] - dot * xd[j]
                    q_data[(i - 1) * stride + (k + j)]     = q_data[(i - 1) * stride + (k + j)]     - dot * xd[j + 1]
                    q_data[(i - 1) * stride + (k + j + 1)] = q_data[(i - 1) * stride + (k + j + 1)] - dot * xd[j + 2]
                    q_data[(i - 1) * stride + (k + j + 2)] = q_data[(i - 1) * stride + (k + j + 2)] - dot * xd[j + 3]
                    j = j + 4
                end
                while j <= n - k do
                    q_data[(i - 1) * stride + (k + j - 1)] = q_data[(i - 1) * stride + (k + j - 1)] - dot * xd[j]
                    j = j + 1
                end
            end
        end
    end
    
    return H, Q
end
function lapack.null(A,tol)
    tol=tol or EPS; local M=A:clone(); local pivCols={}; local row=1
    for col=1,M.cols do
        local pivR=nil; for i=row,M.rows do if abs(M:get(i,col))>tol then pivR=i;break end end
        if pivR then pivCols[#pivCols+1]=col
            for j=1,M.cols do local t=M:get(row,j);M:set(row,j,M:get(pivR,j));M:set(pivR,j,t) end
            local p=M:get(row,col); for j=1,M.cols do M:set(row,j,M:get(row,j)/p) end
            for i=1,M.rows do if i~=row then local f=M:get(i,col)
                for j=1,M.cols do M:set(i,j,M:get(i,j)-f*M:get(row,j)) end end end
            row=row+1 end end
    local pivSet={}; for _,c in ipairs(pivCols) do pivSet[c]=true end
    local free={}; for j=1,M.cols do if not pivSet[j] then free[#free+1]=j end end
    local basis={}
    for _,fc in ipairs(free) do local v=Vec.new(M.cols); v._d:set(fc,1)
        for pi,pc in ipairs(pivCols) do v._d:set(pc,-M:get(pi,fc)) end; basis[#basis+1]=v end
    return basis
end
function lapack.expm(A,terms)
    terms=terms or 20; local n=A.rows; local R=Mat.identity(n); local Ak=Mat.identity(n); local fk=1
    for k=1,terms do fk=fk*k; Ak=blas.dgemm(Ak,A); R:add_(Ak:scale(1/fk)) end; return R
end
mathx.lapack = lapack
mathx.blas   = blas
local la = {}
la.det       = lapack.det
la.inv       = lapack.inv
la.solve     = function(A,b) local L,U,P=lapack.dgetrf(A); return lapack.dgetrs(L,U,P,b) end
la.solveM    = function(A,B)
    local X=Mat.new(A.rows,B.cols)
    for j=1,B.cols do local col=la.solve(A,B:col(j)); for i=1,A.rows do X:set(i,j,col._d:get(i)) end end; return X
end
la.lu        = lapack.dgetrf
la.qr        = lapack.dgeqrf
la.eig       = lapack.dsyev
la.svd       = lapack.dgesvd
la.chol      = lapack.dpotrf
la.pinv      = lapack.pinv
la.lstsq     = lapack.lstsq
la.cond      = lapack.cond
la.rank      = lapack.rank
la.null      = lapack.null
la.expm      = lapack.expm
la.hessenberg= lapack.hessenberg
la.norm      = function(A,k) if k=="fro" or not k then return A:frobenius() end
    if k==1 then local m=0; for j=1,A.cols do local s=A:col(j):map(function(v) return v<0 and -v or v end):sum(); if s>m then m=s end end; return m end
    if k==huge then local m=0; for i=1,A.rows do local s=A:row(i):map(function(v) return v<0 and -v or v end):sum(); if s>m then m=s end end; return m end
end
la.gramSchmidt = function(vs)
    local r={}
    for _,v in ipairs(vs) do local u=v:clone()
        for _,q in ipairs(r) do blas.daxpy(q,-blas.ddot(q,v),u) end
        local n=blas.dnrm2(u); if n>EPS then r[#r+1]=u:scale(1/n) end end; return r
end
mathx.la     = la
mathx.linalg = la
local fp = {}
local FP_ONE = 65536
function fp.fromFloat(x) return floor(x * FP_ONE + 0.5) end
function fp.toFloat(x)   return x / FP_ONE end
function fp.add(a,b)     return a+b end
function fp.sub(a,b)     return a-b end
function fp.mul(a,b)     return floor(a*b/FP_ONE) end
function fp.div(a,b)     return floor(a*FP_ONE/b) end
function fp.neg(a)       return -a end
function fp.abs_(a)      return a<0 and -a or a end
function fp.sqrt_(a)     return fp.fromFloat(sqrt(fp.toFloat(a))) end
function fp.floor_(a)    return floor(a/FP_ONE)*FP_ONE end
function fp.ceil_(a)     return ceil(a/FP_ONE)*FP_ONE end
function fp.lerp_(a,b,t) return a + fp.div(fp.mul(b-a, t), FP_ONE) end
function fp.dot(as,bs)
    local s=0; for i=1,#as do s=s+fp.mul(as[i],bs[i]) end; return s
end
function fp.Vec(t)
    local v={}; for i,x in ipairs(t) do v[i]=fp.fromFloat(x) end; return v
end
function fp.toFloatVec(v)
    local t={}; for i,x in ipairs(v) do t[i]=fp.toFloat(x) end; return t
end
local FP_MAX =  0x7FFFFFFF
local FP_MIN = -0x80000000
function fp.addSat(a,b)
    local r=a+b; return r>FP_MAX and FP_MAX or r<FP_MIN and FP_MIN or r
end
function fp.mulSat(a,b)
    local r=floor(a*b/FP_ONE); return r>FP_MAX and FP_MAX or r<FP_MIN and FP_MIN or r
end
mathx.fp  = fp
mathx.fixedpoint = fp
local pp = {}
local function toF32(x)
    if x==0 or x~=x then return x end
    local s=x<0 and -1 or 1; local a=abs(x)
    local e=floor(math.log(a,10))
    local scale=10^(7-e)
    return s*floor(a*scale+0.5)/scale
end
function pp.dgemm_f32(A,B)
    local m,k,n=A.rows,A.cols,B.cols; local C=Mat.new(m,n)
    for i=1,m do for j=1,n do local s=0
        for p=1,k do s=toF32(s+toF32(toF32(A:get(i,p))*toF32(B:get(p,j)))) end
        C:set(i,j,s) end end; return C
end
function pp.iterRefine(A, b, maxIter, tol)
    tol = tol or EPS; maxIter = maxIter or 5
    local L,U,P=lapack.dgetrf(A)
    local x=lapack.dgetrs(L,U,P,b)
    for _=1,maxIter do
        local r=b:sub(blas.dgemv(A,x))
        local rNrm=blas.dnrm2(r)
        if rNrm<tol then break end
        local delta=lapack.dgetrs(L,U,P,r)
        blas.daxpy(delta,1,x)
    end; return x
end
function pp.eigProgressive(A, roughIters, refineIters, tol)
    roughIters = roughIters or 10; refineIters = refineIters or 1000
    tol = tol or EPS; local n=A.rows
    local Ak=A:clone(); local V=Mat.identity(n)
    for _=1,roughIters do
        local Q,R=lapack.dgeqrf(Ak); Ak=blas.dgemm(R,Q); V=blas.dgemm(V,Q)
    end
    for _=1,refineIters do
        local Q,R=lapack.dgeqrf(Ak); Ak=blas.dgemm(R,Q); V=blas.dgemm(V,Q)
        local off=0
        for i=1,n do for j=1,n do if i~=j then local v=Ak:get(i,j); off=off+v*v end end end
        if sqrt(off)<tol then break end
    end
    local vals=Vec.new(n); for i=1,n do vals._d:set(i,Ak:get(i,i)) end; return vals,V
end
mathx.pp = pp
mathx.progressivePrecision = pp
local smx = {}
function smx.hilbert(n)  return Mat.new(n,n):map_(function(_,i,j) return 1/(i+j-1) end) end
function smx.vandermonde(v)
    local n=v.n; local m=Mat.new(n,n)
    for i=1,n do for j=1,n do m:set(i,j, v._d:get(i)^(j-1)) end end; return m
end
function smx.companion(c)
    local n=#c-1; local m=Mat.new(n,n)
    for i=1,n-1 do m:set(i+1,i,1) end
    for i=1,n do m:set(i,n,-c[i]/c[n+1]) end; return m
end
function smx.toeplitz(row,col)
    col=col or row; local r=#row;local c=#col; local m=Mat.new(r,c)
    for i=1,r do for j=1,c do local d=j-i; m:set(i,j, d>=0 and row[d+1] or col[-d+1]) end end; return m
end
function smx.circulant(v)
    local n=#v; local m=Mat.new(n,n)
    for i=1,n do for j=1,n do m:set(i,j,v[((j-i)%n)+1]) end end; return m
end
function smx.hadamardMat(n)
    if n==1 then return Mat.fromTable({{1}}) end
    local H=smx.hadamardMat(math.floor(n/2)); local m=Mat.new(n,n)
    for i=1,math.floor(n/2) do for j=1,math.floor(n/2) do local v=H:get(i,j)
        m:set(i,j,v);m:set(i,j+math.floor(n/2),v);m:set(i+math.floor(n/2),j,v);m:set(i+math.floor(n/2),j+math.floor(n/2),-v) end end; return m
end
function smx.kron(A,B)
    local m=Mat.new(A.rows*B.rows, A.cols*B.cols)
    for i=1,A.rows do for j=1,A.cols do local a=A:get(i,j)
        for p=1,B.rows do for q=1,B.cols do
            m:set((i-1)*B.rows+p,(j-1)*B.cols+q, a*B:get(p,q)) end end end end; return m
end
function smx.blockDiag(mats)
    local tr,tc=0,0; for _,M in ipairs(mats) do tr=tr+M.rows;tc=tc+M.cols end
    local B=Mat.new(tr,tc); local roff,coff=0,0
    for _,M in ipairs(mats) do
        for i=1,M.rows do for j=1,M.cols do B:set(roff+i,coff+j,M:get(i,j)) end end
        roff=roff+M.rows;coff=coff+M.cols end; return B
end
function smx.laplacian(adj)
    local n=adj.rows; local D=Mat.new(n,n)
    for i=1,n do local deg=0; for j=1,n do deg=deg+adj:get(i,j) end; D:set(i,i,deg) end
    return D:sub(adj)
end
function smx.rotation2d(th)  return Mat.fromTable({{cos(th),-sin(th)},{sin(th),cos(th)}}) end
function smx.rotation3d(axis,th)
    local c,s=cos(th),sin(th)
    if axis=="x" then return Mat.fromTable({{1,0,0},{0,c,-s},{0,s,c}}) end
    if axis=="y" then return Mat.fromTable({{c,0,s},{0,1,0},{-s,0,c}}) end
    return Mat.fromTable({{c,-s,0},{s,c,0},{0,0,1}})
end
function smx.householder(v)
    local n=v.n; local vn=v:normalize(); local m=Mat.new(n,n)
    for i=1,n do for j=1,n do m:set(i,j,(i==j and 1 or 0)-2*vn._d:get(i)*vn._d:get(j)) end end; return m
end
function smx.givens(n,i,j,th)
    local G=Mat.identity(n); local c2,s2=cos(th),sin(th)
    G:set(i,i,c2);G:set(j,j,c2);G:set(i,j,-s2);G:set(j,i,s2); return G
end
function smx.pascal(n)
    local m=Mat.new(n,n)
    local function ch(nn,kk) if kk<0 or kk>nn then return 0 end
        local r=1; kk=math.min(kk,nn-kk); for ii=0,kk-1 do r=r*(nn-ii)/(ii+1) end; return floor(r+0.5) end
    for i=1,n do for j=1,n do m:set(i,j,ch(i+j-2,i-1)) end end; return m
end
function smx.tridiag(d,e,f)
    local n=#d; local m=Mat.new(n,n)
    for i=1,n do m:set(i,i,d[i]) end
    for i=1,n-1 do m:set(i+1,i,e[i]);m:set(i,i+1,f[i]) end; return m
end
function smx.stochastic(n)
    local m=Mat.new(n,n)
    for i=1,n do local row={};local s=0
        for j=1,n do row[j]=rand();s=s+row[j] end
        for j=1,n do m:set(i,j,row[j]/s) end end; return m
end
function smx.dftMatrix(n)
    local Wr,Wi=Mat.new(n,n),Mat.new(n,n)
    for i=1,n do for j=1,n do local ang=-2*pi*(i-1)*(j-1)/n
        Wr:set(i,j,cos(ang));Wi:set(i,j,sin(ang)) end end; return Wr,Wi
end
mathx.smx = smx
local calc = {}
function calc.diff(f,x,h)   h=h or 1e-7; return (f(x+h)-f(x-h))/(2*h) end
function calc.diff2(f,x,h)  h=h or 1e-5; return (f(x+h)-2*f(x)+f(x-h))/(h*h) end
function calc.diffN(f,x,n,h)
    if n==0 then return f(x) end; h=h or 1e-4
    return (calc.diffN(f,x+h,n-1,h/2)-calc.diffN(f,x-h,n-1,h/2))/(2*h)
end
function calc.partial(f,x,i,h)
    h=h or 1e-7; local xp=x:clone();xp._d:set(i,xp._d:get(i)+h)
    local xm=x:clone();xm._d:set(i,xm._d:get(i)-h); return (f(xp)-f(xm))/(2*h)
end
function calc.grad(f,x,h)
    h=h or 1e-7; local g=Vec.new(x.n)
    for i=1,x.n do g._d:set(i, calc.partial(f,x,i,h)) end; return g
end
function calc.jacobian(f,x,h)
    h=h or 1e-7; local fx=f(x); local J=Mat.new(fx.n,x.n)
    for j=1,x.n do
        local xp=x:clone();xp._d:set(j,xp._d:get(j)+h)
        local xm=x:clone();xm._d:set(j,xm._d:get(j)-h)
        local col=f(xp):sub(f(xm)):scale_(1/(2*h))
        for i=1,fx.n do J:set(i,j,col._d:get(i)) end end; return J
end
function calc.hessian(f,x,h)
    h=h or 1e-4; local n=x.n; local H=Mat.new(n,n)
    for i=1,n do for j=1,n do
        local pp2=x:clone();pp2._d:set(i,pp2._d:get(i)+h);pp2._d:set(j,pp2._d:get(j)+h)
        local pm=x:clone();pm._d:set(i,pm._d:get(i)+h);pm._d:set(j,pm._d:get(j)-h)
        local mp=x:clone();mp._d:set(i,mp._d:get(i)-h);mp._d:set(j,mp._d:get(j)+h)
        local mm=x:clone();mm._d:set(i,mm._d:get(i)-h);mm._d:set(j,mm._d:get(j)-h)
        H:set(i,j,(f(pp2)-f(pm)-f(mp)+f(mm))/(4*h*h)) end end; return H
end
local GL8={{-0.960289856,-0.796666477,-0.525532410,-0.183434642, 0.183434642, 0.525532410, 0.796666477, 0.960289856},
           { 0.101228536, 0.222381034, 0.313706646, 0.362683783, 0.362683783, 0.313706646, 0.222381034, 0.101228536}}
function calc.gaussLegendre(f,a,b)
    local mid,half=(a+b)/2,(b-a)/2; local s=0
    for i=1,8 do s=s+GL8[2][i]*f(mid+half*GL8[1][i]) end; return s*half
end
function calc.simpson(f,a,b,n)
    n=n or 1000; if n%2==1 then n=n+1 end; local h=(b-a)/n; local s=f(a)+f(b)
    for i=1,n-1 do s=s+(i%2==0 and 2 or 4)*f(a+i*h) end; return s*h/3
end
function calc.romberg(f, a, b, maxk)
    maxk = maxk or 12
    local R = {}
    for k = 1, maxk do
        local n2 = 2 ^ (k - 1)
        local h = (b - a) / n2
        local s = 0
        for i = 0, n2 do
            local weight
            if i == 0 or i == n2 then
                weight = 0.5
            else
                weight = 1
            end
            s = s + weight * f(a + i * h)
        end
        R[k] = { s * h }
        for j = 2, k do
            local p = 4 ^ (j - 1)
            R[k][j] = (p * R[k][j - 1] - R[k - 1][j - 1]) / (p - 1)
        end
        if k > 1 and math.abs(R[k][k] - R[k - 1][k - 1]) < EPS then
            return R[k][k]
        end
    end
    return R[maxk][maxk]
end
calc.quad = calc.gaussLegendre
function calc.rk4(f,t0,y0,tf,n)
    n=n or 1000; local h=(tf-t0)/n
    local function A(a,b2,s) return type(a)=="number" and a+b2*s or a:add(b2:scale(s)) end
    local t,y=t0,y0; local ts,ys={t0},{y0}
    for _=1,n do
        local k1=f(t,y); local k2=f(t+h/2,A(y,k1,h/2))
        local k3=f(t+h/2,A(y,k2,h/2)); local k4=f(t+h,A(y,k3,h))
        if type(y)=="number" then y=y+(k1+2*k2+2*k3+k4)*h/6
        else y=y:add(k1:add(k2:scale(2)):add(k3:scale(2)):add(k4):scale(h/6)) end
        t=t+h; ts[#ts+1]=t; ys[#ys+1]=y
    end; return ts,ys
end
function calc.euler(f,t0,y0,tf,n)
    n=n or 1000; local h=(tf-t0)/n; local t,y=t0,y0; local ts,ys={t0},{y0}
    for _=1,n do local dy=f(t,y)
        y=type(y)=="number" and y+h*dy or y:add(dy:scale(h))
        t=t+h; ts[#ts+1]=t; ys[#ys+1]=y end; return ts,ys
end
function calc.bisect(f,a,b,tol,maxI)
    tol=tol or EPS; maxI=maxI or 200
    for _=1,maxI do local c=(a+b)/2; local fc=f(c)
        if abs(fc)<tol or (b-a)/2<tol then return c,fc end
        if f(a)*fc<0 then b=c else a=c end end; return (a+b)/2
end
function calc.newton(f,df,x0,tol,maxI)
    tol=tol or EPS; maxI=maxI or 100; local x=x0
    for _=1,maxI do local fx=f(x); if abs(fx)<tol then return x,fx end
        x=x-(fx/(df and df(x) or calc.diff(f,x))) end; return x,f(x)
end
function calc.secant(f,x0,x1,tol,maxI)
    tol=tol or EPS; maxI=maxI or 100
    for _=1,maxI do local f0,f1=f(x0),f(x1); if abs(f1)<tol then return x1,f1 end
        local dx=f1*(x1-x0)/(f1-f0); x0,x1=x1,x1-dx; if abs(dx)<tol then return x1,f(x1) end end
    return x1,f(x1)
end
function calc.newtonVec(F,x0,tol,maxI)
    tol=tol or 1e-10; maxI=maxI or 100; local x=x0:clone()
    for _=1,maxI do local Fx=F(x); if Fx:norm2()<tol then return x end
        local J=calc.jacobian(F,x); local dx=la.solve(J,Fx:neg()); x:add_(dx)
        if dx:norm2()<tol then return x end end; return x
end
function calc.goldenSearch(f,a,b,tol)
    tol=tol or 1e-10; local gr=(sqrt(5)-1)/2
    local c=b-gr*(b-a); local d=a+gr*(b-a)
    while abs(b-a)>tol do
        if f(c)<f(d) then b=d else a=c end; c=b-gr*(b-a); d=a+gr*(b-a) end
    return (a+b)/2,f((a+b)/2)
end
function calc.gradDesc(f,x0,lr,maxI,tol)
    lr=lr or 0.01; maxI=maxI or 10000; tol=tol or 1e-8; local x=x0:clone()
    for _=1,maxI do local g=calc.grad(f,x); if g:norm2()<tol then break end; x:sub_(g:scale(lr)) end
    return x,f(x)
end
function calc.nelderMead(f,x0,maxI,tol)
    maxI=maxI or 5000; tol=tol or 1e-8; local n=x0.n
    local S={x0:clone()}
    for i=1,n do local xi=x0:clone(); xi._d:set(i,xi._d:get(i)+(abs(xi._d:get(i))<1e-10 and 0.00025 or 0.05)); S[i+1]=xi end
    for _=1,maxI do
        local vals={}; for i,p in ipairs(S) do vals[i]={f(p),i} end
        table.sort(vals,function(a2,b2) return a2[1]<b2[1] end)
        if vals[n+1][1]-vals[1][1]<tol then break end
        local cen=Vec.new(n); for i=1,n do cen:add_(S[vals[i][2]]) end; cen:scale_(1/n)
        local xw=S[vals[n+1][2]]; local xr=cen:add(cen:sub(xw)); local fr=f(xr)
        if fr<vals[1][1] then local xe=cen:add(cen:sub(xw):scale(2)); S[vals[n+1][2]]=f(xe)<fr and xe or xr
        elseif fr<vals[n][1] then S[vals[n+1][2]]=xr
        else local xc=cen:add(xw:sub(cen):scale(0.5))
            if f(xc)<vals[n+1][1] then S[vals[n+1][2]]=xc
            else local x1=S[vals[1][2]]
                for i=2,n+1 do S[vals[i][2]]=x1:add(S[vals[i][2]]:sub(x1):scale(0.5)) end end end
    end
    local vals={}; for i,p in ipairs(S) do vals[i]={f(p),i} end; table.sort(vals,function(a2,b2) return a2[1]<b2[1] end)
    local best=S[vals[1][2]]; return best,f(best)
end
local Poly={}; Poly.__index=Poly
function Poly.new(c) local self=setmetatable({c={}},Poly); for i,v in ipairs(c) do self.c[i]=v end; self.deg=#c-1; return self end
function Poly:eval(x)   local s=0;local xk=1; for _,v in ipairs(self.c) do s=s+v*xk;xk=xk*x end; return s end
function Poly:deriv()   if self.deg==0 then return Poly.new({0}) end; local nc={}; for i=2,self.deg+1 do nc[i-1]=(i-1)*self.c[i] end; return Poly.new(nc) end
function Poly:integ(C)  C=C or 0; local nc={C}; for i=1,self.deg+1 do nc[i+1]=self.c[i]/i end; return Poly.new(nc) end
function Poly:add(b)    local nc={}; for i=1,math.max(self.deg,b.deg)+1 do nc[i]=(self.c[i] or 0)+(b.c[i] or 0) end; return Poly.new(nc) end
function Poly:mul(b)    local nc={}; for i=1,self.deg+b.deg+2 do nc[i]=0 end
    for i=1,self.deg+1 do for j=1,b.deg+1 do nc[i+j-1]=nc[i+j-1]+self.c[i]*b.c[j] end end; return Poly.new(nc) end
function Poly:scale(s)  local nc={}; for i,v in ipairs(self.c) do nc[i]=v*s end; return Poly.new(nc) end
function Poly:integrate(a,b2) return self:integ():eval(b2)-self:integ():eval(a) end
function Poly:roots()
    if self.deg==0 then return {} end
    if self.deg==1 then return {-self.c[1]/self.c[2]} end
    local C=smx.companion(self.c); local vals=la.eig(C); local r={}
    for i=1,vals.n do r[i]=vals._d:get(i) end; return r
end
function Poly:__tostring()
    local parts={}; for i=self.deg+1,1,-1 do local cv=self.c[i]; local e=i-1
        if abs(cv)>1e-14 then
            if e==0 then parts[#parts+1]=fmt("%.6g",cv)
            elseif e==1 then parts[#parts+1]=fmt("%.6gx",cv)
            else parts[#parts+1]=fmt("%.6gx^%d",cv,e) end end end
    return #parts>0 and tcat(parts," + ") or "0"
end
calc.Poly=Poly; function calc.poly(t) return Poly.new(t) end
function calc.cubicSpline(xs,ys)
    local n=#xs-1; local h={}; for i=1,n do h[i]=xs[i+1]-xs[i] end
    local al={}; for i=2,n do al[i]=3/h[i]*(ys[i+1]-ys[i])-3/h[i-1]*(ys[i]-ys[i-1]) end
    local l,mu,z={1},{0},{0}
    for i=2,n do l[i]=2*(xs[i+1]-xs[i-1])-h[i-1]*mu[i-1]; mu[i]=h[i]/l[i]; z[i]=(al[i]-h[i-1]*z[i-1])/l[i] end
    l[n+1]=1; z[n+1]=0; local cn={[n+1]=0}; local b2,d={},{}
    for j=n,1,-1 do cn[j]=z[j]-mu[j]*(cn[j+1] or 0)
        b2[j]=(ys[j+1]-ys[j])/h[j]-h[j]*((cn[j+1] or 0)+2*cn[j])/3
        d[j]=((cn[j+1] or 0)-cn[j])/(3*h[j]) end
    return function(x) for i=1,n do if x<=xs[i+1] or i==n then
        local dx=x-xs[i]; return ys[i]+b2[i]*dx+cn[i]*dx^2+d[i]*dx^3 end end end
end
function calc.lagrange(xs,ys)
    return function(x) local s=0; local n2=#xs
        for i=1,n2 do local li=1
            for j=1,n2 do if j~=i then li=li*(x-xs[j])/(xs[i]-xs[j]) end end
            s=s+ys[i]*li end; return s end
end
mathx.calc = calc
local fft = {}
local Cx = {}; Cx.__index = Cx
function Cx.new(r,i) return setmetatable({r=r or 0,i=i or 0},Cx) end
function Cx:add(b)   return Cx.new(self.r+b.r,self.i+b.i) end
function Cx:sub(b)   return Cx.new(self.r-b.r,self.i-b.i) end
function Cx:mul(b)   return Cx.new(self.r*b.r-self.i*b.i, self.r*b.i+self.i*b.r) end
function Cx:scale(s) return Cx.new(self.r*s,self.i*s) end
function Cx:conj()   return Cx.new(self.r,-self.i) end
function Cx:mag()    return sqrt(self.r*self.r+self.i*self.i) end
function Cx:arg()    return math.atan(self.i,self.r) end
function Cx:mag2()   return self.r*self.r+self.i*self.i end
mathx.Cx = Cx
function mathx.cx(r,i) return Cx.new(r,i) end
local function np2(n) local p=1; while p<n do p=p*2 end; return p end
local function fftIP(a,inv)
    local n=#a; if n<=1 then return end
    local even,odd={},{}
    for i=1,n,2 do even[#even+1]=a[i]; odd[#odd+1]=a[i+1] end
    fftIP(even,inv); fftIP(odd,inv)
    local ang=2*pi/n*(inv and 1 or -1)
    local wr,wi,wnr,wni=1,0,cos(ang),sin(ang)
    for k=1,math.floor(n/2) do
        local er,ei,or2,oi=even[k].r,even[k].i,odd[k].r,odd[k].i
        local tr=wr*or2-wi*oi; local ti=wr*oi+wi*or2
        a[k]=Cx.new(er+tr,ei+ti); a[k+math.floor(n/2)]=Cx.new(er-tr,ei-ti)
        local nwr=wr*wnr-wi*wni; wi=wr*wni+wi*wnr; wr=nwr
    end
end
function fft.fft(xs)
    local n=np2(#xs); local a={}
    for i=1,n do a[i]=type(xs[i])=="number" and Cx.new(xs[i]) or (xs[i] or Cx.new(0)) end
    fftIP(a,false); return a
end
function fft.ifft(a)
    local n=#a; local b={}; for i=1,n do b[i]=a[i]:conj() end
    fftIP(b,false); for i=1,n do b[i]=b[i]:conj():scale(1/n) end; return b
end
function fft.rfft(xs)
    local f = fft.fft(xs);
    local r = {};
    local n = math.floor(#f / 2) + 1      for i = 1, n do
        r[i] = f[i]
    end;
    return r
end
function fft.mag(a)   local v=Vec.new(#a); for i=1,#a do v._d:set(i,a[i]:mag()) end; return v end
function fft.phase(a) local v=Vec.new(#a); for i=1,#a do v._d:set(i,a[i]:arg()) end; return v end
function fft.power(a) local v=Vec.new(#a); for i=1,#a do v._d:set(i,a[i]:mag2()) end; return v end
function fft.freq(n,sr) sr=sr or 1; local v=Vec.new(n); for i=1,n do v._d:set(i,(i-1)*sr/n) end; return v end
function fft.convolve(a,b)
    local n=np2(#a+#b-1); local fa,fb={},{}
    for i=1,n do fa[i]=Cx.new(a[i] or 0);fb[i]=Cx.new(b[i] or 0) end
    fftIP(fa,false); fftIP(fb,false)
    local fc={}; for i=1,n do fc[i]=fa[i]:mul(fb[i]) end
    fftIP(fc,true); for i=1,n do fc[i]=fc[i]:scale(1/n) end
    local r={}; for i=1,#a+#b-1 do r[i]=fc[i].r end; return r
end
function fft.xcorr(a,b) local bb={}; for i=#b,1,-1 do bb[#bb+1]=b[i] end; return fft.convolve(a,bb) end
function fft.autocorr(a) return fft.xcorr(a,a) end
function fft.window(kind,n)
    local w=Vec.new(n)
    for i=1,n do local t=(i-1)/(n-1)
        if kind=="hann"     then w._d:set(i,0.5-0.5*cos(2*pi*t))
        elseif kind=="hamming" then w._d:set(i,0.54-0.46*cos(2*pi*t))
        elseif kind=="blackman" then w._d:set(i,0.42-0.5*cos(2*pi*t)+0.08*cos(4*pi*t))
        elseif kind=="bartlett" then w._d:set(i,1-abs(2*t-1))
        else w._d:set(i,1) end end; return w
end
function fft.stft(xs,winSize,hop,winKind)
    winSize=winSize or 256; hop=hop or math.floor(winSize/4); winKind=winKind or "hann"
    local win=fft.window(winKind,winSize); local nF=floor((#xs-winSize)/hop)+1; local frames={}
    for fi=1,nF do local s=(fi-1)*hop; local seg={}
        for i=1,winSize do seg[i]=(xs[s+i] or 0)*win._d:get(i) end; frames[fi]=fft.rfft(seg) end
    return frames
end
function fft.dct(xs)
    local n=#xs; local r={}
    for k=0,n-1 do local s=0
        for i=0,n-1 do s=s+xs[i+1]*cos(pi*(i+0.5)*k/n) end
        r[k+1]=s*(k==0 and sqrt(1/n) or sqrt(2/n)) end; return r
end
function fft.idct(Xs)
    local n=#Xs; local r={}
    for i=0,n-1 do local s=0
        for k=0,n-1 do s=s+Xs[k+1]*(k==0 and sqrt(1/n) or sqrt(2/n))*cos(pi*(i+0.5)*k/n) end
        r[i+1]=s end; return r
end
function fft.fft2(M)
    local rows,cols=M.rows,M.cols; local Ar={}
    for i=1,rows do local row={}; for j=1,cols do row[j]=Cx.new(M:get(i,j)) end; Ar[i]=fft.fft(row) end
    local Wr,Wi=Mat.new(rows,cols),Mat.new(rows,cols)
    for j=1,cols do local col={}; for i=1,rows do col[i]=Ar[i][j] end
        local C=fft.fft(col)
        for i=1,rows do Wr:set(i,j,C[i].r);Wi:set(i,j,C[i].i) end end
    return Wr,Wi
end
mathx.fft = fft
local graph = {}
function graph.new(directed)
    local G={directed=directed or false,nodes={},edges={},adj={},_n=0}
    function G:addNode(id,data) if not self.nodes[id] then self.nodes[id]=data or {};self.adj[id]={};self._n=self._n+1 end; return self end
    function G:addEdge(u,v,w)
        w=w or 1; self:addNode(u);self:addNode(v); self.adj[u][v]=w
        self.edges[#self.edges+1]={u=u,v=v,w=w}
        if not self.directed then self.adj[v][u]=w end; return self
    end
    function G:neighbors(u) local r={}; for v,w in pairs(self.adj[u] or {}) do r[#r+1]={v=v,w=w} end; return r end
    function G:degree(u)    local d=0; for _ in pairs(self.adj[u] or {}) do d=d+1 end; return d end
    function G:nodeList()   local r={}; for id in pairs(self.nodes) do r[#r+1]=id end; return r end
    function G:hasEdge(u,v) return self.adj[u] and self.adj[u][v]~=nil end
    function G:weight(u,v)  return self.adj[u] and self.adj[u][v] end
    function G:bfs(src)
        local dist={};local parent={};local order={}
        for id in pairs(self.nodes) do dist[id]=huge end; dist[src]=0
        local q={src};local head=1
        while head<=#q do local u=q[head];head=head+1;order[#order+1]=u
            for v in pairs(self.adj[u] or {}) do if dist[v]==huge then
                dist[v]=dist[u]+1;parent[v]=u;q[#q+1]=v end end end
        return {dist=dist,parent=parent,order=order}
    end
    function G:dfs(src)
        local pre,post,parent,vis,onS,cycle={},{},{},{},{},false
        local function visit(u) vis[u]=true;onS[u]=true;pre[#pre+1]=u
            for v in pairs(self.adj[u] or {}) do
                if not vis[v] then parent[v]=u;visit(v)
                elseif onS[v] then cycle=true end end
            onS[u]=false;post[#post+1]=u end
        if src then visit(src)
        else for id in pairs(self.nodes) do if not vis[id] then visit(id) end end end
        return {pre=pre,post=post,parent=parent,cycle=cycle}
    end
    function G:dijkstra(src)
        local dist={};local parent={};local vis={}
        for id in pairs(self.nodes) do dist[id]=huge end; dist[src]=0
        local heap={{d=0,id=src}}
        local function hpush(item)
            heap[#heap+1]=item
            local i=#heap
            while i>1 do local p=math.floor(i/2)
                if heap[p].d<=heap[i].d then break end
                heap[i],heap[p]=heap[p],heap[i]; i=p end
        end
        local function hpop()
            local top=heap[1]; local n2=#heap; heap[1]=heap[n2]; heap[n2]=nil
            local i=1
            while true do local l=i*2;local r=i*2+1;local s=i
                if l<=n2-1 and heap[l].d<heap[s].d then s=l end
                if r<=n2-1 and heap[r] and heap[r].d<heap[s].d then s=r end
                if s==i then break end
                heap[i],heap[s]=heap[s],heap[i]; i=s end
            return top
        end
        while #heap>0 do
            local cur=hpop(); local u=cur.id
            if not vis[u] then vis[u]=true
                for v,w in pairs(self.adj[u] or {}) do local nd=dist[u]+w
                    if nd<dist[v] then dist[v]=nd;parent[v]=u;hpush({d=nd,id=v}) end end end end
        return dist,parent
    end
    function G:bellmanFord(src)
        local dist={};local parent={};for id in pairs(self.nodes) do dist[id]=huge end; dist[src]=0
        for _=1,self._n-1 do for _,e in ipairs(self.edges) do
            if dist[e.u]<huge and dist[e.u]+e.w<dist[e.v] then dist[e.v]=dist[e.u]+e.w;parent[e.v]=e.u end end end
        local neg=false; for _,e in ipairs(self.edges) do if dist[e.u]<huge and dist[e.u]+e.w<dist[e.v] then neg=true end end
        return dist,parent,neg
    end
    function G:floydWarshall()
        local ids=self:nodeList();local n=#ids;local idx={}; for i,id in ipairs(ids) do idx[id]=i end
        local d={}; for i=1,n do d[i]={};for j=1,n do d[i][j]=i==j and 0 or huge end end
        for _,e in ipairs(self.edges) do d[idx[e.u]][idx[e.v]]=math.min(d[idx[e.u]][idx[e.v]],e.w) end
        for k=1,n do for i=1,n do for j=1,n do
            if d[i][k]<huge and d[k][j]<huge and d[i][k]+d[k][j]<d[i][j] then d[i][j]=d[i][k]+d[k][j] end
        end end end; return d,ids
    end
    function G:kruskalMST()
        local uf={}; local function find(x) if uf[x]~=x then uf[x]=find(uf[x]) end; return uf[x] end
        local function union(a2,b2) uf[find(a2)]=find(b2) end
        for id in pairs(self.nodes) do uf[id]=id end
        local edges={}; for _,e in ipairs(self.edges) do edges[#edges+1]=e end
        table.sort(edges,function(a2,b2) return a2.w<b2.w end)
        local mst={};local total=0
        for _,e in ipairs(edges) do if find(e.u)~=find(e.v) then union(e.u,e.v);mst[#mst+1]=e;total=total+e.w end end
        return mst,total
    end
    function G:topoSort()
        local inDeg={}; for id in pairs(self.nodes) do inDeg[id]=0 end
        for _,e in ipairs(self.edges) do inDeg[e.v]=(inDeg[e.v] or 0)+1 end
        local q={}; for id,d in pairs(inDeg) do if d==0 then q[#q+1]=id end end
        local order={};local head=1
        while head<=#q do local u=q[head];head=head+1;order[#order+1]=u
            for v in pairs(self.adj[u] or {}) do inDeg[v]=inDeg[v]-1; if inDeg[v]==0 then q[#q+1]=v end end end
        if #order~=self._n then return nil,"cycle" end; return order
    end
    function G:scc()
        local idx_={};local low={};local onS={};local stk={};local sccs={};local ctr=0
        local function sc(v) idx_[v]=ctr;low[v]=ctr;ctr=ctr+1;stk[#stk+1]=v;onS[v]=true
            for w in pairs(self.adj[v] or {}) do
                if not idx_[w] then sc(w);low[v]=math.min(low[v],low[w])
                elseif onS[w] then low[v]=math.min(low[v],idx_[w]) end end
            if low[v]==idx_[v] then local comp={}; repeat local w=rem(stk);onS[w]=false;comp[#comp+1]=w until w==v; sccs[#sccs+1]=comp end
        end
        for id in pairs(self.nodes) do if not idx_[id] then sc(id) end end; return sccs
    end
    function G:astar(src,dst,heuristic)
        heuristic=heuristic or function() return 0 end
        local g={};local f={};local parent={}
        for id in pairs(self.nodes) do g[id]=huge;f[id]=huge end
        g[src]=0; f[src]=heuristic(src,dst)
        local open={{id=src,f=f[src]}}
        local function hpush(item)
            open[#open+1]=item; local i=#open
            while i>1 do local p=math.floor(i/2)
                if open[p].f<=open[i].f then break end
                open[i],open[p]=open[p],open[i]; i=p end
        end
        local function hpop()
            local top=open[1]; local n2=#open; open[1]=open[n2]; open[n2]=nil
            local i=1
            while true do local l=i*2;local r=i*2+1;local s=i
                if l<=n2-1 and open[l] and open[l].f<open[s].f then s=l end
                if r<=n2-1 and open[r] and open[r].f<open[s].f then s=r end
                if s==i then break end; open[i],open[s]=open[s],open[i]; i=s end
            return top
        end
        local closed={}
        while #open>0 do
            local cur=hpop(); local u=cur.id
            if u==dst then
                local path={}; local node=dst
                while node do path[#path+1]=node; node=parent[node] end
                local rev={}; for i=#path,1,-1 do rev[#rev+1]=path[i] end
                return rev,g[dst]
            end
            if not closed[u] then closed[u]=true
                for v,w in pairs(self.adj[u] or {}) do
                    local ng=g[u]+w
                    if ng<g[v] then g[v]=ng; f[v]=ng+heuristic(v,dst); parent[v]=u; hpush({id=v,f=f[v]}) end
                end
            end
        end; return nil,huge
    end
    function G:primMST(src2)
        src2=src2 or self:nodeList()[1]
        local inMST={};local key={};local parent2={}
        for id in pairs(self.nodes) do key[id]=huge end; key[src2]=0
        local mstEdges={};local totalW=0
        for _=1,self._n do
            local u=nil; for id in pairs(self.nodes) do
                if not inMST[id] and (u==nil or key[id]<key[u]) then u=id end end
            if not u then break end; inMST[u]=true
            if parent2[u] then mstEdges[#mstEdges+1]={u=parent2[u],v=u,w=key[u]};totalW=totalW+key[u] end
            for v,w in pairs(self.adj[u] or {}) do
                if not inMST[v] and w<key[v] then key[v]=w;parent2[v]=u end end
        end; return mstEdges,totalW
    end
    function G:isBipartite()
        local color={}; local queue={}
        for id in pairs(self.nodes) do
            if not color[id] then
                color[id]=1; queue[#queue+1]=id; local head=1
                while head<=#queue do local u=queue[head];head=head+1
                    for v in pairs(self.adj[u] or {}) do
                        if not color[v] then color[v]=3-color[u]; queue[#queue+1]=v
                        elseif color[v]==color[u] then return false end end end
            end end; return true,color
    end
    function G:shortestPath(src2,dst)
        local dist,parent2=self:dijkstra(src2)
        if dist[dst]==huge then return nil,huge end
        local path={}; local node=dst
        while node do path[#path+1]=node; node=parent2[node] end
        local rev={}; for i=#path,1,-1 do rev[#rev+1]=path[i] end
        return rev,dist[dst]
    end
    function G:density()
        local n=self._n; if n<2 then return 0 end
        local maxE=self.directed and n*(n-1) or n*(n-1)/2
        return #self.edges/maxE
    end
    function G:clustering(u)
        local nbrs={}; for v in pairs(self.adj[u] or {}) do nbrs[#nbrs+1]=v end
        local k=#nbrs; if k<2 then return 0 end
        local tri=0
        for i=1,k do for j=i+1,k do
            if self:hasEdge(nbrs[i],nbrs[j]) or self:hasEdge(nbrs[j],nbrs[i]) then tri=tri+1 end end end
        return 2*tri/(k*(k-1))
    end
    function G:pageRank(d,maxI,tol)
        d=d or 0.85;maxI=maxI or 100;tol=tol or 1e-8
        local ids=self:nodeList();local n=#ids;local pr={}
        for _,id in ipairs(ids) do pr[id]=1/n end
        for _=1,maxI do local np={};local diff=0
            for _,id in ipairs(ids) do np[id]=(1-d)/n end
            for _,e in ipairs(self.edges) do local deg=self:degree(e.u)
                if deg>0 then np[e.v]=np[e.v]+d*pr[e.u]/deg end end
            for _,id in ipairs(ids) do diff=diff+abs(np[id]-pr[id]);pr[id]=np[id] end
            if diff<tol then break end end; return pr
    end
    function G:toMatrix()
        local ids=self:nodeList();local n=#ids;local idx={}; for i,id in ipairs(ids) do idx[id]=i end
        local M=Mat.new(n,n)
        for u,nbrs in pairs(self.adj) do for v,w in pairs(nbrs) do M:set(idx[u],idx[v],w) end end
        return M,ids
    end
    return G
end
function graph.complete(n) local G=graph.new(false); for i=1,n do G:addNode(i) end; for i=1,n do for j=i+1,n do G:addEdge(i,j) end end; return G end
function graph.path(n)     local G=graph.new(false); for i=1,n do G:addNode(i) end; for i=1,n-1 do G:addEdge(i,i+1) end; return G end
function graph.cycle(n)    local G=graph.path(n); G:addEdge(n,1); return G end
function graph.grid(r,c)
    local G=graph.new(false); local function id(i,j) return (i-1)*c+j end
    for i=1,r do for j=1,c do G:addNode(id(i,j))
        if j<c then G:addEdge(id(i,j),id(i,j+1)) end
        if i<r then G:addEdge(id(i,j),id(i+1,j)) end end end; return G
end
mathx.graph = graph
local itg = {}
local function ch(n,k) if k<0 or k>n then return 0 end; if k==0 or k==n then return 1 end
    k=math.min(k,n-k); local r=1; for i=0,k-1 do r=r*(n-i)/(i+1) end; return floor(r+0.5) end
function itg.gcd(a,b)    local function g(x,y) return y==0 and x or g(y,x%y) end; return g(abs(floor(a)),abs(floor(b))) end
function itg.lcm(a,b)    return a/itg.gcd(a,b)*b end
function itg.isPrime(n)
    if n<2 then return false end; if n==2 or n==3 then return true end
    if n%2==0 or n%3==0 then return false end
    local i=5; while i*i<=n do if n%i==0 or n%(i+2)==0 then return false end; i=i+6 end; return true
end
function itg.primes(n)
    local s={}; for i=2,n do s[i]=true end
    for i=2,floor(sqrt(n)) do if s[i] then for j=i*i,n,i do s[j]=false end end end
    local r={}; for i=2,n do if s[i] then r[#r+1]=i end end; return r
end
function itg.factorize(n) local f={}; local d=2
    while d*d<=n do while n%d==0 do f[d]=(f[d] or 0)+1;n=floor(n/d) end; d=d+1 end
    if n>1 then f[n]=(f[n] or 0)+1 end; return f
end
function itg.divisors(n)
    local r={}; for i=1,floor(sqrt(n)) do if n%i==0 then r[#r+1]=i; if i~=n/i then r[#r+1]=n/i end end end
    table.sort(r); return r
end
function itg.euler_phi(n) local r=n; local tmp=n
    for p=2,floor(sqrt(tmp)) do if tmp%p==0 then r=r-r/p; while tmp%p==0 do tmp=floor(tmp/p) end end end
    if tmp>1 then r=r-r/tmp end; return r
end
function itg.modinv(a,m)
    local function eg(x,y) if y==0 then return x,1,0 end; local g,u,v=eg(y,x%y); return g,v,u-floor(x/y)*v end
    local g,x=eg(a%m,m); assert(g==1,"modinv: no inverse"); return (x%m+m)%m
end
function itg.modpow(base,e,mod)
    local r=1; base=base%mod
    while e>0 do if e%2==1 then r=(r*base)%mod end; e=floor(e/2);base=(base*base)%mod end; return r
end
function itg.crt(rs,ms)
    local M=1; for _,m in ipairs(ms) do M=M*m end; local x=0
    for i,r in ipairs(rs) do local Mi=M/ms[i]; x=x+r*Mi*itg.modinv(Mi,ms[i]) end; return x%M
end
function itg.millerRabin(n,k)
    k=k or 20; if n<2 then return false end; if n==2 or n==3 then return true end; if n%2==0 then return false end
    local d=n-1; local r2=0; while d%2==0 do d=floor(d/2);r2=r2+1 end
    for _=1,k do local a=2+rand(n-4); local x=itg.modpow(a,d,n)
        if x~=1 and x~=n-1 then local ok=false
            for _=1,r2-1 do x=(x*x)%n; if x==n-1 then ok=true;break end end
            if not ok then return false end end end; return true
end
function itg.nextPrime(n)  repeat n=n+1 until itg.millerRabin(n); return n end
function itg.fibonacci(n)  local a,b=0,1; for _=1,n do a,b=b,a+b end; return a end
function itg.lucas(n)      local a,b=2,1; for _=1,n do a,b=b,a+b end; return a end
function itg.catalan(n)    return ch(2*n,n)/(n+1) end
function itg.stirling2(n,k)
    if k==0 then return n==0 and 1 or 0 end; if k==n then return 1 end
    local s=0; for j=0,k do s=s+(j%2==0 and 1 or -1)*ch(k,j)*(k-j)^n end
    local fk=1; for i=1,k do fk=fk*i end; return s/fk
end
function itg.bernoulli(n)
    local B={[1]=1}
    for m=2,n+1 do local s=0; for k=1,m-1 do s=s+ch(m,k)*(B[k] or 0) end; B[m]=-s/m end
    return B[n+1] or 0
end
function itg.mobius(n)
    if n==1 then return 1 end; local tmp=n; local f={}
    for p=2,floor(sqrt(tmp)) do if tmp%p==0 then f[#f+1]=p
        if tmp%(p*p)==0 then return 0 end; while tmp%p==0 do tmp=floor(tmp/p) end end end
    if tmp>1 then f[#f+1]=tmp end; return #f%2==0 and 1 or -1
end
function itg.choose(n,k)  return ch(n,k) end
function itg.fact(n)      local r=1; for i=2,n do r=r*i end; return r end
function itg.continuedFraction(x,maxT)
    maxT=maxT or 20; local t={}
    for _=1,maxT do local a=floor(x);t[#t+1]=a;x=x-a; if abs(x)<EPS then break end; x=1/x end; return t
end
function itg.cfToRational(t)
    local p,q,pp,qq=t[1],1,1,0
    for i=2,#t do p,pp=t[i]*p+pp,p; q,qq=t[i]*q+qq,q end; return p,q
end
mathx.itg = itg
local ltx = {}
local GREEK2={["\\alpha"]="Î±",["\\beta"]="Î²",["\\gamma"]="Î³",["\\delta"]="Î´",
              ["\\epsilon"]="Îµ",["\\theta"]="Î¸",["\\lambda"]="Î»",["\\mu"]="Î¼",
              ["\\pi"]="pi",["\\sigma"]="Ïƒ",["\\phi"]="Ï†",["\\omega"]="Ï‰",
              ["\\infty"]="âˆž"}
local TRIG2={["\\sin"]="sin",["\\cos"]="cos",["\\tan"]="tan",["\\cot"]="cot",
             ["\\sec"]="sec",["\\csc"]="csc",["\\arcsin"]="arcsin",
             ["\\arccos"]="arccos",["\\arctan"]="arctan",
             ["\\sinh"]="sinh",["\\cosh"]="cosh",["\\tanh"]="tanh",
             ["\\exp"]="exp",["\\ln"]="ln",["\\log"]="log"}
local function ltxTok(src)
    local T={}; local i=1
    while i<=#src do local c=src:sub(i,i)
        if c:match("%s") then i=i+1
        elseif c=="\\" then local name=src:match("^%a+",i+1)
            if name then T[#T+1]={k="cmd",v="\\"..name};i=i+1+#name
            else T[#T+1]={k="sym",v=c};i=i+1 end
        elseif c:match("%d") then local num=src:match("^%d+%.?%d*",i)
            T[#T+1]={k="num",v=tonumber(num)};i=i+#num
        elseif c:match("[%a]") then T[#T+1]={k="var",v=c};i=i+1
        elseif c=="{" then T[#T+1]={k="lb"};i=i+1
        elseif c=="}" then T[#T+1]={k="rb"};i=i+1
        elseif c=="(" then T[#T+1]={k="lp"};i=i+1
        elseif c==")" then T[#T+1]={k="rp"};i=i+1
        elseif c=="[" then T[#T+1]={k="lbr"};i=i+1
        elseif c=="]" then T[#T+1]={k="rbr"};i=i+1
        elseif c:match("[%+%-%*/^_=!,|']") then T[#T+1]={k="op",v=c};i=i+1
        else T[#T+1]={k="unk",v=c};i=i+1 end
    end
    T[#T+1]={k="eof"}; return T
end
local function mkP(T)
    local pos=1
    local function pk()   return T[pos] end
    local function adv()  local t=T[pos];pos=pos+1;return t end
    local function eat(k) if T[pos].k==k then return adv() end end
    local pE
local function grp()
    if pk().k == "lb" then 
        adv()          local e = pE()
        if pk().k == "rb" then 
            adv()          end
        return e 
    end 
    return pE()
end
local function atom()
    local t = pk()
    if not t or t.k == "eof" then 
        return {k = "n", v = 0}
    end
    
    if t.k == "num" then 
        adv() 
        return {k = "n", v = t.v}
    end
    
    if t.k == "var" then 
        adv() 
        return {k = "x", v = t.v}
    end
    
    if t.k == "lb" then  
        adv()          local e = pE()
        if pk() and pk().k == "rb" then 
            adv()          end
        return e 
    end
    
    if t.k == "lp" then  
        adv()          local e = pE()
        if pk() and pk().k == "rp" then 
            adv()          end
        return e 
    end
    
    if t.k == "op" and t.v == "-" then 
        adv() 
        return {k = "u", v = "-", a = atom()}
    end
    
    if t.k == "op" and t.v == "+" then 
        adv() 
        return atom()
    end
    
    if t.k == "op" and t.v == "|" then 
        adv() 
        local e = pE()
        if pk() and pk().k == "op" and pk().v == "|" then 
            adv() 
        end
        return {k = "abs", a = e}
    end
    
    if t.k == "cmd" then
        adv() 
        local cmd = t.v
        
                if cmd == "\\frac" or cmd == "\\dfrac" then 
            local n2 = grp()
            local d = grp()
            return {k = "frac", n = n2, d = d}
        end
        
        if cmd == "\\sqrt" then 
            local deg = nil
            if pk() and pk().k == "lbr" then 
                adv()
                deg = pE()
                if pk() and pk().k == "rbr" then 
                    adv()
                end
            end
            return {k = "sqrt", a = grp(), deg = deg}
        end
        
        if TRIG2[cmd] then 
            local fn = TRIG2[cmd]
            local expn = nil
            if pk() and pk().k == "op" and pk().v == "^" then 
                adv()
                expn = grp()
            end
            local arg = grp()
            local call = {k = "call", fn = fn, a = arg}
            if expn then 
                return {k = "pow", b = call, e = expn}
            end 
            return call
        end
        
        if GREEK2[cmd] then
            if GREEK2[cmd] == "pi" then 
                return {k = "n", v = pi}
            end
            if GREEK2[cmd] == "âˆž" then 
                return {k = "n", v = huge}
            end
            return {k = "x", v = GREEK2[cmd]}
        end
        
                return {k = "x", v = cmd}
    end
    
    adv()      return {k = "n", v = 0}
end

local function postfix()
    local b = atom()
    while true do 
        local t2 = pk()
        if not t2 or t2.k == "eof" then 
            break 
        end
        if t2.k == "op" and t2.v == "^" then 
            adv()
            b = {k = "pow", b = b, e = atom()}
        elseif t2.k == "op" and t2.v == "!" then 
            adv()
            b = {k = "call", fn = "factorial", a = b}
        else
            break
        end
    end
    return b
end
local function impl()
    local a = postfix()
    while true do 
        local t2 = pk()
        if not t2 or t2.k == "eof" then 
            break 
        end
                if t2.k == "num" or t2.k == "var" or t2.k == "lb" or t2.k == "lp" or
           (t2.k == "cmd" and (TRIG2[t2.v] or GREEK2[t2.v] or t2.v == "\\frac" or 
            t2.v == "\\sqrt" or t2.v == "\\sum" or t2.v == "\\int" or 
            t2.v == "\\lim" or t2.v == "\\sin" or t2.v == "\\cos" or
            t2.v == "\\tan")) then
            a = {k = "mul", a = a, b = postfix()}
        else
            break
        end
    end
    return a
end
local function mulDiv()
    local a = impl()
    while true do 
        local t2 = pk()
        if not t2 or t2.k == "eof" then 
            break 
        end
        if t2.k == "op" and (t2.v == "*" or t2.v == "/") then 
            local op = adv().v
            a = op == "*" and {k = "mul", a = a, b = impl()} or {k = "div", a = a, b = impl()}
        elseif t2.k == "cmd" and (t2.v == "\\cdot" or t2.v == "\\times") then 
            adv()
            a = {k = "mul", a = a, b = impl()}
        else
            break
        end
    end
    return a
end
    local function addSub()
        local a=mulDiv()
        while pk().k=="op" and (pk().v=="+" or pk().v=="-") do
            local op=adv().v; a=op=="+" and {k="add",a=a,b=mulDiv()} or {k="sub",a=a,b=mulDiv()}
        end; return a
    end
    pE=function()
        local a=addSub()
        if pk().k=="op" and pk().v=="=" then adv();return {k="eq",a=a,b=addSub()} end; return a
    end
    return pE()
end
local FNMAP={sin=sin,cos=cos,tan=tan,cot=function(v) return 1/tan(v) end,
             sec=function(v) return 1/cos(v) end,csc=function(v) return 1/sin(v) end,
             arcsin=math.asin,arccos=math.acos,arctan=math.atan,
             sinh=math.sinh,cosh=math.cosh,tanh=math.tanh,
             exp=exp,ln=log,log=function(v) return log(v)/log(10) end,
             sqrt=sqrt,abs=abs,sign=function(v) return v>0 and 1 or v<0 and -1 or 0 end,
             floor=floor,ceil=ceil,
             factorial=function(v) local r=1;for i=2,floor(v) do r=r*i end;return r end}
local function evalN(node,env)
    if not node then return 0 end; local k=node.k
    if k=="n" then return node.v end
    if k=="x" then
        local v=env and env[node.v]
        if v then return v end
        if node.v=="pi" or node.v=="Ï€" then return pi end
        if node.v=="e" then return exp(1) end
        if node.v=="âˆž" then return huge end
        return 0
    end
    if k=="u"   then return node.v=="-" and -evalN(node.a,env) or evalN(node.a,env) end
    if k=="add" then return evalN(node.a,env)+evalN(node.b,env) end
    if k=="sub" then return evalN(node.a,env)-evalN(node.b,env) end
    if k=="mul" then return evalN(node.a,env)*evalN(node.b,env) end
    if k=="div" then return evalN(node.a,env)/evalN(node.b,env) end
    if k=="frac" then return evalN(node.n,env)/evalN(node.d,env) end
    if k=="pow" then return evalN(node.b,env)^evalN(node.e,env) end
    if k=="sqrt" then local a=evalN(node.a,env); return node.deg and a^(1/evalN(node.deg,env)) or sqrt(a) end
    if k=="abs"  then return abs(evalN(node.a,env)) end
    if k=="eq"   then return evalN(node.a,env)==evalN(node.b,env) and 1 or 0 end
    if k=="call" then local fn=FNMAP[node.fn]; return fn and fn(evalN(node.a,env)) or 0 end
    if k=="sum"  then local vn=node.var.v; local lo_=floor(evalN(node.lo,env)); local hi_=floor(evalN(node.hi,env)); local s=0
        for i=lo_,hi_ do local e2={}; if env then for kk,vv in pairs(env) do e2[kk]=vv end end; e2[vn]=i; s=s+evalN(node.body,e2) end; return s end
    if k=="int"  then
        local vn=node.var and node.var.v or "x"
        local lo_=node.lo and evalN(node.lo,env) or -huge; local hi_=node.hi and evalN(node.hi,env) or huge
        local f=function(x) local e2={}; if env then for kk,vv in pairs(env) do e2[kk]=vv end end; e2[vn]=x; return evalN(node.body,e2) end
        if lo_==-huge or hi_==huge then
            local s=0; local N=1000
            for i=1,N-1 do local x=math.tan(pi/2*(2*i/N-1)); local dt=pi/(N*cos(pi/2*(2*i/N-1))^2); s=s+f(x)*dt end; return s
        end; return calc.romberg(f,lo_,hi_)
    end
    if k=="lim"  then local vn=node.var.v; local to_=evalN(node.to,env); local h=1e-5
        local f=function(x) local e2={}; if env then for kk,vv in pairs(env) do e2[kk]=vv end end; e2[vn]=x; return evalN(node.body,e2) end
        return (f(to_+h)+f(to_-h))/2 end
    return 0
end
local function astToStr(n)
    if not n then return "0" end; local k=n.k
    if k=="n" then return n.v==huge and "\\infty" or tostring(n.v) end
    if k=="x" then return n.v end
    if k=="u" then return "-"..astToStr(n.a) end
    if k=="add" then return astToStr(n.a).." + "..astToStr(n.b) end
    if k=="sub" then return astToStr(n.a).." - "..astToStr(n.b) end
    if k=="mul" then return astToStr(n.a).." \\cdot "..astToStr(n.b) end
    if k=="div" or k=="frac" then return "\\frac{"..astToStr(n.a or n.n).."}{"..astToStr(n.b or n.d).."}" end
    if k=="pow" then return "{"..astToStr(n.b).."}^{"..astToStr(n.e).."}" end
    if k=="sqrt" then return n.deg and "\\sqrt["..astToStr(n.deg).."]{"..astToStr(n.a).."}" or "\\sqrt{"..astToStr(n.a).."}" end
    if k=="abs"  then return "\\left|"..astToStr(n.a).."\\right|" end
    if k=="call" then return "\\"..n.fn.."\\left("..astToStr(n.a).."\\right)" end
    if k=="sum"  then return "\\sum_{"..astToStr(n.var).."="..astToStr(n.lo).."}^{"..astToStr(n.hi).."}"..astToStr(n.body) end
    if k=="int"  then local lim=n.lo and "_{"..astToStr(n.lo).."}^{"..astToStr(n.hi).."}" or ""
        return "\\int"..lim..astToStr(n.body).."\\,d"..astToStr(n.var) end
    if k=="lim"  then return "\\lim_{"..astToStr(n.var).."\\to "..astToStr(n.to).."}"..astToStr(n.body) end
    return ""
end

local function simplify(n)
    if not n then return {k="n",v=0} end
    local k=n.k
    if k=="add" then
        local a,b=simplify(n.a),simplify(n.b)
        if a.k=="n" and a.v==0 then return b end
        if b.k=="n" and b.v==0 then return a end
        if a.k=="n" and b.k=="n" then return {k="n",v=a.v+b.v} end
        return {k="add",a=a,b=b}
    end
    if k=="sub" then
        local a,b=simplify(n.a),simplify(n.b)
        if b.k=="n" and b.v==0 then return a end
        if a.k=="n" and b.k=="n" then return {k="n",v=a.v-b.v} end
        if a.k=="n" and a.v==0 then return {k="u",v="-",a=b} end
        return {k="sub",a=a,b=b}
    end
    if k=="mul" then
        local a,b=simplify(n.a),simplify(n.b)
        if a.k=="n" and a.v==0 then return {k="n",v=0} end
        if b.k=="n" and b.v==0 then return {k="n",v=0} end
        if a.k=="n" and a.v==1 then return b end
        if b.k=="n" and b.v==1 then return a end
        if a.k=="n" and b.k=="n" then return {k="n",v=a.v*b.v} end
        return {k="mul",a=a,b=b}
    end
    if k=="div" or k=="frac" then
        local a,b=simplify(n.a or n.n),simplify(n.b or n.d)
        if a.k=="n" and a.v==0 then return {k="n",v=0} end
        if b.k=="n" and b.v==1 then return a end
        if a.k=="n" and b.k=="n" and b.v~=0 then return {k="n",v=a.v/b.v} end
        return {k=k,a=a,n=a,b=b,d=b}
    end
    if k=="pow" then
        local base,ex=simplify(n.b),simplify(n.e)
        if ex.k=="n" and ex.v==0 then return {k="n",v=1} end
        if ex.k=="n" and ex.v==1 then return base end
        if base.k=="n" and base.v==1 then return {k="n",v=1} end
        if base.k=="n" and ex.k=="n" then return {k="n",v=base.v^ex.v} end
        return {k="pow",b=base,e=ex}
    end
    if k=="u" then
        local a=simplify(n.a)
        if a.k=="n" then return {k="n",v=-a.v} end
        if a.k=="u" then return a.a end
        return {k="u",v="-",a=a}
    end
    if k=="sqrt" then
        local a=simplify(n.a)
        if a.k=="n" and a.v>=0 then return {k="n",v=math.sqrt(a.v)} end
        return {k="sqrt",a=a,deg=n.deg}
    end
    if k=="call" then return {k="call",fn=n.fn,a=simplify(n.a)} end
    return n
end
local function simplifyN(node,passes)
    passes=passes or 4
    for _=1,passes do node=simplify(node) end
    return node
end
local function sdiff(n,var)
    if not n then return {k="n",v=0} end; local k=n.k
    local function D(m) return sdiff(m,var) end
    local function N(v) return {k="n",v=v} end
    local function add(a,b) return {k="add",a=a,b=b} end
    local function sub(a,b) return {k="sub",a=a,b=b} end
    local function mul(a,b) return {k="mul",a=a,b=b} end
    local function div(a,b) return {k="div",a=a,b=b} end
    local function pow(a,b) return {k="pow",b=a,e=b} end
    local function neg(a)   return {k="u",v="-",a=a} end
    local function call(fn,a) return {k="call",fn=fn,a=a} end
    if k=="n"  then return N(0) end
    if k=="x"  then return N(n.v==var and 1 or 0) end
    if k=="u"  then return {k="u",v=n.v,a=D(n.a)} end
    if k=="add" then return add(D(n.a),D(n.b)) end
    if k=="sub" then return sub(D(n.a),D(n.b)) end
    if k=="mul" then return add(mul(D(n.a),n.b),mul(n.a,D(n.b))) end
    if k=="div" or k=="frac" then
        local f,g=n.a or n.n,n.b or n.d
        return div(sub(mul(D(f),g),mul(f,D(g))),pow(g,N(2))) end
    if k=="pow" then
        if n.e.k=="n" then local gv=n.e.v; return mul(mul(N(gv),pow(n.b,N(gv-1))),D(n.b)) end
        return mul(pow(n.b,n.e),add(mul(D(n.e),call("ln",n.b)),mul(n.e,div(D(n.b),n.b)))) end
    if k=="sqrt" then return div(D(n.a),mul(N(2),{k="sqrt",a=n.a})) end
    if k=="abs"  then return mul(call("sign",n.a),D(n.a)) end
    if k=="call" then local fn=n.fn; local f=n.a; local df=D(f)
        if fn=="sin" then return simplifyN(mul(call("cos",f),df)) end
        if fn=="cos" then return simplifyN(mul(neg(call("sin",f)),df)) end
        if fn=="tan" then return simplifyN(mul(div(N(1),pow(call("cos",f),N(2))),df)) end
        if fn=="exp" then return simplifyN(mul(call("exp",f),df)) end
        if fn=="ln"  then return simplifyN(mul(div(N(1),f),df)) end
        if fn=="sinh" then return simplifyN(mul(call("cosh",f),df)) end
        if fn=="cosh" then return simplifyN(mul(call("sinh",f),df)) end
        if fn=="arcsin" then return simplifyN(mul(div(N(1),{k="sqrt",a=sub(N(1),pow(f,N(2)))}),df)) end
        if fn=="arctan" then return simplifyN(mul(div(N(1),add(N(1),pow(f,N(2)))),df)) end
        if fn=="sqrt" then return simplifyN(mul(div(N(1),mul(N(2),call("sqrt",f))),df)) end
        return N(0) end
    return simplifyN(N(0))
end
function ltx.parse(src)   return mkP(ltxTok(src)) end
function ltx.eval(src,env) return evalN(ltx.parse(src),env) end
function ltx.toLatex(src)  return astToStr(ltx.parse(src)) end
function ltx.diff(src,var,ord)
    var=var or "x"; ord=ord or 1; local ast=ltx.parse(src)
    for _=1,ord do ast=simplifyN(sdiff(ast,var)) end
    return astToStr(ast), function(env) return evalN(ast,env) end
end
function ltx.diffEval(src,var,xval)
    var=var or "x"; local ast=sdiff(ltx.parse(src),var)
    return evalN(ast,{[var]=xval})
end
function ltx.integrate(src,var,a,b2)
    var=var or "x"; local ast=ltx.parse(src)
    local f=function(x) return evalN(ast,{[var]=x}) end
    if a and b2 then return calc.romberg(f,a,b2) end
    return "(antiderivative: use ltx.integrate(src,var,a,b))"
end
function ltx.simplify(src,env)
    local ok,v=pcall(ltx.eval,src,env or {}); return ok and tostring(v) or src
end
mathx.latex = ltx
mathx.ltx   = ltx
mathx.PI   = pi; mathx.E = exp(1); mathx.TAU = 2*pi; mathx.PHI = (1+sqrt(5))/2
mathx.EPS  = EPS; mathx.INF = huge
mathx.sqrt = sqrt; mathx.abs   = abs;   mathx.floor = floor; mathx.ceil = ceil
mathx.log  = log;  mathx.exp   = exp;   mathx.sin   = sin;   mathx.cos  = cos
mathx.tan  = tan
mathx.map    = function(t,f) local r={}; for i,v in ipairs(t) do r[i]=f(v,i) end; return r end
mathx.filter = function(t,f) local r={}; for _,v in ipairs(t) do if f(v) then r[#r+1]=v end end; return r end
mathx.reduce = function(t,f,init) local a=init; for _,v in ipairs(t) do a=f(a,v) end; return a end
mathx.sum    = function(t) local s=0; for _,v in ipairs(t) do s=s+v end; return s end
mathx.prod   = function(t) local s=1; for _,v in ipairs(t) do s=s*v end; return s end
mathx.mean   = function(t) return mathx.sum(t)/#t end
mathx.stc = {}
mathx.stc.count = function(t) return #t end
mathx.stc.sum = mathx.sum
mathx.stc.mean = mathx.mean
mathx.stc.sorted = function(t)
    local r = {}
    for i = 1, #t do r[i] = t[i] end
    table.sort(r)
    return r
end
mathx.stc.min = function(t)
    if #t == 0 then return 0 end
    local m = t[1]
    for i = 2, #t do local v = t[i]; if v < m then m = v end end
    return m
end
mathx.stc.max = function(t)
    if #t == 0 then return 0 end
    local m = t[1]
    for i = 2, #t do local v = t[i]; if v > m then m = v end end
    return m
end
mathx.stc.range = function(t)
    if #t == 0 then return 0 end
    return mathx.stc.max(t) - mathx.stc.min(t)
end
mathx.stc.percentile = function(t,p)
    local n = #t
    if n == 0 then return 0 end
    if p <= 0 then return mathx.stc.min(t) end
    if p >= 1 then return mathx.stc.max(t) end
    local a = mathx.stc.sorted(t)
    local idx = (n - 1) * p + 1
    local lo = floor(idx)
    local hi = ceil(idx)
    local loVal = a[lo]
    local hiVal = a[hi]
    if lo == hi or hi > n then return loVal end
    return loVal + (idx - lo) * (hiVal - loVal)
end
mathx.stc.q = mathx.stc.percentile
mathx.stc.q1 = function(t) return mathx.stc.percentile(t, 0.25) end
mathx.stc.q2 = function(t) return mathx.stc.percentile(t, 0.5) end
mathx.stc.q3 = function(t) return mathx.stc.percentile(t, 0.75) end
mathx.stc.median = function(t) return mathx.stc.q2(t) end
mathx.stc.iqr = function(t) return mathx.stc.q3(t) - mathx.stc.q1(t) end
mathx.stc.interquartileRange = mathx.stc.iqr
mathx.stc.quartileDeviation = function(t) return mathx.stc.iqr(t) / 2 end
mathx.stc.semiInterquartileRange = mathx.stc.quartileDeviation
mathx.stc.midhinge = function(t) return (mathx.stc.q1(t) + mathx.stc.q3(t)) / 2 end
mathx.stc.trimean = function(t) return (mathx.stc.q1(t) + 2 * mathx.stc.q2(t) + mathx.stc.q3(t)) / 4 end
mathx.stc.qd = function(t) return mathx.stc.quartileDeviation(t) end
mathx.stc.mode = function(t)
    local n = #t
    if n == 0 then return {} end
    local counts = {}
    local maxCount = 0
    for i = 1, n do
        local v = t[i]
        counts[v] = (counts[v] or 0) + 1
        if counts[v] > maxCount then maxCount = counts[v] end
    end
    local modes = {}
    for v,c in pairs(counts) do
        if c == maxCount then modes[#modes + 1] = v end
    end
    if #modes == 1 then return modes[1] end
    table.sort(modes)
    return modes
end
mathx.stc.variance = function(t, sample)
    local n = #t
    if n == 0 then return 0 end
    local mu = mathx.stc.mean(t)
    local s = 0
    for i = 1, n do
        local d = t[i] - mu
        s = s + d * d
    end
    if sample and n > 1 then
        return s / (n - 1)
    end
    return s / n
end
mathx.stc.std = function(t, sample) return sqrt(mathx.stc.variance(t, sample)) end
mathx.stc.stddev = mathx.stc.std
mathx.stc.skewness = function(t)
    local n = #t
    if n < 2 then return 0 end
    local mu = mathx.stc.mean(t)
    local sd = mathx.stc.std(t)
    if sd < EPS then return 0 end
    local s = 0
    for i = 1, n do
        local d = (t[i] - mu) / sd
        s = s + d * d * d
    end
    return s / n
end
mathx.stc.kurtosis = function(t, excess)
    local n = #t
    if n < 2 then return 0 end
    local mu = mathx.stc.mean(t)
    local sd = mathx.stc.std(t)
    if sd < EPS then return 0 end
    local s = 0
    for i = 1, n do
        local d = (t[i] - mu) / sd
        s = s + d * d * d * d
    end
    local result = s / n
    if excess then return result - 3 end
    return result
end
mathx.stc.histogram = function(t, bins)
    bins = bins or 10
    local n = #t
    if n == 0 then return {counts = {}, breaks = {}, bins = 0} end
    local minv = mathx.stc.min(t)
    local maxv = mathx.stc.max(t)
    if minv == maxv then
        return {counts = {n}, breaks = {minv, maxv}, bins = 1}
    end
    local counts = {}
    local breaks = {}
    local width = (maxv - minv) / bins
    for i = 0, bins do
        breaks[#breaks + 1] = minv + i * width
        counts[#counts + 1] = 0
    end
    for i = 1, n do
        local value = t[i]
        local index = floor((value - minv) / width) + 1
        if index < 1 then index = 1 end
        if index > bins then index = bins end
        counts[index] = counts[index] + 1
    end
    return {counts = counts, breaks = breaks, bins = bins, min = minv, max = maxv}
end
mathx.stc.covariance = function(a, b, sample)
    local n = #a
    if n == 0 or n ~= #b then return 0 end
    local ma = mathx.stc.mean(a)
    local mb = mathx.stc.mean(b)
    local s = 0
    for i = 1, n do
        s = s + (a[i] - ma) * (b[i] - mb)
    end
    if sample and n > 1 then
        return s / (n - 1)
    end
    return s / n
end
mathx.stc.correlation = function(a, b)
    local cov = mathx.stc.covariance(a, b, false)
    local sa = mathx.stc.std(a, false)
    local sb = mathx.stc.std(b, false)
    if sa < EPS or sb < EPS then return 0 end
    return cov / (sa * sb)
end
mathx.stc.zscore = function(t)
    local n = #t
    if n == 0 then return {} end
    local mu = mathx.stc.mean(t)
    local sd = mathx.stc.std(t)
    local z = {}
    for i = 1, n do
        if sd < EPS then
            z[i] = 0
        else
            z[i] = (t[i] - mu) / sd
        end
    end
    return z
end
mathx.stc.outliers = function(t, method, threshold)
    method = method or "iqr"
    if method == "zscore" then
        threshold = threshold or 3
        local z = mathx.stc.zscore(t)
        local indices = {}
        local values = {}
        for i = 1, #z do
            if abs(z[i]) > threshold then
                indices[#indices + 1] = i
                values[#values + 1] = t[i]
            end
        end
        return {method = method, threshold = threshold, indices = indices, values = values}
    end
    threshold = threshold or 1.5
    local q1 = mathx.stc.q1(t)
    local q3 = mathx.stc.q3(t)
    local iqr = q3 - q1
    local low = q1 - threshold * iqr
    local high = q3 + threshold * iqr
    local indices = {}
    local values = {}
    for i = 1, #t do
        if t[i] < low or t[i] > high then
            indices[#indices + 1] = i
            values[#values + 1] = t[i]
        end
    end
    return {method = method, threshold = threshold, lower = low, upper = high, indices = indices, values = values}
end
mathx.stc.linearRegression = function(x, y)
    local n = #x
    if n == 0 or n ~= #y then return {slope = 0, intercept = 0, r = 0, r2 = 0, covariance = 0, mean_x = 0, mean_y = 0} end
    local mean_x = mathx.stc.mean(x)
    local mean_y = mathx.stc.mean(y)
    local sxx = 0
    local syy = 0
    local sxy = 0
    for i = 1, n do
        local dx = x[i] - mean_x
        local dy = y[i] - mean_y
        sxx = sxx + dx * dx
        syy = syy + dy * dy
        sxy = sxy + dx * dy
    end
    local slope = sxx == 0 and 0 or sxy / sxx
    local intercept = mean_y - slope * mean_x
    local r = (sxx == 0 or syy == 0) and 0 or sxy / sqrt(sxx * syy)
    return {slope = slope, intercept = intercept, r = r, r2 = r * r, covariance = sxy / n, mean_x = mean_x, mean_y = mean_y}
end
mathx.stc.entropy = function(t, base)
    base = base or 2
    local n = #t
    if n == 0 then return 0 end
    local counts = {}
    for i = 1, n do
        counts[t[i]] = (counts[t[i]] or 0) + 1
    end
    local h = 0
    for _, count in pairs(counts) do
        local p = count / n
        h = h - p * (math.log(p) / math.log(base))
    end
    return h
end
mathx.stc._erf = function(x)
    local sign = x < 0 and -1 or 1
    x = abs(x)
    local t = 1 / (1 + 0.3275911 * x)
    local a1, a2, a3, a4, a5 = 0.254829592, -0.284496736, 1.421413741, -1.453152027, 1.061405429
    local y = 1 - (((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t) * exp(-x * x)
    return sign * y
end
mathx.stc._comb = function(n, k)
    if k < 0 or k > n then return 0 end
    k = k > n - k and n - k or k
    local num, den = 1, 1
    for i = 1, k do
        num = num * (n - k + i)
        den = den * i
    end
    return num / den
end
mathx.stc.normalPDF = function(x, mu, sigma)
    mu = mu or 0
    sigma = sigma or 1
    local z = (x - mu) / sigma
    return exp(-0.5 * z * z) / (sigma * sqrt(2 * pi))
end
mathx.stc.normalCDF = function(x, mu, sigma)
    mu = mu or 0
    sigma = sigma or 1
    return 0.5 * (1 + mathx.stc._erf((x - mu) / (sigma * sqrt(2))))
end
mathx.stc.uniformPDF = function(x, a, b)
    a = a or 0
    b = b or 1
    if b == a or x < a or x > b then return 0 end
    return 1 / (b - a)
end
mathx.stc.uniformCDF = function(x, a, b)
    a = a or 0
    b = b or 1
    if x < a then return 0 end
    if x > b then return 1 end
    return (x - a) / (b - a)
end
mathx.stc.binomialPDF = function(n, k, p)
    p = p or 0.5
    if k < 0 or k > n or p < 0 or p > 1 then return 0 end
    return mathx.stc._comb(n, k) * p ^ k * (1 - p) ^ (n - k)
end
mathx.stc.binomialCDF = function(n, k, p)
    local sum = 0
    for i = 0, k do
        sum = sum + mathx.stc.binomialPDF(n, i, p)
    end
    return sum
end
mathx.stc.sampleUniform = function(a, b)
    a = a or 0
    b = b or 1
    return a + rand() * (b - a)
end
mathx.stc.sampleNormal = function(mu, sigma)
    mu = mu or 0
    sigma = sigma or 1
    local u1 = rand()
    local u2 = rand()
    local r = sqrt(-2 * log(u1))
    local theta = 2 * pi * u2
    return mu + sigma * r * cos(theta)
end
mathx.stc.sampleBinomial = function(n, p)
    p = p or 0.5
    local count = 0
    for i = 1, n do
        if rand() < p then count = count + 1 end
    end
    return count
end
mathx.stc.normalizeMinMax = function(t, newMin, newMax)
    local n = #t
    if n == 0 then return {} end
    newMin = newMin or 0
    newMax = newMax or 1
    local minv = mathx.stc.min(t)
    local maxv = mathx.stc.max(t)
    local range = maxv - minv
    local out = {}
    for i = 1, n do
        if range == 0 then
            out[i] = newMin
        else
            out[i] = ((t[i] - minv) / range) * (newMax - newMin) + newMin
        end
    end
    return out
end
mathx.stc.normalizeZScore = function(t)
    local n = #t
    local out = {}
    if n == 0 then return out end
    local mu = mathx.stc.mean(t)
    local sd = mathx.stc.std(t)
    for i = 1, n do
        out[i] = sd < EPS and 0 or (t[i] - mu) / sd
    end
    return out
end
mathx.stc.normalizeRobust = function(t)
    local n = #t
    local out = {}
    if n == 0 then return out end
    local q1 = mathx.stc.q1(t)
    local q3 = mathx.stc.q3(t)
    local iqr = q3 - q1
    for i = 1, n do
        out[i] = iqr == 0 and 0 or (t[i] - q1) / iqr
    end
    return out
end
mathx.stc.groupBy = function(t, keyFn)
    keyFn = keyFn or function(value) return value end
    local groups = {}
    for i = 1, #t do
        local key = keyFn(t[i], i)
        groups[key] = groups[key] or {}
        groups[key][#groups[key] + 1] = t[i]
    end
    return groups
end
mathx.stc.groupStats = function(t, keyFn, aggFn)
    local groups = mathx.stc.groupBy(t, keyFn)
    aggFn = aggFn or mathx.stc.describe
    local stats = {}
    for key, values in pairs(groups) do
        stats[key] = aggFn(values, key)
    end
    return stats
end
mathx.stc._shuffle = function(t)
    local n = #t
    local out = {}
    for i = 1, n do out[i] = t[i] end
    for i = n, 2, -1 do
        local j = floor(rand() * i) + 1
        out[i], out[j] = out[j], out[i]
    end
    return out
end
mathx.stc.bootstrap = function(t, statFn, samples, sampleSize)
    statFn = statFn or mathx.stc.mean
    samples = samples or 1000
    sampleSize = sampleSize or #t
    local out = {}
    for s = 1, samples do
        local sample = {}
        for i = 1, sampleSize do
            sample[i] = t[floor(rand() * #t) + 1]
        end
        out[s] = statFn(sample)
    end
    return out
end
mathx.stc.permutationTest = function(a, b, statFn, samples)
    statFn = statFn or function(x, y) return mathx.stc.mean(x) - mathx.stc.mean(y) end
    samples = samples or 1000
    local combined = {}
    for i = 1, #a do combined[#combined + 1] = a[i] end
    for i = 1, #b do combined[#combined + 1] = b[i] end
    local observed = statFn(a, b)
    local count = 0
    for s = 1, samples do
        local perm = mathx.stc._shuffle(combined)
        local xa, xb = {}, {}
        for i = 1, #a do xa[i] = perm[i] end
        for i = 1, #b do xb[i] = perm[#a + i] end
        if abs(statFn(xa, xb)) >= abs(observed) then
            count = count + 1
        end
    end
    return count / samples
end
mathx.stc.trainTestSplit = function(t, testRatio, shuffle)
    testRatio = testRatio or 0.2
    if testRatio < 0 then testRatio = 0 end
    if testRatio > 1 then testRatio = 1 end
    local n = #t
    local idx = {}
    for i = 1, n do idx[i] = i end
    if shuffle == nil or shuffle then idx = mathx.stc._shuffle(idx) end
    local testCount = floor(n * testRatio)
    local train, test = {}, {}
    for i = 1, n do
        if i <= testCount then
            test[#test + 1] = t[idx[i]]
        else
            train[#train + 1] = t[idx[i]]
        end
    end
    return train, test
end
mathx.stc.crossValidationSplit = function(t, k, shuffle)
    k = k or 5
    if k < 2 then return {t} end
    local n = #t
    local idx = {}
    for i = 1, n do idx[i] = i end
    if shuffle == nil or shuffle then idx = mathx.stc._shuffle(idx) end
    local folds = {}
    local foldSize = floor(n / k)
    local remainder = n - foldSize * k
    local pos = 1
    for fold = 1, k do
        local size = foldSize + (fold <= remainder and 1 or 0)
        local group = {}
        for j = 1, size do
            group[#group + 1] = t[idx[pos]]
            pos = pos + 1
        end
        folds[#folds + 1] = group
    end
    return folds
end
mathx.stc.movingAverage = function(t, window)
    window = window or 3
    local n = #t
    local out = {}
    if n == 0 or window <= 1 then
        for i = 1, n do out[i] = t[i] end
        return out
    end
    local sum = 0
    for i = 1, n do
        sum = sum + t[i]
        if i > window then sum = sum - t[i - window] end
        out[i] = sum / math.min(i, window)
    end
    return out
end
mathx.stc.exponentialSmoothing = function(t, alpha)
    alpha = alpha or 0.3
    local n = #t
    local out = {}
    if n == 0 then return out end
    out[1] = t[1]
    for i = 2, n do
        out[i] = alpha * t[i] + (1 - alpha) * out[i - 1]
    end
    return out
end
mathx.stc.autocorrelation = function(t, lag)
    lag = lag or 1
    local n = #t
    if n == 0 or lag < 0 or lag >= n then return 0 end
    local mu = mathx.stc.mean(t)
    local num, denom = 0, 0
    for i = 1, n - lag do
        num = num + (t[i] - mu) * (t[i + lag] - mu)
    end
    for i = 1, n do
        denom = denom + (t[i] - mu) ^ 2
    end
    return denom < EPS and 0 or num / denom
end
mathx.stc.covarianceMatrix = function(mat, sample)
    if #mat == 0 then return {} end
    local rows = #mat
    local cols = #mat[1]
    local vars = {}
    for j = 1, cols do
        vars[j] = {}
        for i = 1, rows do
            vars[j][#vars[j] + 1] = mat[i][j] or 0
        end
    end
    local cov = {}
    for i = 1, cols do
        cov[i] = {}
        for j = 1, cols do
            cov[i][j] = mathx.stc.covariance(vars[i], vars[j], sample)
        end
    end
    return cov
end
mathx.stc.correlationMatrix = function(mat)
    local cov = mathx.stc.covarianceMatrix(mat, false)
    local cols = #cov
    local corr = {}
    for i = 1, cols do
        corr[i] = {}
        for j = 1, cols do
            local si = sqrt(cov[i][i] or 0)
            local sj = sqrt(cov[j][j] or 0)
            corr[i][j] = (si < EPS or sj < EPS) and 0 or cov[i][j] / (si * sj)
        end
    end
    return corr
end
mathx.stc.describe = function(t)
    local c = {
        count = #t,
        mean = mathx.stc.mean(t),
        range = mathx.stc.range(t),
        q1 = mathx.stc.q1(t),
        q2 = mathx.stc.q2(t),
        q3 = mathx.stc.q3(t),
        qd = mathx.stc.iqr(t),
        min = mathx.stc.min(t),
        max = mathx.stc.max(t),
        sorted = mathx.stc.sorted(t),
    }
    c.median = mathx.stc.median(t)
    c.mode = mathx.stc.mode(t)
    c.variance = mathx.stc.variance(t)
    c.std = mathx.stc.std(t)
    c.iqr = mathx.stc.iqr(t)
    c.skewness = mathx.stc.skewness(t)
    c.kurtosis = mathx.stc.kurtosis(t, true)
    c.histogram = mathx.stc.histogram(t, 5)
    return c
end
mathx.stc.table = mathx.stc.describe
mathx.linspace = function(a,b,n) n=n or 100; local r={}; for i=1,n do r[i]=a+(b-a)*(i-1)/(n-1) end; return r end
mathx.range    = function(a,b,step) step=step or 1; local r={}; for x=a,b,step do r[#r+1]=x end; return r end
local B = 1000000
local P = 6
local function trim(d)
    local n = #d
    while n > 0 and d[n] == 0 do d[n] = nil; n = n - 1 end
    return d
end
local function clone(d)
    local c = {}
    for i = 1, #d do c[i] = d[i] end
    return c
end
local function cmp(a,b)
    local na, nb = #a, #b
    if na < nb then return -1 elseif na > nb then return 1 end
    for i = na, 1, -1 do
        if a[i] < b[i] then return -1 elseif a[i] > b[i] then return 1 end
    end
    return 0
end
local function add(a,b)
    local o = {}
    local c = 0
    local n = #a > #b and #a or #b
    for i = 1, n do
        local s = (a[i] or 0) + (b[i] or 0) + c
        if s >= B then c = 1; s = s - B else c = 0 end
        o[i] = s
    end
    if c > 0 then o[#o + 1] = c end
    return o
end
local function sub(a,b)
    local o = {}
    local c = 0
    for i = 1, #a do
        local s = (a[i] or 0) - (b[i] or 0) - c
        if s < 0 then s = s + B; c = 1 else c = 0 end
        o[i] = s
    end
    return trim(o)
end
local function mul(a,b)
    if #a == 0 or #b == 0 then return {} end
    local o = {}
    for i = 1, #a + #b do o[i] = 0 end
    for i = 1, #a do
        local c = 0
        for j = 1, #b do
            local k = i + j - 1
            local t = o[k] + a[i] * b[j] + c
            c = floor(t / B)
            o[k] = t - c * B
        end
        o[i + #b] = o[i + #b] + c
    end
    return trim(o)
end
local function muls(a,s)
    if s == 0 or #a == 0 then return {} end
    local o = {}
    local c = 0
    for i = 1, #a do
        local t = a[i] * s + c
        c = floor(t / B)
        o[i] = t - c * B
    end
    if c > 0 then o[#o + 1] = c end
    return o
end
local function divmod(a,b)
    if #b == 0 then error("division by zero") end
    if cmp(a,b) < 0 then return {}, clone(a) end
    local nx, ny = #a, #b
    local q = {}
    local r = {}
    for i = nx, 1, -1 do
        if #r > 0 then
            table.insert(r, 1, 0)
        else
            r[1] = 0
        end
        r[1] = a[i]
        trim(r)
        if cmp(r,b) < 0 then
            q[i] = 0
        else
            local l = r[#r]
            local l1 = r[#r - 1] or 0
            local e = floor((l * B + l1) / b[#b])
            if e >= B then e = B - 1 end
            local p = muls(b, e)
            while cmp(r,p) < 0 do
                e = e - 1
                p = muls(b, e)
            end
            q[i] = e
            r = sub(r,p)
        end
    end
    local qq = {}
    for i = 1, #q do qq[i] = q[i] or 0 end
    return trim(qq), trim(r)
end
local BigInt = {}
BigInt.__index = BigInt
setmetatable(BigInt, { __call = function(_, v) return BigInt.new(v) end })
function BigInt._new(sign,digits)
    local self = setmetatable({sign = sign, digits = digits or {}}, BigInt)
    if #self.digits == 0 or sign == 0 then self.sign = 0; self.digits = {} end
    return self
end
function BigInt.fromNumber(value)
    value = floor(value or 0)
    if value == 0 then return BigInt._new(0,{}) end
    local sign = 1
    if value < 0 then sign = -1; value = -value end
    local d = {}
    while value > 0 do
        d[#d + 1] = value % B
        value = floor(value / B)
    end
    return BigInt._new(sign, d)
end
function BigInt.fromString(value)
    local s = tostring(value)
    local sign = 1
    if s:sub(1,1) == '-' then sign = -1; s = s:sub(2)
    elseif s:sub(1,1) == '+' then s = s:sub(2) end
    s = s:gsub('^0+', '')
    if s == '' then return BigInt._new(0,{}) end
    local d = {}
    for i = #s, 1, -P do
        local startIndex = i - P + 1
        if startIndex < 1 then startIndex = 1 end
        d[#d + 1] = tonumber(s:sub(startIndex, i))
    end
    return BigInt._new(sign, d)
end
function BigInt.new(value)
    if getmetatable(value) == BigInt then return value end
    if type(value) == 'number' then return BigInt.fromNumber(value) end
    return BigInt.fromString(value)
end
function BigInt:toString()
    if self.sign == 0 then return '0' end
    local parts = {}
    for i = #self.digits, 1, -1 do
        if i == #self.digits then
            parts[#parts + 1] = tostring(self.digits[i])
        else
            parts[#parts + 1] = fmt('%0' .. P .. 'd', self.digits[i])
        end
    end
    return (self.sign < 0 and '-' or '') .. table.concat(parts)
end
function BigInt:clone()
    return BigInt._new(self.sign, clone(self.digits))
end
function BigInt:__tostring()
    return self:toString()
end
function BigInt:__eq(other)
    other = BigInt.new(other)
    if self.sign ~= other.sign then return false end
    if #self.digits ~= #other.digits then return false end
    for i = 1, #self.digits do
        if self.digits[i] ~= other.digits[i] then return false end
    end
    return true
end
local function compare_bigints(a,b)
    if a.sign < b.sign then return -1 end
    if a.sign > b.sign then return 1 end
    if a.sign == 0 then return 0 end
    local c = cmp(a.digits, b.digits)
    return a.sign < 0 and -c or c
end
function BigInt:__lt(other)
    return compare_bigints(self, BigInt.new(other)) < 0
end
function BigInt:__le(other)
    return compare_bigints(self, BigInt.new(other)) <= 0
end
function BigInt:__unm()
    if self.sign == 0 then return self:clone() end
    local r = self:clone(); r.sign = -r.sign; return r
end
function BigInt:abs()
    if self.sign >= 0 then return self:clone() end
    local r = self:clone(); r.sign = 1; return r
end
function BigInt:compare(other)
    return compare_bigints(self, BigInt.new(other))
end
function BigInt:add(other)
    other = BigInt.new(other)
    if self.sign == 0 then return other:clone() end
    if other.sign == 0 then return self:clone() end
    if self.sign == other.sign then
        return BigInt._new(self.sign, add(self.digits, other.digits))
    end
    local c = cmp(self.digits, other.digits)
    if c == 0 then return BigInt._new(0,{}) end
    if c > 0 then
        return BigInt._new(self.sign, sub(self.digits, other.digits))
    end
    return BigInt._new(other.sign, sub(other.digits, self.digits))
end
function BigInt:sub(other)
    return self:add(BigInt.new(other):__unm())
end
function BigInt:mul(other)
    other = BigInt.new(other)
    if self.sign == 0 or other.sign == 0 then return BigInt._new(0,{}) end
    return BigInt._new(self.sign * other.sign, mul(self.digits, other.digits))
end
function BigInt:divmod(other)
    other = BigInt.new(other)
    if other.sign == 0 then error('division by zero') end
    if self.sign == 0 then return BigInt._new(0,{}), BigInt._new(0,{}) end
    local sign = self.sign * other.sign
    local q, r = divmod(self.digits, other:abs().digits)
    q = BigInt._new(sign, q)
    r = BigInt._new(self.sign == 0 and 0 or self.sign, r)
    return q, r
end
function BigInt:div(other)
    return self:divmod(other)
end
function BigInt:mod(other)
    local _, r = self:divmod(other)
    return r
end
function BigInt:pow(exp)
    exp = tonumber(exp)
    if not exp or exp < 0 or exp ~= floor(exp) then error('BigInt exponent must be a non-negative integer') end
    local result = BigInt._new(1,{1})
    local base = self:clone()
    while exp > 0 do
        if exp % 2 == 1 then result = result:mul(base) end
        exp = floor(exp / 2)
        if exp > 0 then base = base:mul(base) end
    end
    return result
end
function BigInt:toNumber()
    local value = 0
    for i = #self.digits, 1, -1 do
        value = value * B + self.digits[i]
    end
    return self.sign < 0 and -value or value
end
mathx.BigInt = BigInt
mathx.bigtint = BigInt
function mathx.eval(src,env)  return ltx.eval(src,env) end
function mathx.D(f,x,h)       return calc.diff(f,x,h) end
function mathx.I(f,a,b)       return calc.romberg(f,a,b) end
function mathx.solve(A,b)     return la.solve(A,b) end
function mathx.gemm(A,B)      return blas.dgemm(A,B) end
function mathx.strassen(A,B)  return blas.strassen(A,B) end
function mathx.winograd(A,B)  return blas.winograd(A,B) end
mathx._VERSION = "0x090402"
mathx._AUTHOR  = "nodecompact"
mathx._FEATURES = "TArray|Buffer|COW|InPlace|BLAS-L123|LAPACK|Strassen|Winograd|BlockedGEMM|FixedPoint|ProgressivePrecision|BigInt"

local function wrap_error(fn, name)
    return function(...)
        local res = { pcall(fn, ...) }
        if res[1] then
            table.remove(res, 1)
            return table.unpack(res)
        end
        local err = res[2]
        local msg = tostring(err)
        if type(err) == "table" and err.message then
            msg = tostring(err.message)
        end
        local trace = debug and debug.traceback and debug.traceback(nil, 2) or "(no traceback available)"
        error(("mathx.%s failed: %s\n%s"):format(name, msg, trace), 0)
    end
end

local function wrap_table(tbl, prefix, seen)
    if seen[tbl] then return end
    seen[tbl] = true
    for key, value in pairs(tbl) do
        if type(value) == "function" then
            tbl[key] = wrap_error(value, prefix .. "." .. tostring(key))
        elseif type(value) == "table" then
            wrap_table(value, prefix .. "." .. tostring(key), seen)
        end
    end
end

wrap_table(mathx, "mathx", {})

nc.mathx = mathx



return nc






