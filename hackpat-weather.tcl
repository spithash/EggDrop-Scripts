# Copyright (c) 2014 Patrick Hudson
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# Required steps in short:
#     1. Go to the Google developers console https://console.developers.google.com
#     2. Create a new project. Give it a name like 'eggdrop', doesn't matter much.
#     3. When the project is loaded, select menu "APIs" under "APIs & auth"
#     4. In the list of APIs, enable the "GeoCoding API".
#     5. Select menu "Credentials" and click "Create new key".
#     6. Select key type "server".
#     7. Fill in the IP(s) or IP range from which the eggdrop bot will send
#        requess to google's servers. This is a whitelist, if the request
#        comes from a different IP, it will be rejected.
#        Note: If my-ip or my-hostname is configured in eggdrop.conf, they should
#              be entered here.
#     8. You now have an API KEY; copy it to the googleapikey variable in CONFIG SECTION
# OpenWeather configuration
# 	Goto http://openweathermap.org/
# 		Click Sign Up
# 		Fill in required boxes
# 		After sign op, login, and goto http://openweathermap.org/my
# 		Paste API KEy into apikey variable in CONFIG SECTION
package require json
namespace eval hackpatweather {
	#CONFIG SECTION
	set apikey ""
	set googleapikey ""
	#/CONFIG SECTION
	proc getweather {nick uhand hand args} {
		set url "http://api.openweathermap.org/data/2.5/weather?APPID=$hackpatweather::apikey&units=imperial&q=us,"
		set chan [lindex $args 0]
		set input [lindex $args 1]
	      if {[lindex $input 0] == "-set"} {
	        if {[validuser $hand]} { 
	          setuser $hand XTRA incith:weather.location "[lrange $input 1 end]"
	          putserv "PRIVMSG $chan :Default weather location set to [lrange $input 1 end]."
	          return
	        } else {
	          putserv "PRIVMSG $chan :Sorry, your bot handle was not found. Unable to set a default."
	          return
	        }
	      } elseif {[regexp -- "^\\s*$" $input] && [validuser $hand]} {
	        set input [getuser $hand XTRA incith:weather.location]
	      }
		set search [lindex $input 0]
		set get [concat $url$search]
		set json [http::data [http::geturl $get]]
		set d1 [json::json2dict $json]
		set name [dict get $d1 name]
		set country [dict get $d1 sys country]
		set temp [dict get $d1 main temp]
#		set visibility [dict get $d1 visibility]
		set temp_min [dict get $d1 main temp_min]
		set temp_max [dict get $d1 main temp_max]
		set tempcel [format {%0.0f} [expr {($temp - 32) * 5/9}]]
		set tempcel_min [format {%0.0f} [expr {($temp_min - 32) * 5/9}]]
		set tempcel_max [format {%0.0f} [expr {($temp_max - 32) * 5/9}]]
		set windspeed [dict get $d1 wind speed]
		set humidity [dict get $d1 main humidity]
		set pressure [dict get $d1 main pressure]
		set lat [dict get $d1 coord lat]
		set long [dict get $d1 coord lon]
		set cond1 [dict get $d1 weather]
		regexp -nocase {description \{(.*?)\} icon} $cond1 " " cond
		set condout ""
		foreach word $cond {
			append condout "[string toupper $word 0 0] "
		}
		regsub {[\ ]*$} $condout "" condout
		set gapi "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&sensor=true&result_type=administrative_area_level_1&key=$hackpatweather::googleapikey"
		set json [http::data [http::geturl $gapi -strict 0]]
		set gdict [json::json2dict $json]
		regexp -nocase {formatted_address \{(.*?)\} geometry} $gdict " " location
		putserv "PRIVMSG $chan :$name, $location: \002Conditions:\002 $condout \00312-\003 \002Temperature:\002 $temp°\F ($tempcel°\C) \00312-\003 \002High/Low:\002 $temp_max/$temp_min°\F ($tempcel_max/$tempcel_min°\C) \00312-\003 \002Humdity:\002 $humidity% \00312-\003 \002Wind Speed:\002 $windspeed\MPH \00312-\003 \002Pressure:\002 $pressure\hpa"
	}
	proc getforecast {nick uhand hand args} {
		set url "http://api.openweathermap.org/data/2.5/forecast/daily?mode=json&?APPID=$hackpatweather::apikey&units=imperial&cnt=5&q=us,"
		set chan [lindex $args 0]
		set input [lindex $args 1]
	      if {[lindex $input 0] == "-set"} {
	        if {[validuser $hand]} { 
	          setuser $hand XTRA incith:weather.location "[lrange $input 1 end]"
	          putserv "PRIVMSG $chan :Default weather location set to [lrange $input 1 end]."
	          return
	        } else {
	          putserv "PRIVMSG $chan :Sorry, your bot handle was not found. Unable to set a default."
	          return
	        }
	      } elseif {[regexp -- "^\\s*$" $input] && [validuser $hand]} {
	        set input [getuser $hand XTRA incith:weather.location]
	      }
		set search [lindex $input 0]
		set get [concat $url$search]
		set json [http::data [http::geturl $get]]
		set d1 [json::json2dict $json]
		set d2 [dict get $d1 list]
		set name [dict get $d1 city name]
		set lat [dict get $d1 city coord lat]
		set long [dict get $d1 city coord lon]
		set gapi "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&sensor=true&result_type=administrative_area_level_1&key=$hackpatweather::googleapikey"
		set json [http::data [http::geturl $gapi -strict 0]]
		set gdict [json::json2dict $json]
		regexp -nocase {formatted_address \{(.*?)\} geometry} $gdict " " location
		set i 0
		array set days {}
		foreach item $d2 {
			set days($i) $item
			incr i
		}
		set todayDate [clock format [clock seconds] -format {%A %B %e, %Y}]
		set forecast "Today's Date \002$todayDate\002 - Forecast for \002$name, $location\002 (High/Low) "
		set returnString ""
		for {set i 0} {$i < 5} {incr i} {
			set ret [parseForecast $days($i)]
			append returnString $ret
			 
		}
		set final [concat $forecast $returnString]
		putserv "PRIVMSG $chan : $final"
	}
	proc parseForecast {day} {
		regexp -nocase {dt (.*?) temp} $day " " date
		regexp -nocase {temp \{(.*?)\} pressure} $day " " temp
		
		regexp -nocase {min (.*?) max} $day " " lowtemp
		set lowcel [format {%0.0f} [expr {($lowtemp - 32) * 5/9}]]
		regexp -nocase {max (.*?) night} $day " " hightemp
		set highcel [format {%0.0f} [expr {($hightemp - 32) * 5/9}]]
		regexp -nocase {description \{(.*?)\} icon} $day " " condition
		set condout ""
		foreach word $condition {
			append condout "[string toupper $word 0 0] "
		}
		regsub {[\ ]*$} $condout "" condout
		set humanReadableDate [clock format $date]
		set humanReadableDate [lindex $humanReadableDate 0]
		
		set returnString "\002$humanReadableDate:\002 $condout; High of $hightemp°F ($highcel°C), Low of $lowtemp°F ($lowcel°C) "
		return $returnString
	}
}
bind pub -|- "!wz" hackpatweather::getweather
bind pub -|- "!fc" hackpatweather::getforecast

putlog ".:Loaded:. hackpat-weather.tcl - HackPat@Freenode"
