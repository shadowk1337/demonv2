% 16 пункт 
% 15 прошёл как по маслу
% попробуем 16 бахнуть
% и 17 заодно
% коэффициенты подгонки зарешали

function [res] = modalController(Data, CalcData, AdditionalData)
    [num, den] = numden(AdditionalData('Ws'));
    WsTf = tf(sym2poly(num), sym2poly(den));
    [A, B, C, D] = ssdata(WsTf);
    
    disp("A = ");disp(A);
    disp("B = ");disp(B);
    disp("C = ");disp(C);
    disp("D = ");disp(D);
    
    % Изменяя коэффициент подгонки меняешь графки
    
    choice = 'y'; r1 = 200; r2 = 200;
    while (choice == 'y')
        disp("Коэффициенты подгонки:"); disp(r1); disp(r2);
        P = [-1, -0.5 + 0.866i, -0.5 - 0.866i] * r1;
        K = place(A, B, P);
        disp("А теперь вычислим матрицу коэффициентов обратных связей");
        disp("K = ");disp(K);
        disp("Вычислим матрицу обратной связи наблюдателя");
        pn = [-1, -0.5 + 0.866i, -0.5 - 0.866i] * r2;
        L = place(A', C', pn)';
        display(L);
        disp("Вычислим матрицы динамического регулятора для расчета " + ...
            "передаточной функции");
        [Ar, Br, Cr, Dr] = reg(A, B, C, D, K, L);
        disp("Ar = ");disp(Ar);
        disp("Br = ");disp(Br);
        disp("Cr = ");disp(Cr);
        disp("Dr = ");disp(Dr);
        [numr, denr] = ss2tf(Ar, Br, Cr, Dr);
        Wreg = tf(numr, denr);
        display(Wreg);
        Wz = feedback(WsTf, Wreg);
        display(Wz);
        step(Wz);
        grid on;
        S = stepinfo(Wz);
        disp(S);

        choice = input("Изменить коэффициенты подгонки? [y/n]: ", 's');
        if (ischar(choice) && lower(choice) == 'y')
            r1 = input('НОВЫЙ коэффициент подгонки #1: ');
            r2 = input('НОВЫЙ коэффициент подгонки #2: ');
            cla reset;
        end
    end
    
    res = true;
end
