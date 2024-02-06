import string
import mqtt


class mmw_radar : Driver
	var ser  	# Serial object
	var mov		# {bool} Movement detected
	var occ		# {bool} Occupancy detected
	var mth1	# {float} 0~2.8m Sensitivity. `10` to `600`, step: `5`
	var mth2	# {float} 2.8~8m Sensitivity. `5` to `300`, step: `5`
	var mth3	# {float} >8m Sensitivity. `5` to `200`, step: 5
	var rmax	# {float} Max detection distance. `0.4` to `12`, step: `0.2`
	var topic	# {string} MQTT topic. Automatically populated


	#-	Constructor
		rx	{int} Serial read GIOP
		tx	{int} Serial send GIOP
		mth1	{float} 0~2.8m Sensitivity. Default of `60.0`
		mth2	{float} 2.8~8m Sensitivity. Default of `30.0`
		mth3	{float} >8m Sensitivity. Default of `20.0`
		rmax	{float} Max detection distance. Default of `8.0`
	-#
	def init(rx, tx, mth1, mth2, mth3, rmax)
		self.mov  = false
		self.occ = false

		if !mth1	mth1 = 60.0		end
		if !mth2	mth2 = 30.0		end
		if !mth3	mth3 = 20.0		end
		if !rmax 	rmax = 8.0		end

		self.mth1 = mth1
		self.mth2 = mth2
		self.mth3 = mth3
		self.rmax = rmax

		self.ser = serial(rx, tx, 115200, serial.SERIAL_8N1)

		self.radar_send("mth1", self.mth1)
		self.radar_send("mth2", self.mth2)
		self.radar_send("mth3", self.mth3)
		self.radar_send("rmax", self.rmax)

		self.topic = tasmota.cmd('Status ', true)['Status']['Topic']

		tasmota.add_driver(self)
	end


	#-	Send serial command to radar

		cmd "mth1|mth2|mth3|rmax"
		val Float
	-#
	def radar_send(cmd, val)
		var msg = string.format(cmd == "rmax" ? "%s=%.1f" : "%s=%.0f",cmd, val)

		self.ser.flush()
		self.ser.write(bytes().fromstring(msg))
	end


	#-	Main loop - Read from radar via serial
	-#
	def every_100ms()
		var new_occ = false
		var new_mov = false

		if self.ser.available() > 0
			var msg = self.ser.read()

			if size(msg) > 0
				# occ
				if msg[0] == 0x6F
					new_occ = true

				# mov
				elif msg[0] == 0x6D
					new_occ = true
					new_mov = true
				end
			end
		end

		if new_occ != self.occ
			self.occ = new_occ
			mqtt.publish("tele/" + self.topic + "/OCC", self.occ ? "true" : "false", true)
		end

		if new_mov != self.mov
			self.mov = new_mov
			mqtt.publish("tele/" + self.topic + "/MOV", self.mov ? "true" : "false", true)
		end
	end

end


# Init driver
var radar = mmw_radar(16, 17)
tasmota.add_driver(radar)


#- Register send command
	payload_json `{"set": "mth1|mth2|mth3|rmax", "value": FLOAT }`
-#
def radar_send(cmd, idx, payload, payload_json)
	radar.radar_send(payload_json['set'], real(payload_json['value']))
	tasmota.resp_cmnd_done()
end

tasmota.add_cmd('RadarSend', radar_send)
