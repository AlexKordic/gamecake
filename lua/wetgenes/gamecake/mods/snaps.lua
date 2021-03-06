--
-- (C) 2013 Kriss@XIXs.com
--
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require
local gcinfo=gcinfo

local hex=function(str) return tonumber(str,16) end

local pack=require("wetgenes.pack")
local wzips=require("wetgenes.zips")

local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local win=require("wetgenes.win")

local wgrd   =require("wetgenes.grd")
local lfs ; (function() pcall( function() lfs=require("lfs") end ) end)()

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(oven,snaps)

	snaps=snaps or {}
	
	local gl=oven.gl
	local cake=oven.cake
	local canvas=cake.canvas
	local layout=cake.layouts.create{}

	function snaps.setup()
		if not lfs then return end

		lfs.mkdir(win.files_prefix.."snaps")
	end

	function snaps.clean()
	end
	
	function snaps.update()
	end
	
	function snaps.draw()


		if snaps.auto then
			snaps.frame=snaps.frame+1
			
			if snaps.frame%snaps.frame_skip == 0 then
				snaps.idx=snaps.idx+1

				local name=snaps.auto.."_"..(("%04d"):format(snaps.idx))

if lfs then -- shove files in dir
		lfs.mkdir(win.files_prefix.."snaps/"..snaps.auto)
		name=snaps.auto.."/"..(("%04d"):format(snaps.idx))
end
				local g=wgrd.create( wgrd.FMT_U8_RGBA_PREMULT , oven.win.width , oven.win.height , 1 )
				gl.ReadPixels(0,0,oven.win.width,oven.win.height,gl.RGBA,gl.UNSIGNED_BYTE,g.data)
				g:flipy() -- open gl is upside down
				local path=win.files_prefix.."snaps/"..name..".png"
print("Auto "..path)
--				g:scale(oven.win.width/3 , oven.win.height/3,1)
--				g:remap(gb)
				assert(g:save(path))
				snaps.list[#snaps.list+1]=path

				if snaps.frame>=snaps.frame_max then -- finished


if snaps.encode_gif then

	local gb=wgrd.create( wgrd.FMT_U8_INDEXED , oven.win.width , oven.win.height , 1 )
	gb:palette(0,32,{
-- force swanky32 palette when converting to GIF
		0x00,0x00,0x00,0x00,
		0x33,0x66,0x22,0xff,
		0x44,0x88,0x22,0xff,
		0x66,0xaa,0x33,0xff,
		0x66,0xbb,0x77,0xff,
		0x66,0xcc,0xcc,0xff,
		0x55,0x99,0xcc,0xff,
		0x55,0x77,0xcc,0xff,
		0x44,0x55,0x99,0xff,
		0x33,0x33,0x66,0xff,
		0x33,0x22,0x44,0xff,
		0x44,0x22,0x33,0xff,
		0x66,0x33,0x33,0xff,
		0x88,0x44,0x33,0xff,
		0xbb,0x77,0x66,0xff,
		0xee,0xaa,0x99,0xff,
		0xee,0x88,0xbb,0xff,
		0xdd,0x66,0x66,0xff,
		0xcc,0x33,0x33,0xff,
		0xdd,0x55,0x33,0xff,
		0xdd,0x77,0x33,0xff,
		0xdd,0xaa,0x33,0xff,
		0xdd,0xdd,0x44,0xff,
		0x88,0x88,0x33,0xff,
		0x00,0x00,0x00,0xff,
		0x22,0x22,0x22,0xff,
		0x44,0x44,0x44,0xff,
		0x66,0x66,0x66,0xff,
		0x88,0x88,0x88,0xff,
		0xaa,0xaa,0xaa,0xff,
		0xcc,0xcc,0xcc,0xff,
		0xff,0xff,0xff,0xff,
	})

	local stream=gb:stream({filename=win.files_prefix.."snaps/"..snaps.auto..".gif",speed=1000/30})

		for i,v in ipairs(snaps.list) do
			
			print("frame",v)

			local g=wgrd.create(v)
			g:remap(gb)

			stream.write(gb)
		end
		print("GIF",win.files_prefix.."snaps/"..snaps.auto..".gif")

		stream.close(gb)
end


					snaps.auto=false
					oven.frame_rate=snaps.frame_rate

				end
				
			end

			return nil
		end

	end
		
	snaps.list={}
	snaps.shift_key=false
	snaps.auto=false
	snaps.idx=0
	snaps.frame=0
	snaps.frame_max=60*12  -- tweleve seconds, at 60fps
	snaps.frame_skip=2     -- only record every other frame, so 30 fps output.
	snaps.encode_gif=false -- encode to gif? nah, best not to.
	function snaps.msg(m)
		if not lfs then return m end

--print(wstr.dump(m))

		if     m.class=="key" and ( m.keyname=="shift" or m.keyname=="shift_l" or m.keyname=="shift_r" ) and m.action==1 then
			snaps.shift_key=true
		elseif m.class=="key" and ( m.keyname=="shift" or m.keyname=="shift_l" or m.keyname=="shift_r" ) and m.action==-1 then
			snaps.shift_key=false
		end

		if ( m.class=="key" and m.keyname=="f12" and m.action==1 ) then

			if snaps.shift_key then
				if snaps.auto then
					snaps.auto=nil
				else
					snaps.auto=os.date("%Y%m%d_%H%M%S")
					snaps.idx=0
					snaps.frame=0
					snaps.list={}
					snaps.frame_rate=oven.frame_rate
					oven.frame_rate=nil -- disable limiter
				end
				return nil
			end

			local name=os.date("%Y%m%d_%H%M%S")
print("Snaps "..win.files_prefix.."snaps/"..name..".png")
			local g=wgrd.create( wgrd.FMT_U8_RGBA_PREMULT , oven.win.width , oven.win.height , 1 )
			gl.ReadPixels(0,0,oven.win.width,oven.win.height,gl.RGBA,gl.UNSIGNED_BYTE,g.data)
--			g:convert( wgrd.FMT_U8_RGBA ) -- save code expects this format
			g:flipy() -- open gl is upside down
			g:save(win.files_prefix.."snaps/"..name..".png")
			return nil
		end
		return m
	end

	return snaps
end
