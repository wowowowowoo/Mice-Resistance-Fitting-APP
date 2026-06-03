function Z = processBodyPartData_APP(filePath,bodyPart)
%processBodyPartData 处理并绘制给定身体部位的阻抗数据。
%   processBodyPartData(bodyPart) 接受一个字符串 'bodyPart' (例如, '肾')
%   作为输入。它读取指定身体部位的雌性和雄性数据，
%   清洗数据，计算不同年龄组（2、9和18月龄）的平均值和包络线，
%   然后生成一个包含3个子图的图形，显示每个年龄组的原始数据、平均曲线和包络线。
%
%   示例:
%      processBodyPartData('肾');

% 根据输入的bodyPart动态构建文件路径
female_filepath = fullfile([filePath,'\6.30-雌性'], [bodyPart '-Z.csv']);
male_filepath = fullfile(filePath,'\7.4-雄性', [bodyPart '-Z.csv']);

% 读取CSV文件
data_female = readtable(female_filepath);
data_male = readtable(male_filepath);

%% 处理雌性数据
% 从第二行第二列开始提取数据，忽略第一列和第一行
data_female = data_female(1:end, 2:end); % 移除第一列和第一行
num_cols = width(data_female); % 获取总列数
if num_cols < 36
    error('文件列数不足36列，请检查数据！');
end

% 去除空行（全为缺失值的行）
data_female = data_female(~all(ismissing(data_female), 2), :);

% 每12列分为一个年龄组，顺序为2、9、18月龄
age2_data_raw_female = data_female(:, 1:12);    % 2月龄数据（第2列到第13列）
age9_data_raw_female = data_female(:, 13:24);   % 9月龄数据（第14列到第25列）
age18_data_raw_female = data_female(:, 25:36);  % 18月龄数据（第26列到第37列）

% 去除每个月龄对应数据的空列
age2_data_female = age2_data_raw_female(:, ~all(ismissing(age2_data_raw_female), 1));
age9_data_female = age9_data_raw_female(:, ~all(ismissing(age9_data_raw_female), 1));
age18_data_female = age18_data_raw_female(:, ~all(ismissing(age18_data_raw_female), 1));

% 将数据转换为矩阵（移除缺失值后的数据）
if ~isempty(age2_data_female)
    age2_data_female = table2array(age2_data_female); % 转换为数组
%end
%if ~isempty(age9_data_female)
    age9_data_female = table2array(age9_data_female); % 转换为数组
end
if ~isempty(age18_data_female)
    age18_data_female = table2array(age18_data_female); % 转换为数组
end

% 计算各月龄数据的平均值（按行平均）
age2_mean_female = mean(age2_data_female, 2);
age9_mean_female = mean(age9_data_female, 2);
age18_mean_female = mean(age18_data_female, 2);

% 确保所有平均值向量都是15×1
if size(age2_mean_female,1) > 15
    age2_mean_female = age2_mean_female(1:15);
end
if size(age9_mean_female,1) > 15
   age9_mean_female = age9_mean_female(1:15);
end
if size(age18_mean_female,1) > 15
    age18_mean_female = age18_mean_female(1:15);
end

% 将平均值数据分配到工作区变量
assignin('base', 'age2_mean_female', age2_mean_female);
assignin('base', 'age9_mean_female', age9_mean_female);
assignin('base', 'age18_mean_female', age18_mean_female);

%% 

% 从第二行第二列开始提取数据，忽略第一列和第一行
data_male = data_male(1:end, 2:end); % 移除第一列和第一行
num_cols = width(data_male); % 获取总列数
if num_cols < 39
    error('文件列数不足39列，请检查数据！');
end

% 去除空行（全为缺失值的行）
data_male = data_male(~all(ismissing(data_male), 2), :);

% 每12列分为一个年龄组，顺序为2、9、18月龄
age2_data_raw_male = data_male(:, 1:13);    % 2月龄数据（第2列到第14列）
age9_data_raw_male = data_male(:, 14:26);   % 9月龄数据（第15列到第27列）
age18_data_raw_male = data_male(:, 27:39);  % 18月龄数据（第28列到第40列）

% 去除每个月龄对应数据的空列
age2_data_male = age2_data_raw_male(:, ~all(ismissing(age2_data_raw_male), 1));
age9_data_male = age9_data_raw_male(:, ~all(ismissing(age9_data_raw_male), 1));
age18_data_male = age18_data_raw_male(:, ~all(ismissing(age18_data_raw_male), 1));

% 将数据转换为矩阵（移除缺失值后的数据）
if ~isempty(age2_data_male)
    age2_data_male = table2array(age2_data_male); % 转换为数组
end
if ~isempty(age9_data_male)
    age9_data_male = table2array(age9_data_male); % 转换为数组
end
if ~isempty(age18_data_male)
    age18_data_male = table2array(age18_data_male); % 转换为数组
end

% 计算各月龄数据的平均值（按行平均）
age2_mean_male = mean(age2_data_male, 2);
age9_mean_male = mean(age9_data_male, 2);
age18_mean_male = mean(age18_data_male, 2);

% 确保所有平均值向量都是15×1
if size(age2_mean_male,1) > 15
    age2_mean_male = age2_mean_male(1:15);
end
if size(age9_mean_male,1) > 15
    age9_mean_male = age9_mean_male(1:15);
end
if size(age18_mean_male,1) > 15
    age18_mean_male = age18_mean_male(1:15);
end

% 将平均值数据分配到工作区变量
assignin('base', 'age2_mean_male', age2_mean_male);
assignin('base', 'age9_mean_male', age9_mean_male);
assignin('base', 'age18_mean_male', age18_mean_male);

age18_mean = mean([age18_mean_male,age18_mean_female],2);
age9_mean = mean([age9_mean_male,age9_mean_female],2);
age2_mean = mean([age2_mean_male,age2_mean_female],2);

Z = [age2_mean,age9_mean,age18_mean];


end