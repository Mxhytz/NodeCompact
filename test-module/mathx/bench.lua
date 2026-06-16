local function formatTime(ms)
    if ms < 0.001 then
        return string.format("%.2f ns", ms * 1e6)
    elseif ms < 1 then
        return string.format("%.2f us", ms * 1000)
    elseif ms < 1000 then
        return string.format("%.2f ms", ms)
    else
        return string.format("%.2f s", ms / 1000)
    end
end

local function run(name, fn, iter)
    iter = iter or 100
    local result
    local start = os.clock()
    for i = 1, iter do result = fn() end
    local elapsed = (os.clock() - start) * 1000
    local avg = elapsed / iter
    local ops = math.floor(iter / (elapsed / 1000))
    local resultStr = result == nil and "<no result>" or tostring(result)
    print(string.format("  %-40s %10s total  %9s avg  %8d ops/s  result=%s",
        name, formatTime(elapsed), formatTime(avg), ops, resultStr))
end


print("Mathx Benchmark")
print("eum actually ")



print(string.rep("━", 85))

run("Vec.new(100)", function() return mathx.Vec.new(100) end, 1000)
run("Vec.new(1000)", function() return mathx.Vec.new(1000) end, 500)
run("Vec.zeros(500)", function() return mathx.Vec.zeros(500) end, 500)
run("Vec.ones(500)", function() return mathx.Vec.ones(500) end, 500)
run("Vec.from(table)", function() return mathx.Vec.from(1,2,3,4,5,6,7,8,9,10) end, 1000)
run("Vec.fromTable", function() return mathx.Vec.fromTable({1,2,3,4,5}) end, 1000)
run("Vec.linspace", function() return mathx.Vec.linspace(0, 1, 100) end, 500)
run("Vec.rand(500)", function() return mathx.Vec.rand(500) end, 500)
run("Vec.randn(500)", function() return mathx.Vec.randn(500) end, 200)
run("Vec.basis(100,50)", function() return mathx.Vec.basis(100, 50) end, 500)
print("\n[2. TARRAY BENCHMARKS]")
print(string.rep("━", 85))
local taA = mathx.TArray.new(500)
local taB = mathx.TArray.new(500, 1)
run("TArray.new(500)", function() return mathx.TArray.new(500) end, 1000)
run("TArray.new(1000,1)", function() return mathx.TArray.new(1000, 1) end, 500)
run("TArray.fromTable(500)", function()
    local t = {}
    for i = 1, 500 do t[i] = i end
    return mathx.TArray.fromTable(t)
end, 200)
run("TArray:get (500 times)", function()
    local last
    for i = 1, 500 do last = taB:get(i) end
    return last
end, 1000)
run("TArray:set (500 times)", function()
    for i = 1, 500 do taA:set(i, i) end
    return taA:get(500)
end, 1000)
run("TArray:clone", function() return taB:clone() end, 500)
run("TArray:toTable", function() return taB:toTable() end, 500)
run("TArray:rawPair", function()
    local g,s = taA:rawPair()
    local last
    for i = 1, 500 do last = g(i) end
    s(500, 123)
    return last
end, 500)

print("\n[2. BIGINT]")
print(string.rep("━", 85))
local biA = mathx.BigInt("123456789012345678901234567890")
local biB = mathx.BigInt("987654321098765432109876543210")
run("BigInt.new(string)", function() return mathx.BigInt("123456789012345678901234567890") end, 200)
run("BigInt:add", function() return biA:add(biB) end, 500)
run("BigInt:mul", function() return biA:mul(biB) end, 100)
run("BigInt:pow(3)", function() return biA:pow(3) end, 50)
run("BigInt:toString", function() return biA:toString() end, 500)

print("\n[3. VECTOR ELEMENT ACCESS]")
print(string.rep("-", 85))

local v500 = mathx.Vec.rand(500)
run("Vec:get (500 times)", function()
    local last
    for i = 1, 500 do last = v500:get(i) end
    return last
end, 1000)
run("Vec:set (500 times)", function()
    for i = 1, 500 do v500:set(i, i) end
    return v500:get(500)
end, 1000)


print("\n[3. VECTOR ARITHMETIC - MUTABLE]")
print(string.rep("━", 85))

local vA = mathx.Vec.rand(500)
local vB = mathx.Vec.rand(500)
run("Vec:add_ (vector)", function() return vA:add_(vB) end, 1000)
run("Vec:add_ (scalar)", function() return vA:add_(2.5) end, 1000)
run("Vec:sub_ (vector)", function() return vA:sub_(vB) end, 1000)
run("Vec:sub_ (scalar)", function() return vA:sub_(2.5) end, 1000)
run("Vec:scale_", function() return vA:scale_(2.5) end, 1000)
run("Vec:neg_", function() return vA:neg_() end, 1000)
run("Vec:abs_", function() return vA:abs_() end, 500)
run("Vec:clamp_", function() return vA:clamp_(0.2, 0.8) end, 500)
run("Vec:normalize_", function() return vA:normalize_() end, 500)


print("\n[4. VECTOR ARITHMETIC - IMMUTABLE]")
print(string.rep("━", 85))

local vC = mathx.Vec.rand(500)
local vD = mathx.Vec.rand(500)
run("Vec:add (vector)", function() return vC:add(vD) end, 500)
run("Vec:add (scalar)", function() return vC:add(2.5) end, 500)
run("Vec:sub (vector)", function() return vC:sub(vD) end, 500)
run("Vec:sub (scalar)", function() return vC:sub(2.5) end, 500)
run("Vec:scale", function() return vC:scale(2.5) end, 500)
run("Vec:neg", function() return vC:neg() end, 500)
run("Vec:abs", function() return vC:abs() end, 500)
run("Vec:normalize", function() return vC:normalize() end, 500)


print("\n[5. VECTOR OPERATIONS]")
print(string.rep("━", 85))

local vE = mathx.Vec.rand(500)
local vF = mathx.Vec.rand(500)
run("Vec:dot (100)", function() 
    local a = mathx.Vec.rand(100)
    local b = mathx.Vec.rand(100)
    return a:dot(b)
end, 3000)
run("Vec:dot (500)", function() return vE:dot(vF) end, 2000)
run("Vec:hadamard", function() return vE:hadamard(vF) end, 500)
run("Vec:norm2", function() return vE:norm2() end, 2000)
run("Vec:norm (1)", function() return vE:norm(1) end, 1000)
run("Vec:norm (inf)", function() return vE:norm(math.huge) end, 1000)
run("Vec:sum", function() return vE:sum() end, 3000)
run("Vec:prod", function() return vE:prod() end, 200)
run("Vec:mean", function() return vE:mean() end, 2000)
run("Vec:var", function() return vE:var() end, 500)
run("Vec:std", function() return vE:std() end, 500)
run("Vec:min", function() return vE:min() end, 3000)
run("Vec:max", function() return vE:max() end, 3000)
run("Vec:argmin", function() return vE:argmin() end, 1000)
run("Vec:argmax", function() return vE:argmax() end, 1000)
run("Vec:dist", function() return vE:dist(vF) end, 1000)
run("Vec:angle", function() return vE:angle(vF) end, 500)


print("\n[6. VECTOR TRANSFORMATIONS]")
print(string.rep("━", 85))

local vG = mathx.Vec.rand(500)
run("Vec:map", function() return vG:map(function(x) return x * 2 end) end, 500)
run("Vec:map_", function() return vG:map_(function(x) return x * 2 end) end, 500)
run("Vec:cumsum", function() return vG:cumsum() end, 500)
run("Vec:softmax", function() return vG:softmax() end, 500)
run("Vec:sigmoid", function() return vG:sigmoid() end, 500)
run("Vec:relu", function() return vG:relu() end, 500)
run("Vec:relu_", function() return vG:relu_() end, 500)
run("Vec:zscore", function() return vG:zscore() end, 500)
run("Vec:project", function() return vG:project(vF) end, 500)
run("Vec:reject", function() return vG:reject(vF) end, 500)
run("Vec:lerp", function() return vG:lerp(vF, 0.5) end, 500)


print("\n[7. VECTOR STATISTICS & UTILITIES]")
print(string.rep("━", 85))

local vH = mathx.Vec.rand(500)
run("Vec:quantile(0.25)", function() return vH:quantile(0.25) end, 500)
run("Vec:quantile(0.5)", function() return vH:quantile(0.5) end, 500)
run("Vec:quantile(0.75)", function() return vH:quantile(0.75) end, 500)
run("Vec:median", function() return vH:median() end, 500)
run("Vec:iqr", function() return vH:iqr() end, 500)
run("Vec:cosineSim", function() return vH:cosineSim(vF) end, 500)
run("Vec:clone", function() return vH:clone() end, 1000)
run("Vec:slice(100,400)", function() return vH:slice(100, 400) end, 500)
run("Vec:concat", function() return vH:concat(vH) end, 500)
run("Vec:sort", function() return vH:sort() end, 200)
run("Vec:toTable", function() return vH:toTable() end, 1000)
run("Vec:toMat(25,20)", function() return vH:toMat(25, 20) end, 200)


print("\n[8. MATRIX CONSTRUCTORS]")
print(string.rep("━", 85))

run("Mat.new(32x32)", function() return mathx.Mat.new(32, 32) end, 500)
run("Mat.zeros(32,32)", function() return mathx.Mat.zeros(32, 32) end, 500)
run("Mat.ones(32,32)", function() return mathx.Mat.ones(32, 32) end, 500)
run("Mat.identity(32)", function() return mathx.Mat.identity(32) end, 500)
run("Mat.rand(32,32)", function() return mathx.Mat.rand(32, 32) end, 200)
run("Mat.randn(32,32)", function() return mathx.Mat.randn(32, 32) end, 100)
run("Mat.diag(32)", function() return mathx.Mat.diag(vH) end, 200)
run("Mat.fromTable(16x16)", function()
    local t = {}
    for i = 1, 16 do t[i] = {}
        for j = 1, 16 do t[i][j] = i*j end
    end
    return mathx.Mat.fromTable(t)
end, 100)
run("Mat.fromRows", function()
    local rows = {mathx.Vec.rand(10), mathx.Vec.rand(10), mathx.Vec.rand(10)}
    return mathx.Mat.fromRows(rows)
end, 200)
run("Mat.fromCols", function()
    local cols = {mathx.Vec.rand(10), mathx.Vec.rand(10), mathx.Vec.rand(10)}
    return mathx.Mat.fromCols(cols)
end, 200)


print("\n[9. MATRIX OPERATIONS]")
print(string.rep("━", 85))

local m16a = mathx.Mat.rand(16, 16)
local m16b = mathx.Mat.rand(16, 16)
run("Mat:add", function() return m16a:add(m16b) end, 500)
run("Mat:add_", function() return m16a:add_(m16b) end, 500)
run("Mat:sub", function() return m16a:sub(m16b) end, 500)
run("Mat:scale", function() return m16a:scale(2.5) end, 500)
run("Mat:neg", function() return m16a:neg() end, 500)
run("Mat:T (16x16)", function() return m16a:T() end, 500)
run("Mat:hadamard", function() return m16a:hadamard(m16b) end, 200)
run("Mat:clone", function() return m16a:clone() end, 500)


print("\n[10. MATRIX MULTIPLICATION]")
print(string.rep("━", 85))

local m4 = mathx.Mat.rand(4, 4)
local m8 = mathx.Mat.rand(8, 8)
local m16 = mathx.Mat.rand(16, 16)
local m32 = mathx.Mat.rand(32, 32)

run("Mat:mul (4x4)", function() return m4:mul(m4) end, 2000)
run("Mat:mul (8x8)", function() return m8:mul(m8) end, 1000)
run("Mat:mul (16x16)", function() return m16:mul(m16) end, 500)
run("Mat:mul (32x32)", function() return m32:mul(m32) end, 100)
run("Mat:pow (8x8, p=3)", function() return m8:pow(3) end, 500)


print("\n[11. MATRIX-VECTOR OPERATIONS]")
print(string.rep("━", 85))

local vM = mathx.Vec.rand(32)
local m32v = mathx.Mat.rand(32, 32)
run("Mat:mul (Vec 32)", function() return m32v:mul(vM) end, 1000)


print("\n[12. MATRIX PROPERTIES]")
print(string.rep("━", 85))

local m16c = mathx.Mat.rand(16, 16)
run("Mat:trace", function() return m16c:trace() end, 2000)
run("Mat:frobenius", function() return m16c:frobenius() end, 1000)
run("Mat:sum", function() return m16c:sum() end, 1000)
run("Mat:rowSums", function() return m16c:rowSums() end, 500)
run("Mat:colSums", function() return m16c:colSums() end, 500)
run("Mat:isSymmetric", function() return m16c:isSymmetric() end, 500)
run("Mat:isDiag", function() return m16c:isDiag() end, 500)
run("Mat:colNormalize", function() return m16c:colNormalize() end, 200)


print("\n[13. MATRIX ROW/COLUMN OPERATIONS]")
print(string.rep("━", 85))

local m16d = mathx.Mat.rand(16, 16)
local v16 = mathx.Vec.rand(16)
run("Mat:row", function() return m16d:row(8) end, 2000)
run("Mat:col", function() return m16d:col(8) end, 2000)
run("Mat:setRow", function() return m16d:setRow(8, v16) end, 1000)
run("Mat:setCol", function() return m16d:setCol(8, v16) end, 1000)
run("Mat:submat", function() return m16d:submat(4, 12, 4, 12) end, 1000)
run("Mat:reshape(32,8)", function() return m16d:reshape(32, 8) end, 500)
run("Mat:flatten", function() return m16d:flatten() end, 500)


print("\n[14. BLAS LEVEL 1]")
print(string.rep("━", 85))

local x = mathx.Vec.rand(500)
local y = mathx.Vec.rand(500)
run("blas.ddot", function() return mathx.blas.ddot(x, y) end, 5000)
run("blas.daxpy", function() return mathx.blas.daxpy(x, 2.5, y:clone()) end, 2000)
run("blas.dscal", function() return mathx.blas.dscal(x:clone(), 2.5) end, 2000)
run("blas.dnrm2", function() return mathx.blas.dnrm2(x) end, 5000)
run("blas.dasum", function() return mathx.blas.dasum(x) end, 5000)
run("blas.idamax", function() return mathx.blas.idamax(x) end, 5000)
run("blas.dcopy", function() return mathx.blas.dcopy(x) end, 2000)
run("blas.dswap", function() return mathx.blas.dswap(x:clone(), y:clone()) end, 2000)
run("blas.drot", function() return mathx.blas.drot(x:clone(), y:clone(), 0.5, 0.866) end, 1000)


print("\n[15. BLAS LEVEL 2]")
print(string.rep("━", 85))

local A20 = mathx.Mat.rand(20, 20)
local v20 = mathx.Vec.rand(20)
run("blas.dgemv", function() return mathx.blas.dgemv(A20, v20) end, 1000)
run("blas.dger", function() return mathx.blas.dger(A20:clone(), v20, v20) end, 500)
run("blas.dsymv", function() return mathx.blas.dsymv(A20, v20) end, 500)
run("blas.dtrsv", function()
    local L = mathx.lapack.dpotrf(A20:mul(A20:T()))
    return mathx.blas.dtrsv(L, v20, true, false)
end, 500)


print("\n[16. BLAS LEVEL 3]")
print(string.rep("━", 85))

local m16e = mathx.Mat.rand(16, 16)
run("blas.dgemm", function() return mathx.blas.dgemm(m16e, m16e) end, 200)
run("blas.dsyrk", function() return mathx.blas.dsyrk(m16e) end, 200)
run("blas.dtrsm", function()
    local L = mathx.lapack.dpotrf(m16e:mul(m16e:T()))
    return mathx.blas.dtrsm(L, m16e, true)
end, 200)
run("blas.strassen (16x16)", function()
    return mathx.blas.strassen(m16e, m16e)
end, 100)
run("blas.winograd (16x16)", function()
    return mathx.blas.winograd(m16e, m16e)
end, 100)


print("\n[17. LINEAR ALGEBRA - DECOMPOSITIONS]")
print(string.rep("━", 85))

local m12 = mathx.Mat.rand(12, 12)
local sym12 = m12:mul(m12:T())
run("lapack.dgetrf (LU)", function() return mathx.lapack.dgetrf(m12) end, 200)
run("lapack.dgeqrf (QR)", function() return mathx.lapack.dgeqrf(m12) end, 100)
run("lapack.dpotrf (Cholesky)", function() return mathx.lapack.dpotrf(sym12) end, 100)
run("lapack.dgesvd (SVD 12x12)", function() return mathx.lapack.dgesvd(m12) end, 50)
run("lapack.dsyev (Eigenvalues)", function() return mathx.lapack.dsyev(sym12, 20, 1e-6) end, 50)
run("lapack.hessenberg", function() return mathx.lapack.hessenberg(m12) end, 50)


print("\n[18. LINEAR ALGEBRA - SOLVERS]")
print(string.rep("━", 85))

local m10b = mathx.Mat.rand(10, 10)
local v10 = mathx.Vec.rand(10)
run("la.det", function() return mathx.la.det(m10b) end, 200)
run("la.inv", function() return mathx.lapack.inv(m10b) end, 100)
run("la.solve", function() return mathx.la.solve(m10b, v10) end, 200)
run("la.solveM", function() return mathx.la.solveM(m10b, m10b) end, 50)
run("la.pinv", function() return mathx.la.pinv(m10b) end, 50)
run("la.lstsq", function() return mathx.la.lstsq(m10b, v10) end, 100)
run("la.cond", function() return mathx.la.cond(m10b) end, 100)
run("la.rank", function() return mathx.la.rank(m10b) end, 100)
run("la.null", function() return mathx.la.null(m10b) end, 50)
run("la.norm (fro)", function() return mathx.la.norm(m10b, "fro") end, 500)
run("la.norm (1)", function() return mathx.la.norm(m10b, 1) end, 500)
run("la.norm (inf)", function() return mathx.la.norm(m10b, math.huge) end, 500)
run("la.gramSchmidt", function()
    local vs = {mathx.Vec.rand(10), mathx.Vec.rand(10), mathx.Vec.rand(10)}
    return mathx.la.gramSchmidt(vs)
end, 200)


print("\n[19. SPECIAL MATRICES]")
print(string.rep("━", 85))

run("smx.hilbert (30x30)", function() return mathx.smx.hilbert(30) end, 100)
run("smx.vandermonde (30x30)", function()
    local v = mathx.Vec.linspace(1, 30, 30)
    return mathx.smx.vandermonde(v)
end, 100)
run("smx.companion", function() return mathx.smx.companion({1, -3, 2}) end, 500)
run("smx.toeplitz (30x30)", function()
    local r = {}; for i=1,30 do r[i]=i end
    return mathx.smx.toeplitz(r, r)
end, 100)
run("smx.circulant (30)", function()
    local v = {}; for i=1,30 do v[i]=i end
    return mathx.smx.circulant(v)
end, 100)
run("smx.hadamardMat (32)", function() return mathx.smx.hadamardMat(32) end, 50)
run("smx.kron (8x8 -> 16x16)", function()
    local a = mathx.Mat.rand(8, 8)
    local b = mathx.Mat.rand(8, 8)
    return mathx.smx.kron(a, b)
end, 100)
run("smx.blockDiag", function()
    local mats = {mathx.Mat.rand(5,5), mathx.Mat.rand(5,5), mathx.Mat.rand(5,5)}
    return mathx.smx.blockDiag(mats)
end, 100)
run("smx.laplacian", function()
    local adj = mathx.Mat.rand(10, 10)
    adj = adj:mul(adj:T())
    return mathx.smx.laplacian(adj)
end, 100)
run("smx.rotation2d", function() return mathx.smx.rotation2d(math.pi/4) end, 5000)
run("smx.rotation3d (x)", function() return mathx.smx.rotation3d("x", math.pi/4) end, 5000)
run("smx.rotation3d (y)", function() return mathx.smx.rotation3d("y", math.pi/4) end, 5000)
run("smx.rotation3d (z)", function() return mathx.smx.rotation3d("z", math.pi/4) end, 5000)
run("smx.householder", function()
    local v = mathx.Vec.rand(10)
    return mathx.smx.householder(v)
end, 500)
run("smx.givens", function() return mathx.smx.givens(10, 3, 7, math.pi/4) end, 1000)
run("smx.pascal (20x20)", function() return mathx.smx.pascal(20) end, 100)
run("smx.tridiag", function()
    local d = {}; for i=1,20 do d[i]=i end
    local e = {}; for i=1,19 do e[i]=1 end
    return mathx.smx.tridiag(d, e, e)
end, 200)
run("smx.stochastic (20)", function() return mathx.smx.stochastic(20) end, 100)
run("smx.dftMatrix (16)", function() return mathx.smx.dftMatrix(16) end, 100)


print("\n[20. FFT OPERATIONS]")
print(string.rep("━", 85))

local sig64 = {}; for i=1,64 do sig64[i] = math.sin(2*math.pi*i/16) end
local sig128 = {}; for i=1,128 do sig128[i] = math.sin(2*math.pi*i/32) end
local sig256 = {}; for i=1,256 do sig256[i] = math.sin(2*math.pi*i/64) end

run("fft.fft (64)", function() return mathx.fft.fft(sig64) end, 200)
run("fft.fft (128)", function() return mathx.fft.fft(sig128) end, 100)
run("fft.fft (256)", function() return mathx.fft.fft(sig256) end, 50)
run("fft.ifft (128)", function()
    local f = mathx.fft.fft(sig128)
    return mathx.fft.ifft(f)
end, 50)
run("fft.rfft (128)", function() return mathx.fft.rfft(sig128) end, 100)
run("fft.dct (128)", function() return mathx.fft.dct(sig128) end, 100)
run("fft.idct (128)", function()
    local d = mathx.fft.dct(sig128)
    return mathx.fft.idct(d)
end, 100)
run("fft.convolve", function()
    local a = {}; local b = {}
    for i=1,64 do a[i]=math.sin(i*0.1); b[i]=math.cos(i*0.1) end
    return mathx.fft.convolve(a, b)
end, 100)
run("fft.xcorr", function()
    local a = {}; for i=1,64 do a[i]=math.sin(i*0.1) end
    return mathx.fft.xcorr(a, a)
end, 100)
run("fft.autocorr", function()
    local a = {}; for i=1,64 do a[i]=math.sin(i*0.1) end
    return mathx.fft.autocorr(a)
end, 100)
run("fft.mag", function()
    local f = mathx.fft.fft(sig128)
    return mathx.fft.mag(f)
end, 200)
run("fft.phase", function()
    local f = mathx.fft.fft(sig128)
    return mathx.fft.phase(f)
end, 200)
run("fft.power", function()
    local f = mathx.fft.fft(sig128)
    return mathx.fft.power(f)
end, 200)
run("fft.freq", function() return mathx.fft.freq(128) end, 2000)
run("fft.window (hann)", function() return mathx.fft.window("hann", 128) end, 500)
run("fft.window (hamming)", function() return mathx.fft.window("hamming", 128) end, 500)
run("fft.window (blackman)", function() return mathx.fft.window("blackman", 128) end, 500)
run("fft.window (bartlett)", function() return mathx.fft.window("bartlett", 128) end, 500)
run("fft.fft2 (16x16)", function()
    local m = mathx.Mat.rand(16, 16)
    return mathx.fft.fft2(m)
end, 50)


print("\n[21. NUMERICAL COMPUTING - DIFFERENTIATION]")
print(string.rep("━", 85))

local function fn(x) return x*x*x - 2*x*x + 3*x - 5 end
run("calc.diff", function() return mathx.calc.diff(fn, 2) end, 3000)
run("calc.diff2", function() return mathx.calc.diff2(fn, 2) end, 2000)
run("calc.diffN (n=3)", function() return mathx.calc.diffN(fn, 2, 3) end, 1000)
run("calc.partial", function()
    local f = function(v) return v:get(1)^2 + v:get(2)^2 end
    local x = mathx.Vec.from(2, 3)
    return mathx.calc.partial(f, x, 1)
end, 1000)
run("calc.grad", function()
    local f = function(v) return v:get(1)^2 + v:get(2)^2 end
    local x = mathx.Vec.from(2, 3)
    return mathx.calc.grad(f, x)
end, 500)
run("calc.jacobian", function()
    local f = function(v) return mathx.Vec.from(v:get(1)^2, v:get(2)^2) end
    local x = mathx.Vec.from(2, 3)
    return mathx.calc.jacobian(f, x)
end, 200)


print("\n[22. NUMERICAL COMPUTING - INTEGRATION]")
print(string.rep("━", 85))

local function integ1(x) return x*x end
local function integ2(x) return math.sin(x) end
local function integ3(x) return math.exp(-x*x) end

run("calc.simpson (x^2)", function() return mathx.calc.simpson(integ1, 0, 10, 200) end, 500)
run("calc.simpson (sin)", function() return mathx.calc.simpson(integ2, 0, math.pi, 200) end, 500)
run("calc.romberg (x^2)", function() return mathx.calc.romberg(integ1, 0, 10, 6) end, 500)
run("calc.romberg (sin)", function() return mathx.calc.romberg(integ2, 0, math.pi, 6) end, 500)
run("calc.gaussLegendre (sin)", function() return mathx.calc.gaussLegendre(integ2, 0, math.pi) end, 2000)


print("\n[23. NUMERICAL COMPUTING - ROOT FINDING]")
print(string.rep("━", 85))

local function f1(x) return x*x - 4 end
local function df1(x) return 2*x end
local function f2(x) return math.sin(x) - 0.5 end

run("calc.newton (with df)", function() return mathx.calc.newton(f1, df1, 5, 1e-10, 50) end, 2000)
run("calc.newton (auto-diff)", function() return mathx.calc.newton(f2, nil, 1, 1e-10, 50) end, 1000)
run("calc.bisect", function() return mathx.calc.bisect(f1, 0, 10, 1e-10, 100) end, 1000)
run("calc.secant", function() return mathx.calc.secant(f1, 0, 5, 1e-10, 50) end, 1000)


print("\n[24. OPTIMIZATION & ODE]")
print(string.rep("━", 85))

local function opt1(x) return (x-3)^2 + 2 end
run("calc.goldenSearch", function() return mathx.calc.goldenSearch(opt1, 0, 10, 1e-8) end, 1000)

local function ode(t,y) return -y end
run("calc.rk4 (500 steps)", function() return mathx.calc.rk4(ode, 0, 1, 10, 500) end, 200)
run("calc.euler (500 steps)", function() return mathx.calc.euler(ode, 0, 1, 10, 500) end, 200)


print("\n[25. INTERPOLATION]")
print(string.rep("━", 85))

local xs = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
local ys = {0, 1, 4, 9, 16, 25, 36, 49, 64, 81}
local spline = mathx.calc.cubicSpline(xs, ys)
local lagrange = mathx.calc.lagrange(xs, ys)

run("calc.cubicSpline (eval)", function() return spline(4.5) end, 5000)
run("calc.lagrange (eval)", function() return lagrange(4.5) end, 2000)


print("\n[26. POLYNOMIAL OPERATIONS]")
print(string.rep("━", 85))

local p1 = mathx.calc.poly({1, -3, 2, 0, -5})
local p2 = mathx.calc.poly({1, 0, -4})

run("Poly.new", function() return mathx.calc.poly({1, -3, 2}) end, 5000)
run("Poly:eval", function() return p1:eval(2.5) end, 5000)
run("Poly:deriv", function() return p1:deriv() end, 2000)
run("Poly:integ", function() return p1:integ() end, 2000)
run("Poly:add", function() return p1:add(p2) end, 2000)
run("Poly:mul", function() return p1:mul(p2) end, 1000)
run("Poly:scale", function() return p1:scale(2.5) end, 2000)
run("Poly:integrate", function() return p1:integrate(0, 5) end, 1000)


print("\n[27. FIXED POINT ARITHMETIC]")
print(string.rep("━", 85))

run("fp.fromFloat", function() return mathx.fp.fromFloat(3.14159) end, 10000)
run("fp.toFloat", function() return mathx.fp.toFloat(205887) end, 10000)
run("fp.mul", function() return mathx.fp.mul(65536, 131072) end, 10000)
run("fp.div", function() return mathx.fp.div(65536, 2) end, 10000)
run("fp.addSat", function() return mathx.fp.addSat(65535, 1) end, 10000)
run("fp.mulSat", function() return mathx.fp.mulSat(65536, 65536) end, 10000)
run("fp.Vec", function() return mathx.fp.Vec({1.5, 2.5, 3.5}) end, 5000)


print("\n[28. GRAPH ALGORITHMS]")
print(string.rep("━", 85))

local g20 = mathx.graph.new(false)
for i=1,20 do g20:addNode(i) end
for i=1,19 do g20:addEdge(i, i+1) end
for i=1,10 do g20:addEdge(i, i+10) end

run("graph:addNode", function() return g20:addNode(99) end, 5000)
run("graph:addEdge", function() return g20:addEdge(1, 99) end, 5000)
run("graph:bfs", function() return g20:bfs(1) end, 1000)
run("graph:dfs", function() return g20:dfs(1) end, 1000)
run("graph:dijkstra", function() return g20:dijkstra(1) end, 1000)
run("graph:degree", function() return g20:degree(1) end, 5000)
run("graph:neighbors", function() return g20:neighbors(1) end, 5000)
run("graph:hasEdge", function() return g20:hasEdge(1, 2) end, 10000)
run("graph:weight", function() return g20:weight(1, 2) end, 10000)
run("graph:nodeList", function() return g20:nodeList() end, 5000)
run("graph:pageRank", function() return g20:pageRank(0.85, 10, 1e-6) end, 200)
run("graph:isBipartite", function() return g20:isBipartite() end, 500)
run("graph:density", function() return g20:density() end, 5000)
run("graph:clustering", function() return g20:clustering(1) end, 1000)


print("\n[29. GRAPH FACTORY FUNCTIONS]")
print(string.rep("━", 85))

run("graph.complete (20)", function() return mathx.graph.complete(20) end, 100)
run("graph.path (20)", function() return mathx.graph.path(20) end, 200)
run("graph.cycle (20)", function() return mathx.graph.cycle(20) end, 200)
run("graph.grid (5x5)", function() return mathx.graph.grid(5, 5) end, 100)



print("\n[30. LATEX PARSING]")
print(string.rep("━", 85))

local latex_exprs = {
    "x^2 + 2x + 1",
    "\\frac{a}{b}",
    "\\sqrt{x^2 + y^2}",
    "\\int_0^1 x^2 dx",
    "\\sum_{i=1}^{n} i^2",
    "\\sin(\\theta) + \\cos(\\theta)",
    "\\lim_{x \\to 0} \\frac{\\sin x}{x}"
}

run("ltx.parse (simple)", function() 
    return mathx.ltx.parse("x^2 + 2x + 1") 
end, 1000)

run("ltx.parse (fraction)", function() 
    return mathx.ltx.parse("\\frac{a}{b}") 
end, 1000)

run("ltx.parse (sqrt)", function() 
    return mathx.ltx.parse("\\sqrt{x^2 + y^2}") 
end, 500)

run("ltx.parse (integral)", function() 
    return mathx.ltx.parse("\\int_0^1 x^2 dx") 
end, 500)

run("ltx.parse (sum)", function() 
    return mathx.ltx.parse("\\sum_{i=1}^{n} i^2") 
end, 500)

run("ltx.eval (quadratic at x=2)", function() 
    return mathx.ltx.eval("x^2 + 2x + 1", {x = 2}) 
end, 2000)

run("ltx.eval (fraction)", function() 
    return mathx.ltx.eval("\\frac{a}{b}", {a = 10, b = 2}) 
end, 2000)

run("ltx.toLatex", function() 
    return mathx.ltx.toLatex("(a+b)^2") 
end, 2000)

run("ltx.simplify", function() 
    return mathx.ltx.simplify("2*x + 3*x") 
end, 1000)

run("ltx.diff (derivative)", function() 
    return mathx.ltx.diff("x^2 + 2x + 1", "x", 1) 
end, 500)

run("ltx.diffEval", function() 
    return mathx.ltx.diffEval("x^2 + 2x + 1", "x", 2) 
end, 1000)

run("ltx.integrate", function() 
    return mathx.ltx.integrate("x^2", "x", 0, 1) 
end, 100)
print("\n[31. INTEGER MATH]")
print(string.rep("━", 85))

run("itg.gcd", function() return mathx.itg.gcd(123456, 789012) end, 10000)
run("itg.lcm", function() return mathx.itg.lcm(123, 456) end, 10000)
run("itg.isPrime (1013)", function() return mathx.itg.isPrime(1013) end, 5000)
run("itg.primes (100)", function() return mathx.itg.primes(100) end, 500)
run("itg.factorize (123456)", function() return mathx.itg.factorize(123456) end, 1000)
run("itg.divisors (100)", function() return mathx.itg.divisors(100) end, 1000)
run("itg.euler_phi (1000)", function() return mathx.itg.euler_phi(1000) end, 1000)
run("itg.modinv", function() return mathx.itg.modinv(17, 100) end, 5000)
run("itg.modpow", function() return mathx.itg.modpow(7, 13, 100) end, 10000)
run("itg.crt", function() return mathx.itg.crt({2,3,2}, {3,5,7}) end, 1000)
run("itg.millerRabin (1013)", function() return mathx.itg.millerRabin(1013) end, 2000)
run("itg.nextPrime (1000)", function() return mathx.itg.nextPrime(1000) end, 500)
run("itg.fibonacci (30)", function() return mathx.itg.fibonacci(30) end, 10000)
run("itg.lucas (20)", function() return mathx.itg.lucas(20) end, 10000)
run("itg.catalan (10)", function() return mathx.itg.catalan(10) end, 5000)
run("itg.stirling2 (10,5)", function() return mathx.itg.stirling2(10, 5) end, 2000)
run("itg.bernoulli (10)", function() return mathx.itg.bernoulli(10) end, 500)
run("itg.mobius (100)", function() return mathx.itg.mobius(100) end, 5000)
run("itg.choose (20,10)", function() return mathx.itg.choose(20, 10) end, 10000)
run("itg.fact (10)", function() return mathx.itg.fact(10) end, 10000)
run("itg.continuedFraction (pi)", function() return mathx.itg.continuedFraction(math.pi) end, 2000)


print("\n[32. UTILITY FUNCTIONS]")
print(string.rep("━", 85))

local t = {1,2,3,4,5,6,7,8,9,10}
run("mathx.map", function() return mathx.map(t, function(x) return x*2 end) end, 10000)
run("mathx.filter", function() return mathx.filter(t, function(x) return x%2==0 end) end, 10000)
run("mathx.reduce (sum)", function() return mathx.reduce(t, function(a,b) return a+b end, 0) end, 10000)
run("mathx.sum", function() return mathx.sum(t) end, 20000)
run("mathx.prod", function() return mathx.prod(t) end, 10000)
run("mathx.mean", function() return mathx.mean(t) end, 10000)
run("mathx.stc.mean", function() return mathx.stc.mean(t) end, 10000)
run("mathx.stc.range", function() return mathx.stc.range(t) end, 10000)
run("mathx.stc.q1", function() return mathx.stc.q1(t) end, 10000)
run("mathx.stc.q2", function() return mathx.stc.q2(t) end, 10000)
run("mathx.stc.q3", function() return mathx.stc.q3(t) end, 10000)
run("mathx.stc.qd", function() return mathx.stc.qd(t) end, 10000)
run("mathx.stc.iqr", function() return mathx.stc.iqr(t) end, 10000)
run("mathx.stc.interquartileRange", function() return mathx.stc.interquartileRange(t) end, 10000)
run("mathx.stc.quartileDeviation", function() return mathx.stc.quartileDeviation(t) end, 10000)
run("mathx.stc.semiInterquartileRange", function() return mathx.stc.semiInterquartileRange(t) end, 10000)
run("mathx.stc.midhinge", function() return mathx.stc.midhinge(t) end, 10000)
run("mathx.stc.trimean", function() return mathx.stc.trimean(t) end, 10000)
run("mathx.stc.median", function() return mathx.stc.median(t) end, 10000)
run("mathx.stc.mode", function() return mathx.stc.mode(t) end, 10000)
run("mathx.stc.variance", function() return mathx.stc.variance(t) end, 10000)
run("mathx.stc.std", function() return mathx.stc.std(t) end, 10000)
run("mathx.stc.skewness", function() return mathx.stc.skewness(t) end, 10000)
run("mathx.stc.kurtosis", function() return mathx.stc.kurtosis(t, true) end, 10000)
run("mathx.stc.histogram", function() return mathx.stc.histogram(t, 5) end, 5000)
local u = {2,4,6,8,10,12,14,16,18,20}
run("mathx.stc.correlation", function() return mathx.stc.correlation(t, u) end, 10000)
run("mathx.stc.zscore", function() return mathx.stc.zscore(t) end, 10000)
run("mathx.stc.outliers", function() return mathx.stc.outliers(t, "iqr", 1.5) end, 10000)
run("mathx.stc.outliers (zscore)", function() return mathx.stc.outliers(t, "zscore", 3) end, 10000)
run("mathx.stc.linearRegression", function() return mathx.stc.linearRegression(t, u) end, 10000)
run("mathx.stc.entropy", function() return mathx.stc.entropy(t, 2) end, 10000)
run("mathx.stc.normalizeMinMax", function() return mathx.stc.normalizeMinMax(t, 0, 1) end, 10000)
run("mathx.stc.normalizeZScore", function() return mathx.stc.normalizeZScore(t) end, 10000)
run("mathx.stc.normalizeRobust", function() return mathx.stc.normalizeRobust(t) end, 10000)
run("mathx.stc.groupBy", function() return mathx.stc.groupBy(t, function(v) return v % 2 end) end, 10000)
run("mathx.stc.bootstrap", function() return mathx.stc.bootstrap(t, mathx.stc.mean, 50, 5) end, 2000)
run("mathx.stc.permutationTest", function() return mathx.stc.permutationTest(t, u, nil, 50) end, 2000)
run("mathx.stc.groupStats", function() return mathx.stc.groupStats(t, function(v) return v % 2 end) end, 5000)
run("mathx.stc.trainTestSplit", function() return mathx.stc.trainTestSplit(t, 0.3, false) end, 5000)
run("mathx.stc.crossValidationSplit", function() return mathx.stc.crossValidationSplit(t, 3, false) end, 5000)
run("mathx.stc.normalPDF", function() return mathx.stc.normalPDF(0, 0, 1) end, 10000)
run("mathx.stc.normalCDF", function() return mathx.stc.normalCDF(0, 0, 1) end, 10000)
run("mathx.stc.uniformPDF", function() return mathx.stc.uniformPDF(0.5, 0, 1) end, 10000)
run("mathx.stc.uniformCDF", function() return mathx.stc.uniformCDF(0.5, 0, 1) end, 10000)
run("mathx.stc.binomialPDF", function() return mathx.stc.binomialPDF(10, 3, 0.5) end, 10000)
run("mathx.stc.binomialCDF", function() return mathx.stc.binomialCDF(10, 3, 0.5) end, 10000)
run("mathx.stc.sampleUniform", function() return mathx.stc.sampleUniform(0, 1) end, 10000)
run("mathx.stc.sampleNormal", function() return mathx.stc.sampleNormal(0, 1) end, 10000)
run("mathx.stc.sampleBinomial", function() return mathx.stc.sampleBinomial(10, 0.5) end, 10000)
run("mathx.stc.movingAverage", function() return mathx.stc.movingAverage(t, 3) end, 10000)
run("mathx.stc.exponentialSmoothing", function() return mathx.stc.exponentialSmoothing(t, 0.3) end, 10000)
run("mathx.stc.autocorrelation", function() return mathx.stc.autocorrelation(t, 1) end, 10000)
run("mathx.stc.covarianceMatrix", function()
    return mathx.stc.covarianceMatrix({{1,2,3},{4,5,6},{7,8,9}}, false)
end, 5000)
run("mathx.stc.correlationMatrix", function()
    return mathx.stc.correlationMatrix({{1,2,3},{4,5,6},{7,8,9}})
end, 5000)
run("mathx.stc.table", function() return mathx.stc.table(t) end, 5000)
run("mathx.linspace", function() return mathx.linspace(0, 1, 100) end, 2000)
run("mathx.range", function() return mathx.range(1, 100, 2) end, 2000)


print("\n[33. MEMORY MANAGEMENT]")
print(string.rep("━", 85))

run("Pool:acquireArray (500)", function()
    local a = mathx.pool:acquireArray(500, 0)
    return mathx.pool:releaseArray(a)
end, 5000)
run("Pool:acquireMat (16x16)", function()
    local m = mathx.pool:acquireMat(16, 16, 0)
    return mathx.pool:releaseMat(m, 16, 16)
end, 2000)
run("Vec:alias", function()
    local v = mathx.Vec.rand(500)
    return v:alias()
end, 2000)
run("Vec:toTable", function()
    return v500:toTable()
end, 2000)


print("\n[34. PROGRESSIVE PRECISION]")
print(string.rep("━", 85))

local m8p = mathx.Mat.rand(8, 8)
local v8p = mathx.Vec.rand(8)
run("pp.dgemm_f32 (8x8)", function() return mathx.pp.dgemm_f32(m8p, m8p) end, 200)
run("pp.iterRefine", function() return mathx.pp.iterRefine(m8p, v8p, 3) end, 100)
run("pp.eigProgressive", function() return mathx.pp.eigProgressive(m8p:mul(m8p:T()), 5, 10) end, 50)


print("\n[35. MATRIX EXPONENTIAL & POWER]")
print(string.rep("━", 85))

local m6 = mathx.Mat.rand(6, 6)
run("lapack.expm (6x6)", function() return mathx.lapack.expm(m6, 10) end, 100)
