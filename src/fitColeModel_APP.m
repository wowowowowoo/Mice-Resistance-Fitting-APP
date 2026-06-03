function [r_squared,rmse_value,T_output] = fitColeModel_APP(app,Z)
%fitColeModel 对Cole模型进行拟合，并返回拟合参数和评价指标。
%   [fit_results, T_output] = fitColeModel(Z)
%   输入:
%       Z: 一个 15x3 的矩阵，其中包含各月龄（2, 9, 18）的平均阻抗值。
%          Z的列顺序应为 [2月龄数据, 9月龄数据, 18月龄数据]。
%   输出:
%       fit_results: 一个结构体，包含以下字段:
%           .fittedmodel: 拟合模型对象
%           .gof: 拟合的 goodness-of-fit 结构体 (包含 R方, RMSE等)
%           .parameters: 包含所有拟合系数的结构体 (例如: .Rs_a, .Rs_b等)
%           .rsquare: 拟合的R平方值
%           .rmse: 拟合的RMSE值
%       T_output: 一个表格 (table) 对象，包含拟合参数的名称和值。
%
%   示例:
%       % 假设您已经有了Z矩阵，例如从之前的 processBodyPartData 函数获取
%       % Z_kidney = processBodyPartData('肾');
%       % [results, param_table] = fitColeModel(Z_kidney);
%       % disp(results.rsquare);
%       % disp(param_table);

% 确保 Z 是一个 15x3 的矩阵
if ~ismatrix(Z) || size(Z,1) ~= 15 || size(Z,2) ~= 3
    error('输入 Z 必须是一个 15x3 的矩阵。');
end

% 提取图1中的数据 (与原代码保持一致)
frequencies = [20; 40; 60; 80; 100; 200; 500; 1000; 5000; 10000; 20000; 50000; 100000; 500000; 1000000];
months = [2,9,18]; % 只有这三个月龄

% 阻抗值 (Z)
% 注意：Z_data 的行对应频率，列对应月龄
Z_data = Z; % 直接使用输入的 Z

% 将数据展平以进行拟合
% Fit expects column vectors for independent and dependent variables
% 根据 Z_data 的结构，F_flat 和 M_flat 需要重新构建以匹配 Z_flat
% 这里的 F_flat 和 M_flat 应该与 Z_data 的展平顺序匹配
num_freq = length(frequencies);
num_months = length(months);

F_flat = repmat(frequencies, num_months, 1); % 频率按月龄重复
M_flat = repelem(months, num_freq)';         % 月龄按频率重复

Z_flat = Z_data(:); % 确保 Z_data 的维度和顺序与 M_flat, F_flat 匹配

% 定义拟合函数句柄
% 参数顺序:
% p = [Rs_a, Rs_b, Rct_a, Rct_b, Q_a, Q_b, n_a, n_b]
% 输入参数: month (m), frequency (f)
customEqn_age_dependent = fittype(@(Rs_a, Rs_b, Rct_a, Rct_b, Q_a, Q_b, n_a, n_b, m, f) ...
    calculate_Z_magnitude(Rs_a, Rs_b, Rct_a, Rct_b, Q_a, Q_b, n_a, n_b, m, f), ...
    'independent', {'m', 'f'}, 'dependent', 'Z', ...
    'coefficients', {'Rs_a', 'Rs_b', 'Rct_a', 'Rct_b', 'Q_a', 'Q_b', 'n_a', 'n_b'});

% 定义初始猜测值
init_Rs_b = 5;
init_Rct_b = 50;
init_Q_b = 1e-4;
init_n_b = 0.9;

init_Rs_a = -0.5;
init_Rct_a = -2;
init_Q_a = 0;
init_n_a = 0;

initial_guess_values = [init_Rs_a, init_Rs_b, init_Rct_a, init_Rct_b, ...
                        init_Q_a, init_Q_b, init_n_a, init_n_b];

% 定义参数的下限和上限
lower_bounds = [-Inf, 0, -Inf, 0, -Inf, 0, -Inf, 0]; % Rs_b, Rct_b, Q_b, n_b 需为正
upper_bounds = [Inf, Inf, Inf, Inf, Inf, Inf, Inf, 1]; % n_b 可以高达1

% 拟合选项
fitOptions = fitoptions(customEqn_age_dependent);
fitOptions.StartPoint = initial_guess_values;
fitOptions.Lower = lower_bounds;
fitOptions.Upper = upper_bounds;
fitOptions.MaxFunEvals = 2000; % 增加迭代次数
fitOptions.MaxIter = 2000;
fitOptions.Display = 'off'; % 拟合过程中不显示迭代信息，保持函数输出整洁
fitOptions.TolFun = 1e-9;

% 执行拟合
[fittedmodel_age_dependent, gof_age_dependent] = fit([M_flat, F_flat], Z_flat, customEqn_age_dependent, fitOptions);

% --- 准备输出数据 ---
fit_results.fittedmodel = fittedmodel_age_dependent;
fit_results.gof = gof_age_dependent;
fit_results.rsquare = gof_age_dependent.rsquare;
fit_results.rmse = gof_age_dependent.rmse;

% 提取并存储拟合参数到结构体
param_names = coeffnames(fittedmodel_age_dependent);
fit_values = coeffvalues(fittedmodel_age_dependent);
for i = 1:length(param_names)
    fit_results.parameters.(param_names{i}) = fit_values(i);
end

% 创建表格 T_output
column_headers = param_names'; % 参数名称作为列名
data_row_for_table = fit_values; % 拟合值作为数据行
T_output = array2table(data_row_for_table, 'VariableNames', column_headers);

% --- 绘图部分 (保持原样，但为了函数返回，将其放在可选部分或独立函数中) ---
% 为了让函数更专注于计算和返回，您可以选择将绘图代码注释掉
% 或将其移到另一个函数中，通过调用该函数来绘制。
% 这里我保留了绘图部分，以便您能看到结果。

% 创建更细的网格用于绘图
plot_months = linspace(min(months), max(months), 10);
plot_frequencies = linspace(min(frequencies), max(frequencies), 50);

[plot_M, plot_F] = meshgrid(plot_months, plot_frequencies);

% 使用拟合模型计算预测的 Z 值
plot_Z_predicted = feval(fittedmodel_age_dependent, plot_M, plot_F);

% 绘制原始数据散点图和拟合曲面
% figure;


% 提取原始数据点
age2_mean = Z_data(:,1);
age9_mean = Z_data(:,2);
age18_mean = Z_data(:,3);
hold(app.UIAxes, 'on');   % 保持住，以便叠加绘图
scatter3(app.UIAxes,months(1)*ones(size(frequencies)), frequencies, age2_mean, 'filled', 'o','MarkerFaceColor', 'blue', 'DisplayName', sprintf('%dmonth', months(1)));
%scatter3(app.UIAxes,months(2)*ones(size(frequencies)), frequencies, age9_mean, 'filled', '^', 'MarkerFaceColor', 'red', 'DisplayName', sprintf('%dmonth', months(2)));
scatter3(app.UIAxes,months(3)*ones(size(frequencies)), frequencies, age18_mean, 'filled', 's', 'MarkerFaceColor', 'green', 'DisplayName', sprintf('%dmonth', months(3)));
% 绘制拟合曲面
surf(app.UIAxes,plot_M, plot_F, plot_Z_predicted, 'FaceAlpha', 0.6, 'EdgeColor', 'none', 'DisplayName', 'fitted curve');
colormap(app.UIAxes,jet);
% 删除现有的 colorbar（如果存在）
if ~isempty(app.UIAxes.Colorbar)
    delete(app.UIAxes.Colorbar);
end
% 创建新 colorbar
c = colorbar(app.UIAxes, 'eastoutside');
% 设置colorbar大小（保持自动位置，只修改宽度和高度）
currentPos = c.Position; % 获取当前的位置
c.Position = [currentPos(1), currentPos(2), 0.01, 0.3]; % 保持left和bottom不变，只修改width和height
% 设置colorbar标签字体大小
c.FontSize = 8;
xlabel(app.UIAxes,'Age-month');
ylabel(app.UIAxes,'Frequency(Hz)');
set(app.UIAxes, 'YScale', 'log');
zlabel(app.UIAxes,'Impedance(Z, KΩ)');
legend(app.UIAxes,'show');

view(app.UIAxes,-140,60); % 3D视图

r_squared = gof_age_dependent.rsquare;
rmse_value = gof_age_dependent.rmse;

end