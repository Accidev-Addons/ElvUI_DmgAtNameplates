
from pathlib import Path
from lupa.lua51 import LuaRuntime
import unittest
ROOT=Path(__file__).resolve().parents[1]

COMMON='\nformat=string.format; tinsert=table.insert; max=math.max\nfunction wipe(t) for k in pairs(t) do t[k]=nil end return t end\nfunction newFrame(parent)\n local f={parent=parent,shown=true,width=100,height=16,points={},scripts={},events={}}\n function f:ClearAllPoints() self.points={} end\n function f:SetPoint(...) table.insert(self.points,{...}) end\n f.Point=f.SetPoint\n function f:ClearAndSetPoint(...) self:ClearAllPoints() self:SetPoint(...) end\n function f:SetSize(w,h) self.width=w self.height=h or w end; f.Size=f.SetSize\n function f:SetWidth(v) self.width=v end; f.Width=f.SetWidth\n function f:SetHeight(v) self.height=v end; f.Height=f.SetHeight\n function f:GetWidth() return self.width end\n function f:GetHeight() return self.height end\n function f:GetSize() return self.width,self.height end\n function f:GetFrameLevel() return 1 end\n function f:GetParent() return self.parent end\n function f:SetParent(p) self.parent=p end\n function f:IsShown() return self.shown end; f.IsVisible=f.IsShown\n function f:Show() self.shown=true end\n function f:Hide() self.shown=false end\n function f:SetShown(v) self.shown=not not v end\n function f:SetText(v)\n  assert(not self.isFontString or self.fontSet, "SetText(): Font not set")\n  self.text=v\n end\n function f:FontTemplate() self.fontSet=true end\n function f:SetFont() self.fontSet=true end\n function f:SetFormattedText(fmt,...) assert(not self.isFontString or self.fontSet,"SetFormattedText(): Font not set");self.text=string.format(fmt,...) end\n function f:GetStringHeight() return 12 end\n function f:SetTextColor(...) self.color={...} end\n function f:SetValue(v) self.value=v end\n function f:SetMinMaxValues(a,b) self.min=a self.max=b end\n function f:CreateTexture() return newFrame(self) end\n function f:CreateFontString() local text=newFrame(self);text.isFontString=true;return text end\n function f:SetScript(k,v) self.scripts[k]=v end\n function f:RegisterEvent(k) self.events[k]=true end\n function f:UnregisterEvent(k) self.events[k]=nil end\n function f:CanChangeProtectedState() return not self.locked end\n function f:IsObjectType() return true end\n function f:GetStatusBarTexture() return self.texture end\n setmetatable(f,{__index=function(_,k) if k:match(\'^Set\') or k:match(\'^Get\') or k==\'FontTemplate\' or k==\'EnableMouse\' then return function() end end end})\n return f\nend\nframes={}\nfunction CreateFrame(_,name,parent) local f=newFrame(parent); table.insert(frames,f); if name then _G[name]=f end return f end\nhooks={}\nfunction hooksecurefunc(a,b,c) if type(a)==\'string\' then hooks[a]=b else hooks[b]=c end end\nC_Timer={After=function(_,_,fn) fn() end}\nNP={db={units={}},VisiblePlates={},CreatedPlates={}}\nfunction NP:Pixel(x) return x end; NP.SirusPixel=NP.Pixel\nfunction NP:GetHealth(f) return f.health or 80,f.maxHealth or 100 end\nE={media={blankTex=\'blank\'},Libs={LSM={Fetch=function(_,_,v) return v end}},UIParent=newFrame(),oUF={Private={frame_metatable={__index={}}},colors={}}}\nfunction E:GetModule() return NP end\nfunction E:ShortValue(v) return tostring(v) end\nfunction E:ClassColor() return {r=1,g=0,b=0} end\nfunction E:CreateMover() end\nElvUI={E,setmetatable({},{__index=function(_,k) return k end}),{},{nameplates={units={}}},{}}\nunitGUIDs={player=\'PLAYER\',target=\'NPC\'}\nfunction UnitGUID(u) return unitGUIDs[u] end\nfunction UnitExists(u) return unitGUIDs[u]~=nil end\nfunction UnitName(u) return u end\nfunction UnitClass() return \'Mage\',\'MAGE\' end\nfunction UnitIsPlayer() return false end\nfunction UnitCanAttack() return true end\nfunction GetSpellInfo(x) return tostring(x),nil,\'texture\' end\n'

def env():
 l=LuaRuntime(unpack_returned_tuples=True);l.execute(COMMON)
 l.execute("""
 DAN={}; E.db={DmgAtNameplates={enable=true,font='font',fontSize=20,fontOutline='OUTLINE',duration=1,showIcon=false,textFormat='none',showDmgToEnemy=true,playerToTargetDamageText=true,showFromAnotherPlayer=true,miss={font='missfont',fontOutline='OUTLINE',fontSize=18},dispel={font='dispelfont',fontOutline='OUTLINE',fontSize=16}}}
 E.Libs.EP={RegisterPlugin=function() end}; function E:GetModule(k) return k=='DmgAtNameplates' and DAN or NP end
 function E:RegisterModule() end
 LibStub=function() return {InExpo=function(_,b,c) return b+c*.5 end,InQuad=function(t,b,c,d) return b+c*t/d end,OutQuint=function(_,b,c) return b+c end,InQuint=function(_,b,c) return b+c end} end
 bit={band=function(a,b) local r,p=0,1 while a>0 and b>0 do if a%2==1 and b%2==1 then r=r+p end a=math.floor(a/2);b=math.floor(b/2);p=p*2 end return r end}
 COMBATLOG_OBJECT_TYPE_PLAYER=1;COMBATLOG_OBJECT_TYPE_NPC=2;COMBATLOG_OBJECT_REACTION_FRIENDLY=4;COMBATLOG_OBJECT_REACTION_HOSTILE=8;COMBATLOG_OBJECT_REACTION_NEUTRAL=16;COMBATLOG_OBJECT_TYPE_PET=32;COMBATLOG_OBJECT_TYPE_GUARDIAN=64;COMBATLOG_OBJECT_AFFILIATION_MINE=128
 SCHOOL_MASK_PHYSICAL=1;SCHOOL_MASK_HOLY=2;SCHOOL_MASK_FIRE=4;SCHOOL_MASK_NATURE=8;SCHOOL_MASK_FROST=16;SCHOOL_MASK_SHADOW=32;SCHOOL_MASK_ARCANE=64
 UIParent=newFrame(); now=0; timeCalls=0; GetTime=function() timeCalls=timeCalls+1 return now end
 frame=newFrame();frame.guid='NPC';frame.unit='nameplate1';frame.Health=newFrame(frame);unitGUIDs.nameplate1='NPC';NP.VisiblePlates[frame]=1
 function DAN:RegisterEvent() end;function DAN:UnregisterEvent() end;function DAN:GetName() return 'DmgAtNameplates' end
 NP.OnShow=function() end;NP.OnHide=function() end
 fonts={};local originalFont=newFrame
 function frame:CreateFontString() local text=originalFont(self);text.isFontString=true;table.insert(fonts,text);return text end
 -- Keep font strings created on arbitrary pooled frames observable.
 local originalCreateFrame=CreateFrame
 CreateFrame=function(...)
  local f=originalCreateFrame(...)
  function f:CreateFontString() local text=originalFont(self);text.isFontString=true;table.insert(fonts,text)
   function text:SetFont(path,size,outline) self.fontSet=true;self.fontCalls=(self.fontCalls or 0)+1;self.fontPathSet=path;self.sizeSet=size end
   function text:SetAlpha(alpha) self.alpha=alpha end
   return text
  end
  function f:SetAlpha(alpha) self.alpha=alpha end
  function f:CreateTexture() local texture=originalFont(self);function texture:SetAlpha(alpha) self.alpha=alpha end;return texture end
  return f
 end
 """)
 l.execute((ROOT/'Core/Core.lua').read_text());l.execute('DAN.db=E.db.DmgAtNameplates;DAN:PLAYER_ENTERING_WORLD();DAN:InitializePlateIndex()')
 return l

class Runtime(unittest.TestCase):
 def test_lua51(self):
  l=LuaRuntime(unpack_returned_tuples=True);f=l.eval('function(s) local f,e=loadstring(s);return f~=nil,e end')
  self.assertTrue(f((ROOT/'Core/Core.lua').read_text())[0])
 def test_font_initialized_before_first_text(self):
  l=env();l.execute('DAN:DisplayText(frame,"first",20,1,"verticalUp",123,false,"Spell")')
  self.assertEqual(l.eval('fonts[1].text'),'first');self.assertEqual(l.eval('fonts[1].fontCalls'),1)
  l.execute('DAN:DeleteFontString(fonts[1]);DAN:DisplayText(frame,"reused",18,1,"verticalUp",123,false,"Spell","miss")')
  self.assertEqual(l.eval('#fonts'),1);self.assertEqual(l.eval('fonts[1].text'),'reused');self.assertEqual(l.eval('fonts[1].fontPathSet'),'missfont')
 def test_guid_index_hits_do_not_scan(self):
  l=env();l.execute('scans=0; local original=pairs;pairs=function(t) if t==NP.VisiblePlates then scans=scans+1 end return original(t) end;for i=1,1000 do assert(DAN:GetNameplateFrame("NPC")==frame) end')
  self.assertEqual(l.eval('scans'),0)
 def test_guid_index_hide_and_reuse(self):
  l=env();l.execute('NP.VisiblePlates[frame]=nil;frame.shown=false;hooks.OnHide({ElvUIFrame=frame})')
  self.assertIsNone(l.eval('DAN:GetNameplateFrame("NPC")'))
  l.execute('frame.shown=true;frame.guid="NEW";unitGUIDs.nameplate1="NEW";NP.VisiblePlates[frame]=1;hooks.OnShow({ElvUIFrame=frame})')
  self.assertIsNone(l.eval('DAN:GetNameplateFrame("NPC")'));self.assertTrue(l.eval('DAN:GetNameplateFrame("NEW")==frame'))
 def test_ignored_events_skip_unit_api(self):
  l=env();l.execute('guidCalls=0;local old=UnitGUID;UnitGUID=function(u) guidCalls=guidCalls+1 return old(u) end;DAN:FilterEvent("CLEU",1,"SPELL_CAST_SUCCESS","PLAYER","player",1,"NPC","mob",10)')
  self.assertEqual(l.eval('guidCalls'),0);self.assertEqual(l.eval('#fonts'),0)
 def test_disabled_animation_does_not_allocate(self):
  l=env();l.execute('DAN:DisplayText(frame,"text",20,1,"disabled",123,false,"Spell")');self.assertEqual(l.eval('#fonts'),0)
 def test_animation_pool_time_and_alpha(self):
  l=env();l.execute('E.db.DmgAtNameplates.showIcon=true;for i=1,3 do DAN:DisplayText(frame,"hit",20,.4,"verticalUp",123,false,"Spell") end;now=.2;timeCalls=0;DAN.DmgTextFrame.scripts.OnUpdate()')
  self.assertEqual(l.eval('timeCalls'),1);self.assertAlmostEqual(l.eval('fonts[1].alpha'),.2);self.assertAlmostEqual(l.eval('fonts[1].icon.alpha'),.2)
  l.execute('now=2;DAN.DmgTextFrame.scripts.OnUpdate();DAN:DisplayText(frame,"new",20,1,"verticalUp",123,false,"Spell")')
  self.assertEqual(l.eval('#fonts'),3)
 def test_critical_restores_event_font(self):
  l=env();l.execute('DAN:DisplayText(frame,"miss",18,1,"verticalUp",123,true,"Spell","miss");now=.3;DAN.DmgTextFrame.scripts.OnUpdate()')
  self.assertEqual(l.eval('fonts[1].fontPathSet'),'missfont');self.assertEqual(l.eval('fonts[1].sizeSet'),18)
 def test_recycled_plate_clears_text(self):
  l=env();l.execute('DAN:DisplayText(frame,"old",20,1,"verticalUp",123,false,"Spell");frame.guid="OTHER";DAN.DmgTextFrame.scripts.OnUpdate()')
  self.assertFalse(l.eval('fonts[1].shown'));self.assertIsNone(l.eval('fonts[1].nameplateFrame'))
 def test_legacy_fallback(self):
  l=env();l.execute('NP.VisiblePlates={};legacy=newFrame();legacy.guid="LEGACY";NP.PlateGUID={LEGACY=legacy}')
  self.assertTrue(l.eval('DAN:GetNameplateFrame("LEGACY")==legacy'))

if __name__=='__main__':unittest.main(verbosity=2)
