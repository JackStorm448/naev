--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Emergency of Immediate Inspiration">
 <flags>
  <unique />
 </flags>
 <avail>
  <priority>4</priority>
  <done>Advanced Nebula Research</done>
  <chance>30</chance>
  <location>Bar</location>
  <faction>Empire</faction>
  <cond>system.get("Gamma Polaris"):jumpDist() &lt; 3 and planet.cur():class() ~= "1" and planet.cur():class() ~= "2" and planet.cur():class() ~= "3"</cond>
 </avail>
</mission>
--]]
--[[

   Mission: Emergency of Immediate Inspiration

   Description: Take Dr. Mensing to Jorla as fast as possible!

   Difficulty: Easy

--]]

local car = require "common.cargo"
local fmt = require "format"
local zlk = require "common.zalek"

local request_text = _([["There's actually another thing I've almost forgotten. I also have to attend another conference very soon on behalf of professor Voges who obviously is very busy with some project he would not tell me about. But I don't want to go there - my research is far too important! So could you instead bring Robert there? You remember the student you helped out recently? I'm sure he will do the presentation just fine! I'll tell him to meet you in the bar as soon as possible!"
    With that being said Dr. Mensing leaves you immediately without waiting for your answer. It appears you should head to the bar to meet up with the student.]])

function create()
    -- mission variables
    credits = 400e3
    homeworld, homeworld_sys = planet.get("Jorla")
    origin = planet.cur()
    origin_sys = system.cur()

    local numjumps = origin_sys:jumpDist(homeworld_sys, false)
    local traveldist = car.calculateDistance(origin_sys, origin:pos(), homeworld_sys, homeworld)
    local stuperpx   = 0.15
    local stuperjump = 10000
    local stupertakeoff = 10000
    local allowance  = traveldist * stuperpx + numjumps * stuperjump + stupertakeoff + 240 * numjumps
    timelimit  = time.get() + time.create(0, 0, allowance)

    -- Spaceport bar stuff
    misn.setNPC(_("Dr. Mensing"), "zalek/unique/mensing.webp", _("It appears she wants to talk with you."))
end

function accept()
    if not tk.yesno(_("Bar"), _([["Well met, %s! In fact, it's a lucky coincidence that we meet. You see, I'm in dire need of your service. I'm here on a... conference of sorts, not a real one. We are obligated to present the newest results of our research to scientists of the Empire once per period - even though these jokers lack the skills to understand our works! It's just a pointless ritual anyway. But I just got an ingenious idea on how to prevent the volatile Sol nebula from disrupting ship shields! I will spare you with the details - to ensure my idea is not going to be stolen, nothing personal. You can never be sure who is listening."
    "Anyway, you have to take me back to my lab on %s in the %s system immediately! I'd also pay %s if necessary."]]):format(player:name(), homeworld:name(), homeworld_sys:name(), fmt.credits(credits))) then
        misn.finish()
    end
    tk.msg(_("Bar"), _([["Splendid! I'd like to start with my work as soon as possible, so please hurry! Off to %s we go!"
    With that being said she drags you out of the bar. When realizing that she actually does not know on which landing pad your ship is parked she lets you loose and orders you to lead the way.]]):format(homeworld:name()))

    -- Set up mission information
    misn.setTitle(_("Emergency of Immediate Inspiration"))
    misn.setReward(_("%s"):format(fmt.credits(credits)))
    misn.setDesc(_("Take Dr. Mensing to %s in the %s system as fast as possible!"):format(homeworld:name(), homeworld_sys:name()))
    misn_marker = misn.markerAdd(homeworld_sys, "low")

    misn.accept()
    misn.osdCreate(_("Emergency of Immediate Inspiration"), {
       _("Fly to %s in the %s system."):format(homeworld:name(), homeworld_sys:name()),
    })

    hook.land("land")
end

function land()
    landed = planet.cur()
    if landed == homeworld then
        if timelimit < time.get() then
            tk.msg(_("Mission accomplished"), _([["That took long enough! I can't await getting started. I doubt you deserve full payment. I'll rather give you a reduced payment of %s for educational reasons." She hands you over a credit chip.
    %s]]):format(fmt.credits(credits / 2), request_text))
            player.pay(credits / 2)
        else
            tk.msg(_("Mission accomplished"), _([["Finally! I can't await getting started. Before I forget -" She hands you over a credit chip worth %s.
    %s]]):format(fmt.credits(credits), request_text))
            player.pay(credits)
        end
        misn.markerRm(misn_marker)
        zlk.addNebuResearchLog(_([[You brought Dr. Mensing back from a Empire scientific conference.]]))
        misn.finish(true)
    end
end

