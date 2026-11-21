function ttc = compute_ttc(distance, ego_speed, obstacle_speed)
%COMPUTE_TTC Calcule le Time-To-Collision (TTC) en secondes.
%
%   ttc = COMPUTE_TTC(distance, ego_speed, obstacle_speed) renvoie le temps
%   restant avant la collision avec l'obstacle situe devant le vehicule ego,
%   en supposant les vitesses constantes.
%
%   Entrees :
%     distance       - distance relative a l'obstacle (m), >= 0
%     ego_speed      - vitesse du vehicule ego (m/s)
%     obstacle_speed - vitesse de l'obstacle dans le meme sens (m/s)
%
%   Sortie :
%     ttc - Time-To-Collision (s). Vaut Inf si le vehicule ego ne rattrape
%           pas l'obstacle (vitesse relative nulle ou negative), evitant
%           ainsi toute division par zero.
%
%   Formule : TTC = distance / (ego_speed - obstacle_speed)
%
%   Exemple :
%     ttc = compute_ttc(30, 25, 0);   % -> 1.2 s

    % --- Validation des entrees ---
    if distance < 0
        error('compute_ttc:invalidDistance', ...
              'La distance doit etre positive ou nulle.');
    end

    % Vitesse relative : positive si l'ego se rapproche de l'obstacle
    relative_speed = ego_speed - obstacle_speed;

    % Tolerance numerique pour considerer la vitesse relative comme nulle
    epsilon = 1e-6;

    if relative_speed <= epsilon
        % L'obstacle s'eloigne ou les vitesses sont egales :
        % aucune collision prevue -> TTC infini.
        ttc = Inf;
    else
        % Rapprochement : calcul classique du TTC.
        ttc = distance / relative_speed;
    end
end
