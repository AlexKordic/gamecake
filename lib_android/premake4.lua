project "lib_android"

language "C"

files { "code/*.h" , "code/*.c" }

links { "lib_lua" }

SET_KIND("StaticLib")
SET_TARGET("","lib_android")

