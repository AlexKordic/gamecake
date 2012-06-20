-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local ngx=require("ngx")

local log=require("wetgenes.www.any.log").log

local wstr=require("wetgenes.string")

module(...)
local _M=require(...)
package.loaded["wetgenes.www.any.srv"]=_M

--------------------------------------------------------------------------------
--
-- build a new srv structure for this request
--
--------------------------------------------------------------------------------
function new()
	srv={}
	
	srv.put=function(...)
		ngx.print(...)
	end
	
	srv.exit=function(n)
		ngx.exit(n)
		return n
	end
	
	srv.set_header=function(n,v)
--		log("srv.set_header:",n,"=",v)
		ngx.header[n] = v;
	end
	
	srv.set_mimetype=function(v)	
		srv.set_header("content_type",v)
--		log("srv.set_mimetype:",v)
	end
	
	srv.set_cookie=function(t)
--		log("srv.set_cookie:",t.name,"=",t.value)		
		ngx.header["Set-Cookie"]=t.name.."="..t.value.."; Domain="..t.domain.."; Path="..t.path..";  Expires="..ngx.cookie_time(t.live)
	end

	srv.redirect=function(url)
--		log("srv.redirect:",url)
		return ngx.redirect(url)
	end

	srv.reloadcache=function(...)
		log("srv.reloadcache:",...)
	end

	srv.cache={} -- a very local cache
	
	srv.method=ngx.var.request_method -- probably GET or POST
	
	srv.ip=ngx.var.remote_addr -- users IP
	


	local scheme=ngx.var.scheme			-- http or https
	local domain=ngx.var.host
	local port=ngx.var.server_port
	local uri=ngx.var.uri				-- begins with /
	
	if port and port~="80" then
	
		srv.url=scheme.."://"..domain..":"..port..uri -- the url requested (not including any query string)

	else

		srv.url=scheme.."://"..domain..uri -- the url requested (not including any query string)

	end
	
	srv.query=ngx.var.args -- the query string
--log(srv.query)
	
	
	srv.headers={}
	for n,v in pairs( ngx.req.get_headers() ) do
		srv.headers[string.lower(n)]=v -- force all lowercase
	end
	
--print("HEADERS",wstr.dump(ngx.req.get_headers()))

	srv.cookies={}
	local cs
	if type(srv.headers.cookie)=="string" then
		cs=wstr.split(srv.headers.cookie,";")
	else
		cs=srv.headers.cookie
	end
	log(srv.headers.cookie)
	for i,s in ipairs(cs or {}) do
		local n,v=wstr.split_equal(wstr.trim(s))
		srv.cookies[n]=v
	end

	local body	-- pulling the body in is slightly complex
	ngx.req.read_body()
	local fn=ngx.req.get_body_file()
	if fn then
		local fp=io.open(fn,"r")
		body=fp:read("*a")
		fp:close()
	else
		body=ngx.req.get_body_data()
	end
	
	srv.posts={}
	srv.uploads={}
	
	local content_type=srv.headers["content-type"]
--log(wstr.serialize(srv.headers))
	
	if not content_type then --nothing?

	elseif string.find(content_type, "x-www-form-urlencoded", 1, true) then
	
		srv.posts=ngx.req.get_post_args()
	
	elseif string.find(content_type, "multipart/form-data", 1, true) then
	
		local _,_,boundary = string.find (content_type, "boundary%=(.-)$")
	  
		boundary="--"..boundary

		local parts=wstr.split(body,boundary)
	  
		for i,v in ipairs(parts) do
		
			local _,header_end=string.find(v, "\r\n\r\n") -- this terminates the header
			
			if header_end then -- and we can ignore this chunk if it has no header
			
				local header_str=v:sub(1,header_end)
				local data
				if v:sub(-2)=="\r\n" then -- check and
					data=v:sub(header_end+1,-3) -- kill crlf data tail
				else
					data=v:sub(header_end+1)
				end
				local headers={}
				for i,v in ipairs( wstr.split(header_str,"\r\n") ) do
					local aa=wstr.split(v,":")
					if aa[1] and aa[2] then
						headers[ wstr.trim(aa[1]) ] = aa[2]
					end
				end
				
				local attrs={}
				if headers["Content-Disposition"] then
					string.gsub(headers["Content-Disposition"], ';%s*([^%s=]+)="(.-)"',
						function(attr, val)
							attrs[attr] = val
						end)
				end
				
				if attrs.name then
					if attrs.filename then -- this be an uploaded file.
						srv.uploads[attrs.name]={data=data,size=#data,name=attrs.filename,type=headers["Content-Type"]}
					else
						srv.posts[attrs.name]=data
					end
				end
			end
		end
	end

	srv.gets=ngx.req.get_uri_args()

--print("UPLOADS",wstr.dump(srv.uploads))
--print("POSTS",wstr.dump(srv.posts))
--print("GETS",wstr.dump(srv.gets))

	srv.vars={}
	for key, val in pairs( srv.posts ) do
		srv.vars[key]=val
	end
	for key, val in pairs( srv.gets ) do
		srv.vars[key]=val
	end

	return srv
end
