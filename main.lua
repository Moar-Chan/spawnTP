-- Easy config here:
SpawnTPDebug = false;           --(implimented)     Debug for developing it
SpawnTPOnDeath = true;          --(implimented)     If you want to SpawnTP after death.
SpawnTPOnLogin = false;         --(implimented)     If set true will always random spawn you no matter if you are logging in or died.
SpawnTPOnFirstLogin = false;    --(not implimented) Will spawn you in a random spot on first login.
SpawnTPCommand = false;         --(not implimented) Not actually implimented

SpawnTPPluginName = "spawnTP";
SpawnTPPrefix = SpawnTPPluginName .. ": ";


-- config spawn area
Xmax = 8192;
Xmin = -8192;

Y = 72;     -- Should be a pretty good nummber but can honestly be done alot better!

Zmax = 8192;
Zmin = -8192;

DB = sqlite3.open("Plugins/spawnTP/ReturningPlayers.sqlite"); --Change string to store elsewhere


-- the function used to Teleport player
function SpawnTP(Player)
    local UUID = Player:GetUUID()
    local X = math.random(Xmin, Xmax);
    local Z = math.random(Zmin, Zmax);

    Player:SendAboveActionBarMessage("Spawning @(x = " .. X .. ", y = " .. Y ..", z = " .. Z .. ")"); -- Change spawn message
    Player:TeleportToCoords(X, Y, Z);

    local msg = "spawned: ( name = " .. Player.GetName() .. " UUID = " .. UUID .. " @(x = " .. X .. ", y = " .. Y ..", z = " .. Z .. "))";
    debug(msg);
end

-- the command processer
function CommandProcess(Player, CommandSplit, EntireCommand)
    if (string.lower(CommandSplit[1]) == "spawntp") then
    CSpawnTP(Player);
    end
end

-- 
function CSpawnTP(Player)
    Debug("CSpawnTP called by: " .. Player.GetName());
    spawnTP(Player);
end


-- Actual code not much to customizing under here!
function Initialize(Plugin)
	Plugin:SetName("spawnTP")
	Plugin:SetVersion(1)

    -- A table to see if the player died or logged in.
    deathflag = {};

    -- For getting when a player spawns
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, Spawning)

    -- For temp logging death
    cPluginManager:AddHook(cPluginManager.HOOK_KILLED, Deded);

    -- for command
    cPluginManager:AddHook(cPluginManager.HOOK_EXECUTE_COMMAND, CommandProcess);

    if(SpawnTPOnFirstLogin)
    then
        if (DB == nil) then
            LOGWARNING(Plugin.GetName() .. ": Cannot open ReturningPlayers.sqlite");
            return false;
        end

    if not(
        DB:execute([[CREATE TABLE players ('id' string NOT NULL UNIQUE,
        PRIMARY KEY("id"))]])
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


--small debug that checks config
function Debug(message)
    if (SpawnTPDebug) then
    LOG(message);
    end
end

-- Add player to died list, this is so we can track if its a login spawn or not.
function Deded(Victim)
    if (Victim:IsPlayer())
    then
        local UUID = Victim:GetUUID()
        table.insert(deathflag, UUID);
        local msg = SpawnTPPrefix .. "Player register to death list: ( name = " .. Victim:GetName() .. ", UUID = " .. UUID;
        debug(msg);
    else

    end
    
end

function Spawning(Player)
    local onDeath = false;
    local UUID = Player:GetUUID();
    -- see if they have died
    for _,v in pairs(deathflag) do
        if v == UUID then
            onDeath = true;
            table.remove(deathflag, _)
          break
        end
      end

      -- if random spawn on first login is true
    if(SpawnTPOnFirstLogin)
    then
        --local hits, errorstring = DB:execute([[SELECT count(*) FROM players where id = "]] .. id .. [["]]);
        local rows = DB:nrows([[SELECT * FROM players where id = "]] .. UUID .. [["]]);
        local msg = "I have HIT: " .. rows[1] .. " rows that match users ID";
        debug(msg);
        if hits < 1
        then
            local msg = "Inserting and spawning player with ID = " .. UUID;
            debug(msg);
            SpawnTP(Player);
            DB:execute([[insert into players (id) values ("]] .. UUID .. [[")]])
        end
    end

    -- if they have died
    if (onDeath)
    then
        SpawnTP(Player)
    else
        if (SpawnTPOnLogin)
        then
            SpawnTP(Player)
        end
    end
end