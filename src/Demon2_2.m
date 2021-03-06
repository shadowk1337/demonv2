% Второй пункт бля

function [res] = RCChainAnalysys(Data, CalcData, AdditionalData)
    w = zeros(1, 6);
    disp("Введите абсциссы точек перегиба полученного графика" + ...
        " слева направо (их должно быть 6):");
    for i = 1:6
        w(i) = 1 / input("Точка " + i + ": ");
    end

    WKy1 = tf([w(2), 1], [w(1), 1]);
    WKy2 = tf([w(3), 1], [w(5), 1]);
    WKy3 = tf([w(4), 1], [w(6), 1]);
    display(WKy1);
    display(WKy2);
    display(WKy3);

    [num, den] = numden(AdditionalData('Ws'));
    WsTf = tf(sym2poly(num), sym2poly(den));

    WKyRemake1 = filter(WKy1, 1);
    WKyRemake2 = filter(WKy2, 2);
    WKyRemake3 = filter(WKy3, 3);

    % Пункт 12 Метро Измайловская Работаем
    WKy = vpa(WKyRemake1 * WKyRemake2 * WKyRemake3, 5);
    W = vpa(WKy * AdditionalData('Ws'), 5);
    [num, den] = numden(W);
    W = tf(sym2poly(num), sym2poly(den));

%     disp("Итоговая передаточная функция корректирующего устройства ");
%     display(zpk(WKy));

    disp("Передаточная функция системы с корректирующим устройством ");
    display(zpk(W));

    WTransient = W / (1 + W);
    %     WsTransient = WsTf / (1 + WsTf);
    % step(Ws_transient);
    %     hold on;
    step(WTransient);
    grid on;

    disp("Характеристики системы с корректирующим устройством");
    S = stepinfo(WTransient);
    disp(S);
    title('Переходной процесс');
    % legend('Без коректирущего устройсва', 'С коректирующем устройсвом');

    function [WKyRemake] = filter(WKyInner, i)
        [numInner, denInner] = tfdata(WKyInner);
        numInner = cell2mat(numInner); denInner = cell2mat(denInner);
        C = capacitorFromUser(i);

        if (i == 1)
            R2 = vpa(numInner(1) / C, 4);
            R1 = vpa(denInner(1) / C - R2, 4);
        elseif (i == 2)
            k = vpa(denInner(1) / numInner(1), 4);
            R1 = vpa(numInner(1) / C, 4);
            R2 = vpa(k * R1 / (1 - k), 4);
        elseif (i == 3)
            k = vpa(denInner(1) / numInner(1), 4);
            R1 = vpa(numInner(1) / C, 4);
            R2 = vpa(k * R1 / (1 - k), 4);
        end
        disp("С" + i + " = ");
        disp(C);
        disp("R" + (2 * i - 1) + " = ");
        R1 = parseE24(R1);
        disp(R1)
        disp("R" + (2 * i) + " = ");
        R2 = parseE24(R2);
        disp(R2);
    
        if (i == 1)
            [w1, w2] = frequencyRemake(R2 * C, (R1 + R2) * C, i);
        elseif (i == 2)
            [w1, w2] = frequencyRemake(R1 * C, k * R1 * C, i);
        elseif (i == 3)
            [w1, w2] = frequencyRemake(R1 * C, k * R1 * C, i);
        end
    
        s = sym('s');

        WKyRemake = vpa((1 / w1 * s + 1) / (1 / w2 * s + 1), 5);
        disp("В итоге передаточная функция фильтра " + i + " будет " + ...
            "равна:");
        display(WKyRemake);
    end

    function Rres = parseE24(R)
        E24 = [1, 1.1, 1.2, 1.3, 1.5, 1.6, 1.8, 2, 2.2, 2.4, 2.7, 3, + ...
            3.3, 3.6, 3.9, 4.3, 4.7, 5.1, 5.6, 6.2, 6.8, 7.5, 8.2, 9.1];
        tt = 10 ^ floor(log10(R));
        R = R / tt;
        fres = 0;
        for iInner = 1:max(size(E24))
            if iInner == max(size(E24))
                fres = E24(iInner);
                break;
            end
            if E24(iInner) > R
                diff = abs(R - E24(iInner - 1)) - abs(R - E24(iInner));
                if (diff >= 0)
                    fres = E24(iInner);
                else
                    fres = E24(iInner - 1);
                end
                break;
            end
        end
        Rres = fres * tt;
    end

    function C = capacitorFromUser(i)
        disp("Введите значения ёмкости (любое стандартное) в ФАРАДАХ:");
        C = input("C" + i + ": ");
    end
    
    function [w1Res, w2Res] = frequencyRemake(t, T, i)
        w1Inner = vpa(1 / t, 4);
        w2Inner = vpa(1 / T, 4);
        disp("Уточнённые значения частот сопряжения:");
        disp("w" + (2 * i - 1) + " = ");
        disp(w1Inner);
        disp("w" + (2 * i) + " = ");
        disp(w2Inner);
        w1Res = w1Inner;
        w2Res = w2Inner;
    end

    res = true;
end
