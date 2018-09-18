
function value = get_value(array16_33)
    global line_info;
    num = length(array16_33);
    value = 0;
    for i = 1:num
        value=value+line_info(array16_33(i),3);
    end
end