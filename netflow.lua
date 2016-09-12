
local cjson = require "cjson"
local redis = require "resty.redis"

local red = redis:new()

local proto = ngx.var["protocol"]
local src = ngx.var["src"]
local dst = ngx.var["dst"]
local ip = ngx.var["ip"]

red:set_timeout(-1)

ngx.header.content_type = "text/event-stream"
ngx.header.cache_control = "no-cache"
ngx.header.access_control_allow_origin = "*"

function connect()
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.say("1: failed to connect: ", err)
        return
    end
    local res, err = red:subscribe("suricata")
    if not res then
        ngx.say("1: failed to subscribe: ", err)
        return
    end
end

connect()

while true do
    local res, err = red:read_reply()
    if not res then
        if not err == "timeout" then
            ngx.say("1: failed to read reply: ", err)
            return
        end
        --- ngx.sleep(1)
        --- connect()
    else
        eve = cjson.decode(res[3])
        -- if eve["event_type"] == "netflow" then
        ngx.say("event: ", eve["event_type"], "\ndata: ", cjson.encode(eve), "\n")
        ngx.flush()
        --- end
    end
end
