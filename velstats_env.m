% Outer script for velocitystats.m

clear

iq_plot_flag = 0; % Generate checkiq.m plots
iq_save_flag = 1; % Save checkiq.m variables into .mat file
plot_flag = [0 0 0 0 0 0]; % Produce each plot from this script
plot_save_flag = 0; % Save plots from this script
LES_flag = 0; % Compare sim retrievals with LES ground truth
var_save_flag = 1; % Save swp/les/avg variables

% sim_bases: suctvort, suctvort_large, onecell, breakdown, torgen, moore
% sim_dates: 200116, 200122, 200615, xxxxxx, xxxxxx, xxxxxx
sim_base = 'onecell';
sim_date = '200615';
dtypes = [0 1 2 3 4 5 6];
dnums = [1000 10000 100000 1000000];
nd_concept = {'U'};
dd_concept = 'DBCU';

base_dir = '/Users/schneider/Documents/'; % Directory where you run the script
dir_loc = [base_dir 'sims']; % SimRadar output directory


%%

for dtype = dtypes
    if dtype == 0 % no debris
        dnum = [];
        for cc = 1:length(nd_concept)
            concept = nd_concept{cc};
            sim_dir = [dir_loc '/' sim_base '/' sim_date '/nodebris'];
        
            velocitystats
        
            if exist('dumbass_flag', 'var')
                return
            end
        end
    else % with debris
        concept = dd_concept;
        for dnum = dnums
            sim_dir = [dir_loc '/' sim_base '/' sim_date '/debris' num2str(dtype)];
            
            velocitystats
            
            if exist('dumbass_flag', 'var')
                return
            end
        end
    end
    
    
end








