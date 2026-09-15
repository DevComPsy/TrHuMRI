%% script to conduct behavioural regression and make reg plot (Fig 1C) 
% Based on April Nadescha Trudel 2022
% behavioural information gathering analyses
clear; clc
beep off

%% Read in Data 
regs_all_tab = readtable("~\Scripts\behaviour.csv");

%% Conduct Regression
pcont_mmdl = fitglme(regs_all_tab, 'cont_ch ~ 1 + totevminus + deltaev + trial + termination + trial:termination + totevminus:termination + deltaev:termination + (totevminus + deltaev + trial + termination + trial:termination + totevminus:termination + deltaev:termination | userID)', 'Distribution', 'binomial','Link','logit')

%% extract model predictions for fmri
model_predictions = pcont_mmdl.predict(regs_all_tab);

save("model_predictions.mat", "model_predictions")

% plot
[B,BNames,stats]= fixedEffects(pcont_mmdl);

stats_toplot = [stats(4:5,:); stats(2:3,:)];

varnames = {'N draws', 'Horizon', 'ES_{d-1}', 'ΔES'}

N = size(varnames,2);

figure
hold on
scatter([1:4], stats_toplot.Estimate(1:4), [], 'k',  'filled')
e = errorbar([1:4], stats_toplot.Estimate(1:4), stats_toplot.SE(1:4), 'vertical', 'LineStyle', 'none', 'Color', 'k')
e.CapSize = 0;
e.LineWidth = 1;
% ylim([0, 2.5])
xlim([0.5,4.5])
set(gcf,'color','w'); set(gca,'XTick',1:4,'XTickLabel', varnames,'FontSize',14);
ylabel('Beta coefficients of p(decide)', 'FontSize', 14);  

%% Extract betas per subject

%run function
perSub_betas = getSubjectBetas(pcont_mmdl, regs_all_tab, unique(dataTable.userID));

save("perSub_betas.mat","perSub_betas");

writetable(perSub_betas, "perSub_betas.csv");
