-- Easy config here:
TPSpawnOnLogin = false; -- If set true will always random spawn you no matter if you are logging in or died.
TPSpawnOnFirstLogin = true; -- Will spawn you in a random spot on first login.
TPSpawnCommand = false; -- Not actually implimented
-- confid area
Xmax = 8192;
Xmin = -8192;
Y = 72; -- Should be a pretty good nummber but can honestly be done alot better!
Zmax = 8192;
Zmin = -8192;
DB = sqlite3.open("Plugins/spawnTP/ReturningPlayers.sqlite"); --Change string to store elsewhere



function SpawnTP(Player)
    local X = math.random(Xmin, Xmax);
    local Z = math.random(Zmin, Zmax);
    Player:SendAboveActionBarMessage("Spawning @(x = " .. X .. ", y = " .. Y ..", z = " .. Z .. ")"); -- Change spawn message
    Player:TeleportToCoords(X, Y, Z);
end


-- Actual code not much to customizing under here!
function Initialize(Plugin)
	Plugin:SetName("spawnTP")
	Plugin:SetVersion(1)

    -- A table to see if the player died or logged in.
    deathflag = {};

    -- For getting when a player spawns
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, Spawning)
    cPluginManager:AddHook(cPluginManager.HOOK_KILLED, Deded);
    if(TPSpawnOnFirstLogin)
    then
        if (DB == nil) then
            LOGWARNING(Plugin.GetName() .. ": Cannot open ReturningPlayers.sqlite");
            return false;
        end

    if not(
        DB:execute([[CREATE TABLE players ('id' INTEGER)]])
	) then
		LOGWARNING(PluginPrefix .. "Cannot create DB tables!")
		return false
	end
	
	return true;
    end

	-- Command Bindings

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

-- Add player to died list, this is so we can track if its a login spawn or not.
function Deded(Victim)
    if (Victim:IsPlayer())
    then
        table.insert(deathflag, Victim:GetUUID()); LOG("Ree YOUR SELF!"); 
    else

    end
    
end

function Spawning(Player)
    local onDeath = false;
    -- see if they have died
    for _,v in pairs(deathflag) do
        if v == Player:GetUUID() then
            onDeath = true;
            table.remove(deathflag, _)
          break
        end
      end

      -- if random spawn on first login is true
    if(TPSpawnOnFirstLogin)
    then
        local cursor = DB:execute([[select * from players where id =]] .. Player:GetUUID() .. [[ ]]);

        if(cursor == 0)
        then
            SpawnTP(Player);
            DB:execute([[insert into players (id) values (]] .. Player:GetUUID() .. [[)]])
        end
    end

    -- if they have died
    if (onDeath)
    then
        SpawnTP(Player)
    else
        if (TPSpawnOnLogin)
        then
            SpawnTP(Player)
        end
    end
end