local string=string
local table=table
local math=math

local type=type
local pairs=pairs
local ipairs=ipairs
local tostring=tostring
local setmetatable=setmetatable

--
-- Some useful functions.
--

module("wetgenes.util")




-----------------------------------------------------------------------------
--
-- safe lookup within a table that returns nil if any part of the lookup is nil
-- so we never cause an error, just returns nil
--
-----------------------------------------------------------------------------
function lookup(tab,...)
	for i,v in ipairs{...} do
		if type(tab)~="table" then return nil end
		tab=tab[v]
	end
	return tab
end
