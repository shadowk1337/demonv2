% пункт 15 
% Корневой годограф
% Кто бля?
% Годограф

function [res] = rootHodograph(Data, CalcData, AdditionalData)
    s = sym('s');

    [numCopy, trash] = numden(AdditionalData('Ws'));
    trash = sym2poly(trash);
    numCopy = numCopy / trash(3);
    
    P = round(solve(1 / AdditionalData('Ws')), 3);
    P = sort(P);
    disp("P1 = "); disp(P(1));
    disp("P2 = "); disp(P(2));
    disp("P3 = "); disp(P(3));
    
    disp("3. Точка пересечения асимптот:")
    sigmaAsimp = vpa((sum(P) / 3), 4);
    disp(sigmaAsimp);
    
    disp("5. Подходящая точка пересечения с действительной " + ...
        "осью (находящаяся в пределах КГ):");
    Cx = 1 / (s - P(1)) + 1 / (s - P(2)) + 1 / (s - P(3));
    Cx = round(solve(Cx), 2);
    Cx = max(Cx);
    display(Cx);
    
    disp("6. Определим границу устойчивости по коэффициенту " + ...
        "усиления (точки пересечения с мнимой осью):")
    lambda = sym('lambda');k = sym('k');
    D = subs(AdditionalData('Ws'), s, lambda);
    D = vpa(D * k + 1, 3);
    display(D);
    [num, den] = numden(D);
    numLambda = subs(num, k, 1);
    numArr = sym2poly(numLambda);
    num = vpa(num / numArr(3), 5);
    % display(num);
    
    % Таблица Рауса
    % Костыль
    DsCoeffs = round(coeffs(num), 5);
    MSize = max(size(DsCoeffs));
    c11 = vpa(DsCoeffs(MSize - 1), 5);
    c21 = vpa(DsCoeffs(MSize - 3), 5);
    c31 = 0;
    c12 = vpa(DsCoeffs(MSize - 2), 5);
    c22 = vpa(DsCoeffs(4) * k, 5);
    c32 = 0;
    c13 = vpa(c21 - vpa((c11 / c12), 3) * c22, 5);
    c23 = vpa(c31 - (c11 / c12) * c32, 5);
    c33 = 0;
    c14 = vpa(c22 - (c12 / c13) * c23, 5);
    c24 = 0;
    c34 = 0;
    
    fprintf("i\t|1\t\t\t\t\t|2\t\t\t\t\t\n");
    fprintf("1\t|%f\t\t\t|%f\t\t\t\n", c11, c21);
    fprintf("2\t|%f\t\t\t|%s\t\t\t\n", c12, c22);
    fprintf("3\t|%s\t|%f\t\t\t\n", c13, c23);
    fprintf("4\t|%s\t\t|%f\t\t\t\n", c14, c24);
    
    k = vpa(subs(c12 / (c11 * c22), k, 1), 5);
    display(k);
    
    disp("Коэффициент усиления системы на границе устойчивости:");
    Kkr = vpa(k * numCopy, 6);
    display(Kkr);
    
    jw = sym('jw');
    equation = [c11, c12 1, Kkr];
    equation = vpa(poly2sym(equation, jw), 5);
    display(equation);
    
    disp("Выражаем из мнимой части уравнения wkr^2");
    wkr = vpa(sqrt(1 / c11), 5);
    disp(wkr);
    
    Ws = AdditionalData('Ws') * k;
    [num, den] = numden(Ws);
    WsTf = tf(sym2poly(num), sym2poly(den));
    
    W = WsTf;
    rlocus(W);
    disp("Нажмите любую кнопку чтобы продолжить");
    pause;
    disp("Возьмём коэффициент усиления в 90% относительно " + ...
        "коэффициента усиления на графнице устойчивочти");
    disp("K = ");
    kek = vpa(0.9 * Kkr, 5);
    disp(kek);
    
    Ws = Ws * 0.9;
    [num, den] = numden(Ws);
    WsTf = tf(sym2poly(num), sym2poly(den));
    W = WsTf / (1 + WsTf);

    step(W);
    grid on
    S = stepinfo(W);
    disp(S);

    res = true;
end