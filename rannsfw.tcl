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
# Commands: 
# ---------
# OPs:  !ignore add <*!*host@mask.etc> <duration> <reason>
#       !ignore add <nick> <duration> <reason>
#       !ignore del *!*host@mask.etc
#       !ignores
package require http
package require tls
package require json
# The trigger

set pubtrig "!"

# ---- EDIT END ----
proc getTrigger {} {
  global pubtrig
  return $pubtrig
}
bind pub - ${pubtrig}tits tits:pub
bind pub - ${pubtrig}ass ass:pub
bind pub - ${pubtrig}pussy pussy:pub
bind pub - ${pubtrig}nsfw nsfw:pub
bind pub - ${pubtrig}gif gif:pub

proc tits:pub {nick host hand chan arg} {
  set page [myRand 0 50]
  set theurl "https://api.imgur.com/3/gallery/r/Boobies/time/$page"
  dict set hdr Authorization "Client-ID cefb2e6ae32f74f"
  http::register https 443 [list ::tls::socket -tls1 1]
  set token [http::geturl $theurl -headers $hdr -query]
  set responseBody [::json::json2dict [http::data $token]]
  set data [lindex $responseBody 1]
  set linkid [myRand 0 30]
  set imagedata [lindex $data $linkid]
  if {[regexp -nocase {link (.*?) reddit_comments} $imagedata " " link]} {
    regsub -nocase -- {link (.*?) reddit_comments} $link "\\1" link
    regsub -nocase -- {looping true} $link "" link
  } else {
    set link "Wohhh there cowboy, slow down!"
  }
  if {[regexp -nocase {title {(.*?)} description} $imagedata " " title]} {
    regsub -nocase -- {title {(.*?)} description} $title "\\1" title
  } else {
    set title "Title Unknown"
  }
  putserv "PRIVMSG $chan :\002NSFW\002 Your random tits! $link - Title: $title"
  http::cleanup $token
}
proc ass:pub {nick host hand chan arg} {
  set page [myRand 0 50]
  set theurl "https://api.imgur.com/3/gallery/r/ass/time/$page"
  dict set hdr Authorization "Client-ID cefb2e6ae32f74f"
  http::register https 443 [list ::tls::socket -tls1 1]
  set token [http::geturl $theurl -headers $hdr -query]
  set responseBody [::json::json2dict [http::data $token]]
  set data [lindex $responseBody 1]
  set linkid [myRand 0 30]
  set imagedata [lindex $data $linkid]
  if {[regexp -nocase {link (.*?) reddit_comments} $imagedata " " link]} {
    regsub -nocase -- {link (.*?) reddit_comments} $link "\\1" link
    regsub -nocase -- {looping true} $link "" link
  } else {
    set link "Wohhh there cowboy, slow down!"
  }
  if {[regexp -nocase {title {(.*?)} description} $imagedata " " title]} {
    regsub -nocase -- {title {(.*?)} description} $title "\\1" title
  } else {
    set title "Title Unknown"
  }
  putserv "PRIVMSG $chan :\002NSFW\002 Your random ass! $link - Title: $title"
  http::cleanup $token
}
proc pussy:pub {nick host hand chan arg} {
  set page [myRand 0 50]
  set theurl "https://api.imgur.com/3/gallery/r/pussy/time/$page"
  dict set hdr Authorization "Client-ID cefb2e6ae32f74f"
  http::register https 443 [list ::tls::socket -tls1 1]
  set token [http::geturl $theurl -headers $hdr -query]
  set responseBody [::json::json2dict [http::data $token]]
  set data [lindex $responseBody 1]
  set linkid [myRand 0 30]
  set imagedata [lindex $data $linkid]
  if {[regexp -nocase {link (.*?) reddit_comments} $imagedata " " link]} {
    regsub -nocase -- {link (.*?) reddit_comments} $link "\\1" link
    regsub -nocase -- {looping true} $link "" link
  } else {
    set link "Wohhh there cowboy, slow down!"
  }
  if {[regexp -nocase {title {(.*?)} description} $imagedata " " title]} {
    regsub -nocase -- {title {(.*?)} description} $title "\\1" title
  } else {
    set title "Title Unknown"
  }
  putserv "PRIVMSG $chan :\002NSFW\002 Your random pussy! $link - Title: $title"
  http::cleanup $token
}
proc gif:pub {nick host hand chan arg} {
  set page [myRand 0 50]
  set theurl "https://api.imgur.com/3/gallery/r/NSFW_GIF/time/$page"
  dict set hdr Authorization "Client-ID cefb2e6ae32f74f"
  http::register https 443 [list ::tls::socket -tls1 1]
  set token [http::geturl $theurl -headers $hdr -query]
  set responseBody [::json::json2dict [http::data $token]]
  set data [lindex $responseBody 1]
  set linkid [myRand 0 30]
  set imagedata [lindex $data $linkid]
  if {[regexp -nocase {link (.*?) reddit_comments} $imagedata " " link]} {
    regsub -nocase -- {link (.*?) reddit_comments} $link "\\1" link
    regsub -nocase -- {looping true} $link "" link
  } else {
    set link "Wohhh there cowboy, slow down!"
  }
  if {[regexp -nocase {title {(.*?)} description} $imagedata " " title]} {
    regsub -nocase -- {title {(.*?)} description} $title "\\1" title
  } else {
    set title "Title Unknown"
  }
  putserv "PRIVMSG $chan :\002NSFW\002 Your random porn gif! $link - Title: $title"
  http::cleanup $token
}
proc nsfw:pub {nick host hand chan arg} {
  set page [myRand 0 50]
  set theurl "https://api.imgur.com/3/gallery/r/nsfw/time/$page"
  dict set hdr Authorization "Client-ID cefb2e6ae32f74f"
  http::register https 443 [list ::tls::socket -tls1 1]
  set token [http::geturl $theurl -headers $hdr -query]
  set responseBody [::json::json2dict [http::data $token]]
  set data [lindex $responseBody 1]
  set linkid [myRand 0 30]
  set imagedata [lindex $data $linkid]
  if {$arg == "help"} {
    putserv "PRIVMSG $chan :\002NSFW\002 use !tits for random tits, !ass for random ass, !pussy for random pussy, !nsfw for random porn, !nsfw NUMBER for a list of porn"
    return "hai"
  }
  if {$arg != "" && $arg != "help"} {
    set listnsfw ""
    for {set i 0} {$i < $arg} {incr i} {
      set randata [lindex $data $i]
        if {[regexp -nocase {link (.*?) reddit_comments} $randata " " link]} {
          regsub -nocase -- {link (.*?) reddit_comments} $link "\\1" link
          regsub -nocase -- {looping true} $link "" link
          lappend listnsfw $link
        } else {
          set link "Wohhh there cowboy, slow down!"
        }
    }
    putserv "PRIVMSG $chan :\002NSFW\002 Random Tities/Ass/Pussy/Whoknows $listnsfw"
  } else {
        if {[regexp -nocase {link (.*?) reddit_comments} $imagedata " " link]} {
          regsub -nocase -- {link (.*?) reddit_comments} $link "\\1" link
          regsub -nocase -- {looping true} $link "" link
        } else {
          set link "Wohhh there cowboy, slow down!"
        }
        if {[regexp -nocase {title {(.*?)} description} $imagedata " " title]} {
          regsub -nocase -- {title {(.*?)} description} $title "\\1" title
        } else {
          set title "Title Unknown"
        }
        putserv "PRIVMSG $chan :\002NSFW\002 Random Tities/Ass/Pussy/Whoknows $link - Title: $title"
  }
  
  http::cleanup $token
}
proc myRand { min max } {
    set maxFactor [expr [expr $max + 1] - $min]
    set value [expr int([expr rand() * 100])]
    set value [expr [expr $value % $maxFactor] + $min]
return $value
}

#putlog ".:Loaded:. ignore.tcl - HackPat@Freenode"