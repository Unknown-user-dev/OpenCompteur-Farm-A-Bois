local computer = require("computer");--Utilisé uniquement pour l'énergie informatique();
local term = require("term");--Utilisé uniquement pour effacer la console
local robot = require("robot");


--Configuration de la ferme arboricole
local sizeX = 7;
local sizeZ = 7;
local minimumEnergyToWork = 3000;
local timerMultiplier = 5;




-- Clear console
if term.isAvailable() then 
    term.clear();
end

--Position des jeunes arbres dans l'inventaire du robot
robot.select(1);


--Fonction planter, retourner true si planter le jeune arbre, false sinon
local function tryPlant()
    if robot.count(1) == 1 then--Pas assez de jeunes arbres, doit avoir au moins 1
        print("Besoin de plus de pouce d'arbres");
        os.sleep(20);
        return false;
    
    else--Planté l'arbre
        robot.placeDown();
        return true;
    end
end

-- fonction pour abattre un arbre
local function cutTree()
    local treeHeight = 0;
    while( robot.detectUp() or robot.detect())
    do
        robot.swingUp();
        if robot.up() == nil then
            break
        end
        treeHeight = treeHeight +1;
    end
    robot.swing();
    robot.down();
    robot.turnLeft();
    for y = 1, treeHeight, 1 do -- Boucle dans la hauteur de l'arbre
        for i = 0,7,1 do -- Boucle autour du bloc de bois pour tout dégager, pour obtenir des gaules
            robot.turnLeft();
            robot.swing();
            robot.turnRight();
            robot.swing();
            if i%2 == 0 then
                robot.forward();
            else
                robot.turnRight();
                robot.swing();
                robot.forward();
            end
        end
        robot.turnRight();
        robot.swing();
        if y ~= treeHeight then
            robot.swingDown();
            robot.down();
            robot.turnLeft();
        end
    end
    robot.forward();
    robot.swingDown();
    robot.placeDown();
end

-- Fonction de boucle, cultiver les arbres et replanter
local function farming()
    for x = 0,sizeX-1,3 do 
        for z = 0,sizeZ-4,3 do
            robot.swing(); --Feuilles claires posibles
            robot.forward();
            robot.swing(); --Feuilles claires posibles
            robot.forward();
            if robot.detect() then --Arbre détecté
                cutTree();
            else
                robot.forward();
            end
        end
        if  x ~= sizeX-1 then 
            if x%6 == 0 then     -- x = 0 postion
                robot.turnRight();
                robot.swing(); --Feuilles claires posibles
                robot.forward();
                robot.swing(); --Feuilles claires posibles
                robot.forward();
                if robot.detect() then --Arbre détecté
                    cutTree();
                else
                    robot.forward();
                end
                robot.turnRight();
                
            else                 -- x = max position
                robot.turnLeft();
                robot.swing(); --Feuilles claires posibles
                robot.forward();
                robot.swing(); --Feuilles claires posibles
                robot.forward();
                if robot.detect() then --Arbre détecté
                    cutTree();
                else
                    robot.forward();
                end
                robot.turnLeft();
            end
        else                    -- terminer la plantation
            robot.turnAround();
            while(computer.energy() < minimumEnergyToWork) do
                print("Mode AFK, nécessite une charge solaire...");
                os.sleep(60 * timerMultiplier);
            end
        end
    end
end

--Boucle initiale pour planter tous les gaules de la ferme
local function plantSplings()
    robot.up();
    for x = 0,sizeX-1,3 do 
        for z = 0,sizeZ-1,3 do
            if tryPlant() then
                if z ~= sizeX-1 then
                    robot.forward();
                    robot.forward();
                    robot.forward();
                end
            else--Je ne peux pas planter, attendre plus d'arbres
                z = z -3;
            end
        end
        if  x ~= sizeX-1 then 
            if x%6 == 0 then     -- x = 0 postion
                robot.turnRight();
                robot.forward();
                robot.forward();
                robot.forward();
                robot.turnRight();
            else                 -- x = max position
                robot.turnLeft();
                robot.forward();
                robot.forward();
                robot.forward();
                robot.turnLeft();
            end
        else                    -- terminer la plantation
            robot.turnAround();
            print("Terminez la plantation initiale en attendant un peu de temps...");
            os.sleep(200);--Attendez le temps initial, pour que certains arbres finissent de pousser
        end
    end
end

print("Exécution du programme treeFarmer...");
--Vérifiez avoir assez d'énergie
while(computer.energy() < minimumEnergyToWork) do
    print("Mode AFK, nécessite une charge solaire...");
    os.sleep(60 * timerMultiplier);
end

while(robot.count(1) == 0) do
    print("Besoin de jeunes arbres dans l'emplacement 1 de l'inventaire. Recommandé: épicéa ou bouleau");
    os.sleep(20);
end

plantSplings();
while(true) do
    farming();
    print("Fin de l'itération, en attendant le prochain...")
    os.sleep(40 * timerMultiplier);
end
print("Ne devrait pas arriver");