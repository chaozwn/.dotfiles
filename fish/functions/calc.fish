# 计算器
function calc --wraps numbat
    numbat --pretty-print=always -e $argv
end
