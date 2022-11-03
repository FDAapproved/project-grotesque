// -----------------------------------------------------------------------------
// Shotgun Shells
// -----------------------------------------------------------------------------

class HDShellAmmo : HDRoundAmmo
{
	default
	{		
		// Pointers.
		hdroundammo.casing  "HDSpentShell";
		hdroundammo.bundle  "ShellBoxPickup";
		
		// Unpack/Pack Sprites. 
		hdroundammo.spritesingle "SHELA0";
		hdroundammo.spritepacked "SHL1A0"; 
		
		// Pack amounts.
		hdroundammo.amountpack   4; 
		hdroundammo.amountbundle 20;

		inventory.pickupmessage        "Picked up a shotgun shell.";
		hdroundammo.packpickupmessage  "Picked up some shotgun shells.";
		scale 0.3;
		tag "shotgun shells";
		hdpickup.refid HDLD_SHOTSHL;
		hdpickup.bulk ENC_SHELL;
		inventory.icon "SHELA0";
	}
	override void GetItemsThatUseThis()
	{
		itemsthatusethis.push("Hunter");
		itemsthatusethis.push("Slayer");
	}
	states
	{
	spawn:
		SHL1 A -1;
		stop;
	death:
		ESHL A -1
		{
			if(Wads.CheckNumForName("id",0)==-1)A_SetTranslation("FreeShell");
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}
		stop;
	}
}







class HDSpentShell:HDDebris{
	default{
		-noteleport +forcexybillboard
		seesound "misc/casing2";scale 0.3;height 2;radius 2;
		bouncefactor 0.5;
	}
	override void postbeginplay(){
		super.postbeginplay();
		if(Wads.CheckNumForName("id",0)==-1)A_SetTranslation("FreeShell");
		if(vel==(0,0,0))A_ChangeVelocity(0.0001,0,-0.1,CVF_RELATIVE);
	}
	vector3 lastvel;
	override void Tick(){
		if(!isFrozen())lastvel=vel;
		super.Tick();
	}
	states{
	spawn:
		ESHL ABCDEFGH 2;
		loop;
	death:
		ESHL A -1{
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}
//a shell that can be caught in hand, launched from the Slayer
class HDUnSpentShell:HDSpentShell{
	states{
	spawn:
		ESHL ABCDE 2;
		TNT1 A 0{
			if(A_JumpIfInTargetInventory("HDShellAmmo",0,"null"))
			A_SpawnItemEx("HDFumblingShell",
				0,0,0,vel.x+frandom(-1,1),vel.y+frandom(-1,1),vel.z,
				0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
			);else A_GiveToTarget("HDShellAmmo",1);
		}
		stop;
	}
}
//any other single shell tumblng out
class HDFumblingShell:HDSpentShell{
	default{
		bouncefactor 0.3;
	}
	states{
	spawn:
		ESHL ABCDEFGH 2;
		loop;
	death:
		TNT1 A 0{
			let sss=spawn("HDShellAmmo",pos);
			sss.vel.xy=lastvel.xy+lastvel.xy.unit()*abs(lastvel.z);
			sss.setstatelabel("death");
			if(sss.vel.x||sss.vel.y){
				sss.A_FaceMovementDirection();
				sss.angle+=90;
				sss.frame=randompick(0,4);
			}else sss.frame=randompick(0,0,0,4,4,4,2,2,5);
			inventory(sss).amount=1;
		}stop;
	}
}


class ShellBoxPickup:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of Shotgun Shells"
		//$Sprite "SBOXA0"
		scale 0.4;
		hdupk.amount 20;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Picked up some shotgun shells.";
		hdupk.pickuptype "HDShellAmmo";
		translation "160:167=80:105";
	}
	states{
	spawn:
		SBOX A -1 nodelay{
			if(Wads.CheckNumForName("id",0)==-1)scale=(0.25,0.25);
		}
	}
}

// Four shells. Replaces shellpickups. 
class ShellPickup:IdleDummy
{
	default
	{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Four Shotgun Shells"
		//$Sprite "SHELA0"
	}
	states
	{
	spawn:
		SHEL A 0 nodelay{
			let iii=hdpickup(spawn("HDShellAmmo",pos,ALLOW_REPLACE));
			if(iii){
				hdf.transferspecials(self,iii,hdf.TS_ALL);
				iii.amount=4;
			}
		}stop;
	}
}
