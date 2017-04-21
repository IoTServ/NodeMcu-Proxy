id = 'your id'
ssid = 'ssid'
ssidpwd = 'ssid password'  --view on http://www.mcunode.com/proxy/<yourid>/<anystring> like:http://www.mcunode.com/proxy/4567/index.html
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid,ssidpwd)    --set your ap info !!!!!!
wifi.sta.autoconnect(1)
led1 = 3  
led2 = 4  
gpio.mode(led1, gpio.OUTPUT)  
gpio.mode(led2, gpio.OUTPUT)  
function startServer()
conn=net.createConnection(net.TCP, 0) 
conn:on("connection", function(conn, c)
conn:send(id)
tmr.alarm(2, 30000, 1, function() 
	conn:send(' ')
end)
end)
conn:on("receive", function(conn, pl)
		local _, _, method, path, vars = string.find(pl, "([A-Z]+) (.+)?(.+) HTTP");
		local buf = "";
		local _GET = {}  
        if (vars ~= nil)then  
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do  
                _GET[k] = v
            end  
        end
        buf = buf.."<h1> ESP8266 Web Server</h1>";  
        buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a> <a href=\"?pin=OFF1\"><button>OFF</button></a></p>";  
        buf = buf.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a> <a href=\"?pin=OFF2\"><button>OFF</button></a></p>"..'<h3>Raw Data To MCU:</h3><br>'..pl;
        local _on,_off = "",""  
        if(_GET.pin == "ON1")then  
            gpio.write(led1, gpio.HIGH);
			print('on led1')
        elseif(_GET.pin == "OFF1")then  
            gpio.write(led1, gpio.LOW);
			print('off led1')
        elseif(_GET.pin == "ON2")then  
            gpio.write(led2, gpio.HIGH);
			print('on led2')
        elseif(_GET.pin == "OFF2")then  
            gpio.write(led2, gpio.LOW);
			print('off led2')
        end
		conn:send(buf); 
        collectgarbage(); end)
conn:connect(8001,"www.mcunode.com")
end
tmr.alarm(1, 1000, 1, function() 
   if wifi.sta.getip()==nil then
		print("Connect AP, Waiting...") 
   else
		tmr.stop(1)
		startServer()
      
   end
end)
