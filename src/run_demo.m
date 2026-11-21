%RUN_DEMO Demonstration du systeme AEB sur plusieurs scenarios.
%
%   Ce script execute la logique de freinage d'urgence automatique sur une
%   serie de scenarios de conduite et affiche, pour chacun, la distance, les
%   vitesses, le TTC calcule et l'etat AEB decide.
%
%   Usage :
%     addpath('src');
%     run_demo

% Assure que les fonctions du dossier src sont accessibles.
addpath(fileparts(mfilename('fullpath')));

% --- Definition des scenarios ---
% Colonnes : description, distance (m), vitesse ego (m/s), vitesse obstacle (m/s)
scenarios = {
    'Route degagee, obstacle lointain',        120, 30,  0;
    'Vehicule lent devant (alerte FCW)',         80, 30, 10;
    'Rapprochement, freinage partiel',           50, 30,  5;
    'Obstacle arrete proche (freinage total)',   15, 25,  0;
    'Pieton surgissant tres proche',              8, 14,  0;
    'Vehicule devant plus rapide (sur)',         40, 20, 30;
    'Meme vitesse, suivi stable (sur)',          30, 25, 25;
};

fprintf('\n==================== DEMONSTRATION AEB ====================\n\n');
fprintf('%-42s | %6s | %6s | %6s | %8s | %-13s\n', ...
        'Scenario', 'd(m)', 've(m/s)', 'vo(m/s)', 'TTC(s)', 'Etat AEB');
fprintf('%s\n', repmat('-', 1, 100));

for i = 1:size(scenarios, 1)
    desc           = scenarios{i, 1};
    distance       = scenarios{i, 2};
    ego_speed      = scenarios{i, 3};
    obstacle_speed = scenarios{i, 4};

    % Decision AEB.
    [state, brake_level, ttc] = aeb_logic(distance, ego_speed, obstacle_speed);

    % Mise en forme du TTC (Inf -> "inf").
    if isinf(ttc)
        ttc_str = '   inf';
    else
        ttc_str = sprintf('%6.2f', ttc);
    end

    fprintf('%-42s | %6.0f | %6.0f | %6.0f | %8s | %-13s (lvl=%.1f)\n', ...
            desc, distance, ego_speed, obstacle_speed, ttc_str, state, brake_level);
end

fprintf('%s\n', repmat('-', 1, 100));
fprintf('\nLegende : SAFE = aucune action | WARNING = alerte FCW | ');
fprintf('PARTIAL_BRAKE = freinage partiel | FULL_BRAKE = freinage total\n\n');
