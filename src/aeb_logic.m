function [state, brake_level, ttc] = aeb_logic(distance, ego_speed, obstacle_speed)
%AEB_LOGIC Decision de freinage d'urgence automatique (AEB).
%
%   [state, brake_level, ttc] = AEB_LOGIC(distance, ego_speed, obstacle_speed)
%   implemente la machine d'etats du systeme AEB. A partir de la distance et
%   des vitesses, la fonction calcule le Time-To-Collision (TTC) puis decide
%   du niveau d'intervention.
%
%   Entrees :
%     distance       - distance relative a l'obstacle (m)
%     ego_speed      - vitesse du vehicule ego (m/s)
%     obstacle_speed - vitesse de l'obstacle (m/s)
%
%   Sorties :
%     state       - etat AEB (char) : 'SAFE', 'WARNING',
%                   'PARTIAL_BRAKE' ou 'FULL_BRAKE'
%     brake_level - niveau de freinage normalise dans [0, 1]
%                   (0 = aucun, 0.5 = partiel, 1 = total)
%     ttc         - Time-To-Collision calcule (s)
%
%   Seuils de TTC (strategie AEB) :
%     TTC < 1.5 s            -> FULL_BRAKE    (freinage total)
%     1.5 s <= TTC < 2.5 s   -> PARTIAL_BRAKE (freinage partiel)
%     2.5 s <= TTC < 4.0 s   -> WARNING       (alerte FCW)
%     TTC >= 4.0 s ou Inf    -> SAFE          (aucune action)
%
%   Exemple :
%     [s, lvl, t] = aeb_logic(30, 25, 0);

    % --- Seuils de decision (en secondes) ---
    TTC_FULL_BRAKE    = 1.5;   % freinage d'urgence total
    TTC_PARTIAL_BRAKE = 2.5;   % freinage partiel
    TTC_WARNING       = 4.0;   % alerte au conducteur

    % --- Calcul du Time-To-Collision ---
    ttc = compute_ttc(distance, ego_speed, obstacle_speed);

    % --- Machine d'etats AEB ---
    if ttc < TTC_FULL_BRAKE
        % Collision imminente : freinage maximal.
        state       = 'FULL_BRAKE';
        brake_level = 1.0;
    elseif ttc < TTC_PARTIAL_BRAKE
        % Risque eleve : freinage partiel pour reduire l'impact.
        state       = 'PARTIAL_BRAKE';
        brake_level = 0.5;
    elseif ttc < TTC_WARNING
        % Risque modere : alerte Forward Collision Warning.
        state       = 'WARNING';
        brake_level = 0.0;
    else
        % Situation sure : aucune intervention.
        state       = 'SAFE';
        brake_level = 0.0;
    end
end
