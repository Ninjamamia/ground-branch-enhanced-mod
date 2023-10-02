local log                = require('gbem.util.class.logger').create('ActorStateManager')
local sprintf            = require('gbem.util.ext.strings').sprintf
local tableIsEmpty       = require('gbem.util.ext.tables').isEmpty
local tableNotEmpty      = require('gbem.util.ext.tables').notEmpty
local count              = require('gbem.util.ext.tables').count
local fif                = require('gbem.util.ext.values').fif

local _actor = actor
local actor = nil

--- @class ActorStateManager
 ---
 --- Used as a proxy to the proper GB actors state. Build a list of managed actors
 --- by storing each actor along with their desired state in the _managedActors
 --- field. Allows us to reset all managed actors to a desired state when we need.
 ---
 --- @todo Maybe the "shouldEnable" thing passing around and stored in the
 ---         _managedActors private could be an enum?
 ---         Also the setGBActorState uses a state object, maybe we could tie
 ---         this into the enum as well?
 ---
 --- @field private _managedActors table
 ---
local ActorStateManager = {}
ActorStateManager.__index = ActorStateManager

-- Set visibility and/or collision of an actor according to the given state
local function setGBActorState(actor, state)
    local out = {}
    if state.visible ~= nil then
        _actor.SetHidden(actor, not state.visible)
        table.insert(out, sprintf("visible=%s", state.visible))
    end
    if state.collide ~= nil then
        _actor.SetEnableCollision(actor, state.collide)
        table.insert(out, sprintf("collide=%s", state.collide))
    end
    local actorStateStr
    if tableNotEmpty(out) then
        actorStateStr = table.concat(out, ', ')
    else
        actorStateStr = '(no change)'
    end

    log:debug(sprintf("Applied state to actor '%s': %s", _actor.GetName(actor), actorStateStr))
end

--- Instantiate the ActorStateManager
 ---
 --- @return ActorStateManager      Instance of the ActorGroupRandomiser
 ---
function ActorStateManager.create()
    local instance = setmetatable({}, ActorStateManager)
    instance._managedActors = {},
    log:debug('ActorStateManager instantiated')
    return instance
end

--- Set state of a single actor to "enable", store it in the managed actors
 ---
 --- @param actor userdata          The userdata actor from GB
 ---
function ActorStateManager:setEnable(actor)
    self:set(actor, true)
end

--- Set state of a single actor to "disable", store it in the managed actors
 ---
 --- @param actor userdata          The userdata actor from GB
 ---
function ActorStateManager:setDisable(actor)
    self:set(actor, false)
end

--- Set state of a single actor to "enable" or "disable", store it in the managed actors
 ---
 --- @param actor userdata          The userdata actor from GB
 --- @param shouldEnable boolean    True to enable the actor, false to disable it
 ---
function ActorStateManager:set(actor, shouldEnable)
    self._managedActors[actor] = shouldEnable

    local actorName = _actor.GetName(actor)
    local setState = fif(shouldEnable, "enabled", "disabled")

    log:debug(sprintf("Set state to actor '%s': %s",
        actorName, setState
    ))
end

--- Apply state to each managed actors
 ---
function ActorStateManager:apply()
    log:info("Applying managed actors state...")

    if tableIsEmpty(self._managedActors) then
        log:info("-> No managed actors")
        return
    end

    for actor, shouldEnable in pairs(self._managedActors) do
        setGBActorState(actor, {
            visible = shouldEnable,
            collide = shouldEnable,
        })
    end

    log:info(sprintf("-> Applied state to %s actor(s)", count(self._managedActors)))
end

--- Set all managed actors to enable and remove them from the managed actors
 ---
function ActorStateManager:reset()
    log:info("Resetting managed actors state...")

    if tableIsEmpty(self._managedActors) then
        log:info("-> No managed actors")
        return
    end

    for actor, _ in pairs(self._managedActors) do
        setGBActorState(actor, {
            visible = true,
            collide = true,
        })
    end
    
    log:info(sprintf("-> Reset state of %s actor(s)", count(self._managedActors)))
    self._managedActors = {}
end

return ActorStateManager
