% пункт 14
% Даааа ебать того рот

function [res] = analysys(Data, CalcData, AdditionalData)
    s = sym('s'); z = sym('z');

    display(CalcData('ZKy'));
    WKyFromz = d2c(CalcData('ZKy'), 'tustin');
    display(WKyFromz);
    [num, den] = numden(AdditionalData('Ws'));
    WsTf = tf(sym2poly(num), sym2poly(den));
    W = WsTf * WKyFromz;
    display(W);
    W = W / (1 + W);
    Wd = c2d(W, CalcData('T'));
    step(Wd);
    grid on;
    hold on;
    S = stepinfo(Wd);
    disp(S);

    res = true;
end
