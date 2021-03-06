--
-- (C) 2016 Kriss@XIXs.com
--
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local wgrd=require("wetgenes.grd")
local wstr=require("wetgenes.string")

local fbitdown=require("wetgenes.gamecake.fun.bitdown")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

local s={}

-- export the raw strings
M.textmap=s;

-- Numbers

s["0"]=[[
# # # . 
# . # . 
# . # . 
# . # . 
# # # . 
. . . . 
]]

s["1"]=[[
. # . . 
# # . . 
. # . . 
. # . . 
# # # . 
. . . . 
]]

s["2"]=[[
# # # . 
. . # . 
# # # . 
# . . . 
# # # . 
. . . . 
]]

s["3"]=[[
# # # . 
. . # . 
# # # . 
. . # . 
# # # . 
. . . . 
]]

s["4"]=[[
# . # . 
# . # . 
# # # . 
. . # . 
. . # . 
. . . . 
]]

s["5"]=[[
# # # . 
# . . . 
# # # . 
. . # . 
# # # . 
. . . . 
]]

s["6"]=[[
# # # . 
# . . . 
# # # . 
# . # . 
# # # . 
. . . . 
]]

s["7"]=[[
# # # . 
. . # . 
. . # . 
. . # . 
. . # . 
. . . . 
]]

s["8"]=[[
# # # . 
# . # . 
# # # . 
# . # . 
# # # . 
. . . . 
]]

s["9"]=[[
# # # . 
# . # . 
# # # . 
. . # . 
. . # . 
. . . . 
]]

-- letters

s["A"]=[[
# # # . 
# . # . 
# # # . 
# . # . 
# . # . 
. . . . 
]]

s["B"]=[[
# # # . 
# . # . 
# # . . 
# . # . 
# # # . 
. . . . 
]]

s["C"]=[[
# # # . 
# . . . 
# . . . 
# . . . 
# # # . 
. . . . 
]]

s["D"]=[[
# # . . 
# . # . 
# . # . 
# . # . 
# # . . 
. . . . 
]]

s["E"]=[[
# # # . 
# . . . 
# # . . 
# . . . 
# # # . 
. . . . 
]]

s["F"]=[[
# # # . 
# . . . 
# # . . 
# . . . 
# . . . 
. . . . 
]]

s["G"]=[[
# # # . 
# . . . 
# . . . 
# . # . 
# # # . 
. . . . 
]]

s["H"]=[[
# . # . 
# . # . 
# # # . 
# . # . 
# . # . 
. . . . 
]]

s["I"]=[[
# # # . 
. # . . 
. # . . 
. # . . 
# # # . 
. . . . 
]]

s["J"]=[[
. # # . 
. . # . 
. . # . 
# . # . 
# # # . 
. . . . 
]]

s["K"]=[[
# . # . 
# . # . 
# # . . 
# . # . 
# . # . 
. . . . 
]]

s["L"]=[[
# . . . 
# . . . 
# . . . 
# . . . 
# # # . 
. . . . 
]]

s["M"]=[[
# . # . 
# # # . 
# # # . 
# . # . 
# . # . 
. . . . 
]]

s["N"]=[[
# # # . 
# . # . 
# . # . 
# . # . 
# . # . 
. . . . 
]]

s["O"]=[[
. # # . 
# . # . 
# . # . 
# . # . 
# # . . 
. . . . 
]]

s["P"]=[[
# # # . 
# . # . 
# # # . 
# . . . 
# . . . 
. . . . 
]]

s["Q"]=[[
. # # . 
# . # . 
# . # . 
# # # . 
# # # . 
. . . . 
]]

s["R"]=[[
# # # . 
# . # . 
# # . . 
# . # . 
# . # . 
. . . . 
]]

s["S"]=[[
# # # . 
# . . . 
. # . . 
. . # . 
# # # . 
. . . . 
]]

s["T"]=[[
# # # . 
. # . . 
. # . . 
. # . . 
. # . . 
. . . . 
]]

s["U"]=[[
# . # . 
# . # . 
# . # . 
# . # . 
# # # . 
. . . . 
]]

s["V"]=[[
# . # . 
# . # . 
# . # . 
. # . . 
. # . . 
. . . . 
]]

s["W"]=[[
# . # . 
# . # . 
# # # . 
# # # . 
# . # . 
. . . . 
]]

s["X"]=[[
# . # . 
# . # . 
. # . . 
# . # . 
# . # . 
. . . . 
]]

s["Y"]=[[
# . # . 
# . # . 
# # # . 
. # . . 
. # . . 
. . . . 
]]

s["Z"]=[[
# # # . 
. . # . 
. # . . 
# . . . 
# # # . 
. . . . 
]]

-- lowercase

s["a"]=[[
. . . . 
# # # . 
. . # . 
# # # . 
# # # . 
. . . . 
]]

s["b"]=[[
# . . . 
# # # . 
# . # . 
# . # . 
# # # . 
. . . . 
]]

s["c"]=[[
. . . . 
# # # . 
# . . . 
# . . . 
# # # . 
. . . . 
]]

s["d"]=[[
. . # . 
# # # . 
# . # . 
# . # . 
# # # . 
. . . . 
]]

s["e"]=[[
. . . . 
# # # . 
# # # . 
# . . . 
# # # . 
. . . . 
]]

s["f"]=[[
. # # . 
. # . . 
# # # . 
. # . . 
. # . . 
. . . . 
]]

s["g"]=[[
. . . . 
# # # . 
# # # . 
. . # . 
# # # . 
. . . . 
]]

s["h"]=[[
# . . . 
# # # . 
# . # . 
# . # . 
# . # . 
. . . . 
]]

s["i"]=[[
. . . . 
# # # . 
. # . . 
. # . . 
# # # . 
. . . .
]]

s["j"]=[[
. . . . 
. . # . 
. . # . 
# . # . 
# # # . 
. . . . 
]]

s["k"]=[[
# . . . 
# . # . 
# # . . 
# . # . 
# . # . 
. . . . 
]]

s["l"]=[[
# # . . 
. # . . 
. # . . 
. # . . 
. # # . 
. . . . 
]]

s["m"]=[[
. . . . 
# # # . 
# # # . 
# . # . 
# . # . 
. . . . 
]]

s["n"]=[[
. . . . 
# # # . 
# . # . 
# . # . 
# . # . 
. . . . 
]]

s["o"]=[[
. . . . 
# # # . 
# . # . 
# . # . 
# # # . 
. . . . 
]]

s["p"]=[[
. . . . 
# # # . 
# . # . 
# # # . 
# . . . 
. . . . 
]]

s["q"]=[[
. . . . 
# # # . 
# . # . 
# # # . 
. . # . 
. . . . 
]]

s["r"]=[[
. . . . 
# # # . 
# . . . 
# . . . 
# . . . 
. . . . 
]]

s["s"]=[[
. . . . 
# # # . 
# # . . 
. # # . 
# # # . 
. . . . 
]]

s["t"]=[[
. # . . 
# # # . 
. # . . 
. # . . 
. # # . 
. . . . 
]]

s["u"]=[[
. . . . 
# . # . 
# . # . 
# . # . 
# # # . 
. . . . 
]]

s["v"]=[[
. . . . 
# . # . 
# . # . 
# . # . 
. # . . 
. . . . 
]]

s["w"]=[[
. . . . 
# . # . 
# . # . 
# # # . 
# # # . 
. . . . 
]]

s["x"]=[[
. . . . 
# . # . 
. # . . 
. # . . 
# . # . 
. . . . 
]]

s["y"]=[[
. . . . 
# . # . 
# # # . 
. . # . 
# # # . 
. . . . 
]]

s["z"]=[[
. . . . 
# # # . 
. # # . 
# # . . 
# # # . 
. . . . 
]]


-- symbols

s["!"]=[[
. # . . 
. # . . 
. # . . 
. . . . 
. # . . 
. . . . 
]]

s["\""]=[[
# . # . 
# . # . 
. . . . 
. . . . 
. . . . 
. . . . 
]]

s["#"]=[[
# . # . 
# # # . 
# . # . 
# # # . 
# . # . 
. . . . 
]]

s["$"]=[[
. # # . 
# # . . 
# # # . 
. # # . 
# # . . 
. . . . 
]]

s["%"]=[[
# . . . 
. . # . 
. # . . 
# . . . 
. . # . 
. . . . 
]]

s["&"]=[[
. # . . 
# . # . 
. # . . 
# . # . 
. # # . 
. . . . 
]]

s["'"]=[[
. # . . 
. # . . 
. . . . 
. . . . 
. . . . 
. . . . 
]]

s["("]=[[
. # . . 
# . . . 
# . . . 
# . . . 
. # . . 
. . . . 
]]

s[")"]=[[
. # . . 
. . # . 
. . # . 
. . # . 
. # . . 
. . . . 
]]

s["*"]=[[
# . # . 
. # . . 
# # # . 
. # . . 
# . # . 
. . . . 
]]

s["+"]=[[
. . . . 
. # . . 
# # # . 
. # . . 
. . . . 
. . . . 
]]

s[","]=[[
. . . . 
. . . . 
. . . . 
# . . . 
# . . . 
. . . . 
]]

s["-"]=[[
. . . . 
. . . . 
# # # . 
. . . . 
. . . . 
. . . . 
]]

s["."]=[[
. . . . 
. . . . 
. . . . 
# # . . 
# # . . 
. . . . 
]]

s["/"]=[[
. . . . 
. . # . 
. # . . 
# . . . 
. . . . 
. . . . 
]]

s[":"]=[[
. # # . 
. # # . 
. . . . 
. # # . 
. # # . 
. . . . 
]]

s[";"]=[[
. # # . 
. # # . 
. . . . 
. # . . 
. # . . 
. . . . 
]]

s["<"]=[[
. . # . 
. # . . 
# . . . 
. # . . 
. . # . 
. . . . 
]]

s["="]=[[
. . . . 
# # # . 
. . . . 
# # # . 
. . . . 
. . . . 
]]

s[">"]=[[
# . . . 
. # . . 
. . # . 
. # . . 
# . . . 
. . . . 
]]

s["?"]=[[
# # # . 
# . # . 
. # # . 
. # . . 
. # . . 
. . . . 
]]

s["@"]=[[
# # # . 
# . # . 
# # # . 
# . . . 
# # # . 
. . . . 
]]

s["="]=[[
. . . . 
# # # . 
. . . . 
# # # . 
. . . . 
. . . . 
]]

s["["]=[[
# # . . 
# . . . 
# . . . 
# . . . 
# # . . 
. . . . 
]]

s["\\"]=[[
. . . . 
# . . . 
. # . . 
. . # . 
. . . . 
. . . . 
]]

s["]"]=[[
. # # . 
. . # . 
. . # . 
. . # . 
. # # . 
. . . . 
]]

s["^"]=[[
. # . . 
# . # . 
. . . . 
. . . . 
. . . . 
. . . . 
]]

s["_"]=[[
. . . . 
. . . . 
. . . . 
. . . . 
# # # . 
. . . . 
]]

s["`"]=[[
. # . . 
. . # . 
. . . . 
. . . . 
. . . . 
. . . . 
]]

s["{"]=[[
. # . . 
# . . . 
. # . . 
# . . . 
. # . . 
. . . . 
]]

s["|"]=[[
. # . . 
. # . . 
. # . . 
. # . . 
. # . . 
. . . . 
]]

s["}"]=[[
. # . . 
. . # . 
. # . . 
. . # . 
. # . . 
. . . . 
]]

s["~"]=[[
# . # . 
. # . . 
. . . . 
. . . . 
. . . . 
. . . . 
]]

-- build a bitmap which is a 128x1 array of characters.
M.grd_mask=wgrd.create("U8_RGBA_PREMULT",128*4,1*6,1)

M.build_grd=function(g,w) return fbitdown.font_grd(s,g,4,6,w) end

M.build_grd(M.grd_mask,128)

