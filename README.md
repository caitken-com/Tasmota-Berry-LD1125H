# Tasmota-Berry-LD1125H
Berry script driver for LD1125H mmWave sensor

![Wiring diagram](https://github.com/caitken-com/Tasmota-Berry-LD1125H/blob/main/LD1125H_wiring.png?raw=true)

## Driver class `mmw_radar(rx, tx, mth1, mth2, mth3, rmax)`

- `rx`	{int} Serial read GIOP. Currently set to `16`
- `tx`	{int} Serial send GIOP. Currently set to `17`
- `mth1`	{float} Optional 0~2.8m Sensitivity. Default of `60.0`. Range: `10` to `600`
- `mth2`	{float} Optional 2.8~8m Sensitivity. Default of `30.0`. Range: `5` to `300`
- `mth3`	{float} Optional >8m Sensitivity. Default of `20.0`. Range: `5` to `200`
- `rmax`	{float} Optional Max detection distance. Default of `8.0`. Range: `0.4` to `12`

## `RadarSend` command

Set sensitivity levels of the mmWave sensor

### MQTT topc:

`cmnd/%id%/RadarSend`

### MQTT payload:

```json
{"set": "mth1|mth2|mth3|rmax", "value": 60.0 }
```
- `set` {string} Either: `mth1`, `mth2`, `mth3`, or `rmax`.
- `value` {float} Value to set.

## Published topics to subscribe to

### Occupancy detected

`tele/%id%/OCC` Payload is {boolean} 

 ### Movement detected

 `tele/%id%/MOV` Payload is {boolean} 
