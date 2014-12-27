--
-- (C) 2013 Kriss@XIXs.com
--
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local tardis=require("wetgenes.tardis")

-- widget class master
-- the master widget

local wstr=require("wetgenes.string")



--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(oven,wmaster)
wmaster=wmaster or {}

local gl=oven.gl
local cake=oven.cake
local canvas=oven.canvas

local framebuffers=oven.rebake("wetgenes.gamecake.framebuffers")

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

local mkeys=oven.rebake("wetgenes.gamecake.mods.keys")

--
-- add meta functions
--
function wmaster.setup(widget,def)

	widget.solid=true -- catch background clicks

	local master=widget
	local meta=widget.meta
--	local win=def.win

--meta.setup(widget,def)

--	widget.hx=0
--	widget.hy=0
--	widget.sx=1
--	widget.sy=1

	master.throb=0
--	master.fbo=_G.win.fbo(0,0,0) -- use an fbo
--	master.fbo=framebuffers.create(0,0,0)
	master.dirty=true

-- the master gets some special overloaded functions to do a few more things
	function master.update(widget,resize)

		
		local ups=srecaps.ups()
		if ups then -- use skeys / srecaps code 


			if master.focus then
				skeys.set_opts("typing",true)
			else
				skeys.set_opts("typing",false)
			end
			
			if not master.press then -- do not move when button is held down
				local vx=0
				local vy=0
				if ups.button("left_set")  then vx=-1 end
				if ups.button("right_set") then vx= 1 end
				if ups.button("up_set")    then vy=-1 end
				if ups.button("down_set")  then vy= 1 end
				master.keymove(vx,vy)
			end

			if ups.button("fire_set")  then

				master.press=true

				if master.over then

					if master.active~=master.over then
						master.active=master.over
						local axis=ups.axis()
						local rx,ry=master.over.parent:mousexy(axis.mx,axis.my)
						master.active_x=rx-master.over.px--widget.pxd
						master.active_y=ry-master.over.py--widget.pyd
						
						master.active:call_hook("active") -- an active widget is about to click (button down)
					end

					if master.active and master.active.can_focus then
						master.set_focus(master.active)
					end

					master.over:set_dirty()

				end

			end
			
			if ups.button("fire_clr")  then

				master.press=false

				if master.over --[[ and master.active==master.over ]] then -- no click if we drag away from button
				
					if ups.button("mouse_left_clr")  then
						master.over:call_hook("click",{keyname="mouse_left"}) -- its a left click
					elseif ups.button("mouse_right_clr")  then
						master.over:call_hook("click",{keyname="mouse_right"}) -- its a right click
					elseif ups.button("mouse_middle_clr")  then
						master.over:call_hook("click",{keyname="mouse_middle"}) -- its a right click
					else
						master.over:call_hook("click") -- probably not a mouse click
					end
					
					master.over:set_dirty()
					
				end
				
				master.active=nil
				
			end

		end

	
		local tim=os.time()
		for w,t in pairs(master.timehooks) do
			if t<=tim then
--print("tim",t)
				w:call_hook("timedelay",t)
				master.timehooks[w]=nil
			end
		end
	
		if resize then
--print("resize",wstr.dump(resize))
			if widget.hx==resize.hx and widget.hy==resize.hy then
			else
				widget.hx=resize.hx or widget.hx
				widget.hy=resize.hy or widget.hy
				widget:layout()
			end
		end
	
		local throb=(widget.throb<128)
		
		widget.throb=widget.throb-4
		if widget.throb<0 then widget.throb=255 end
		
		if throb ~= (widget.throb<128) then -- dirty throb...
			local w=widget.focus
			if w and w.class=="textedit" then
				w:set_dirty()
			end
			if w~=widget.edit then
				w=widget.edit
				if w and w.class=="textedit" then
					w:set_dirty()
				end
			end
		end

		meta.update(widget)
	end
	
	function master.layout(widget)
--print("master layout")
		meta.layout(widget)
		meta.build_m4(widget)
		master.remouse(widget)
--exit()
	end

	local dirty_fbos={}
	local find_dirty_fbos -- to recurse is defined...
	find_dirty_fbos=function(widget)
		if widget.fbo and widget.dirty then
			dirty_fbos[ #dirty_fbos+1 ]=widget
		end
		for i,v in ipairs(widget) do
			find_dirty_fbos(v)
		end
	end

	function master.draw(widget)

		dirty_fbos={}
		find_dirty_fbos(widget)

		gl.Disable(gl.CULL_FACE)
		gl.Disable(gl.DEPTH_TEST)

		gl.PushMatrix()
		
		
		if #dirty_fbos>0 then
			for i=#dirty_fbos,1,-1 do -- call in reverse so sub fbos can work
--print("DIRTY",i)
				meta.draw(dirty_fbos[i]) -- dirty, so this only builds the fbo
			end
		end

		meta.draw(widget)
		
		gl.PopMatrix()
	end
	
	function master.msg(widget,m)
	
		if m.class=="key" then
			if skeys.opts.typing or m.softkey then -- fake keyboard only
				widget:key(m.ascii,m.keyname,m.action)
			end
		elseif m.class=="mouse" then
			widget:mouse(m.action,m.x,m.y,m.keyname)
		end

	end

	function master.set_focus_edit(edit)
		if master.edit==edit then return end -- no change

		if master.edit then
			master.edit:call_hook("unfocus_edit")
			master.edit=nil
		end

		if edit then -- can set to nil
			widget.edit=edit
			master.edit:call_hook("focus_edit")
		end
	end
	
	function master.set_focus(focus)
	
		if master.focus==focus then return end -- no change
	
		if master.focus then
			master.focus:call_hook("unfocus")
			master.focus=nil
		end

		if focus then -- can set to nil
			master.focus=focus
			master.focus:call_hook("focus")
			if focus.class=="textedit" then -- also set edit focus
				master.set_focus_edit(focus)
			end
		end
	
	end
--
-- handle key input
--
	function master.key(widget,ascii,key,act)

		if master.focus then -- key focus, steals all the key presses until we press enter again
		
			if master.focus.key then
				master.focus:key(ascii,key,act)
			end
			
		else
		
			if master.edit then
				if	key=="left" or
					key=="right" or
					key=="up" or
					key=="down" or
					key=="return" then
					-- ignore
				else
					master.edit:key(ascii,key,act)
				end
			end
		
		end

	end


	function master.keymove(vx,vy)
		if vx~=0 or vy~=0 then -- move hover selection
		
			if master.over and master.over.hx and master.over.hy then
				local over=master.over
				local best={}
				local ox=over.pxd+(over.hx/2)
				local oy=over.pyd+(over.hy/2)

--print("over",ox,oy)

				master:call_descendents(function(w)
					if w.solid and w.hooks and not w.hidden then
						local wx=w.pxd+(w.hx/2)
						local wy=w.pyd+(w.hy/2)
						local dx=wx-ox
						local dy=wy-oy
						local dd=0
						if vx==0 then dd=dd+dx*dx*8 else dd=dd+dx*dx end
						if vy==0 then dd=dd+dy*dy*8 else dd=dd+dy*dy end
--print(w,wx,wy,dx,dy,by,by)
						if	( dx<0 and vx<0 ) or
							( dx>0 and vx>0 ) or
							( dy<0 and vy<0 ) or
							( dy>0 and vy>0 ) then -- right direction
							
							if best.over then
								if best.dd>dd then -- closer
									best.over=w
									best.dd=dd
								end
							else
								best.over=w
								best.dd=dd
							end
						end
					end
				end)
				if best.over then
					over:set_dirty()
					best.over:set_dirty()
					master.over=best.over
					if master.over then master.over:call_hook("over") end
				end
			end
			if not master.over then
				master:call_descendents(function(v)
					if not master.over then
						if v.solid and v.hooks and not v.hidden then
							master.over=v
							v:set_dirty()
							master.over:call_hook("over")
						end
					end
				end)
			end
			
		end
	end
--
-- set the mouse position to its last position
-- call this after adding/removing widgets to make sure they highlight properly
--	
	function master.remouse(widget)
		local p=widget.last_mouse_position -- or {0,0}
		if p then
			widget.mouse(widget,nil,p[1],p[2],nil)
		end
	end
--
-- handle mouse input
--	
	function master.mouse(widget,act,x,y,keyname)

		master.last_mouse_position={x,y}

		local old_active=master.active
		local old_over=master.over

		meta.mouse(widget,act,x,y,keyname) -- cascade down into all widgets
		
		if master.dragging() then -- slide :)
		
			local w=master.active
			local p=w.parent

			local rx,ry=w.parent:mousexy(x,y)
			local x,y=rx-master.active_x,ry-master.active_y

			local maxx=p.hx-w.hx
			local maxy=p.hy-w.hy

--print("slide",miny,maxy)
			
			w.px=x
			w.py=y
			
			if w.px<0    then w.px=0 end
			if w.px>maxx then w.px=maxx end
			if w.py<0    then w.py=0 end
			if w.py>maxy then w.py=maxy end
			
			if w.parent.snap then
				w.parent:snap()
			end
			
			w:call_hook("slide")
			
			w:set_dirty()
			
			w:layout()
			w:build_m4()

		end
		
--mark as dirty
		if master.active~=old_active then
			if master.active then master.active:set_dirty() end
			if old_active then old_active:set_dirty() end
		end
		if master.over~=old_over then
			if master.over then master.over:set_dirty() end
			if old_over then old_over:set_dirty() end
			if master.over then master.over:call_hook("over") end
		end
		
	end
--

	function master.clean_all(m)
		meta.clean_all(m)
		master.over=nil
		master.active=nil
		master.focus=nil
		master.edit=nil
		master.go_back_id=nil
		master.go_forward_id=nil
		master.ids={}
		master.timehooks={}
	end
	
	function master.dragging()

		if master.active and (master.active.class=="drag") and master.press then
			return true
		end
		
		return false
	end

--
-- Select this widget by id, so we can have a simple default action on each screen if the user hammers buttons
--
	function master.activate_by_id(id)
		master:call_descendents(function(w)
			if w.id==id then
				master.over=w
				if w.class=="textedit" then
					master.edit=w
				end
				if master.over then master.over:call_hook("over") end
			end
		end)
		
	end
	
end

return wmaster
end
