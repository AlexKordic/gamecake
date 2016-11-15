--
-- (C) 2013 Kriss@XIXs.com
--
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,luaload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local bit=require('bit')
local grd=require('wetgenes.grd')
local pack=require('wetgenes.pack')
local tardis=require('wetgenes.tardis')

local wzips=require("wetgenes.zips")
local wstr=require("wetgenes.string")


local apps=apps

local function explode_color(c)

	local r,g,b,a
	
	a=bit.band(bit.rshift(c,24),0xff)
	r=bit.band(bit.rshift(c,16),0xff)
	g=bit.band(bit.rshift(c, 8),0xff)
	b=bit.band(c,0xff)

	return r/0xff,g/0xff,b/0xff,a/0xff
end

local function implode_color(r,g,b,a)

	if type(r)=="table" then a=r[4] b=r[3] g=r[2] r=r[1] end -- convert from table?
	
	local c
	
	c=             bit.band(b*0xff,0xff)
	c=c+bit.lshift(bit.band(g*0xff,0xff),8)
	c=c+bit.lshift(bit.band(r*0xff,0xff),16)
	c=c+bit.lshift(bit.band(a*0xff,0xff),24)

	return c
end



--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(oven,wskin)
wskin=wskin or {}

local gl=oven.gl
local cake=oven.cake
local images=cake.images
local sheets=cake.sheets
local canvas=cake.canvas
local font=canvas.font
local flat=canvas.flat

local layouts=cake.layouts


local mode=nil
local texs={}

local margin=0 -- whitespace
local border=0 -- solidspace
--
-- unload a skin, go back to the "builtin" default
--
function wskin.unload()

	mode=nil
	texs={}
	
end


--
-- load a skin
--
function wskin.load(name)
	
--	wskin.unload()
	
	if name then -- load a named skin
	
--		if name=="soapbar" then
			mode=mode or name
			
			images.TEXTURE_MIN_FILTER=gl.LINEAR -- disable mipmapping since GL picks the wrong mips in this case anyhow...
			images.loads{
				"wskins/"..name,
			}
			images.TEXTURE_MIN_FILTER=nil
			margin=15
			border=0
			
--		end
			
	end

end


--
-- add meta functions
--
function wskin.setup(def)

	local master=def.master
	local meta=def.meta
	local win=def.win

	
	local cache_arrays=nil
	local cache_array=nil
	local cache_binded=nil --images.get("wskins/soapbar")


	local function cache_smart_bind(img)
		if not img then
			gl.BindTexture(gl.TEXTURE_2D, 0)
		elseif img[1] then
			gl.BindTexture(gl.TEXTURE_2D, img[1] )
		elseif img.gl then
			images.bind(img)
		end
	end

	local function cache_bind(img)
		img=img or images.get("wskins/soapbar")
		local old=cache_binded
		cache_binded=img
		if cache_arrays then
			cache_array=cache_arrays[img]
			if not cache_array then
				cache_array={}
				cache_arrays[img]=cache_array
				cache_arrays[#cache_arrays+1]=img
			end
		else
			cache_array=nil
			cache_smart_bind(img)
		end
		return old
	end

	local function cache_begin()
		local t={}
		local old=cache_arrays
		cache_arrays=t

		local oldb=cache_bind()
		return function()
			gl.Color(1,1,1,1)
			for i,n in ipairs(cache_arrays) do
				cache_smart_bind(n)
				flat.tristrip("rawuvrgba",cache_arrays[n])
			end
			cache_arrays=old
			cache_bind(oldb)
		end
	end

	local function draw_quad(x1,y1,x2,y2,x3,y3,x4,y4)

		local t=cache_array or {}
	--	if cache_array then t=cache_array else t={} end
		local function draw()
			if cache_array then return end
			flat.tristrip("rawuvrgba",t)
		end
		local ht=#t

		if y4 then
			local r,g,b,a=gl.color_get_rgba()
			local v1=gl.apply_modelview( {x1,y1,0,1} )
			local v2=gl.apply_modelview( {x2,y2,0,1} )
			local v3=gl.apply_modelview( {x4,y4,0,1} )
			local v4=gl.apply_modelview( {x3,y3,0,1} )
			for i,v in ipairs{
				v1[1],v1[2],v1[3],		-2,-2,	r,g,b,a,
				v1[1],v1[2],v1[3],		-2,-2,	r,g,b,a,
				v2[1],v2[2],v2[3],		-2,-2,	r,g,b,a,
				v3[1],v3[2],v3[3],		-2,-2,	r,g,b,a,
				v4[1],v4[2],v4[3],		-2,-2,	r,g,b,a,
				v4[1],v4[2],v4[3],		-2,-2,	r,g,b,a,
			} do
				t[ht+i]=v
			end
		else
			local r,g,b,a=gl.color_get_rgba()
			local v1=gl.apply_modelview( {x1,y1,0,1} )
			local v2=gl.apply_modelview( {x2,y1,0,1} )
			local v3=gl.apply_modelview( {x1,y2,0,1} )
			local v4=gl.apply_modelview( {x2,y2,0,1} )
			for i,v in ipairs{
				v1[1],v1[2],v1[3],		-2,-2,	r,g,b,a,
				v1[1],v1[2],v1[3],		-2,-2,	r,g,b,a,
				v2[1],v2[2],v2[3],		-2,-2,	r,g,b,a,
				v3[1],v3[2],v3[3],		-2,-2,	r,g,b,a,
				v4[1],v4[2],v4[3],		-2,-2,	r,g,b,a,
				v4[1],v4[2],v4[3],		-2,-2,	r,g,b,a,
			} do
				t[ht+i]=v
			end
		end
		
		draw()
	end


	local function draw33(id,tw,th, mw,mh, vxs,vys, vw,vh)

		local uvs={
			{0.0,0.0,0.5,0.5},
			{0.5,0.0,0.5,0.5},
			{0.0,0.5,0.5,0.5},
			{0.5,0.5,0.5,0.5},
		}
		local uv=uvs[id]

			
	--		local vw,vh=512,52
	--		local mw,mh=24,24

			local force_tww,force_thh
			
			if mw*4>tw then twwidx=1 end -- mipmap hack for small buttons
			if mh*4>th then thhidx=1 end

			if mw*2 > vw then mw=vw/2 end
			if mh*2 > vh then mh=vh/2 end

			
			local tww={mw/tw,(tw-2*mw)/tw,mw/tw}
			local thh={mh/th,(th-2*mh)/th,mh/th}
			local vww={mw,vw-2*mw,mw}
			local vhh={mh,vh-2*mh,mh}
			

				local t=cache_array or {}
				local function drawbox() -- draw all 9 parts in one go
					if cache_array then return end
					flat.tristrip("rawuvrgba",t)
				end
				local function tdrawbox( tx,ty, vx,vy , txp,typ, vxp,vyp )
				
					tx=tx*uv[3]+uv[1]
					ty=ty*uv[4]+uv[2]
					txp=txp*uv[3]
					typ=typ*uv[4]
				
					local ht=#t
					
					local r,g,b,a=gl.color_get_rgba()
					local v1=gl.apply_modelview( {vx,vy,0,1} )
					local v2=gl.apply_modelview( {vx+vxp,vy,0,1} )
					local v3=gl.apply_modelview( {vx,vy+vyp,0,1} )
					local v4=gl.apply_modelview( {vx+vxp,vy+vyp,0,1} )
					
					for i,v in ipairs{
						v1[1],	v1[2],	v1[3],	tx,		ty, 		r,g,b,a,	-- doubletap hack so we can start at any location
						v1[1],	v1[2],	v1[3],	tx,		ty, 		r,g,b,a,
						v2[1],	v2[2],	v2[3],	tx+txp,	ty, 		r,g,b,a,
						v3[1],	v3[2],	v3[3],	tx,		ty+typ, 	r,g,b,a,
						v4[1],	v4[2],	v4[3],	tx+txp,	ty+typ, 	r,g,b,a,
						v4[1],	v4[2],	v4[3],	tx+txp,	ty+typ, 	r,g,b,a, -- doubletap hack so we can start at any location
					} do
						t[ht+i]=v
					end
				end
							
			local tx,ty=0,0
			local vx,vy=vxs,vys-- -vw/2,vh/2

				for iy=1,3 do
					tx=0
					vx=vxs-- -vw/2
					for ix=1,3 do

						tdrawbox( tx,ty, vx,vy , tww[twwidx or ix],thh[thhidx or iy], vww[ix],vhh[iy] ) -- fake texture sample to con mipmap mode

						tx=tx+tww[ix]
						vx=vx+vww[ix]
					end
					ty=ty+thh[iy]
					vy=vy+vhh[iy]
				end

			drawbox()


	end
		
--
-- display this widget and its sub widgets
--
	function meta.draw_base(widget,f)
		local w=widget
	
		if debug_hook then debug_hook("draw",widget) end

--		gl.PopMatrix() -- expect the base to be pushed
		gl.PushMatrix()
--		gl.Translate(widget.px*widget.parent.sx,widget.py*widget.parent.sy,0)
		gl.Translate(widget.px,widget.py,0)
		
		local wsx=1
		local wsy=1
		
		if widget.anim then
			widget.anim:draw()		
		end

		if w.sx~=1 or w.sy~=1 then
			if widget.smode=="center" then
				gl.Translate(w.hx/2,w.hy/2,0)
				gl.Scale(w.sx,w.sy,1)
				gl.Translate(-w.hx/2,-w.hy/2,0)
			else
				gl.Scale(w.sx,w.sy,1)
			end
		end


-- save draw matrix for later use, probably need to remove master.matrix from this before it is useful?
		widget.matrix=gl.SaveMatrix()

		if widget.pan_px and widget.pan_py and not widget.fbo  then -- fidle everything
--print("draw",widget.pan_px,widget.pan_py)
			gl.Translate(-widget.pan_px*wsx,-widget.pan_py*wsy,0)
		end
		
--[[
		if widget.fbo then
--print("draw",widget.pan_px,widget.pan_py)
			if widget.fbo.w~=widget.hx or widget.fbo.h~=widget.hy then -- resize so we need a new fbo
--print("new fbo",widget.sx,widget.sy)
				widget.fbo:resize(widget.hx,widget.hy,widget.hz or 0)
				widget.dirty=true -- flag redraw
			end				
		end
]]


--widget.old_layout
--widget.layout

if ( not widget.fbo ) or widget.dirty then -- if no fbo and then we are always dirty... Dirty, dirty, dirty.

local cache_draw
local font_cache_draw

		if widget.fbo then
--print("into fbo"..wstr.dump(widget.fbo))

			widget.fbo:bind_frame()
			widget.lay=layouts.create{parent={x=0,y=0,w=widget.fbo.w,h=widget.fbo.h}}

			gl.Disable(gl.DEPTH_TEST)
			gl.Disable(gl.CULL_FACE)
			gl.Color(1,1,1,1)
--			canvas.gl_default()
			
			gl.MatrixMode(gl.PROJECTION)
			gl.PushMatrix()
			
			gl.MatrixMode(gl.MODELVIEW)
			gl.PushMatrix()

			widget.old_lay=widget.lay.apply(nil,nil,widget.fbo_fov)

			gl.ClearColor(0,0,0,0)
			gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

			if widget.pan_px and widget.pan_py then -- fidle everything
				gl.Translate(-widget.pan_px*wsx,-widget.pan_py*wsy,0)
			end
			
			gl.PushMatrix() -- put new base matrix onto stack so we can pop to restore?


			if not widget.fbo_batch_draw_disable then
				cache_draw=cache_begin()
				sheets.batch_start()
				font_cache_draw=font.cache_begin()
			end
		end

		
		widget.dirty=nil

		
		if f then f(widget) end		-- this does the custom drawing
		

		for i,v in ipairs(widget) do -- iterate on children
			if not v.fbo or not v.dirty then -- terminate recursion at dirty fbo
				if not v.hidden then v:draw() end
			end
		end		

		if widget.fbo then -- we have drawn into the fbo

			gl.PopMatrix()

			if cache_draw then
				cache_draw()
				sheets.batch_stop()
				sheets.batch_draw()
			end
			if font_cache_draw then
				font_cache_draw()
			end

			gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
			
			widget.old_lay.restore() --restore old viewport
			gl.MatrixMode(gl.PROJECTION)
			gl.PopMatrix()			
			gl.MatrixMode(gl.MODELVIEW)
			gl.PopMatrix()


			widget.lay=nil
			widget.old_lay=nil

-- call mipmap twice because driver bugs
-- gl.Flush did not help but this does?
			
			widget.fbo:mipmap()
			widget.fbo:mipmap()
		end
		
else -- we can only draw once

		if widget.fbo then -- we need to draw our cached fbo
		
			gl.Disable(gl.DEPTH_TEST)
			gl.Disable(gl.CULL_FACE)
			gl.Color(1,1,1,1)

			local old=cache_bind({widget.fbo.texture})

			local t=cache_array or {}
			
			local ht=#t
			
			local r,g,b,a=gl.color_get_rgba()
			local v1=gl.apply_modelview( {0,			0,				0,1} )
			local v2=gl.apply_modelview( {widget.fbo.w,	0,				0,1} )
			local v3=gl.apply_modelview( {0,			widget.fbo.h,	0,1} )
			local v4=gl.apply_modelview( {widget.fbo.w,	widget.fbo.h,	0,1} )

			for i,v in ipairs{
				v1[1],	v1[2],	v1[3],	0,				widget.fbo.uvh,	r,g,b,a,	-- doubletap hack
				v1[1],	v1[2],	v1[3],	0,				widget.fbo.uvh,	r,g,b,a,
				v2[1],	v2[2],	v2[3],	widget.fbo.uvw,	widget.fbo.uvh,	r,g,b,a,
				v3[1],	v3[2],	v3[3],	0,				0, 				r,g,b,a,
				v4[1],	v4[2],	v4[3],	widget.fbo.uvw,	0, 				r,g,b,a,
				v4[1],	v4[2],	v4[3],	widget.fbo.uvw,	0,			 	r,g,b,a, 	-- doubletap hack
			} do
				t[ht+i]=v
			end

			if not cache_array then
				flat.tristrip("rawuvrgba",t)
			end
			
			cache_bind(old)

		end
		
end

		gl.PopMatrix()
		
		return widget
		
	end
	
	function meta.iterate_draw_color(widget)
		local layer=0
		return function()
			layer=layer+1
			local ret,r,g,b,a=meta.draw_color(widget,layer)
			if ret then return layer end
			return nil
		end 
	end
	function meta.draw_color(widget,layer)
		local hilight=0
		local w=widget
		local master=widget.master
		local buttdown=false
		if ( master.press and master.over==widget ) or widget.state=="selected" then
			buttdown=true
		end

		local c={explode_color(widget.color)}

		if widget.highlight=="none" then
			if layer>1 then
				return false
			else
				gl.Color( c[1],c[2],c[3],c[4] )
			end
		elseif master.over==widget or widget.parent==master.active then
			if buttdown then
				if layer>1 then	
--					local a=1/16
--					gl.Color( c[1]*a,c[2]*a,c[3]*a,0 )
					return false
				else
					local a=15/16
					gl.Color( c[1]*a,c[2]*a,c[3]*a,c[4] )
				end
			else
				if layer>1 then
--					local a=2/16
--					gl.Color( c[1]*a,c[2]*a,c[3]*a,0 )
					return false
				else
					gl.Color( c[1],c[2],c[3],c[4] )
				end
			end
		else
				if layer>1 then
					return false
				else
					local a=13/16
					if widget.state=="selected" then a=15/16 end
					gl.Color( c[1]*a,c[2]*a,c[3]*a,c[4] )
				end
		end
		if layer>2 then return false end
		return true
	end
	
	function meta.draw(widget)
		local wsx=1
		local wsy=1

		local w=widget
		local master=widget.master
	
		meta.draw_base(widget,function(widget)
						
		local txp,typ=0,0
		
		if widget.color then -- need a color to draw, so no color, no draw
		
			local style=widget.style
			
			if not style then -- make assumptions
			
				style="button" -- default

				if  widget.class=="textedit" then
				
					style="indent" -- draw upside down button?
					
				elseif (not widget.hooks) then -- probably not a button
				
					style="flat"
				
				end
			end
						
			local buttdown=false
			if ( master.press and master.over==widget ) or widget.state=="selected" then
				buttdown=true
			end

			local hx=widget.hx
			local hy=widget.hy
			local bb=2
			local tl={1,1,1,0.25}
			local br={0,0,0,0.25}
			tl[1]=tl[1]*tl[4]
			tl[2]=tl[2]*tl[4]
			tl[3]=tl[3]*tl[4]
			br[1]=br[1]*br[4]
			br[2]=br[2]*br[4]
			br[3]=br[3]*br[4]
			
			if buttdown and style~="flat" then -- flip highlight on button press for builtin style
				tl,br=br,tl
				txp=1
				typ=1
			end
			
for layer in meta.iterate_draw_color(widget) do -- something to draw, color has been set for this layer


			local mode=mode
			if widget.skin then
				local tt=type(widget.skin)
				if     tt=="number" then mode=nil -- use builtin 
				elseif tt=="string" then mode=widget.skin
				end
			end
			
			if widget.sheet then -- custom graphics

				sheets.get(widget.sheet):draw(widget.sheet_id or 1,widget.sheet_px or 0,widget.sheet_py or 0,0,widget.sheet_hx or hx,widget.sheet_hy or hy)
			
			elseif mode then -- got some images to play with
			
				if style=="flat" then
				
					images.bind(images.get("wskins/"..mode))
					txp=0
					typ=-1

					draw33(4,128,128, 24,24, 0-margin,0-margin, hx+(margin*2),hy+(margin*2))

				elseif style=="indent" then

					images.bind(images.get("wskins/"..mode))
					txp=0
					typ=0

					draw33(3,128,128, 24,24, 0-margin,0-margin, hx+(margin*2),hy+(margin*2))

				elseif style=="button" then

					if ( master.press and master.over==widget ) or widget.state=="selected" then
						images.bind(images.get("wskins/"..mode))
						txp=0
						typ=-1
						draw33(2,128,128, 24,24, 0-margin,0-margin, hx+(margin*2),hy+(margin*2))
					else
						images.bind(images.get("wskins/"..mode))
						txp=0
						typ=-2
						draw33(1,128,128, 24,24, 0-margin,0-margin, hx+(margin*2),hy+(margin*2))
					end
					
				end
								
			
			else -- builtin
			
			
			draw_quad(	0,		0,
						hx,		0,
						hx,		hy,
						0,		hy)
			gl.Color( tl[1],tl[2],tl[3],tl[4] )
			draw_quad(	0,		0,
						hx,		0,
						hx-bb,	bb,
						0+bb, 	bb)
			draw_quad(	0,		0,
						0+bb,	bb,
						0+bb, 	hy-bb,
						0,    	hy)
			gl.Color( br[1],br[2],br[3],br[4] )
			draw_quad( hx,  	hy,
						0,  	hy,
						0+bb,	hy-bb,
						hx-bb,	hy-bb)
			draw_quad(  hx,    0,
						hx,    hy,
						hx-bb, hy-bb,
						hx-bb, bb)
			end
end
			
		end
		
		if widget.sheet_over then -- custom graphics, on top of a button
			gl.Color( 1,1,1,1 )
			sheets.get(widget.sheet_over):draw(widget.sheet_id or 1,widget.sheet_px or 0,(widget.sheet_py or 0)+typ,0,widget.sheet_hx or hx,widget.sheet_hy or hy)
		end

		if widget.text then
		
			local fy=widget:bubble("text_size") or 16
			local f=widget:bubble("font") or 1
--			f=1
			if f then
				if type(f)=="number" then
				else
					typ=typ-fy/8 -- reposition font slightly as fonts other than the builtin probably have descenders
				end
			end
			
			font.set(cake.fonts.get(f))
			font.set_size(fy,0)

			local lines
			
			if widget.text_align=="wrap" then
				lines=font.wrap(widget.text,{w=widget.hx}) -- break into lines
				widget.lines=lines -- remember wraped text
			else
				lines={widget.text}
			end

			local ty=typ
			local c=widget.text_color
			if widget.text_color_over then
				if master.over==widget then
					c=widget.text_color_over
				end
			end
			
			for i,line in ipairs(lines) do
			
				local tx=font.width(line)
				
				if widget.text_align=="left" or widget.text_align=="wrap" then
					tx=0
				elseif widget.text_align=="right" then
					tx=(widget.hx-tx)
				elseif widget.text_align=="centerx" then
					tx=(widget.hx-tx)/2
				elseif widget.text_align=="left_center" then
					tx=fy/2
					ty=((widget.hy-fy)/2)+typ
				else -- center a single line vertically as well
					tx=(widget.hx-tx)/2 
					ty=((widget.hy-fy)/2)+typ
				end
				
				tx=tx+txp
--				ty=ty+typ
				
				if i==1 then -- remember topleft of text position for first line
					widget.text_x=tx
					widget.text_y=ty
				end

				if widget.text_color_shadow then
					gl.Color( pack.argb8_pmf4(widget.text_color_shadow) )
					font.set_xy((tx+1)*wsx,(ty+1)*wsy)
					font.draw(line)
				end
				
				gl.Color( pack.argb8_pmf4(c) )
				font.set_xy((tx)*wsx,(ty)*wsy)
--print(wstr.dump(line))
				font.draw(line)
				
				if widget.class=="textedit" then -- hack
					if widget.master.focus==widget or widget.master.edit==widget then --only draw curser in active widget
						if widget.master.throb>=128 then
							local sw=font.width(widget.text:sub(1,widget.data.str_idx))

							font.set_xy((tx+sw)*wsx,(ty)*wsy)
							font.draw("_")
						end
						
						if widget.data.str_select~=0 then
							local s1=font.width(widget.text:sub(1,widget.data.str_idx))
							local s2=font.width(widget.text:sub(1,widget.data.str_idx+widget.data.str_select))

							local x0,x1= (tx+s1)*wsx , (tx+s2)*wsx
							local y0,y1= (ty)*wsy	, (ty+fy)*wsy
							
							local c1,c2,c3,c4=pack.argb8_pmf4(c)
							gl.Color( c1,c2,c3,c4*0.25 )

							draw_quad(x0,y0,x1,y0,x1,y1,x0,y1)

						end
						
					end
				end

				ty=ty+fy
			end
		end
		
		end)
		
		return widget
	end



end

return wskin
end