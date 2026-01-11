-- Constants
local ID = "start"

-- Dependencies
local Node = require("node")
local Choice = require("choice")

-- Create node
local node = Node:new(ID) ---@type Node
node.title = "Uma nova aventura"
node.description = "Em uma bela manhã ensolarada você acorda e se prepara para embarcar em uma nova aventura, mas uma importante decisão deve ser tomada. Para onde você vai?"
node.header = [[%{magenta}
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█ ▄▄▀█ ▄▀█▀███▀█ ▄▄█ ▄▄▀█▄ ▄█ ██ █ ▄▄▀█ ▄▄████
█ ▀▀ █ █ ██ ▀ ██ ▄▄█ ██ ██ ██ ██ █ ▀▀▄█ ▄▄████
█ ██ █▄▄████▄███▄▄▄█▄██▄██▄███▄▄▄█▄█▄▄█▄▄▄████
██████████████████████████████████████████████
███ ▄▄▄ ██▄██ ▄▀▄ █ ██ █ ██ ▄▄▀█▄ ▄█▀▄▄▀█ ▄▄▀█
███▄▄▄▀▀██ ▄█ █▄█ █ ██ █ ██ ▀▀ ██ ██ ██ █ ▀▀▄█
███ ▀▀▀ █▄▄▄█▄███▄██▄▄▄█▄▄█▄██▄██▄███▄▄██▄█▄▄█
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
]]
--Salvando node atual como anterior
game.previousNode = game.activeNode

-- Create choices
table.insert(node.choices, Choice:new(
    "kalandra.start",
    "Para a praia ensolarada de Kalandra"
))
table.insert(node.choices, Choice:new(
    "nyff.start",
    "Para as montanhas geladas de Nyff"
))

--Simulador de batalha rodando como um node para ser aplicado em determinados momento do jogo
table.insert(node.choices, Choice:new(
    "battle.battle",
    "Simulador de batalha"
))

return node