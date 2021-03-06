function [res] = findSynthesis(Data, CalcData, AdditionalData)
    [num, den] = numden(AdditionalData('Ws'));
    cf = sym2poly(den);
    num = num / cf(3);
    den = expand(den / cf(3));

    CalcData('B') = getBVal(Data('Sigm'));
    if (CalcData('B') == 0)
        disp("B = 0, так быть не должно!" + newline);
        res = false;
        return;
    end

    wMid = CalcData('B') / Data('Tmax');
    wBegin = 0.01;
    wLow = 0.16 * wMid;
    wHigh = 6.5 * wMid;
    wEnd = 10000;

    disp("Из таблицы вычисляем B:");
    disp(CalcData('B'));
    disp("Нижняя частота:");
    disp(wLow);
    disp("Средняя частота:");
    disp(wMid);
    disp("Верхняя частота:");
    disp(wHigh);

    Ktr = 1 / (Data('Emax') * Data('Kg') * Data('a'));
    disp("Ктр = ");
    disp(Ktr);

    wMidY = 0;
    wLowY = wMidY + 20 * abs(log10(wLow / wMid));
    wBeginY = wLowY + 40 * abs(log10(wBegin / wLow));
    wHighY = wMidY - 20 * abs(log10(wMid / wHigh));
    wEndY = wHighY - 40 * abs(log10(wHigh / wEnd));

    xLower = [wBegin, wLow, wMid, wHigh, wEnd];
    yLower = [wBeginY, wLowY, wMidY, wHighY, wEndY];

    K = round(num, 4);

    den = factor(den, 'FactorMode', 'real');
    dend1 = round(coeffs(den(3)), 4); dend2 = round(coeffs(den(4)), 4);

    T1 = min(dend1(1), dend1(2)) / max(dend1(1), dend1(2));
    T2 = min(dend2(1), dend2(2)) / max(dend2(1), dend2(2));

    disp("T1 = "); disp(vpa(T1, 5));
    disp("T2 = "); disp(vpa(T2, 5));

    wc1 = round(min(1 / T1, 1 / T2));
    wc2 = round(max(1 / T2, 1 / T1));
    wcK = 1;

    disp("Графики должны пересекаться. Притом зелёный график " + ...
        "должен быть ниже." + newline + "Если графики не " + ...
        "пересекаются, измените коэффициент усиления");

    choice = 'y';
    while (choice == 'y')
        disp("Ваш коэффицент усиления:"); disp(K);
        disp("20log(K) = ");
        disp(vpa(20 * log10(K), 5));

        wcKY = 20 * log10(K);
        wBeginY = wcKY + 20 * abs(log10(wcK / wBegin));
        wc1Y = wcKY - 20 * abs(log10(wcK / wc1));
        wc2Y = wc1Y - 40 * abs(log10(wc1 / wc2));
        wEndY = wc2Y - 60 * abs(log10(wc2 / wEnd));

        xHigher = [wBegin, wcK, wc1, wc2, wEnd];
        yHigher = [wBeginY, wcKY, wc1Y, wc2Y, wEndY];

        disp("Точки перегиба графиков");
        disp("Точка 2:");disp(wc1);
        disp("Точка 3:");disp(wLow);
        disp("Точка 4:");disp(wc2);
        disp("Точка 5:");disp(wHigh);

        semilogx(xLower, yLower, 'g', 'LineWidth', 2);
        grid on
        hold on
        semilogx(xHigher, yHigher, 'LineWidth', 2);
        legend('Желаемая', 'Неизменяемая');

        choice = input("Изменить коэффициент усиления? [y/n]: ", 's');
        if (ischar(choice) && lower(choice) == 'y')
            K = input('Новый коэффициент усиления K: ');
            cla reset;
            [num, den] = numden(AdditionalData('Ws'));
            den = sym2poly(den);
            den = den / den(3);
            x = sym('x'); s = sym('s');
            AdditionalData('Ws') = subs(K / poly2sym(den), x, s);
            disp("Новая передаточная функция размокнутой системы:");
            disp(AdditionalData('Ws'));
        end
    end    

    function [b] = getBVal(sigma)
        B = containers.Map('KeyType', 'double', 'ValueType', 'double');
        B(5) = 6.5; B(10) = 6.7; B(20) = 6.9; B(25) = 8.8; B(30) = 11.3; 
        B(35) = 14.1; B(40) = 16.9;

        k = cell2mat(keys(B));
        b = 0;
        for i = 1:length(B)
            key = k(i);
            if (key > sigma)
                break;
            end
            b = B(key);
        end
    end

    res = true;
end