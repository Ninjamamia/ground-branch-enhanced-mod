---
--- About ActorGroupRandomiser
 ---
 --- Used to set the state of actors based on parameters extracted form tags.
 ---
 --- Parsed tags:
 ---
 --- GroupRnd
 ---     Mandatory for actors that should be parsed by this randomiser.
 ---
 --- group = <group_name>
 ---     Arbitrary string used to group actors. Actors in the same group are
 ---     processed together, some parameters only make sense in a group context.
 ---
 --- act = enable | disable
 ---     String 'enable' or 'disable', defaults to 'enable'.
 ---     The state we want the actors to be set to. All actors not set to this
 ---     state (because of the impact of other parameters) will be set to the
 ---     opposite state.
 ---
 --- prob = <integer>
 ---     Integer between 0 and 100, defaults to 100.
 ---     Defines the probability (in percent) that the state is applied to the
 ---     target actor(s).
 ---
 --- num = <integer>
 ---     Integer greater than 0, defaults to the number of actors in the group.
 ---     Used with the group parameter to control the number of actors to apply
 ---     the state to. Selected actors are chosen randomly. If this parameter is
 ---     explicitely provided, max and min parameters will be disregarded.
 ---
 --- min = <integer>
 ---     Integer greater than 0, defaults to 0.
 ---     Used with the group parameter to control the minimum number of actors to
 ---     apply the state to. The num parameter will be randomly chosen between
 ---     the min value and the max value. Disregarded when the num parameter is
 ---     explicitly provided.
 ---
 --- max = <integer>
 ---     Integer greater than 0, defaults to the number of actors in the group.
 ---     Used with the group parameter to control the maximum number of actors to
 ---     apply the state to. The num parameter will be randomly chosen between
 ---     the min value and the max value. Disregarded when the num parameter is
 ---     explicitly provided.
---

local logger                 = require('gbem.util.class.logger').create('ActorGroupRandomiser')
local pipe                   = require('gbem.util.ext.functions').pipe
local sprintf                = require('gbem.util.ext.strings').sprintf
local count                  = require('gbem.util.ext.tables').count
local icount                 = require('gbem.util.ext.tables').icount
local tableContains          = require('gbem.util.ext.tables').contains
local tableEmpty             = require('gbem.util.ext.tables').isEmpty
local map                    = require('gbem.util.ext.tables').map
local reduce                 = require('gbem.util.ext.tables').reduce
local mergeAssoc             = require('gbem.util.ext.tables').naiveMergeAssocTables
local shuffleTable           = require('gbem.util.ext.tables').shuffleTable
local default                = require('gbem.util.ext.values').default
local fif                    = require('gbem.util.ext.values').fif

local ParamParser            = require('gbem.util.class.param_parser')

--- @class ActorGroupRandomiser
 --- @field private _actorStateManager ActorStateManager
 --- @field private _actorGroups table
 ---
local ActorGroupRandomiser = {
    _actorStateManager = nil,
    _actorGroups = {},
}

local paramParser = ParamParser.create({
    {
        validates = function(params)
            local knownParams = { "act", "prob", "num", "min", "max", "group" }
            for paramName, _ in pairs(params) do
                if not tableContains(knownParams, paramName) then
                    error(sprintf(
                        "Invalid parameter name: Expected one of 'act', 'prob', 'num', "..
                        "'min', 'max', 'group', got '%s'", paramName
                    ), 0)
                end
            end
            return params
        end,
    }, {
        paramName = "act",
        validates = ParamParser.validators.inList{"enable", "disable"},
        error = "Expected string 'enable' or 'disable', got '%s'",
    }, {
        paramName = "prob",
        validates = ParamParser.validators.integer(0, 100),
        error = "Expected integer between 0 to 100, got '%s'",
    }, {
        paramName = "num",
        validates = ParamParser.validators.integer(0, 100),
        error = "Expected integer greater than or equal to 0, got '%s'",
    }, {
        paramName = "min",
        validates = ParamParser.validators.integer(0, 100),
        error = "Expected integer greater than or equal to 0, got '%s'",
    }, {
        paramName = "max",
        validates = ParamParser.validators.integer(0, 100),
        error = "Expected integer greater than or equal 0, got '%s'",
    }
})

local function debugParams(params)
    if params == nil then return '(nil)' end
    if tableEmpty(params) then return '(none)' end

    local out = {}
    -- order of params (just for predictable output during tests)
    local paramsIndex = { 'group', 'act', 'num', 'min', 'max', 'prob' }
    for _, paramName in ipairs(paramsIndex) do
        local paramValue = params[paramName]
        if paramValue ~= nil then
            table.insert(out, string.format('%s=%s', paramName, paramValue))
        end
    end
    return table.concat(out, ', ')
end

local function getActors(flagTag)
    logger:info(sprintf("Gathering actors with tag '%s'...", flagTag))
    local actors = gameplaystatics.GetAllActorsWithTag(flagTag)

    if #actors == 0 then
        logger:info(sprintf("-> No actor found"))
        return nil
    end

    return actors
end

local function parseActorsParams(actors)
    local actorsWithParams = {}

    for _, actorItem in pairs(actors) do
        logger:debug(sprintf("Parsing actor '%s'...", actor.GetName(actorItem)))
        -- catch errors
        local success, result = pcall(function()
            return paramParser:Parse(actor.GetTags(actorItem))
        end)
        if not success then
            local error = result
            logger:error(sprintf("Tag parsing failed for actor '%s': %s", actor.GetName(actorItem), error))
        else
            local params = result
            table.insert(actorsWithParams, {
                actor = actorItem,
                params = params
            })
        end
    end

    if #actorsWithParams == 0 then
        logger:info(sprintf("-> No valid actor found"))
        return nil
    end

    logger:info(sprintf("-> Found %s valid actor(s)", #actorsWithParams))
    return actorsWithParams
end

local function groupActors(actorsWithParams)
    logger:info("Grouping actors based on their 'group' param...")
    local groupedActors = reduce(actorsWithParams, function(actorWithParams, result)
        if not actorWithParams.params.group then
            logger:debug(sprintf("Add lone actor '%s'", actor.GetName(actorWithParams.actor)))
            table.insert(result, { actorWithParams })
        else
            local groupName = actorWithParams.params.group
            if result[groupName] == nil then
                logger:debug(sprintf("Add actor group '%s'", groupName))
                result[groupName] = {}
            end
            table.insert(result[groupName], actorWithParams)
        end
        return result
    end, {})
    local totalCount = count(groupedActors) -- count all keys
    local loneCount = icount(groupedActors) -- count only int keys
    local groupCount = totalCount - loneCount

    if (groupCount > 0 and loneCount > 0) then
        logger:info(sprintf("-> Found %s actor group(s) and %s lone actor(s)", groupCount, loneCount))
    elseif (groupCount > 0) then
        logger:info(sprintf("-> Found %s actor group(s)", groupCount))
    elseif (loneCount > 0) then
        logger:info(sprintf("-> Found %s lone actor(s)", loneCount))
    end

    return groupedActors
end

local function mergeParamsInGroups(groupedActors)
    return map(groupedActors, function(actionArgsList)
        -- make a list of targets
        local actors = map(actionArgsList, function(actionArgs)
            return actionArgs.actor
        end)
        -- make a list of params and merge them all
        local params = map(actionArgsList, function(actionArgs)
            return actionArgs.params
        end)
        params = mergeAssoc(table.unpack(params))
        return {
            actors = actors,
            params = params,
        }
    end)
end
-- if result is nil return nil, else call the function
local function ifNotNil(func) return function(result)
    if nil == result
        then return nil
        else return func(result)
    end
end end

ActorGroupRandomiser.__index = ActorGroupRandomiser

--- Instantiate the ActorGroupRandomiser
 ---
 --- @param actorStateManager ActorStateManager     The object to set actor state
 --- @return ActorGroupRandomiser instance          New instance of the ActorGroupRandomiser
 ---
function ActorGroupRandomiser.create(actorStateManager)
    local instance = setmetatable({}, ActorGroupRandomiser)
    instance._actorStateManager = actorStateManager
    logger:debug('ActorGroupRandomiser instantiated')
    return instance
end

--- Parse and save actors wearing the flagtag
 ---
 --- @return nil
 ---
function ActorGroupRandomiser:parse()
    local flagtag = "GroupRnd"
    self._actorGroups = pipe({
        getActors,
        ifNotNil(parseActorsParams),
        ifNotNil(groupActors),
        ifNotNil(mergeParamsInGroups),
    })(flagtag)
end

--- Process saved actors and set each actor state 
 ---
 --- @todo Can we split that into smaller functions?
 ---
 --- @return nil
 ---
function ActorGroupRandomiser:process()
    for _, actorGroup in pairs(self._actorGroups) do
        local actors = actorGroup.actors
        local params = default(actorGroup.params, {})

        local actorsCount = #actors

        -- no actors
        if actorsCount == 0 then
            return

        -- 1 actor
        elseif actorsCount == 1 then
            logger:info(sprintf("Processing lone actor '%s'...",
                actor.GetName(actors[1])))

        -- named actor group
        elseif params.group then
            logger:info(sprintf("Processing actor group '%s'...", params.group))

        -- unnamed actor group
        else
            logger:info(sprintf("Processing unnamed actor group..."))
        end

        logger:debug(sprintf("Given params: %s", debugParams(params)))

        -- the three variables we need to execute are probRealised, num and reverse
        local prob = default(params.prob, 100)
        local probRealised = umath.random(100) <= prob
        local reverse = params.act == 'disable'
        local num
        if params.num == nil and params.min == nil and params.max == nil then
            num = actorsCount
        elseif params.num ~= nil then
            num = params.num
        else
            -- set default values for min and max
            local min = default(params.min, 0)
            local max = default(params.max, actorsCount)
            -- force enableMin between 0 and actorsCount
            min = math.max(0, math.min(min, actorsCount))
            -- force max between min and actorsCount
            max = math.max(min, math.min(max, actorsCount))
            -- pick a random number of targets to enable
            num = math.random(min, max)
        end

        logger:debug(sprintf("Effective params: probRealised=%s, num=%s, reverse=%s", probRealised, num, reverse))

        -- process the targets
        local enabledCount = 0
        for index, target in ipairs(shuffleTable(actors)) do
            local reachedNum = index > num
            local shouldEnable = true
            if probRealised then
                if reachedNum then
                    shouldEnable = not shouldEnable
                end
            else
                shouldEnable = not shouldEnable
            end

            if reverse then shouldEnable = not shouldEnable end

            self._actorStateManager:set(target, shouldEnable)

            if shouldEnable ~= reverse then enabledCount = enabledCount + 1 end
        end

        local actStr = fif(reverse, "disabled", "enabled");

        logger:info(sprintf('-> %s / %s actor(s) set to be %s', enabledCount, actorsCount, actStr))
    end
end

return ActorGroupRandomiser
