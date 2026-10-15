import unittest
from test_runtime import env

def combat(l,event,payload,source='PLAYER',target='NPC',flags=1):
 l.globals().combatEvent=event;l.globals().source=source;l.globals().target=target;l.globals().flags=flags
 l.execute('DAN.DmgTextFrame.scripts.OnEvent(DAN.DmgTextFrame,"COMBAT_LOG_EVENT_UNFILTERED",1,combatEvent,source,"source",flags,target,"dest",10,'+payload+')')

def configured():
 l=env();l.execute('''local db=DAN.db;db.petToTargetDamageText=true;db.targetToPlayerDamageText=true
 db.autoAttackPlusCritAnimation='verticalUp';db.autoAttack='fountain';db.critAnimation='verticalUp';db.commonDMGAnimation='fountain'
 db.interrupt={font='interruptfont',fontSize=17,fontOutline='OUTLINE'}
 db.playerToTargetHealText=true;db.petToTargetHealText=true;db.targetToPlayerHealText=true;db.showOverHeal=true
 ACTION_SPELL_MISSED_MISS='Miss' ''');return l

class CombatPayloads(unittest.TestCase):
 def test_swing_critical_end_to_end_in_all_directions(self):
  for source,target,flags in [('PLAYER','NPC',1),('OTHER','PLAYER',1),('PET','NPC',160),('GUARDIAN','NPC',192)]:
   for crit in ('true','false'):
    with self.subTest(source=source,crit=crit):
     l=configured();combat(l,'SWING_DAMAGE','100,0,1,0,0,0,'+crit+',false,false',source,target,flags)
     self.assertEqual(l.eval('#fonts'),1);self.assertEqual(l.eval('fonts[1].pow'),crit=='true');self.assertIn('100',l.eval('fonts[1].text'))
     self.assertTrue(l.eval('fonts[1].nameplateFrame==frame') if target=='NPC' else l.eval('fonts[1].nameplateFrame==nil'))
 def test_swing_miss_reason_end_to_end(self):
  for source,target,flags in [('PLAYER','NPC',1),('OTHER','PLAYER',1),('PET','NPC',160),('GUARDIAN','NPC',192)]:
   for reason,label in [('DODGE','Dodge'),('PARRY','Parry'),('MISS','Miss')]:
    with self.subTest(source=source,reason=reason):
     l=configured();combat(l,'SWING_MISSED','"'+reason+'",false',source,target,flags)
     self.assertEqual(l.eval('#fonts'),1);self.assertIn(label,l.eval('fonts[1].text'))
 def test_spell_payloads_still_reach_real_rendering(self):
  for event in ('SPELL_DAMAGE','SPELL_PERIODIC_DAMAGE','RANGE_DAMAGE'):
   l=configured();combat(l,event,'123,"Spell",4,120,0,4,0,0,0,true');self.assertTrue(l.eval('fonts[1].pow'));self.assertIn('120',l.eval('fonts[1].text'))
  l=configured();combat(l,'SPELL_MISSED','123,"Spell",4,"PARRY"');self.assertIn('Parry',l.eval('fonts[1].text'))
  l=configured();combat(l,'SPELL_HEAL','123,"Heal",2,75,0,0,true');self.assertIn('75',l.eval('fonts[1].text'))
 def test_disabled_swing_directions_and_unrelated_combat_do_not_render(self):
  for source,target,flags,toggle in [('PLAYER','NPC',1,'playerToTargetDamageText'),('OTHER','PLAYER',1,'targetToPlayerDamageText'),('PET','NPC',160,'petToTargetDamageText')]:
   for event,payload in [('SWING_DAMAGE','100,0,1,0,0,0,true'),('SWING_MISSED','"PARRY",false')]:
    l=configured();l.execute('DAN.db.'+toggle+'=false');combat(l,event,payload,source,target,flags);self.assertEqual(l.eval('#fonts'),0)
  for source,flags in [('OTHER',1),('FOREIGNPET',32)]:
   l=configured();combat(l,'SWING_DAMAGE','100,0,1,0,0,0,true',source,'NPC',flags);self.assertEqual(l.eval('#fonts'),0)

class EventFont(unittest.TestCase):
 def test_real_miss_handler_uses_miss_font_and_restores_it_after_animation(self):
  for event,payload in [('SWING_MISSED','"DODGE",false'),('SPELL_MISSED','123,"Spell",4,"PARRY"')]:
   l=configured();combat(l,event,payload)
   self.assertEqual(l.eval('fonts[1].fontPathSet'),'missfont')
   l.execute('now=.3;DAN.DmgTextFrame.scripts.OnUpdate()')
   self.assertEqual(l.eval('fonts[1].fontPathSet'),'missfont');self.assertEqual(l.eval('fonts[1].sizeSet'),18)

class EventAlpha(unittest.TestCase):
 def test_event_alpha_reaches_text_icon_and_animation(self):
  for source,flags,event,payload,category in [
   ('PLAYER',1,'SPELL_MISSED','123,"Spell",4,"DODGE"','miss'),
   ('PET',160,'SWING_MISSED','"PARRY",false','miss'),
   ('PLAYER',1,'SPELL_DISPEL','123,"Dispel",2,456,"Aura",4,"BUFF"','dispel'),
   ('PLAYER',1,'SPELL_INTERRUPT','123,"Interrupt",1,456,"Interrupted",4','interrupt')]:
   for alpha in (0,.2,.75,1):
    with self.subTest(event=event,alpha=alpha):
     l=configured();l.execute('DAN.db.showIcon=true;DAN.db.'+category+'.fontAlpha='+str(alpha))
     combat(l,event,payload,source,'NPC',flags)
     self.assertEqual(l.eval('#fonts'),1);self.assertAlmostEqual(l.eval('fonts[1].startAlpha'),alpha)
     self.assertAlmostEqual(l.eval('fonts[1].alpha'),alpha);self.assertAlmostEqual(l.eval('fonts[1].icon.alpha'),alpha)
     l.execute('now=.2;DAN.DmgTextFrame.scripts.OnUpdate()')
     self.assertAlmostEqual(l.eval('fonts[1].alpha'),alpha*.5);self.assertAlmostEqual(l.eval('fonts[1].icon.alpha'),alpha*.5)
 def test_missing_event_alpha_defaults_to_one(self):
  l=configured();combat(l,'SWING_MISSED','"DODGE",false');self.assertEqual(l.eval('fonts[1].startAlpha'),1)
 def test_reused_font_reads_new_profile_alpha(self):
  l=configured();l.execute('DAN.db.miss.fontAlpha=.2');combat(l,'SWING_MISSED','"DODGE",false')
  l.execute('DAN:DeleteFontString(fonts[1]);local old=DAN.db;E.db.DmgAtNameplates={};for k,v in pairs(old) do E.db.DmgAtNameplates[k]=v end;E.db.DmgAtNameplates.miss={font="newfont",fontSize=19,fontOutline="OUTLINE",fontAlpha=.7}')
  combat(l,'SWING_MISSED','"PARRY",false');self.assertEqual(l.eval('#fonts'),1);self.assertEqual(l.eval('fonts[1].fontPathSet'),'newfont');self.assertAlmostEqual(l.eval('fonts[1].startAlpha'),.7)
