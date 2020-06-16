% Outer script for velocitystats.m

iq_plot_flag = 0; % Generate checkiq.m plots
iq_save_flag = 1; % Save checkiq.m variables into .mat file
plot_flag = [1 1 1 0 0 0]; % Produce each plot from this script
plot_save_flag = 0; % Save plots from this script
LES_compare = 0; % Compare sim retrievals with LES ground truth
var_save_flag = 1; % Save swp/les/avg variables

sim_name = 'torgen';

base_dir = '/Users/schneider/Documents/'; % Directory where you run the script
fig_dir = [base_dir 'imgs/']; % Figure output directory
dir_loc = [base_dir 'sims/']; % SimRadar output directory
save_dir = [base_dir 'stats/']; % Velocity stats output directory
%case_dir = uigetdir(dir_loc);
%dtypes = dir([case_dir '/*debris*']);

%%












%%

load([dir_loc 'les/' sim_name '/grid.mat'])
u_LES = zeros(size(Xmf,1), size(Xmf,2), size(Xmf,3), 320);
v_LES = u_LES;
w_LES = u_LES;
tke_LES = u_LES;
p_LES = u_LES;
t_LES = zeros(1,320);

x_LES = Xmf;
y_LES = Ymf;
z_LES = Zmf;
for k = 1:32
    load([dir_loc 'les/' sim_name '/LES_', num2str(k), '.mat'])
    u_LES(:,:,:,k*10-9:k*10) = ustore;
    v_LES(:,:,:,k*10-9:k*10) = vstore;
    w_LES(:,:,:,k*10-9:k*10) = wstore;
    tke_LES(:,:,:,k*10-9:k*10) = tkestore;
    p_LES(:,:,:,k*10-9:k*10) = pstore;
    t_LES(k*10-9:k*10) = time;
end

save([dir_loc 'les/' sim_name '/LES_all.mat'], 'x_LES', 'y_LES', 'z_LES',...
    't_LES', 'u_LES', 'v_LES', 'w_LES', 'tke_LES', 'p_LES', '-v7.3', '-nocompression')
clear u_LES v_LES w_LES tke_LES p_LES t_LES




