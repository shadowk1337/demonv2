% Калькулятор для решения домашнего задания номер 2 Деменкова Н.П.,
% выдаваемого на 5 семестре студентам кафедры ИУ4

addpath("src");
addpath("src/demon_simulink");

main();

function main()
    % Данные значения
    Data            = containers.Map('KeyType', 'char', ...
                                    'ValueType', 'double');

    % Расчетные значения
    CalcData        = containers.Map('KeyType', 'char', ...
                                    'ValueType', 'any');

    % Дополнительные значения
    AdditionalData  = containers.Map('KeyType', 'char', ...
                                    'ValueType', 'any');

    disp(newline + "******Данные из ДЗ1******" + newline);

    Data('Ng')  = input('Введите Nзад: ');
    Data('Ky')  = input('Введите Kу: ');
    Data('La')  = input('Введите Lя: ');
    Data('Kd')  = input('Введите Kд: ');
    Data('Tm')  = input('Введите Tм: ');
    Data('tau') = input('Введите τ (тао): ');

    Data('Kcap')    = 0.2;      % Kцап
    Data('Ra')      = 10;       % Rя
    Data('Rk')      = 0.01;     % Rк
    Data('Kg')      = 62500;    % Kг
    Data('i')       = 0.05;     % i
    Data('a')       = 1e-6;     % a
    Data('Te')      = Data('La') / Data('Ra');  % Тэ
    
    disp(newline + "******Данные из ДЗ2******" + newline);

    Data('Sigm')  = input('Введите σ (сигму) в процентах: ');
    Data('Tmax')  = input('Введите Tпмакс: ');
    Data('Emax')  = input('Введите Eмакс: ');

    AdditionalData('Ws') = findTransferFunctionOpened(Data);
    AdditionalData('WsDef') = AdditionalData('Ws');

    disp(AdditionalData('Ws'));

    AdditionalData('I') = [1 0 0;
                           0 1 0;
                           0 0 1];

    filenames = [
        "Demon2_1";
        "Demon2_2";
        "Demon2_3";
        "Demon2_4";
        "Demon2_5";
        "Demon2_6";
        "Demon2_7";
    ];

    points = [
        "10";
        "11 и 12";
        "13";
        "14";
        "15";
        "16 и 17";
        "18"
    ];

    for i = 1:size(filenames)
        str = upper('пункт ') + points(i);
        if (userInputInit(str))
            fprintf("\n*********%s*********\n", str);
            if (~feval(filenames(i), Data, CalcData, AdditionalData))
                disp("Ошибка!");
                break;
            end
            fprintf("\n*********Конец %s*********\n", str);
        else
            break;
        end
    end

    disp(newline + "*********Конец работы программы*********" + newline);
end

function [userAns] = userInputInit(str)
	out = "y - запустить " + str + ", n - завершить работу " + ...
          "программы [y/n]: ";
    inp = input(newline + out, 's');
    close all;
    
    if (ischar(inp) && lower(inp) == 'y')
        userAns = true;
    else
        userAns = false;
    end
end

function [Ws] = findTransferFunctionOpened(Data)
    syms s;
    
    Ws = (Data('i') * Data('Kcap') * Data('Ky') * Data('Kd') * ...
          Data('Kg') * Data('Rk') / ((Data('Tm') * Data('Te') * ...
          s ^ 2 + (Data('Tm') + Data('Te')) * s + 1) * s));
end