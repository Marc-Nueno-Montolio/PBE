require 'SSD1306'
require 'socket'



disp = SSD1306::Display.new(protocol: :i2c, path: '/dev/i2c-1', address: 0x3C, width: 128, height: 64)


def scroll_text(disp, str1, str2, i, time)
	index = 0
	pos = 9
	str2 = "  " + str2 + " "
	i.times do
		while index != str2.length
			disp.font_size = 2
			disp.println str1
			disp.println ""
			disp.font_size = 2
			disp.println str2[index..pos]
			disp.display!
			sleep time
			disp.clear
			index = index +1
			pos = pos +1
		end
		
		disp.clear!
		if index == str2.length
			index = 0
			pos = 9
		end
	end
end

ip = Socket.ip_address_list[1].ip_address
wireless = `iwgetid -r`

while true
	disp.font_size = 4
	disp.println " PBE"
	disp.font_size = 2
	disp.println ""
	disp.println "Marc Nueno"
	disp.display!
	sleep 1
	disp.clear!
	scroll_text(disp, "IP Address:", ip.to_s , 1, 0.3)
	scroll_text(disp, "Wireless:", wireless , 1, 0.3)
	scroll_text(disp, "Time:", Time.now.to_s , 1, 0.3)
	
end




