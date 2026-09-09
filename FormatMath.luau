--==========================================================================--
--                         Format Math Luau Module                          --
------------------------------------------------------------------------------
--            https://github.com/Bondpley/Format-Math-Luau-Module           --
--                               By Bondpley                                --
--                                  v.1.0                                   --
--==========================================================================--

--!strict

local FormatMath = {}

local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local roman = {
	{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
	{100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
	{10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"}
}

local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function FormatMath.Clamp(val: number, minV: number, maxV: number): number
	return math.max(minV, math.min(maxV, val))
end

function FormatMath.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function FormatMath.Round(val: number, places: number?): number
	local scale = 10 ^ (places or 0)
	return math.floor(val * scale + 0.5) / scale
end

function FormatMath.Map(val: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return (val - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

function FormatMath.Percent(val: number, total: number): number
	return total == 0 and 0 or (val / total) * 100
end

function FormatMath.Factorial(n: number): number
	assert(n >= 0 and n % 1 == 0)

	local res = 1
	for i = 2, n do
		res *= i
	end

	return res
end

function FormatMath.GCD(a: number, b: number): number
	while b ~= 0 do
		a, b = b, a % b
	end

	return math.abs(a)
end

function FormatMath.LCM(a: number, b: number): number
	return math.abs(a * b) / FormatMath.GCD(a, b)
end

function FormatMath.IsPrime(n: number): boolean
	if n < 2 then
		return false
	end

	for i = 2, math.floor(math.sqrt(n)) do
		if n % i == 0 then
			return false
		end
	end

	return true
end

function FormatMath.Distance(x1: number, y1: number, x2: number, y2: number): number
	local dx = x2 - x1
	local dy = y2 - y1
	return math.sqrt(dx * dx + dy * dy)
end

function FormatMath.ToBase(val: number, base: number): string
	assert(base >= 2 and base <= 36)

	if val == 0 then
		return "0"
	end

	local neg = val < 0
	val = math.abs(math.floor(val))

	local res = ""

	while val > 0 do
		local rem = val % base
		res = digits:sub(rem + 1, rem + 1) .. res
		val = math.floor(val / base)
	end

	return neg and "-" .. res or res
end

function FormatMath.FromBase(str: string, base: number): number
	assert(base >= 2 and base <= 36)

	local neg = str:sub(1, 1) == "-"
	if neg then
		str = str:sub(2)
	end

	local res = 0

	for i = 1, #str do
		local ch = str:sub(i, i):upper()
		local idx = digits:find(ch, 1, true)
		assert(idx and idx - 1 < base)

		res = res * base + idx - 1
	end

	return neg and -res or res
end

function FormatMath.ToBinary(val: number): string
	return FormatMath.ToBase(val, 2)
end

function FormatMath.ToHex(val: number): string
	return FormatMath.ToBase(val, 16)
end

function FormatMath.ToOctal(val: number): string
	return FormatMath.ToBase(val, 8)
end

function FormatMath.ToRoman(n: number): string
	assert(n > 0 and n < 4000)

	local res = ""

	for _, pair in ipairs(roman) do
		while n >= pair[1] do
			res ..= pair[2]
			n -= pair[1]
		end
	end

	return res
end

function FormatMath.ToScientific(val: number): string
	if val == 0 then
		return "0e0"
	end

	local exp = math.floor(math.log10(math.abs(val)))
	local mant = val / 10 ^ exp

	return string.format("%.6fe%d", mant, exp)
end

function FormatMath.CharToASCII(ch: string): number
	return string.byte(ch)
end

function FormatMath.ASCIIToChar(code: number): string
	return string.char(code)
end

function FormatMath.StringToASCII(str: string): {number}
	local res = {}

	for i = 1, #str do
		res[i] = string.byte(str, i)
	end

	return res
end

function FormatMath.ASCIIToString(list: {number}): string
	local chars = {}

	for _, code in ipairs(list) do
		table.insert(chars, string.char(code))
	end

	return table.concat(chars)
end

function FormatMath.StringToBinary(str: string): string
	local res = {}

	for i = 1, #str do
		table.insert(res, string.format("%08b", string.byte(str, i)))
	end

	return table.concat(res, " ")
end

function FormatMath.BinaryToString(str: string): string
	local chars = {}

	for bits in str:gmatch("%d+") do
		table.insert(chars, string.char(tonumber(bits, 2)))
	end

	return table.concat(chars)
end

function FormatMath.StringToHex(str: string): string
	local res = {}

	for i = 1, #str do
		table.insert(res, string.format("%02X", string.byte(str, i)))
	end

	return table.concat(res, " ")
end

function FormatMath.HexToString(str: string): string
	local chars = {}

	for hex in str:gmatch("%x%x") do
		table.insert(chars, string.char(tonumber(hex, 16)))
	end

	return table.concat(chars)
end

function FormatMath.Base64Encode(str: string): string
	local res = {}

	for i = 1, #str, 3 do
		local a = string.byte(str, i) or 0
		local b = string.byte(str, i + 1) or 0
		local c = string.byte(str, i + 2) or 0

		local n = a * 65536 + b * 256 + c

		local i1 = math.floor(n / 262144) % 64
		local i2 = math.floor(n / 4096) % 64
		local i3 = math.floor(n / 64) % 64
		local i4 = n % 64

		table.insert(res, b64:sub(i1 + 1, i1 + 1))
		table.insert(res, b64:sub(i2 + 1, i2 + 1))
		table.insert(res, i + 1 <= #str and b64:sub(i3 + 1, i3 + 1) or "=")
		table.insert(res, i + 2 <= #str and b64:sub(i4 + 1, i4 + 1) or "=")
	end

	return table.concat(res)
end

function FormatMath.Base64Decode(str: string): string
	str = str:gsub("=", "")

	local out = {}
	local buf = 0
	local bits = 0

	for i = 1, #str do
		local idx = b64:find(str:sub(i, i), 1, true)

		if idx then
			buf = buf * 64 + idx - 1
			bits += 6

			while bits >= 8 do
				bits -= 8

				local byte = math.floor(buf / 2 ^ bits)
				buf %= 2 ^ bits

				table.insert(out, string.char(byte))
			end
		end
	end

	return table.concat(out)
end

function FormatMath.RandomFloat(minV: number, maxV: number): number
	return minV + math.random() * (maxV - minV)
end

function FormatMath.RandomChoice(list)
	return list[math.random(#list)]
end

function FormatMath.Comma(val: number): string
	local left, mid, right = tostring(val):match("^([^%d]*%d)(%d*)(.-)$")
	return left .. (mid:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end

function FormatMath.PadLeft(str: string, len: number, ch: string?): string
	ch = ch or "0"
	return #str >= len and str or string.rep(ch, len - #str) .. str
end

function FormatMath.PadRight(str: string, len: number, ch: string?): string
	ch = ch or " "
	return #str >= len and str or str .. string.rep(ch, len - #str)
end

return FormatMath
