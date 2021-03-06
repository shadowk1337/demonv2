% 13 пункт какого-то непонятного говна

function [res] = analysys(Data, CalcData, AdditionalData)
    z = sym('z'); w = sym('w'); s = sym('s');

    disp("По теореме Котельникова определим период квантования");
    wMid = CalcData('B') / Data('Tmax');
    wHigh = 6.5 * wMid;
    T = pi / wHigh;
    disp("T = "); disp(T);
    disp("Возьмём период квантования не более данного" + newline + ...
        "Пусть");
    CalcData('T') = round(abs(T - 1/6 * T), 4);
    disp("T = ");disp(CalcData('T'));
    N = floor(log2(Data('Ng') * (1 + Data('Sigm')) / (Data('Emax'))) + 2);
    disp("Определим число разрядов микропроцессора");
    disp("N = ");disp(N);
    
    disp("Передаточная функция разомкнутой системы с требуемым усилением");
    [num, den] = numden(AdditionalData('Ws'));
    display(tf(sym2poly(num), sym2poly(den)));
    Wz = c2d(tf(sym2poly(num), sym2poly(den)), CalcData('T'));
    disp("Проведем z-преобразование");
    
    display(zpk(Wz));
    
    [num, den] = tfdata(Wz);
    Wz = poly2sym(cell2mat(num), z) / poly2sym(cell2mat(den), z);
    Wz = subs(Wz, z, (1 + w) / (1 - w));
    [num, den] = numden(Wz);
    Wz = tf(sym2poly(num), sym2poly(den));
    disp("Заменить в отчете s на jv:");
    display(zpk(Wz));
    [num, den] = tfdata(Wz);
    num = cell2mat(num); den = cell2mat(den);
    k = num(max(size(num))) / den(max(size(den)) - 1);
    num = poly2sym(num); den = poly2sym(den);
     
    num = factor(num, 'FactorMode', 'real');
    den = factor(den, 'FactorMode', 'real');

    vcArrNum = zeros(max(size(num)) - 1, 0);
    vcArrDen = zeros(max(size(den)) - 1, 0);

    for i = 1:(max(size(num)) - 1)
        b = abs(coeffs(num(i + 1)));
        if b(1) < 0.0001 || max(size(b)) < 2 % в случае если скобка x а не x + a1
            b = 0;
        end
        vcArrNum(i) = b(1);
    end

    for i = 1:(max(size(den)) - 1)
        b = abs(coeffs(den(i + 1)));
        if b(1) < 0.0001 || max(size(b)) < 2 % в случае если скобка x а не x + a1
            b = 0;
        end
        vcArrDen(i) = b(1);
    end

    vc = [vcArrDen, vcArrNum];
    vc = sort(vc);
    vc(vc == 0) = []; % удаление 0 из массива
    disp("Vc от vc1 до vc5");
    disp(vc);
    disp("K = "); disp(k);
    kHigh = 20 * log10(k);
    disp("20 * log(k) = ");
    disp(kHigh);
    disp("По этим данным надо график построить");
    
    vcBegin = 1e-6;
    vcEnd = 1e3;
        
    vcBeginY = kHigh + 20 * abs(log10(1 / vcBegin));
    vc1Y = vcBeginY - 20 * abs(log10(vcBegin / vc(1)));
    vc2Y = vc1Y - 40 * abs(log10(vc(1) / vc(2)));
    vc3Y = vc2Y - 60 * abs(log10(vc(2) / vc(3)));
    vc4Y = vc3Y - 40 * abs(log10(vc(3) / vc(4)));
    vc5Y = vc4Y - 20 * abs(log10(vc(4) / vc(5)));
    vcEndY = vc5Y;
    
    xHigh = [vcBegin, vc(1), vc(2), vc(3), vc(4), vc(5), vcEnd];
    yHigh = [vcBeginY, vc1Y, vc2Y, vc3Y, vc4Y, vc5Y, vcEndY];
           
    disp("Параметры желаемой ЛАЧХ");
        
    disp("wсрж = ");
    disp(wMid);
    vMid = tan(wMid * T / 2);
    vLow = 0.16 * vMid;
    vHigh = 6.5 * vMid;
    disp("vсрж = ");disp(vMid);
    disp("vн = ");disp(vLow);
    disp("vв = ");disp(vHigh);
    
    vMidY = 0;
    vLowY = vMidY + 20 * abs(log10(vLow / vMid));
    vHighY = vMidY - 20 * abs(log10(vMid / vHigh));
    vcBeginY = vLowY + 40 * abs(log10(vLow / vcBegin));
    vcEndY = vHighY;
    
    xLow = [vcBegin, vLow, vMid, vHigh, vcEnd];
    yLow = [vcBeginY, vLowY, vMidY, vHighY, vcEndY];
    semilogx(xHigh, yHigh, 'LineWidth', 2);
    grid on;
    hold on;
    semilogx(xLow, yLow, 'LineWidth', 2);
    legend("ЛАЧХ неизменяемой части", "ЛАЧХ желаемой части");

    % продолжение номера 13
    % на вход сюда передаточная функция из графика
    % заебало
        
    w = zeros(1, 8);
    disp("Введите точки абсциссы точек перегиба полученного " + ...
        "графика слева направо (их должно быть 8):");
    for i = 1:8
        w(i) = 1 / input("Точка " + i + ": ");
    end
    
    WkyS = vpa((w(2) * s + 1) * (w(3) * s + 1) * (w(4) * s  + 1) * ...
    (w(5) * s + 1) / + ((w(1) * s + 1) * (w(6) * s + 1) * (w(7) * s + ...
    1) * (w(8) * s + 1)), 5);
    
    WKy = simplify(subs(WkyS, s, (z - 1) / (z + 1)));
    [num, den] = numden(WKy);
    WKyZ = tf(sym2poly(num), sym2poly(den));
    disp("После подстановки w = (1 - z) / (z + 1)");
    disp("В отчёте s заменить на Z");
    display(zpk(WKyZ));
    
    disp("Реализация в виде Z-формы");
    CalcData('ZKy') = filt(sym2poly(num), sym2poly(den), CalcData('T'));
    display(CalcData('ZKy'));
    
    disp("По Wку(z) получаем разностное уравнение");
    num = sym2poly(num);
    den = sym2poly(den);
    num = num / den(1);
    den = den / den(1);
    s = "";
    for i = 1:max(size(num))
        s = s + num2str(num(i)) + " * e[(k - " + num2str(i - 1) + ")T] ";
        if i ~= max(size(num))
            s = s + "+ ";
        end
    end
    s = s + " = ";
    for i = 1:max(size(den))
        s = s + num2str(den(i)) + " * e[(k - " + num2str(i - 1) + ")T] ";
        if i ~= max(size(den))
            s = s + "+ ";
        end
    end
    disp(s);

    res = true;
end
