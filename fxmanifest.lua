
lua54("yes")
fx_version("cerulean")
game("gta5")

client_script("@mythic-base/components/cl_error.lua")
client_script("@cm-pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

client_scripts({ "shared/*.lua", "client/**/*.lua" })

server_scripts({ "shared/*.lua", "server/**/*.lua" })

ui_page("ui/dist/index.html")

files({ "ui/dist/index.html", "ui/dist/*.js" })
