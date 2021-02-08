local ntp = require'./ntp'

local host = os.getenv("NTP_HOST")
host = host or 'time.windows.com'

require('tap')(function(test)
  test('NTP once', function(expect)
    ntp.once(expect(function(sec, msec, rinfo)
      local d = os.date('%c', sec)
      p(d, sec, msec)
      p(rinfo)
    end), host)
  end)

  local cnt = 0
  test('NTP update', function(expect)
    local c
    c = ntp.run(function(sec, msec, rinfo)
      local d = os.date('%c', sec)
      p(d, sec, msec)
      p(rinfo)
      if cnt==10 then
        c:destroy()
      else
        cnt = cnt + 1
        print(cnt)
      end
    end, host, 1)
  end)
end)

