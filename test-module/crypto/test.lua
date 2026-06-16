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