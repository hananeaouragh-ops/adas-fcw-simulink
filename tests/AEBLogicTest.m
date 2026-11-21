classdef AEBLogicTest < matlab.unittest.TestCase
    %AEBLOGICTEST Tests unitaires de la logique AEB et du calcul du TTC.
    %
    %   Execution :
    %     addpath('src');
    %     results = runtests('tests/AEBLogicTest.m');

    methods (TestClassSetup)
        function addSourcePath(~)
            % Ajoute le dossier src au chemin pour acceder aux fonctions.
            here = fileparts(mfilename('fullpath'));
            addpath(fullfile(here, '..', 'src'));
        end
    end

    methods (Test)

        function testCasSafe(testCase)
            % Obstacle lointain : aucune intervention attendue.
            [state, brake_level, ttc] = aeb_logic(120, 30, 0);
            testCase.verifyEqual(state, 'SAFE');
            testCase.verifyEqual(brake_level, 0.0);
            testCase.verifyGreaterThanOrEqual(ttc, 4.0);
        end

        function testCasWarning(testCase)
            % TTC entre 2.5 s et 4.0 s : alerte FCW.
            % d=90, v_rel=30 -> TTC = 3.0 s
            [state, brake_level] = aeb_logic(90, 30, 0);
            testCase.verifyEqual(state, 'WARNING');
            testCase.verifyEqual(brake_level, 0.0);
        end

        function testCasPartialBrake(testCase)
            % TTC entre 1.5 s et 2.5 s : freinage partiel.
            % d=60, v_rel=30 -> TTC = 2.0 s
            [state, brake_level] = aeb_logic(60, 30, 0);
            testCase.verifyEqual(state, 'PARTIAL_BRAKE');
            testCase.verifyEqual(brake_level, 0.5);
        end

        function testCasFullBrake(testCase)
            % TTC < 1.5 s : freinage d'urgence total.
            % d=15, v_rel=25 -> TTC = 0.6 s
            [state, brake_level, ttc] = aeb_logic(15, 25, 0);
            testCase.verifyEqual(state, 'FULL_BRAKE');
            testCase.verifyEqual(brake_level, 1.0);
            testCase.verifyLessThan(ttc, 1.5);
        end

        function testVitesseRelativeNulle(testCase)
            % Vitesses egales : pas de rapprochement -> TTC infini, SAFE.
            % Verifie l'absence de division par zero.
            [state, brake_level, ttc] = aeb_logic(30, 25, 25);
            testCase.verifyEqual(state, 'SAFE');
            testCase.verifyEqual(brake_level, 0.0);
            testCase.verifyTrue(isinf(ttc));
        end

        function testVitesseRelativeNegative(testCase)
            % Obstacle plus rapide (s'eloigne) : TTC infini, SAFE.
            [state, ~, ttc] = aeb_logic(40, 20, 30);
            testCase.verifyEqual(state, 'SAFE');
            testCase.verifyTrue(isinf(ttc));
        end

        function testComputeTtcValeurExacte(testCase)
            % Verifie le calcul direct du TTC.
            ttc = compute_ttc(30, 25, 0);
            testCase.verifyEqual(ttc, 1.2, 'AbsTol', 1e-9);
        end

        function testComputeTtcDistanceNegative(testCase)
            % Une distance negative doit lever une erreur.
            testCase.verifyError(@() compute_ttc(-5, 25, 0), ...
                                 'compute_ttc:invalidDistance');
        end

        function testSeuilLimiteFullBrake(testCase)
            % A la frontiere exacte 1.5 s, l'etat doit etre PARTIAL_BRAKE
            % (le seuil FULL_BRAKE est strictement inferieur a 1.5 s).
            % d=45, v_rel=30 -> TTC = 1.5 s
            state = aeb_logic(45, 30, 0);
            testCase.verifyEqual(state, 'PARTIAL_BRAKE');
        end

    end
end
