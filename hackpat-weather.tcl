package require http
package require json
namespace eval hackpat-weather {
	proc getweather {nick uhand hand args} {
		set url "http://api.openweathermap.org/data/2.5/weather?APPID=c4b5f855bbc19f3565b2bcf1c91f7108&units=imperial&q="
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
		set tempcel [format {%0.0f} [expr {($temp - 32) * 5/9}]]
		set windspeed [dict get $d1 wind speed]
		set humidity [dict get $d1 main humidity]
		set lat [dict get $d1 coord lat]
		set long [dict get $d1 coord lon]
		set cond1 [dict get $d1 weather]
		regexp -nocase {description \{(.*?)\} icon} $cond1 " " cond
		set condout ""
		foreach word $cond {
			append condout "[string toupper $word 0 0] "
		}
		regsub {[\ ]*$} $condout "" condout
		set gapi "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&sensor=true&result_type=administrative_area_level_1&key=AIzaSyCvLosQtBmP1rU1Fjuvc3lWHdIXxDWR87k"
		set json [http::data [http::geturl $gapi -strict 0]]
		set gdict [json::json2dict $json]
		putlog $gapi
		regexp -nocase {formatted_address \{(.*?)\} geometry} $gdict " " location
		putserv "PRIVMSG $chan :$name, $location: \002Conditions:\002 $condout \002Temperature:\002 $temp°\F ($tempcel°\C) \002Humdity:\002 $humidity% \002Wind Speed:\002 $windspeed\MPH"
	}
	proc getforecast {nick uhand hand args} {
		set url "http://api.openweathermap.org/data/2.5/forecast/daily?mode=json&units=imperial&cnt=5&q="
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
		set gapi "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&sensor=true&result_type=administrative_area_level_1&key=AIzaSyCvLosQtBmP1rU1Fjuvc3lWHdIXxDWR87k"
		set json [http::data [http::geturl $gapi -strict 0]]
		set gdict [json::json2dict $json]
		putlog $gapi
		regexp -nocase {formatted_address \{(.*?)\} geometry} $gdict " " location
		set i 0
		array set days {}
		foreach item $d2 {
			set days($i) $item
			incr i
		}
		set todayDate [clock format [clock seconds] -format {%A %B %e, %Y}]
		set forecast "Today's Date $todayDate - Forecast for $name, $location (High/Low) "
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
bind pub -|- "!w" iniweather::getweather
bind pub -|- "!fc" iniweather::getforecast

putlog ".:Loaded:. hackpat-weather.tcl - HackPat@Freenode"