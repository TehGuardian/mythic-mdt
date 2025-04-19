fx_version("cerulean")
game("gta5")
lua54("yes")

client_script("@mythic-base/components/cl_error.lua")
client_script("@mythic-pwnzor/client/check.lua")

server_script "@oxmysql/lib/MySQL.lua"

server_scripts {
    "shared/*.lua",
    "server/**/*.lua"
}

client_scripts {
    "shared/*.lua",
    "client/**/*.lua"
}

ui_page("ui/dist/index.html")
files { "ui/dist/index.html", "ui/dist/*.js" }

