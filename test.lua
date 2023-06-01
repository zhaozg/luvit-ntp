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

  test('NTP ip error', function(expect)
    ntp.once(expect(function(sec, msec, rinfo)
      assert(not sec)
      assert(msec:match("^Invalid IP address or port "))
      assert(rinfo==nil)
    end), '123.456.123.123')
  end)

  test('NTP dns error', function(expect)
    ntp.once(expect(function(sec, msec, rinfo)
      assert(not sec)
      assert(msec:match("^dns ERROR") or msec=='failed to resolve domain name')
      assert(rinfo==nil)
    end), 'ntp.wrongkkhub.com')
  end)

  test('NTP timeout error', function(expect)
    ntp.once(expect(function(sec, msec, rinfo)
      assert(not sec)
      assert(msec:match("^timeout"))
      assert(rinfo==nil)
    end), 'ntp.kkhub.com')
  end)
end)

