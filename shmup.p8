pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- todo
-- -proc explosion
-- -bullet collision fx

function _init()
 --this will clear the screen
 cls(0)

 mode="start"
 blinkt=1
 
 t=0
end

function _update()
 t+=1
 
 blinkt+=1
 
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="over" then
  update_over()
 end
 
end

function _draw()

 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="over" then
  draw_over()
 end
 
end

function startgame()
 mode="game"
 t=0
 
 ship={}
 ship.x=64
 ship.y=64
 ship.sx=0
 ship.sy=0
 ship.spr=2
 
 flamespr=5
 
 bultimer=0
 
 muzzle=0
 
 score=0
 
 lives=4
 invul=0

 stars={} 
 for i=1,100 do
  local newstar={}
  newstar.x=flr(rnd(128))
  newstar.y=flr(rnd(128))
  newstar.spd=rnd(1.5)+0.5
  add(stars,newstar)
 end 
  
 buls={}
 
 enemies={}
 
 parts={}
 
 spawnen()
end

-->8
-- tools

function starfield()
 
 for i=1,#stars do
  local mystar=stars[i]
  local scol=6
  
  if mystar.spd<1 then
   scol=1
  elseif mystar.spd<1.5 then
   scol=13
  end   
  
  pset(mystar.x,mystar.y,scol)
 end
end

function animatestars()
 
 for i=1,#stars do
  local mystar=stars[i]
  mystar.y=mystar.y+mystar.spd
  if mystar.y>128 then
   mystar.y=mystar.y-128
  end
 end

end

function blink()
 local banim={5,5,5,5,5,5,5,5,5,5,5,6,6,7,7,6,6,5}
 
 if blinkt>#banim then
  blinkt=1
 end

 return banim[blinkt]
end

function drwmyspr(myspr)
 spr(myspr.spr,myspr.x,myspr.y)
end

function col(a,b)
 local a_left=a.x
 local a_top=a.y
 local a_right=a.x+7
 local a_bottom=a.y+7
 
 local b_left=b.x
 local b_top=b.y
 local b_right=b.x+7
 local b_bottom=b.y+7

 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true
end

function spawnen()
 local myen={}
 myen.x=rnd(120)
 myen.y=-8
 myen.spr=21
 myen.hp=5
 myen.flash=0
 
 add(enemies,myen)
end

function explode(expx,expy)
 
 local myp={}
 myp.x=expx
 myp.y=expy
 
 myp.sx=0
 myp.sy=0
 
 myp.age=0
 myp.size=8
 myp.maxage=0
 add(parts,myp)
	  
 for i=1,30 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=rnd()*6-3
	 myp.sy=rnd()*6-3
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=10+rnd(10)
	 
	 add(parts,myp)
 end
 
end
-->8
--update

function update_game()
 --controls
 ship.sx=0
 ship.sy=0
 ship.spr=2
 
 if btn(0) then
  ship.sx=-2
  ship.spr=1
 end
 if btn(1) then
  ship.sx=2
  ship.spr=3
 end
 if btn(2) then
  ship.sy=-2
 end
 if btn(3) then
  ship.sy=2
 end
  
 if btn(5) then
  if bultimer<=0 then
	  local newbul={}
	  newbul.x=ship.x
	  newbul.y=ship.y-3
	  newbul.spr=16
	  add(buls,newbul)
	  
	  sfx(0)
	  muzzle=6
	  bultimer=4
  end
 end
 bultimer-=1
 
 --moving the ship
 ship.x+=ship.sx
 ship.y+=ship.sy
 
 --checking if we hit the edge
 if ship.x>120 then
  ship.x=120
 end
 if ship.x<0 then
  ship.x=0
 end
 if ship.y<0 then
  ship.y=0
 end
 if ship.y>120 then
  ship.y=120
 end
 
 --move the bullets
 for i=#buls,1,-1 do
  local mybul=buls[i]
  mybul.y=mybul.y-4
  
  if mybul.y<-8 then
   del(buls,mybul)
  end
 end
 
 --moving enemies 
 for myen in all(enemies) do
  myen.y+=1
  myen.spr+=0.4
  if myen.spr>=25 then
   myen.spr=21
  end
  
  if myen.y>128 then
   del(enemies,myen)
   spawnen()
  end
 end
 
 --collision enemy x bullets
 for myen in all(enemies) do
  for mybul in all(buls) do
   if col(myen,mybul) then
    del(buls,mybul)
    myen.hp-=1
    sfx(3)
    myen.flash=2
    
    if myen.hp<=0 then
     del(enemies,myen)   
     sfx(2)
     score+=1
     spawnen()
     explode(myen.x+4,myen.y+4)
    end
   end
  end
 end
 
 --collision ship x enemies
 if invul<=0 then
	 for myen in all(enemies) do
	  if col(myen,ship) then
	   lives-=1
	   sfx(1)
	   invul=60
	  end
	 end
 else
  invul-=1
 end
 
 if lives<=0 then
  mode="over"
  return
 end
 
 
 --animate flame
 flamespr=flamespr+1
 if flamespr>9 then
  flamespr=5
 end
 
 --animate mullze flash
 if muzzle>0 then
  muzzle=muzzle-1
 end
  
 animatestars()
end

function update_start()
 if btnp(4) or btnp(5) then
  startgame()
 end
end

function update_over()
 if btnp(4) or btnp(5) then
  mode="start"
 end
end
-->8
-- draw

function draw_game()
 cls(0)
 starfield()

 if invul<=0 then
  drwmyspr(ship)
  spr(flamespr,ship.x,ship.y+8)
 else
  --invul state
  if sin(t/5)<0.1 then
   drwmyspr(ship)
   spr(flamespr,ship.x,ship.y+8)
  end
 end
 
 --drawing enemies
 for myen in all(enemies) do
  if myen.flash>0 then
   myen.flash-=1
   for i=1,15 do
    pal(i,7)
   end
  end
  drwmyspr(myen)
  pal()
 end
  
 --drawing bullets
 for mybul in all(buls) do
  drwmyspr(mybul)
 end
 
 if muzzle>0 then
  circfill(ship.x+3,ship.y-2,muzzle,7)
 end
 
 --drawing particles
 for myp in all(parts) do
  local pc=7
  
  if myp.age>5 then
   pc=10
  end
  if myp.age>7 then
   pc=9
  end
  if myp.age>10 then
   pc=8
  end
  if myp.age>12 then
   pc=2
  end
  if myp.age>15 then
   pc=5
  end
  
  circfill(myp.x,myp.y,myp.size,pc)
  
  myp.x+=myp.sx
  myp.y+=myp.sy
  
  myp.sx=myp.sx*0.85
  myp.sy=myp.sy*0.85
  
  myp.age+=1
  
  if myp.age>myp.maxage then
   myp.size-=0.5
   if myp.size<0 then
    del(parts,myp)
   end
  end
  
 end
 
 print("score:"..score,40,1,12)
 
 for i=1,4 do
  if lives>=i then
   spr(13,i*9-8,1)
  else
   spr(14,i*9-8,1)
  end 
 end
 
 --print(#buls,5,5,7)
end

function draw_start()
 --print(blink())
 cls(1)
 
 print("my awesome shmup",34,40,12) 
 print("press any key to start",20,80,blink())
end

function draw_over()
 cls(8)
 print("game over",48,40,2) 
 print("press any key to continue",16,80,blink())
end
__gfx__
00000000000220000002200000022000000000000000000000000000000000000000000000000000000000000000000000000000088008800880088000000000
000000000028820000288200002882000000000000077000000770000007700000c77c0000077000000000000000000000000000888888888008800800000000
007007000028820000288200002882000000000000c77c000007700000c77c000cccccc000c77c00000000000000000000000000888888888000000800000000
0007700000288e2002e88e2002e882000000000000cccc00000cc00000cccc0000cccc0000cccc00000000000000000000000000888888888000000800000000
00077000027c88202e87c8e202887c2000000000000cc000000cc000000cc00000000000000cc000000000000000000000000000088888800800008000000000
007007000211882028811882028811200000000000000000000cc000000000000000000000000000000000000000000000000000008888000080080000000000
00000000025582200285582002285520000000000000000000000000000000000000000000000000000000000000000000000000000880000008800000000000
00000000002992000029920000299200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000330033003300330033003300330033000000000000000000000000000000000000000000000000000000000
09aaaa900000000000000000000000000000000033b33b3333b33b3333b33b3333b33b3300000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000003bbbbbb33bbbbbb33bbbbbb33bbbbbb300000000000000000000000000000000000000000000000000000000
9a7777a9000000000000000000000000000000003b7717b33b7717b33b7717b33b7717b300000000000000000000000000000000000000000000000000000000
9a7777a9000000000000000000000000000000000b7117b00b7117b00b7117b00b7117b000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000037730000377300003773000037730000000000000000000000000000000000000000000000000000000000
09aaaa90000000000000000000000000000000000303303003033030030330300303303000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000300003030000003030000300330033000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000099900000000005555555505000000005050550000000000500000000000000000000000000000000000000000000000000000000
00000000070000000000999999900000050055222222500000050055555250000000000555050000000000000000000000000000000000000000000000000000
00070000000007000009aaaaaaaa9900005022888888255000505555885555500000000550055000000000000000000000000000000000000000000000000000
0000770aaa900000009aaaa777aaa990005288899998825000555222985555000000000000055000000000000000000000000000000000000000000000000000
0000007777aa0000009aaaa7777aaa9005228999aaa9825000225552222585000005550000000550000000000000000000000000000000000000000000000000
00000a7777770700009aa777777aaa0000228a9a7aa9822500522522222885500005550000055550000000000000000000000000000000000000000000000000
0000a7777777a000099aa7777777aa00052889a777a9882500555229552888500000500000555550000000000000000000000000000000000000000000000000
000097777777a00009aaa7777777aa9005289aa77aa9882000059229928285500000000000555500000000000000000000000000000000000000000000000000
000007777777a00009aaa7777777aa9000289aaaaaa9885000559528855225000000000550555500000000000000000000000000000000000000000000000000
00770777777a7000009aaa77777aaa900058899a9999885000558958529985500000000550000000000000000000000000000000000000000000000000000000
000000777aa007000099aaaaaaaaa900005588999988225000555259528825500550000000000000000000000000000000000000000000000000000000000000
000070000000000000099aaaaaa99900005528888222250000052525825255000555550000555500000000000000000000000000000000000000000000000000
00000007007000000000999aa9999000000055522250550000005555555550000555555000555500000000000000000000000000000000000000000000000000
00000000007000000000000999000000000050555005500000005550500500000005500000555000000000000000000000000000000000000000000000000000
__sfx__
000100003455032550305502e5502b550285502555022550205501b55018550165501355011550010000f5500c5500a5500855006550055500455003550015500055000000000000000000000000000100000000
000100002b650366402d65025650206301d6201762015620116200f6100d6100a6100761005610046100361002610026000160000600006000060000600006000000000000000000000000000000000000000000
00010000377500865032550206300d620085200862007620056100465004610026000260001600006200070000700006300060001600016200160001600016200070000700007000070000700007000070000700
000100000961025620006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
