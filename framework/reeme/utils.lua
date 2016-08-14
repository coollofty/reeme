local Utils = {
	__index = {
		--en/decode
		escapeUri = function(str)
			return ngx.escape_uri(str)
		end,
		
		unescapeUri = function(str)
			return ngx.unescape_uri(str)
		end,
		
		argsEncode = function(argsTable)
			return ngx.encode_args(argsTable)
		end,
		
		argsDecode = function(str, maxArgs)
			return ngx.decode_args(str, maxArgs)
		end,
		
		base64Encode = function(str, noPadding)
			return ngx.encode_base64(str, noPadding)
		end,
		
		base64Decode = function(str)
			return decode_base64(str)
		end,
		
		jsonEncode = require("cjson.safe").encode,

		jsonDecode = require("cjson.safe").decode,
		
		crc32 = function(str)
			if not str or type(str) ~= "string" then return nil end
			
			if #str <= 60 then
				return ngx.crc32_short(str)
			else
				return ngx.crc32_long(str)
			end
		end,
		
		hmacSha1 = function(secretKey, str, bReturnBin)
			if not secretKey or type(secretKey) ~= "string" or not str or type(str) ~= "string" then return nil end
			
			if not bReturnBin then
				return ngx.hmac_sha1(secretKey, str)
			else
				return ngx.sha1_bin(str)
			end
		end,
		
		md5 = function(str, bReturnBin)
			if not str or type(str) ~= "string" then return nil end
			
			if not bReturnBin then
				return ngx.md5(str)
			else
				return ngx.md5_bin(str)
			end
		end,
		
		rsaEncrypt = function(publicKey, str)
			local rsa = require("resty.rsa")
			local base64 = require("resty.base64")
			
			local pub, err = rsa:new(publicKey, true)
			if not pub then
				return nil, err
			end
			
			local encrypted, err = pub:encrypt(str)
			if not encrypted then
				return nil, err
			end
			
			return base64.base64_encode(encrypted)
		end,
		
		rsaDecrypt = function(privateKey, str)
			local rsa = require("resty.rsa")
			local base64 = require("resty.base64")
			
			local priv, err = rsa:new(privateKey)
			if not priv then
				return nil, err
			end
			
			local decrypted = priv:decrypt(base64.base64_decode(str))
			if not decrypted then
				return nil, err
			end
			return decrypted
		end,
		
		quoteSql = function(rawValue)
			return ngx.quote_sql_str(rawValue)
		end,
		
		regexMatch = function(self, subject, regex, options, ctx, resTable)
			return ngx.re.match(subject, regex, options, ctx, resTable)
		end,
		regexFind = function(self, subject, regex, options, ctx, nth)
			return ngx.re.find(subject, regex, options, ctx, nth)
		end,
		regexGmatch = function(subject, regex, options)
			return ngx.re.gmatch(subject, regex, options)
		end,
		regexSub = function(subject, regex, replace, options)
			return ngx.re.sub(subject, regex, replace, options)
		end,
		regexGsub = function(subject, regex, replace, options)
			return ngx.re.gsub(subject, regex, replace, options)
		end,
		
		--file
		moveFile = function(source, dest)
			return os.rename(source, dest)
		end,
		
		isFileExists = function(filename)
			local f, err = io.open(filename)
			if f then
				f:close()
				return true
			end
			return false
		end,
		
		copyFile = function(source, destination)
			sourcefile = io.open(source, "rb")
			if not sourcefile then return false end
			destinationfile = io.open(destination, "wb+")
			if not destinationfile then
				sourcefile:close()
				return false
			end

			destinationfile:write(sourcefile:read("*a"))

			sourcefile:close()
			destinationfile:close()
		end,

		removeFile = function(filename)
			return os.remove(filename)
		end,
		
		readFile = function(filename)
			local file, err = io_open(filename, "rb")
			local data = file and file:read("*a") or nil
			if file then
				file:close()
			end
			return data
		end,
		
		--time
		today = function()
			return ngx.today()
		end,
		
		time = function()
			return ngx.time()
		end,
		
		now = function()
			return ngx.now()
		end,
		
		updateTime = function()
			ngx.update_time()
		end,
		
		localtime = function()
			return ngx.localtime()
		end,
		
		utctime = function()
			return ngx.utctime()
		end,
		
		toCookieTime = function(sec)
			return ngx.cookie_time(sec)
		end,
		
		toHttpTime = function(sec)
			return ngx.http_time(sec)
		end,
		
		parseHttpTime = function(str)
			return ngx.parse_http_time(str)
		end,
		
		--timer
		setTimer = function(delaySeconds, callback, ...)
			return ngx.timer.at(delaySeconds, callback, ...)
		end,
		
		getRunningTimerCount = function()
			return ngx.timer.running_count()
		end,
		
		getPendingTimerCount = function()
			return ngx.timer.pending_count()
		end,
	},
}

return function(reeme)
	local utils = { R = reeme }
	
	return setmetatable(utils, Utils)
end