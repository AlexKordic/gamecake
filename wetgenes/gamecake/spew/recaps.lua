--
-- (C) 2013 Kriss@XIXs.com
--
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,recaps)

	recaps=recaps or {} 
	
	local cake=oven.cake
	local canvas=cake.canvas
	
	local keys=oven.rebake("wetgenes.gamecake.spew.keys")


	function recaps.setup(max_up)
		max_up=max_up or 1
		recaps.up={}
		for i=1,max_up do
			recaps.up[i]=recaps.create() -- 1up 2up etc
		end
		return recaps -- so setup is chainable with a bake
	end

	function recaps.step()
		for i,v in ipairs(recaps.up or {}) do
			v.step()
		end
	end
	
	function recaps.get(nam,idx)
		local idx=idx or 1
		local recap=recaps.up and recaps.up[idx]
		if recap then return recap.get(nam) end
	end
	
	function recaps.get_now(nam,idx)
		local idx=idx or 1
		local recap=recaps.up and recaps.up[idx]
		if recap then return recap.get_now(nam) end
	end

	function recaps.get_joy(idx) -- return last "valid" frame data not current "volatile" frame data
		local idx=idx or 1
		local recap=recaps.up and recaps.up[idx]
		if recap then return recap.get_joy() end
	end


-- create a new recap table, then we can load or save this data to or from our server
	function recaps.create(idx)
		local recap={}
		recap.idx=idx
		

		function recap.reset(flow)
			recap.flow=flow or "none" -- do not play or record by default
			recap.last={}
			recap.now={}
			recap.last_joy={}
			recap.now_joy={}
			recap.autoclear={}
			recap.stream={} -- a stream of change "table"s or "number" frame skips
			recap.frame=0
			recap.read=0
			recap.wait=0
		end
		
		function recap.set(nam,dat) -- set the volatile data,this gets copied into last before it should be used
			recap.now[nam]=dat
		end
		function recap.pulse(nam,dat) -- set the volatile data but *only* for one frame
			recap.now[nam]=dat
			recap.autoclear[nam]=true
		end
		function recap.get_now(nam) -- return now or last frame data whatever "volatile" data we have
			local v=recap.now[nam]
			if type(v)=="nil" then v=recap.last[nam] end -- now probably only contains recent changes
			return v
		end
		function recap.get(nam) -- return last "valid" frame data not current "volatile" frame data
			return recap.last[nam]
		end

		function recap.get_joy() -- return last "valid" frame data not current "volatile" frame data
			return recap.last_joy
		end
		
-- use this to set a joysticks position
		function recap.joy(m)
			for _,n in ipairs{"lx","ly","rx","ry","dx","dy","mx","my"} do
				if m[n] then recap.now_joy[n]=m[n] end
			end
		end

-- use this to set button flags, that may trigger a set/clr extra pulse state
		function recap.but(nam,v)
			if type(nam)=="table" then
				for _,n in ipairs(nam) do recap.but(n,v) end -- multi
			else
				local l=recap.now[nam]
				if type(l)=="nil" then l=recap.last[nam] end -- now probably only contains recent changes
				if v then -- set
					if not l then -- change?
						recap.set(nam,true)
						recap.pulse(nam.."_set",true)
					end
				else -- clr
					if l then -- change?
						recap.set(nam,false)
						recap.pulse(nam.."_clr",true)
					end
				end
			end
		end


		function recap.step(flow)
			flow=flow or recap.flow

--print("step "..tostring(flow))	

			if flow=="record" then
				local change
				for n,v in pairs(recap.now) do
					if recap.last[n]~=v then -- changes
						change=change or {}
						change[n]=v
						recap.last[n]=v
						recap.now[n]=nil -- from now on we get the value from the last table
					end
				end
				if change then
					table.insert(recap.stream,change) -- change something
				else
					if type(recap.stream[#recap.stream])=="number" then
						recap.stream[#recap.stream] = recap.stream[#recap.stream] + 1 -- keep on changing nothing
					else
						table.insert(recap.stream,1) -- change nothing
					end
				end
				
			elseif flow=="play" then -- grab from the stream
			
				if recap.wait>0 then
				
					recap.wait=recap.wait-1
					
				else
				
					recap.read=recap.read+1
					
					local t=recap.stream[recap.read]
					local tt=type(t)
					
					if tt=="number" then
					
						recap.wait=t-1

					elseif tt=="table"then
					
						for n,v in pairs(t) do
							recap.last[n]=v
							recap.now[n]=v
						end
					
					end
				end
			
			else -- default of do not record, do not play just be
			
				for n,v in pairs(recap.now) do
					recap.last[n]=v
					recap.now[n]=nil
				end
				
				for n,v in pairs(recap.now_joy) do
					recap.last_joy[n]=v
					recap.now_joy[n]=nil
				end

			end
			
			if flow~="play" then
				for n,b in pairs(recap.autoclear) do -- auto clear volatile button pulse states
					recap.now[n]=false
					recap.autoclear[n]=nil
				end
			end
			
			recap.frame=recap.frame+1 -- advance frame counter
		end
		
		recap.reset()

		return recap
	end


	return recaps
end
