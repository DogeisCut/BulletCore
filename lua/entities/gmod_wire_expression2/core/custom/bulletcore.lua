//author: DogeisCut 
E2Lib.RegisterExtension("BulletCore", true, "Adds functions to fire bullets/tracers from an e2 chip or other entites.")

local BulletCore = {}

BulletCore.fireBullet_max_perSecond = CreateConVar("bulletcore_fireBullet_max_perSecond", "150", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
BulletCore.bulletAmount_max = CreateConVar("bulletcore_bulletAmount_max", "25", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
BulletCore.bulletAmount_max = CreateConVar("bulletcore_bulletAmount_max", "25", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
BulletCore.bulletSpread_max = CreateConVar("bulletcore_bulletSpread_max", "2", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
BulletCore.bulletForce_max = CreateConVar("bulletcore_bulletForce_max", "1000", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
BulletCore.bulletDamage_max = CreateConVar("bulletcore_bulletDamage_max", "1000", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

BulletCore.occurs = {}
BulletCore.nextTime = CurTime()+1

--sorry antcore, i promise these functions are the only thing i took from you
function BulletCore.OccurReset()
	if CurTime() >= BulletCore.nextTime then
		BulletCore.occurs = {}
		BulletCore.nextTime = CurTime()+1
	end
end
hook.Add("Think","BulletCore.OccurReset",BulletCore.OccurReset)

function BulletCore.getCanOccur(id, eventname, maxamt)
	if BulletCore.occurs[id] == nil then BulletCore.occurs[id] = {} end
	if BulletCore.occurs[id][eventname] == nil then BulletCore.occurs[id][eventname] = 0 end
	
	return BulletCore.occurs[id][eventname] < maxamt
end

function BulletCore.setOccur(id, eventname)
	BulletCore.occurs[id][eventname] = BulletCore.occurs[id][eventname] + 1
end
--end of apologies

function BulletCore.setup()
    print("BulletCore loading")
end
BulletCore.setup()

local bullet = {}
effectdata   = EffectData()

__e2setcost(50)
e2function void entity:fireBullet( vector pos, angle rot, force, damage, numbullets, vector spread, string tracername, numtracers) 
    if !IsValid(this) then return end
    bullet.Num = math.Clamp(  math.floor( math.max( 1, numbullets ) ), 1, BulletCore.bulletAmount_max:GetInt() )
    bullet.Src = Vector(pos[1],pos[2],pos[3])
    bullet.Dir = Angle(rot[1],rot[2],rot[3]):Forward()
    bullet.Spread = Vector(math.Clamp( spread[1], 0, BulletCore.bulletSpread_max:GetFloat() ),math.Clamp( spread[2], 0, BulletCore.bulletSpread_max:GetFloat() ),0)
    bullet.Tracer = math.floor( math.max( numtracers or 1 ) )
    bullet.TracerName = string.Trim(tracername)
    bullet.Force = math.Clamp( force, 0, 500 )
    bullet.Damage = math.Clamp( damage, 0, 1000 )
    bullet.Attacker = this

    if not BulletCore.getCanOccur(self,"BulletCore.fireBullet",BulletCore.fireBullet_max_perSecond:GetFloat()) then return end
    BulletCore.setOccur(self,"BulletCore.fireBullet")

    this:FireBullets(bullet)

end

e2function void entity:fireBullet( vector pos, angle rot) 
    if !IsValid(this) then return end
    bullet.Src = Vector(pos[1],pos[2],pos[3])
    bullet.Dir = Angle(rot[1],rot[2],rot[3]):Forward()
    bullet.Attacker = this

    if not BulletCore.getCanOccur(self,"BulletCore.fireBullet",BulletCore.fireBullet_max_perSecond:GetFloat()) then return end
    BulletCore.setOccur(self,"BulletCore.fireBullet")

    this:FireBullets(bullet)
end

__e2setcost(nil)

e2function void setBulletAmount( numbullets )
    bullet.Num = math.Clamp(  math.floor( math.max( 1, numbullets ) ), 1, BulletCore.bulletAmount_max:GetInt() )
end

e2function void setBulletSpread( vector spread )
    bullet.Spread = Vector(math.Clamp( spread[1], 0, BulletCore.bulletSpread_max:GetFloat() ),math.Clamp( spread[2], 0, BulletCore.bulletSpread_max:GetFloat() ),0)
end

e2function void setBulletTracer( numtracers )
    bullet.Tracer = math.floor( math.max( numtracers or 1 ) )
end

e2function void setBulletTracerName( string tracername )
    bullet.TracerName = string.Trim(tracername)
end

e2function void setBulletForce( force )
    bullet.Force = math.Clamp( force, 0, BulletCore.bulletForce_max:GetFloat() )
end

e2function void setBulletDamage( damage )
    bullet.Damage = math.Clamp( damage, 0, BulletCore.bulletDamage_max:GetFloat() )
end


