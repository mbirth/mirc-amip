; rbr-AMIP script 1.1 (2004-11-24)
; (c)2004 by Markus Birth <mbirth@webwriters.de>
;
; For use with AMIP Plugin for WinAMP.
; Just set the output string for mIRC in AMIP to following:
;
;        /amipnotify
;
; Manual invokation:
; 1. Via Context-menu of channel or query window
; 2. Via CTCP (if enabled):
;     CTCP <yournick> AMIP          sends currently playing track as CTCP reply to requester
;     CTCP <yournick> AMIPC         sends curr. playing track to all channels you are on
;     CTCP <yournick> AMIPC #chan   sends curr. playing track to channel #chan
; 3. Via TEXT (if enabled):
;     !amip                         (in Channel or Query) sends curr. playing track to channel or query
; 4. Via Timer every x minutes

; #############
; ##  MENUs  ##
; #############

menu status,channel,query {
  rbr-AMiP
  .$iif($isdde(mPlug) != $true,WinAMP or AMIP-Plugin not running!): echo %amipmsgpre $+ 4,1 WinAMP and/or AMIP-Plugin is/are not running. DDE Server not found. %amipmsgaft
  .$iif(($isdde(mPlug) && ($menu != status)),Announce Song):amipannounce
  .View announcement: amipviewannounce
  .-
  .$iif(%amipannounce != $null,$style(1)) Auto-Announce: amipannounceswitch
  .$submenu($amipmenutimer($1))
  .$iif(%amipontext != $null,$style(1)) React on TEXT: amipontextswitch
  .$iif(%amiponctcp != $null,$style(1)) React on CTCP: amiponctcpswitch
  .$iif(%amiponctcp != $null,$iif(%amiponctcpc != $null,$style(1)),$style(2)) React on CTCP for Channels: amiponctcpchanswitch
  .-
  .$iif($isdde(mPlug),$iif($dde(mPlug,var_playing) != $null,$style(1)) Play): dde mPlug control play
  .$iif($isdde(mPlug),Pause): dde mPlug control pause
  .$iif($isdde(mPlug),$iif($dde(mPlug,var_playing) == $null,$style(1)) Stop): dde mPlug control stop
  .$iif($isdde(mPlug),Next track): dde mPlug control >
  .$iif($isdde(mPlug),Previous track): dde mPlug control <
  .-
  .$iif($isdde(mPlug),$iif( $dde(mPlug,var_repeat) == on ,$style(1)) Repeat): dde mPlug control repeat
  .$iif($isdde(mPlug),$iif( $dde(mPlug,var_shuffle) == on ,$style(1)) Shuffle): dde mPlug control shuffle
  .-
  .$iif($isdde(mPlug),Volume)
  ..$submenu($amipmenuvols($1))
  .$submenu($amipmenumute($1))
}

menu nicklist,query {
  rbr-AMiP
  .Query via CTCP: ctcp $1 AMIP
  .Query via TEXT: msg $1 !amip
  .-
  .Channel-Query via CTCP: ctcp $1 AMIPC
  .$iif($menu == nicklist ,Channel-Query via CTCP for this chan): ctcp $1 AMIPC $chan
  .$iif($menu == nicklist ,Channel-Query via TEXT): msg $chan !amip
}


; ###############
; ##    ONs    ##
; ###############

ON 1:LOAD:{
  set %amipmsgpre 1,7<7,1 rbr-AMiP 1,7 
  set %amipmsgaft 1,7>
  set %amipmsgsep 1,7 
  echo -s %amipmsgpre $+ 11,1 Welcome to AMiP mIRC Interface %amipmsgsep $+ 10,1 (c)2004 by Markus Birth <mbirth@webwriters.de> $+ %amipmsgaft
  echo -s In preferences of AMIP-Plugin for WinAMP, enter "/amipnotify" as output string.
}

ON 1:UNLOAD:{
  unset %amip*
}

ON 1:TEXT:!amip:#:{
  if (%amipontext != $null) {
    amipbuildoutput
    describe $chan $result (requested by $nick $+ )
  }
}

ON 1:TEXT:!amip:?:{
  if (%amipontext != $null) {
    amipbuildoutput
    msg $nick $result
  }
}


; ###############
; ##   CTCPs   ##
; ###############

CTCP 1:AMIP:*:{
  if (%amiponctcp != $null) {
    amipbuildoutput
    ctcpreply $nick AMIP $result
  }
}

CTCP 1:AMIPC:*:{
  if ((%amiponctcp != $null) && (%amiponctcpc != $null)) {
    amipbuildoutput
    if ($2 != $null) {
      describe $2 $result (requested by $nick for $2 $+ )
    }
    else {
      ame $result (requested by $nick $+ )
    }
  }
}


; ###############
; ##  ALIASes  ##
; ###############

alias amipmenutimer {
  if ($1 == 1) {
    return $iif( $timer(amipann) != $null ,$style(1)) Announce every $iif( $timer(amipann) != $null, $round( $calc($timer(amipann).delay / 60) ,0) , x ) minutes: amiptimerannounce
  }
}

alias amipmenuvols {
  if (($isdde(mPlug)) && ($1 <= 21)) {
    var %amipcurvol $round( $calc( $dde(mPlug,var_vol) * 20 / 255 ) ,0)
    var %amipvols = $round( $calc( (21 - $1)*5 ) ,0)
    return $iif( $calc(21-$1) == %amipcurvol ,$style(1)) %amipvols $+ $chr(37) $+ : amipsetvol %amipvols
  }
}

alias amipmenumute {
  if (($isdde(mPlug)) && ($1 == 1)) {
    if ( %amipvol == $null ) {
      return MUTE: amipmute
    }
    else {
      return $style(1) MUTE ( $+ %amipvol $+ ): amipmute
    }
  }
}

alias amipannounceswitch {
  if (%amipannounce == $null) {
    set %amipannounce true
    echo -s %amipmsgpre $+ 11,1 Auto-Announce of WinAMP songs 9ENABLED. %amipmsgaft
  }
  else {
    unset %amipannounce
    echo -s %amipmsgpre $+ 11,1 Auto-Announce of WinAMP songs 4DISABLED. %amipmsgaft
  }
}

alias amipontextswitch {
  if (%amipontext == $null) {
    set %amipontext true
    echo -s %amipmsgpre $+ 11,1 React on TEXT 9ENABLED. %amipmsgaft
  }
  else {
    unset %amipontext
    echo -s %amipmsgpre $+ 11,1 React on TEXT 4DISABLED. %amipmsgaft
  }
}

alias amiponctcpchanswitch {
  if (%amiponctcpc == $null) {
    set %amiponctcpc true
    echo -s %amipmsgpre $+ 11,1 React on CTCP for Channel 9ENABLED. %amipmsgaft
  }
  else {
    unset %amiponctcpc
    echo -s %amipmsgpre $+ 11,1 React on CTCP for Channel 4DISABLED. %amipmsgaft
  }
}

alias amiponctcpswitch {
  if (%amiponctcp == $null) {
    set %amiponctcp true
    echo -s %amipmsgpre $+ 11,1 React on CTCP 9ENABLED. %amipmsgaft
  }
  else {
    unset %amiponctcp
    echo -s %amipmsgpre $+ 11,1 React on CTCP 4DISABLED. %amipmsgaft
  }
}

alias amiptimerannounce {
  var %interval = $?="Enter desired interval in minutes (0 to disable):"
  if (%interval > 0) {
    var %mininterval = $calc( %interval * 60 )
    .timeramipann 0 %mininterval amipannounce
    echo -s %amipmsgpre $+ 11,1 Timed announce every %interval minute(s) 9ENABLED. %amipmsgaft
  }
  else {
    .timeramipann off
    echo -s %amipmsgpre $+ 11,1 Timed announce 4DISABLED. %amipmsgaft
  }
}

alias amipsonginfo {
  set %amipfn $dde(mPlug,var_fn)
  set %amipname $dde(mPlug,var_s)
  set %amipname2 $dde(mPlug,var_name)
  set %amipext $upper($dde(mPlug,var_ext))
  set %amiplen $dde(mPlug,var_min) $+ m $dde(mPlug,var_sec) $+ s
  set %amiplen2 $dde(mPlug,var_min) $+ : $+ $dde(mPlug,var_sec)
  set %amipidartist $dde(mPlug,var_1)
  set %amipidtitle $dde(mPlug,var_2)
  set %amipidtrackno $dde(mPlug,var_3)
  set %amipidalbum $dde(mPlug,var_4)
  set %amipidyear $dde(mPlug,var_5)
  set %amipidcomment $dde(mPlug,var_6)
  set %amipidgenre $dde(mPlug,var_7)
  set %amiptype $dde(mPlug,var_typ)
  set %amipbits $dde(mPlug,var_br)
  set %amipsrate $dde(mPlug,var_sr)
  set %amippos $dde(mPlug,var_pm) $+ m $dde(mPlug,var_ps) $+ s
  set %amipleft $dde(mPlug,var_mil) $+ m $dde(mPlug,var_sel) $+ s
  set %amipperc $dde(mPlug,var_prc)
  set %amipisplaying $dde(mPlug,var_playing)
  if (%amipalbum == $null) {
    set %amipalbum Unknown
  }
  if ((%amipidartist == $null) && (%amipidtitle == $null)) {
    set %amipidtitle %amipname
  }
  if ($pos(%amipext,:,0) > 0) {
    set %amipext Streaming
  }
}

alias amipnotify {
  if ( %amipannounce != $null ) {
    ;Have to use timer because AMiP doesn't like to be queried upon song switch
    timeramip 1 2 amipannounce
  }
}

alias amipmute {
  if ( %amipvol == $null ) {
    set %amipvol $dde(mPlug,var_vol)
    echo -s %amipmsgpre $+ 11,1 Muting WinAMP (Volume was at %amipvol $+ ). %amipmsgaft
    dde mPlug control vol 0
  }
  else {
    echo -s %amipmsgpre $+ 11,1 Unmuting WinAMP to Volume level %amipvol $+ . %amipmsgaft
    dde mPlug control vol %amipvol
    unset %amipvol
  }
}

alias amipsetvol {
  var %amiptmp = $round( $calc( $1 * 255 / 100 ) ,0)
  echo -s %amipmsgpre $+ 11,1 Setting WinAMP Volume level to $1 $+ $chr(37) ( $+ %amiptmp $+ ). %amipmsgaft
  dde mPlug control vol %amiptmp
  if ( %amiptmp == 0 ) set %amipvol 255
  else unset %amipvol
}

alias amipbuildoutput {
  var %amipoutput = %amipmsgpre
  if ($isdde(mPlug) == $true) {
    amipsonginfo
    if (%amipisplaying == 1) {
      %amipoutput = %amipoutput $+ 4,1 %amipext %amipmsgsep
      var %amippdname = $chr(160) $+ %amipname $+ $chr(160)
      var %amippdlen = $len(%amippdname)
      var %amippddone = $round($calc(%amippdlen * %amipperc / 100), 0)
      var %amippdleft = $calc(%amippdlen - %amippddone)
      %amipoutput = %amipoutput $+ 1,11 $+ $left(%amippdname, %amippddone) $+ 11,1 $+ $right(%amippdname, %amippdleft) $+ %amipmsgsep
      if (%amipext != Streaming) %amipoutput = %amipoutput $+ 10,1 %amiplen2 %amipmsgsep
      %amipoutput = %amipoutput $+ 14,1 since %amippos
      if (%amipperc > 0) %amipoutput = %amipoutput ( $+ %amipperc $+ $chr(37) $+ )
      %amipoutput = %amipoutput %amipmsgaft
    }
    else {
      %amipoutput = %amipoutput $+ 4,1 WinAMP is not playing anything. %amipmsgaft
    }
  }
  else {
    %amipoutput = %amipoutput $+ 4,1 No appropriate DDE Server found. %amipmsgaft
  }
  return %amipoutput
}

alias amipannounce {
  amipbuildoutput
  if (%amipisplaying == 1) {
    if ( $active != Status Window ) {
      describe $active $result
    }
  }
  else {
    echo -a $result
  }
}

alias amipviewannounce {
  amipbuildoutput
  echo -a $result
}

alias amipdebug {
  amipsonginfo
  echo -s %amipmsgpre $+ 11,1 DEBUG INFO %amipmsgaft
  echo -s var_fn > $+ %amipfn $+ <
  echo -s var_s > $+ %amipname $+ <
  echo -s var_name > $+ %amipname2 $+ <
  echo -s var_ext > $+ %amipext $+ <
  echo -s var_min / var_sec > $+ %amiplen $+ <
  echo -s var_min / var_sec > $+ %amiplen2 $+ <
  echo -s var_1 > $+ %amipidartist $+ <
  echo -s var_2 > $+ %amipidtitle $+ <
  echo -s var_3 > $+ %amipidtrackno $+ <
  echo -s var_4 > $+ %amipidalbum $+ <
  echo -s var_5 > $+ %amipidyear $+ <
  echo -s var_6 > $+ %amipidcomment $+ <
  echo -s var_7 > $+ %amipidgenre $+ <
  echo -s var_typ > $+ %amiptype $+ <
  echo -s var_br > $+ %amipbits $+ <
  echo -s var_sr > $+ %amipsrate $+ <
  echo -s var_pm / var_ps > $+ %amippos $+ <
  echo -s var_mil / var_sel > $+ %amipleft $+ <
  echo -s var_prc > $+ %amipperc $+ <
  echo -s var_playing > $+ %amipisplaying $+ <
}
