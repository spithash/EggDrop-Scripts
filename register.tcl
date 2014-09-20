#Simple EggDrop script that allows users to Register to your bot. It updates hostmasks at login to make sure that no one gets lost in the userfile
#Copyright (C) 2014 Patrick Hudson (https://patrick.hudson.bz)
#
#
#Register for Eggdrop is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 2 of the License, or
#(at your option) any later version.
#
#Register for Eggdrop is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with Register for Eggdrop.  If not, see <http://www.gnu.org/licenses/>.

#God speed my friend

# The trigger - set this to anything you'd like
set pubtrig "!"

# ---- STOP EDITING HERE. This code was created, and only myself and god knew how it worked. Now only god knows ---- #
proc getTrigger {} {
  global pubtrig
  return $pubtrig
}
bind pub - ${pubtrig}unregister deluser:pub
bind pub n ${pubtrig}purge purge:users
bind pub - ${pubtrig}register adduser:pub
bind join - "#* *!*@*" join:add

proc join:add {nick host handle chan} {
    foreach user [userlist] {
        set handle [string range "$nick" 0 8]
        if {$user == $handle} {
          setuser $handle HOSTS [maskhost $host]
          putlog "Register: <${nick}/${chan}> succesfully updated host to $host"
        }
    }
}

proc adduser:pub {nick uhost handle chan arg} {
  set handle $nick
  set hostmask [lindex $arg 1]
  putlog "$handle $nick"
    if {[validuser $handle]} {
      puthelp "privmsg $chan :$nick: Are you retarded? You already exist, go bother someone else."
      putlog "Register: <${nick}/${chan}> already exists in user file, ignoring"
      return 0
    }
    if {$hostmask == ""} {
      set host [getchanhost $handle]

      if {$host == ""} {
        puthelp "privmsg $chan :$nick: I can't get $handle's host."
        return 0
      }
    }

    if {![validuser $handle]}  {
      adduser $handle [maskhost $uhost]
      puthelp "privmsg $chan :$handle added to the user list."
      putlog "Register: <${nick}/${chan}> added to the user list via !register"
    }

}
proc purge:users {nick uhost hand chan arg} {
  foreach user [userlist] { 
  if {![matchattr $user n]} { deluser $user } 
  } 
}


proc deluser:pub {nick uhost handle chan arg} {
  set handle [string range "$nick" 0 8]
  set hostmask [lindex $arg 1]
    if {[validuser $handle] && $arg == ""} {
      deluser $handle 
      puthelp "privmsg $chan :$handle has been deleted!"
      putlog "Register: <${nick}/${chan}> removed from the user list via !unregister"
      return 0
    }
    if {$arg != ""} {
      puthelp "privmsg $chan : You must seriously think I'm that stupid huh? Like I'd let you unregister someone elses nick. Fuck off."
      putlog "Register: <${nick}/${chan}> tried to delete someone elses nick. What a dumb fuck"
      return 0
    }
    if {![validuser $handle]} {
      puthelp "privmsg $chan : Huh, I don't seem to have you in my database. Contacting N.S.A. for backup database..........Connection Terminated. Oh well."
      putlog "Register: <${nick}/${chan}> tried to unregister a non-existant nick. Dumbass."
      return 0
    }
}
putlog ".:Loaded:. register.tcl - HackPat@freenode"