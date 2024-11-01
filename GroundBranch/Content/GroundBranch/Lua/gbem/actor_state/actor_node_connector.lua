local logger                    = require('gbem.util.class.logger').create('ActorNodeConnector')
local sprintf                   = require('gbem.util.ext.strings').sprintf
local each                      = require('gbem.util.ext.tables').each
local contains                  = require('gbem.util.ext.tables').contains
local shuffleTable              = require('gbem.util.ext.tables').shuffleTable
local pipe                      = require('gbem.util.ext.functions').pipe
local Graph                     = require('gbem.util.class.graph')
local ParamParser               = require('gbem.util.class.param_parser')

-- parsing actors params from their tags
local paramParser = ParamParser.create({
    {
        error = "Parameters 'node1' and 'node2' are required",
        validates = function(params)
            if not params.node1 then return nil end
            if not params.node2 then return nil end
            return params
        end
    }, {
        error = "Parameters 'node1' and 'node2' cannot be equal",
        validates = function(params)
            if params.node1 == params.node2 then return nil end
            return params
        end
    }
})

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
-- if result is nil return nil, else call the function
local function ifNotNil(func) return function(result)
    if nil == result
        then return nil
        else return func(result)
    end
end end

--- @class ActorNodeConnector
 --- @field private _actorStateManager ActorStateManager
 --- @field private _actorsAndParams table
 ---
local ActorNodeConnector = {}

ActorNodeConnector.__index = ActorNodeConnector

--- Instantiate the ActorNodeConnector
 ---
 --- @param actorStateManager ActorStateManager     The object to set actor state
 --- @return ActorNodeConnector instance            New instance of the ActorNodeConnector
 ---
function ActorNodeConnector.create(actorStateManager)
    local instance = setmetatable({}, ActorNodeConnector)
    instance._actorStateManager = actorStateManager
    instance._actorsAndParams = {}
    logger:debug('ActorNodeConnector instantiated')
    return instance
end

--- Parse and save actors wearing the flagtag
 ---
 --- @return nil
 ---
function ActorNodeConnector:parse()
    local flagTag = 'GraphConnector'
    pipe({
        getActors,
        ifNotNil(parseActorsParams),
        ifNotNil(function(value)
            self._actorsAndParams = value
        end)
    })(flagTag)

end

function ActorNodeConnector:process(opennessPercent)
    -- re-enable all actors first (algo below will only disable some)
    each(self._actorsAndParams, function(actorAndParams)
        self._actorStateManager:setEnable(actorAndParams.actor)
    end)

    -- create the graph
    local graph = Graph.create()
    each(self._actorsAndParams, function(item)
        graph:addEdge(
            item.params.node1,
            item.params.node2,
            { item.actor }
        )
    end)

    -- only process connected graph
    if not graph:isConnected() then
        logger:Error('All nodes not reachable')
        return
    end

    -- Completely remove some edges (disable all actors in the edge)
    logger:debug(sprintf('Removing %s%% of edges...', opennessPercent))

    local edgeCount = graph:getEdgeCount()
    local numberOfEdgesToRemove = math.floor(edgeCount * opennessPercent / 100)
    local numberOfEdgesToKeep = edgeCount - numberOfEdgesToRemove

    local removedEdges = 0
    while graph:getEdgeCount() > numberOfEdgesToKeep do
        local node1, node2 = graph:getRandomEdge()
        if not contains({ node1, node2 }, 'out') then
            logger:debug(sprintf('edge to remove: %s, %s', node1, node2))
            local actorsToDisable = graph:dissolveEdge(node1, node2)
            each(actorsToDisable, function(actor)
                self._actorStateManager:setDisable(actor)
            end)
            removedEdges = removedEdges + 1;
        end
    end
    logger:debug(sprintf('Removed %s edges', removedEdges))

    -- Partially open the rest of the edges (disable a few actors in the edge)
    logger:debug(sprintf('Opening the rest of the edges...'))
    local openedEdges = 0
    while graph:getEdgeCount() > 0 do

        local node1, node2 = graph:getRandomEdge()
        logger:debug(sprintf('edge to open: %s, %s', node1, node2))
        local actorsToPotentiallyDisable = graph:dissolveEdge(node1, node2)

        -- magic numbers for the rooms
        -- if and edge is composed of more than 14 actors
        -- then we want two openings in there
        local numberOfOpenings = 1

        if #actorsToPotentiallyDisable > 14 then
            numberOfOpenings = 2
        end

        -- the each() function shortcircuits but it is not clear when,
        -- some table functions need clarification and renaming
        local i = 0;
        each(shuffleTable(actorsToPotentiallyDisable), function(actor)
            i = i + 1
            if i > numberOfOpenings then return false end
            self._actorStateManager:setDisable(actor)
            return true;
        end)
        openedEdges = openedEdges + 1;
    end
    logger:debug(sprintf('Opened %s edges', openedEdges))
end

return ActorNodeConnector
