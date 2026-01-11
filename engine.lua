local class = require("libs.middleclass")
local ansicolorsx = require("libs.ansicolorsx")
local nodeLoader = require("node_loader")
local utils = require("utils")

---@class Engine
local Engine = class("Engine")

function Engine:initialize()

end

local function print(...)
    _G.print(ansicolorsx(...))
end

local function iowrite(...)
    io.write(ansicolorsx(...))
end

function Engine:runMainLoop()
    -- Loop principal
    while not game.isOver do
        -- Get active node
        local node = game.activeNode

        -- Limpar o terminal
        --utils.clearScreen()

        -- Printar Node
        self:printNode(node)

        -- Processar fim do jogo
        if node.gameOver then
            print()
            print("%{red}===== Game Over =====")
            print()
            os.exit()
        elseif node.gameWon then
            print()
            print("%{green}===== Você venceu o jogo! =====")
            print()
            os.exit()
        end

        -- Obter escolhas válidas
        local validChoices = self:getValidChoices(node)
        if #validChoices == 0 then
            warn("Nenhuma escolha válida para o node " .. node.id)
            os.exit()
        end

        -- Mostrar escolhas
        self:showChoices(validChoices)

        -- Perguntar pro usuário
        local choiceIndex = self:askForInput(#validChoices)
        local choice = validChoices[choiceIndex]

        -- Executar rotina da escolha
        local prevActiveNode = game.activeNode
        choice:runRoutine()

        -- Se a rotina mudou `game.activeNode`, respeitamos essa transição
        if game.activeNode ~= prevActiveNode then
            -- rotina já trocou o node (por exemplo engine:startBattle criou um node de batalha)
            goto continue_loop
        end

        -- Avançar pro próximo node (comportamento padrão)
        local destinationId = choice.destination
        if type(destinationId) == "string" and destinationId ~= "" then
            local destinationNode = nodeLoader.getNode(destinationId)
            game.activeNode = destinationNode
        else
            -- Sem destino: permanecer no node atual
            game.activeNode = prevActiveNode
        end
        ::continue_loop::
    end
end

---
---Inicia o simulador de batalha.
---
function Engine:startBattle()
    local ok, battle = pcall(require, "battle.main")
    if not ok then
        ok, battle = pcall(require, "nodes.battle.main")
        if not ok then
            error("Não foi possível carregar o módulo de batalha: tried 'battle.main' and 'nodes.battle.main'")
        end
    end

    if type(battle) ~= "table" then
        error("Módulo de batalha inválido: espera table")
    end

    -- Se o módulo expor um adaptador para Node, usamos ele (integração com o engine)
    if type(battle.asNode) == "function" then
        local prevNode = game.activeNode
        local battleNode = battle.asNode(prevNode)
        if type(battleNode) ~= "table" then
            error("battle.asNode deve retornar um Node")
        end
        game.activeNode = battleNode
        return
    end

    -- Fallback: comportamento antigo (executa diretamente)
    if type(battle.run) ~= "function" then
        error("Módulo de batalha inválido: espera função run() ou asNode()")
    end

    local prevNode = game.activeNode
    print("[Engine] Iniciando battle.run()")
    battle.run()
    print("[Engine] battle.run() finalizado")
    game.activeNode = prevNode
end

---@param title string|nil
---@return string
local function createSeparator(title)
    local width = 50
    local result = "%{white}-----"
    local length = 5
    if title then
        result = string.format("%s[%%{yellow}%s%%{white}]", result, title:upper())
        length = length + 2 + title:len()
    end
    for i = length, width, 1 do
        result = result .. "-"
    end
    return result
end

---@param node Node
function Engine:printNode(node)
    if node.header then
        print(node.header)
    elseif node.gameOver then
        print(utils.getGenericGameOverHeader())
    end
    print(createSeparator(node.title))
    print(node.description)
    print(createSeparator())
end

---@param node Node
---@return Choice[]
function Engine:getValidChoices(node)
    local result = {} ---@type Choice[]
    for _, choice in pairs(node.choices) do
        if (not choice:hasCondition()) or (choice:hasCondition() and choice:runCondition()) then
            table.insert(result, choice)
        end
    end
    return result
end

---@param choices Choice[]
function Engine:showChoices(choices)
    for i, choice in pairs(choices) do
        print(string.format("%%{white}%d) %%{yellow}%s", i, choice.description))
    end
end

---@param amount number
---@return number
function Engine:askForInput(amount)
    while true do
        iowrite("> ")
        local answerString = io.read()
        local answer = tonumber(answerString)
        local isAnswerValid = answer ~= nil and answer >= 1 and answer <= amount
        if isAnswerValid then
            return answer
        end
        print("%{red}Resposta inválida, tente novamente.")
    end
end

return Engine
