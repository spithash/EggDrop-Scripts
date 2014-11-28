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
#
#
# Commands: 
# All commands except !unban require the user to be in the channel
# !op, !deop require the person being modified to be registered within EggDrop
#
# ---------
# Bot Owners
#	!addop <NICK> - Modifies the bot's userfile to add OP (+o) to a user (does not auto OP)
#	!delop <NICK> - Modifies the bot's userfile to remove OP (-o) from a user (does not auto-deop)
# OPs
# 	!op <NICK> - OPs user in channel. To OP yourself use !op <MYNICK>
#	!deop <NICK> - DeOPs user in a channel. To DEOP yourself use !deop <MYNICK>
#	!kick <NICK> - Kicks user from channel
#	!ban <NICK> - bans user from channel for 60 minutes.
#	!unban <HOSTMASK> - unbans user from channel (must use !unban HOSTMASK). Can not unban via Nick (yet)
#
# Public
#	!listops - returns a list of the OPd members on the bot.

# The trigger
set pubtrig "!"

# ---- EDIT END ----
proc getTrigger {} {
  global pubtrig
  return $pubtrig
}

bind pub - ${pubtrig}addop owner:addop
bind pub - ${pubtrig}delop owner:delop
bind pub - ${pubtrig}op op:op
bind pub - ${pubtrig}deop op:deop
bind pub - ${pubtrig}kick op:kick
bind pub - ${pubtrig}ban op:ban
bind pub - ${pubtrig}unban op:unban
bind pub - ${pubtrig}listops op:userlist

proc owner:addop {nick host hand chan arg} {
	if {[matchattr $hand +n]} {
		if {[nick2hand $arg]  != "" } {
			set nickname [nick2hand $arg]
			chattr $nickname "+o"
			putserv "PRIVMSG $chan :$arg added to OP list"
		} else { 
			putserv "PRIVMSG $chan :Something went wrong trying to get users handle. Are you sure they are registered?"
		}
	} else {
		putserv "PRIVMSG $nick :You do not appear to be a bot owner. Are you sure that you should be running this command?"
	}
}
proc owner:delop {nick host hand chan arg} {
	if {[matchattr $hand +n]} {
		if {[nick2hand $arg]  != "" } {
			set nickname [nick2hand $arg]
			chattr $nickname "-o"
			putserv "PRIVMSG $chan :$arg removed from OP list"
		} else { 
			putserv "PRIVMSG $chan :Something went wrong trying to get users handle. Are you sure they are registered?"
		}
	} else {
		putserv "PRIVMSG $nick :You do not appear to be a bot owner. Are you sure that you should be running this command?"
	}
}
proc op:op {nick host hand chan arg} {
	if {[matchattr $hand +o]} {
		if {[nick2hand $arg]  != "" } {
			pushmode $chan +o $arg
		} else { 
			putserv "PRIVMSG $chan :Something went wrong trying to get users handle. Are you sure they are registered?"
		}
	} else {
		putserv "PRIVMSG $nick :You do not appear to be an Operator (OP). Are you sure that you should be running this command?"
	}
}
proc op:deop {nick host hand chan arg} {
	if {[matchattr $hand +o]} {
		if {[nick2hand $arg]  != "" } {
			pushmode $chan -o $arg
		} else { 
			putserv "PRIVMSG $chan :Something went wrong trying to get users handle. Are you sure they are registered?"
		}
	} else {
		putserv "PRIVMSG $chan :You do not appear to be an Operator (OP). Are you sure that you should be running this command?"
	}
}
proc op:kick {nick host hand chan arg} {
	if {[matchattr $hand +o]} {
		set nickname [lindex [split $arg] 0]
		set reason [lrange [split $arg] 1 end]
		if {[nick2hand $nickname]  != "" } {
			if {$reason != ""} {
				putkick $chan $nickname $reason
			} else {
				putkick $chan $nickname "Your behavior isn't conducive to the environment in this channel." 
			}
			
		} else { 
			putserv "PRIVMSG $chan :Something went wrong trying to get users handle. Are you sure they are currently in the channel?"
		}
	} else {
		putserv "PRIVMSG $nick :You do not appear to be an Operator (OP). Are you sure that you should be running this command?"
	}
}
proc op:ban {nick host hand chan arg} {
	if {[matchattr $hand +o]} {
		set nickname [lindex [split $arg] 0]
		set reason [lrange [split $arg] 1 end]
		set hostmask [getchanhost $nickname]
		if {[onchan $nickname $chan] == 0} {
			putserv "PRIVMSG $chan :Something went wrong trying to get users handle. Are you sure they are currently in the channel?"
			return 0
		}
		regsub -all "~" $hostmask "" hostmask
        regsub {^[^@]*} $hostmask "" hostmask
        set hostmask "*!*$hostmask"
		if {[nick2hand $nickname]  != ""} {
			if {$reason != ""} {
				newchanban $chan $hostmask $nick $reason 60
				putkick $chan $nickname $reason
			} else {
				newchanban $chan $hostmask $nick "You have been banned for 1 hour, please cool off and then come back" 60
				putkick $chan $nickname "You have been banned for 1 hour, please cool off and then come back"
			}
			
		} else { 
			putserv "PRIVMSG $chan :Something went wrong trying to get users handle. Are you sure they are currently in the channel?"
		}
	} else {
		putserv "PRIVMSG $nick :You do not appear to be an Operator (OP). Are you sure that you should be running this command?"
	}
}
proc op:unban {nick host hand chan arg} {
	if {[matchattr $hand +o]} {
		set hostmask [lindex [split $arg] 0]
		if {[matchban $arg $chan]} {
			killchanban $chan $hostmask
			putserv "PRIVMSG $chan :$hostmask unbanned"
		} else {
			putserv "PRIVMSG $chan :Something went wrong trying to unban user. You can only unban users by using the hostmask that they were banned with."
		}
	} else {
		putserv "PRIVMSG $nick :You do not appear to be an Operator (OP). Are you sure that you should be running this command?"
	}
}
proc op:userlist {nick host hand chan arg} { 
    if {[userlist $chan] == ""} { 
        putserv "PRIVMSG $nick :Userlist empty for $chan." 
    } else { 
    foreach user [userlist +o] { 
        lappend tmp $user 
    } 
    set oplist [join $tmp ", "]
    putquick "PRIVMSG $chan :OPs in this channel are $oplist." 
  } 
}

putlog "Admin Tools HackPat @ FreeNode"