% Находимся на конце...

function [res] = buildAnalysys(Data, CalcData, AdditionalData)
    disp("Откройте окно Simulink");
    
    [num, den] = numden(AdditionalData('WsDef'));
    num = sym2poly(num); den = sym2poly(den);
    num = num / den(3); den = den / den(3);

    simNum = mat2str(num); simDen = mat2str(den);
    
    Kd = 0;
    Ki = 1;
    Kp = 1;    
    N = Data('Ng');

    set_param('demon_sim/Transfer Fcn', 'Numerator', simNum);
    set_param('demon_sim/Transfer Fcn', 'Denominator', simDen);
    set_param('demon_sim/PID Controller', 'P', 'Kp');
    set_param('demon_sim/PID Controller', 'I', 'Ki');
    set_param('demon_sim/PID Controller', 'D', 'Kd');
    set_param('demon_sim/PID Controller', 'N', 'N');
    set_param('demon_sim/Integrator', 'InitialCondition', num2str(0));

    disp("Kd = "); disp(Kd);
    disp("Ki = "); disp(Ki);
    disp("Kp = "); disp(Kp);
    disp("N = "); disp(N);

    res = true;
end