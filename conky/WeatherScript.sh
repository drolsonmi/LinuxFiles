#!/bin/bash

station="$1.xml"
wdir='/tmp/weather'
color="FFA300"

update_xml() {
	if [ ! -e "$station" ]; then
		wget -q http://w1.weather.gov/xml/current_obs/${station}
		[ -e "$station" ] && touch "${station}"
	else
		# dtime: time the .xml file was downloaded
		# otime: time the weather data was observed
		# ctime: current time (time this script is being run)
		dtime=$(stat -c %Y $station)
		otime=$(date -d "$utime" +%s)
		ctime=$(date +%s)

                dtime=0
                otime=0
                ctime=1

		if (( "$otime" + 4507 < "$ctime" )); then
			if (( "$dtime" + 307 < "$ctime" )); then
				wget -q -O "$station" http://w1.weather.gov/xml/current_obs/${station}
				[ -e "$station" ] && touch "${station}"
			fi
		fi
	fi
}

from_xml() { xmllint -xpath "//$1" - <<< "$xml" | sed 's/<[^>]*>//g'; }
	
[ -d "$wdir" ] || mkdir -p "$wdir"
cd "$wdir" || exit 1

xml=''
[ -r $station ] && xml="$(< $station)"
( update_xml >/dev/null 2>&1 ) &

if [ -n "$xml" ]; then
	location=$(from_xml "location")
	utime=$(from_xml "observation_time_rfc822")
	weather=$(from_xml "weather")
	temperature=$(from_xml "temp_f")
	humid=$(from_xml "relative_humidity")
	wind_dir=$(from_xml "wind_dir")
	case "$wind_dir" in
		"North") wind_dir="N" ;;
		"South") wind_dir="S" ;;
		"East") wind_dir="E" ;;
		"West") wind_dir="W" ;;
		"Northwest") wind_dir="NW" ;;
		"Northeast") wind_dir="NE" ;;
		"Southwest") wind_dir="SW" ;;
		"Southeast") wind_dir="SE" ;;
	esac
	wind_speed=$(from_xml "wind_kt")
	baro_pressure=$(from_xml "pressure_mb")

	echo "$location"
	echo "Updated: $(date -d "$utime" 2>/dev/null )"
	printf 'Weather: %s %s°F\n' "$weather" "$temperature"
	printf 'Barometric Pressure: %s mb\n' "$baro_pressure"
	printf 'Wind: %s at %s knots\n' "$wind_dir" "$wind_speed"
	printf 'Humidity: %s%%\n' "$humid"
else
	echo "No weather data available."
fi
