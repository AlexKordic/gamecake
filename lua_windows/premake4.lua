
project "lua_windows"
language "C"

files {  "code/**.c" , "code/**.h" , "all.h" }
includedirs { "." , "code" }

KIND{lua="wetgenes.win.windows"}

