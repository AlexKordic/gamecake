
local string=string
local table=table
local math=math

local type=type
local pairs=pairs
local ipairs=ipairs
local tostring=tostring
local setmetatable=setmetatable
local error=error
local tonumber=tonumber

--
-- Some ueful string functions.
--

module("wetgenes.string")




-----------------------------------------------------------------------------
--
-- split a string into a table, flag enables pattern match on true
--
-----------------------------------------------------------------------------
function str_split(div,str,flag)

	if (str=='') then return {""} end
	
	if (div=='') or not div then error("div expected", 2) end
	if (str=='') or not str then error("str expected", 2) end

	local pos,arr = 0,{}

	-- for each divider found
	for st,sp in function() return string.find(str,div,pos,not flag) end do
		table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
		pos = sp + 1 -- Jump past current divider
	end

	if pos~=0 then
		table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
	else
		table.insert(arr,str) -- return entire string
	end


	return arr
end




-----------------------------------------------------------------------------
--
-- serialize a simple table to a lua string that would hopefully recreate said table if executed
--
-- returns a string
--
-----------------------------------------------------------------------------
function serialize(o,opts)
opts=opts or {}
opts.done=opts.done or {} -- only do tables once

opts.indent=opts.indent or ""
opts.newline=opts.newline or ( opts.compact and "" or "\n" )

local fout=opts.fout

	if not fout then -- call with a new function to build and return a string
		local ret={}
		opts.fout=function(...)
			for i,v in ipairs({...}) do ret[#ret+1]=v end
		end
		serialize(o,opts)		
		return table.concat(ret)
	end

	if type(o) == "number" then
	
		return fout(o)
		
	elseif type(o) == "boolean" then
	
		if o then return fout("true") else return fout("false") end
		
	elseif type(o) == "string" then
	
		return fout(string.format("%q", o))
		
	elseif type(o) == "table" then
	
		
		if opts.done[o] and opts.no_duplicates then
			fout(opts.indent,"\n",opts.indent,"{--[[DUPLICATE]]}",opts.newline)
			return
		else
		
			fout(opts.newline,opts.indent,"{",opts.newline)

			if opts.pretty then
				opts.indent=opts.indent.." "
			end
			
			opts.done[o]=true
			
			local maxi=0
			
			for k,v in ipairs(o) do -- dump number keys in order
				fout(opts.indent)
				serialize(v,opts)
				fout(",",opts.newline)
				maxi=k -- remember top
			end
			
			for k,v in pairs(o) do
				if (type(k)~="number") or (k<1) or (k>maxi) or (math.floor(k)~=k) then -- skip what we already dumped
					fout(opts.indent,"[")
					serialize(k,opts)
					fout("]=")
					serialize(v,opts)
					fout(",",opts.newline)
				end
			end
			
			if opts.pretty then
				opts.indent=opts.indent:sub(1,-2)
			end
			fout(opts.indent,"}",opts.newline)
			return
		end
	else
		error("cannot serialize a " .. type(o))
	end
	
end


-----------------------------------------------------------------------------
--
-- join a table of things into an english list with commas and an "and" at the end
-- returns nil if the table is empty
--
-----------------------------------------------------------------------------
function str_join_english_list(t)

local s

	for i,v in ipairs(t) do
	
		if not s then -- first
		
			s=v
			
		elseif t[i+1]==nil then -- last
		
			s=s.." and "..v
			
		else -- middle
		
			s=s..", "..v
			
		end
	
	end

	return s

end

-----------------------------------------------------------------------------
--
-- convert a string into a hex string
--
-----------------------------------------------------------------------------
function str_to_hex(s)
	return string.gsub(s, ".", function (c)
		return string.format("%02x", string.byte(c))
	end)
end

-----------------------------------------------------------------------------
--
-- replace any %xx with the intended char, eg "%20" becomes a " "
--
-----------------------------------------------------------------------------
function url_decode(str)
    return string.gsub(str, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

-----------------------------------------------------------------------------
--
-- replace % , & , # , ' , " and = chars with %xx codes
-- this is the bare minimum we need to escape so as not to confuse things
--
-----------------------------------------------------------------------------
function url_encode(str)
    return string.gsub(str, "([&=%%#'\"])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end


-----------------------------------------------------------------------------
--
-- trime whitespace from ends of string
--
-----------------------------------------------------------------------------
function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
function trim_start(s)
  return (s:gsub("^%s*(.-)", "%1"))
end
function trim_end(s)
  return (s:gsub("(.-)%s*$", "%1"))
end

-----------------------------------------------------------------------------
--
-- split on \n, each line also includes its own \n
--
-----------------------------------------------------------------------------
function split_lines(text)
	local separator = "\n"
	
	local parts = {}  
	local start = 1
	
	local split_start, split_end = text:find(separator, start,true)
	
	while split_start do
		table.insert(parts, text:sub(start, split_end))
		start = split_end + 1
		split_start, split_end = text:find(separator, start,true)
	end
	
	if text:sub(start)~="" then
		table.insert(parts, text:sub(start) )
	end
	
	return parts
end

-----------------------------------------------------------------------------
--
-- split on whitespace, throw away all whitespace return only the words
--
-----------------------------------------------------------------------------
function split_words(text,split)
	local separator = split or "%s+"
	
	local parts = {}  
	local start = 1
	
	local split_start, split_end = text:find(separator, start)
	
	while split_start do
		if split_start>1 then table.insert(parts, text:sub(start, split_start-1)) end
		start = split_end + 1
		split_start, split_end = text:find(separator, start)
	end
	
	if text:sub(start)~="" then
		table.insert(parts, text:sub(start) )
	end
	
	return parts
end


-----------------------------------------------------------------------------
--
-- split on transition to or from whitespace, include this white space in the table result
--
-- such that a concat on the result would be a perfect reproduction of the original
--
-----------------------------------------------------------------------------
function split_whitespace(text)
	local separator = "%s+"
	
	local parts = {}  
	local start = 1
	
	local split_start, split_end = text:find(separator, start)
	
	while split_start do
		if split_start>1 then table.insert(parts, text:sub(start, split_start-1)) end		-- the word
		table.insert(parts, text:sub(split_start, split_end))	-- the white space
		start = split_end + 1
		split_start, split_end = text:find(separator, start)
	end
	
	if text:sub(start)~="" then
		table.insert(parts, text:sub(start) )
	end
	
	return parts
end

-----------------------------------------------------------------------------
--
-- split a string in two on first = 
--
-----------------------------------------------------------------------------
function split_equal(text)
	local separator = "="
	
	local parts = {}
	local start = 1
	
	local split_start, split_end = text:find(separator, start,true)
	
	if split_start and split_start>1 and split_end<#text then -- data either side of seperator
	
		return text:sub(1,split_start-1) , text:sub(split_end+1)
		
	end
	
	return nil
end



-----------------------------------------------------------------------------
--
-- private replace utility function
-- look up string a inside data d and return the string we found
-- if we dont find anything then we return {a}
--
-- if we try to look up a table containing a plate field
-- then that plate name will be used to format that table content as {d.it}
-- if that table contains a [1] then it will be treated as an array of data
-- and looped over to produce a result.
--
-----------------------------------------------------------------------------
local replace_lookup
replace_lookup=function(a,d) -- look up a in table d
	local t=d[a]
	if t then
		if type(t)=="table" then -- if a table then
			if t[1] then -- a list of stuff
				if t.plate then -- how to format
					local tt={}
					local it=d.it
					for i,v in ipairs(t) do
						d.it=v
						tt[#tt+1]=macro_replace(d[t.plate] or t.plate,d)
					end
					d.it=it
					return table.concat(tt)
				end
			else -- just one thing
				if t.plate then -- how to format
					local it=d.it
					d.it=t
					local tt=macro_replace(d[t.plate] or t.plate,d)
					d.it=it
					return tt
				end
			end
			return nil -- no not expand
		end
		return tostring(t) -- simple find, make sure we return a string
	end
	
	local a1,a2=string.find(a, "%.") -- try and split on first "."
	if not a1 then return nil end -- didnt find a dot so return nil
	
	a1=string.sub(a,1,a1-1) -- the bit before the .
	a2=string.sub(a,a2+1) -- the bit after the .
	
	local dd=d[a1] -- use the bit before the dot to find the sub table
	
	if type(dd)=="table" then -- check we got a table
		return replace_lookup(a2,dd) -- tail call this function
	end
	
	return nil -- couldnt find anything returnnil
end


-----------------------------------------------------------------------------
--
-- replace {tags} in the string with data provided
-- allow sub table look up with a.b notation in the name
--
-----------------------------------------------------------------------------
function replace(a,d)

return (string.gsub( a , "{([%w%._%-]-)}" , function(a) -- find only words and "._-!" tightly encased in {}
-- this means that almost all legal use of {} in javascript will not match at all.
-- Even when it does (probably as a "{}") then it is unlikley to accidently find anything in the d table
-- so the text will just be returned as is.
-- So it may not be safe, but it is simple to understand and perfecty fine under most use cases.

	return replace_lookup(a,d) or ("{"..a.."}")
	
end )) -- note gsub is in brackes so we just get its first return value

end

-----------------------------------------------------------------------------
--
-- like replace but allows for simple creation of temporary substitutions
-- this enables very simple macro expansion
-- so {var=}value{=var} would set var to value
-- and that value would last for the rest of the chunk
--
-----------------------------------------------------------------------------
local function macro_replace_once(text,old_d,opts)
	opts=opts or {}
	local opts_clean=opts.clean
	local opts_htmldbg=opts.dbg_html_comments

	local d={} -- we can store temporary vars in here
	if old_d then setmetatable(d,{__index=old_d})	end -- wrap original d to protect it
	
	
	local ret={}
	
	local separator = "{[%w%._%-=]-}"
	
	local parts = {}  
	local start = 1
	
	local split_start, split_end = text:find(separator, start)
	
	while split_start do
		if split_start>1 then table.insert(parts, text:sub(start, split_start-1)) end		-- part1
		table.insert(parts, text:sub(split_start, split_end))	-- part2
		start = split_end + 1
		split_start, split_end = text:find(separator, start)
	end
	
	if text:sub(start)~="" then
		table.insert(parts, text:sub(start) )
	end

	local count=0
	local capt=nil
	

-- step through	
	for i=1,#parts do local v=parts[i]
		local tag=nil
		local dat=nil
		local skip_capt=nil
		if string.len(v)>=3 then -- must be at least this long
			local fc=v:sub(1,1) -- first char
			local lc=v:sub(-1) -- last char
			if fc=="{" and lc=="}" then -- special part
				tag=v:sub(2,#v-1)
				local fc=tag:sub(1,1) -- first char
				local lc=tag:sub(-1) -- last char
				
				if lc=="=" then -- start of capture
					if capt==nil then
						capt=tag:sub(1,-2)
						d[capt]=""
						skip_capt=true
						if opts_clean then
							dat=""
						end
					end
				elseif fc=="=" then -- end of capture
					if capt==tag:sub(2) then -- must match
						capt=nil
						if opts_clean then dat="" end
					end
				else -- normal lookup
					dat=replace_lookup(tag,d)
				end
			end
		end
		local s
		if dat then
			count=count+1
			if opts_htmldbg and tag then
				s="<!--{ "..tag.." }-->\n"..dat
			else
				s=dat
			end
		else
			s=v
		end
		
		if not skip_capt then
			if capt then -- record capture
				d[capt]=d[capt]..s
				if opts_clean then s="" end
			end
		end
		
		ret[#ret+1]=s
	end

	return table.concat(ret,""),count
end

function macro_replace(a,d,opts)

local opts=opts or {} --{dbg_html_comments=true} to include html dbg, this will break some macro use inside javascript or html attributes so is off by default turn on to dbg
	
	local ret=a
	local count=0

	opts.clean=false
	for i=1,100 do -- maximum recursion
	
		ret,count=macro_replace_once(ret,d,opts)
		
		if count==0 then break end -- nothing left to replace
		
	end
	opts.clean=true
	ret=macro_replace_once(ret,{},opts) -- finally remove temporary chunks
	
	return ret
end
