if SERVER then
    -- Define the ricochet behavior
    function BulletRicochet(attacker, tr, dmginfo)
        local hitEntity = tr.Entity
        local hitPos = tr.HitPos
        local hitNormal = tr.HitNormal
        local surfaceType = tr.MatType

        -- Define materials considered sharp
        local sharpMaterials = {
            [MAT_METAL] = true,
            [MAT_TILE] = true,
            [MAT_ANTLION] = true, -- Example of an additional material
            [MAT_COMPUTER] = true -- Example of an additional material
        }

        -- Define blunt materials
        local bluntMaterials = {
            [MAT_CONCRETE] = true,
            [MAT_DIRT] = true,
            [MAT_FLESH] = true,
            [MAT_GRATE] = true,
            [MAT_VENT] = true,
            [MAT_PLASTIC] = true,
            [MAT_WOOD] = true,
            [MAT_SAND] = true, -- Example of an additional material
            [MAT_FOLIAGE] = true, -- Example of an additional material
            [MAT_GLASS] = true -- Glass is now considered blunt
        }

        -- Handle entity types (props, world brushes, etc.)
        if hitEntity:IsWorld() or hitEntity:GetClass() == "prop_physics" then
            if sharpMaterials[surfaceType] then
                -- Ricochet logic for sharp surfaces
                local newDir = (hitNormal + VectorRand() * 0.1):GetNormalized()
                local newBullet = {
                    Attacker = attacker,
                    Damage = dmginfo:GetDamage() * 0.5, -- Reduce damage after ricochet
                    Force = dmginfo:GetDamageForce() * 0.5, -- Reduce force after ricochet
                    Num = 1,
                    Src = hitPos,
                    Dir = newDir,
                    Spread = Vector(0, 0, 0),
                    Tracer = 1,
                    TracerName = "Tracer",
                    Callback = BulletRicochet
                }
                timer.Simple(0.01, function() attacker:FireBullets(newBullet) end)
            elseif bluntMaterials[surfaceType] then
                -- No ricochet for blunt surfaces
                -- Just apply the damage and stop
            else
                -- Default behavior for unknown materials
                -- Apply the damage and stop
            end
        else
            -- Default behavior for other entities
            -- Apply the damage and stop
        end
    end

    -- Hook into bullet firing
    hook.Add("EntityFireBullets", "UniversalBulletRicochet", function(ent, data)
        local attacker = ent
        local bulletData = data

        -- Add the ricochet callback
        bulletData.Callback = function(attacker, tr, dmginfo)
            BulletRicochet(attacker, tr, dmginfo)
        end

        return true
    end)
end