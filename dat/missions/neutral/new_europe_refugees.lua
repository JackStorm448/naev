--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="New Europe Refugees">
 <priority>6</priority>
 <chance>100</chance>
 <location>Computer</location>
 <spob>New Europe</spob>
 <notes>
  <tier>1</tier>
 </notes>
</mission>
--]]
local vntk = require "vntk"
local lmisn = require "lmisn"
local fmt = require "format"
local pir = require "common.pirate"

function create ()
   mem.dest_spob, mem.dest_sys = spob.get("Ohon")
   local numjumps = system.cur():jumpDist( mem.dest_sys )

   mem.reward = numjumps*150

   misn.setTitle(_("Refugee Evacuation"))
   misn.setDesc(fmt.f(_([[Nebula refugees want you to get them off world to {spob} in the {sys} system.

#nCargo:#0 as many refugees as you can carry
{jumps}]]),
      {spob=mem.dest_spob, sys=mem.dest_sys,
         jumps=fmt.f( n_( "#nJumps:#0 {jumps}", "#nJumps:#0 {jumps}", numjumps ), {jumps=numjumps} )}))
   misn.setReward( fmt.credits(mem.reward).." per tonne of refugees" )

   hook.land("land")
end

function accept ()
   local pp = player.pilot()
   if pp:cargoFree() <= 0 then
      vntk.msg(_("No room in ship"), _([[You don't have enough room on your ship to take any refugees!]]))
      return
   end

   misn.accept()

   local c = commodity.new( N_("Nebula Refugees"), N_("A bunch of poor and ragged looking refugees looking for a better life.") )
   mem.amount = pp:cargoFree()
   mem.cargo = misn.cargoAdd( c, mem.amount )

   misn.setReward( fmt.credits(mem.reward*mem.amount) )

   vntk.msg(_("Nebula Refugees"), fmt.f(_([[The procession of refugees slowly boards your ship, with more then one person looking back at the dying planet they used to call home. They make themselves as comfortable as they can in your cargo holds and seem to resigned to hoping what they will find at {spob} is better than what they are leaving behind at {home}.]]),
      {spob=mem.dest_spob, home=spob.cur()}))
end

function land ()
   if spob.cur() ~= mem.dest_spob then
      return
   end

   local payment = mem.amount * mem.reward

   lmisn.sfxMoney()
   player.pay( payment )
   pir.reputationNormalMission(rnd.rnd(2,3))
   vntk.msg(_("Nebula Refugees"), fmt.f(_([[You open your cargo holds and the Nebula refugees make their way off your ship and are promptly greeted by an immigration officer. It looks like hardships are not yer over for the refugees. On the positive side, it can only get better, right?]]),
      {}).."\n"..fmt.reward(payment))
   misn.finish(true)
end
