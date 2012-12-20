-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,keys)

	keys=keys or {}
	
	local cake=state.cake
	local canvas=cake.canvas
	
	local recaps=state.rebake("wetgenes.gamecake.spew.recaps")
	
	keys.defaults={}
	keys.defaults[0]={
		["up"]			=	"up",
		["w"]			=	"up",
		["down"]		=	"down",
		["s"]			=	"down",
		["left"]		=	"left",
		["a"]			=	"left",
		["right"]		=	"right",
		["d"]			=	"right",
		["rcontrol"]	=	"fire",
		["rmenu"]		=	"fire",
		["space"]		=	"fire",
		["lcontrol"]	=	"fire",
		["lmenu"]		=	"fire",
	}

	keys.defaults[1]={
		["w"]			=	"up",
		["s"]			=	"down",
		["a"]			=	"left",
		["d"]			=	"right",
		["lcontrol"]	=	"fire",
		["lmenu"]		=	"fire",
	}
	keys.defaults[2]={
		["up"]			=	"up",
		["down"]		=	"down",
		["left"]		=	"left",
		["right"]		=	"right",
		["rcontrol"]	=	"fire",
		["rmenu"]		=	"fire",
	}

	function keys.setup(max_up)
		max_up=max_up or 1
		keys.up={}
		for i=1,max_up do
			keys.up[i]=keys.create(i) -- 1up 2up etc
		end
		
		if max_up==1 then -- single player, grab lots of keys
			for n,v in pairs(keys.defaults[0]) do
				keys.up[1].set(n,v)
			end
		else
			for i=1,max_up do -- multiplayer use keyislands so we can all fit on a keyboard
				for n,v in pairs(keys.defaults[i] or {}) do
					keys.up[i].set(n,v)
				end
			end
		end
		
		return keys -- so setup is chainable with a bake
	end


-- convert keys or whatever into state recaps changes
	function keys.msg(m)
		if not keys.up then return end
		
		for i,v in ipairs(keys.up) do
			v.msg(m)
		end
		
	end
	

-- a players key mappings, maybe we need multiple people on the same keyboard or device
	function keys.create(idx)
		local key={}
		key.idx=idx
		key.maps={}
		
		function key.clear()
			key.maps={}
		end
		function key.set(n,v)
			key.maps[n]=v
		end

		function key.msg(m)
			local recap=key.idx and recaps.up and recaps.up[key.idx]
			if not recap then return end
			
			if m.class=="key" then
				for n,v in pairs(key.maps) do
					if m.keyname==n then
						if m.action==1 then -- key set
							recap.but(v,true)
						elseif m.action==-1 then -- key clear
							recap.but(v,false)
						end
					end
				end
				
			end
			
		end
		
		return key
	end


	return keys
end
