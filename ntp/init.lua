--[[lit-meta
  name = "zhaozg/ntp"
  version = "0.1.0"
  homepage = "https://github.com/zhaozg/luvit-ntp"
  description = "ntp module for luvit."
  tags = {"ntp","client"}
  author = { name = "George Zhao" }
  license = "MIT"
  files = {
    "**.lua"
  }
  dependencies = {
  }
]]

local debug = require'debug'
local client = require('./client')
local M = {}

M.client = client

function M.once(callback, host)
    assert(type(callback)=='function')
    host = host or 'time.windows.com'

    local c = client:new(host, function(c)
        c:query()
    end)

    c:on('error',function(...)
        c:destroy()

        callback(nil, ...)
    end)

    c:on('update',function(sec, msec, rinfo)
        sec = sec - c.tz
        c:destroy()

        xpcall(callback, debug.traceback, sec, msec, rinfo)
    end)
end


function M.run(callback, host, interval)
    assert(type(callback)=='function')
    host = host or 'time.windows.com'
    interval = interval or (5*60)

    local c = client:new(host,function(c)
        c:query()
        c:run(interval)
    end)

    c:on('error',function(...)
        callback(nil, ...)
    end)

    c:on('update',function(sec, msec, rinfo)
        sec = sec - c.tz
        callback(sec, msec, rinfo)
    end)

    return c
end

return M

