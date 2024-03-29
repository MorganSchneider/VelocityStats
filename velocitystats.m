% Plot/save flags

%%% Quantify how good/bad estimates of dynamical/kinematic parameters are
% like deltaV, vorticity, max wind speed, 90th percentile velocity?? other
% percentiles, etc figure out what works best and is less sensitive to
% noise.  How to best estimate tornado wind speeds?

%%% Quantify effects of debris bias on wind speed errors
% Compare debris scans to non debris scans, relationships between debris
% bias/wind errors and polarimetric variables
% Find a best fit line based on DP variables?
%%% Scatter plot of velocity difference between debris/rain as a function
%%% of DP vars - flag gates that are likely to have large bias


% Take straight diff in Vr between debris/no debris at each gate, look for
% correlation with rhohv, reflectivity, zdr, etc
% also correlation with diff in spectrum width?

% fig 1: delta V vs. height
% fig 2: SimRadar retrieved pseudovorticity isosurfaces
% fig 3: SimRadar GBVTD axisymmetric wind retrievals
% fig 4: LES vorticity isosurfaces
% fig 5: LES axisymmetric wind 
% fig 6: SimRadar GBVTD retrievals + LES axisymmetric calculations + difference

if exist('dumbass_flag', 'var')
    clear dumbass_flag
end
clear data swp les
close all

% Check if called from another script

[st,~] = dbstack('-completenames');
if length(st) > 1
    external_call = 1;
else
    external_call = 0;
    
    iq_plot_flag = 0; % Generate checkiq.m plots
    iq_save_flag = 1; % Save checkiq.m variables into .mat file
    plot_flag = [0 0 0 0 0 0]; % Produce each plot from this script
    plot_save_flag = 0; % Save plots from this script
    LES_flag = 0; % Compare sim retrievals with LES ground truth
    var_save_flag = 0; % Save swp and les variables
    state_flag = 0; % Load and analyze debris positions from simstate file
end

external_call_main = external_call;


if ~external_call_main
    base_dir = '/Users/schneider/Documents/';
    dir_loc = [base_dir 'sims']; % SimRadar output directory
    sim_dir = uigetdir(dir_loc); % Location of IQ files
    
    dnum = input(['Number of debris? (Press enter for no debris) ', newline]);
    concept = upper(input(['Simulation concept? ', newline], 's'));
    
    inds = strfind(sim_dir, '/');
    sim_base = sim_dir(inds(5)+1 : inds(6)-1);
    sim_date = sim_dir(inds(6)+1 : inds(7)-1);
    if ~isempty(dnum)
        dtype = sim_dir(inds(7)+7 : end);
    else
        dtype = [];
    end
else
    if ~exist('iq_plot_flag', 'var') || ~exist('iq_save_flag', 'var') || ~exist('plot_flag', 'var') ...
            || ~exist('plot_save_flag', 'var') || ~exist('LES_flag', 'var') || ~exist('var_save_flag', 'var')
        missing_flags = setdiff({'iq_plot_flag', 'iq_save_flag', 'plot_flag', ...
            'plot_save_flag', 'LES_flag', 'var_save_flag'}, who('*flag'));
        disp('You didn''t set all the flags, dumbass!')
        disp(missing_flags)
        dumbass_flag = 1;
        return
    end
    if ~exist('sim_base', 'var') || ~exist('sim_date', 'var') || ~exist('dnum', 'var') ...
            || ~exist('dtype', 'var') || ~exist('concept', 'var')
        missing_vars = setdiff({'sim_base', 'sim_date', 'dnum', ...
            'dtype', 'concept'}, who('*'));
        disp('You didn''t specify which files to use, stupid!')
        disp(missing_vars)
        dumbass_flag = 1;
        return
    end
end

if isnumeric(dtype)
    dtype = num2str(dtype);
end
concept = upper(concept);

sim_name = sim_base;
sim_name(strfind(sim_name, '_')) = '-'; % rename sim_name for plot titles
if ~isempty(dnum)
    str = ['Sim: ' sim_name ', debris type ', dtype, ' n=', num2str(dnum)];
    img_name_base = [sim_date '_d' dtype 'n' num2str(dnum) '_'];
    fig_dir = [base_dir 'imgs/' sim_base '/d' dtype];
    save_dir = [base_dir 'stats/' sim_base '/d' dtype];
else
    str = ['Sim: ' sim_name ', no debris'];
    img_name_base = [sim_date '_nd_' concept '_'];
    fig_dir = [base_dir 'imgs/' sim_base '/nd'];
    save_dir = [base_dir 'stats/' sim_base '/nd'];
end

if ~exist(fig_dir, 'dir')
    mkdir(fig_dir)
    addpath(genpath(fig_dir))
end
if ~exist(save_dir, 'dir')
    mkdir(save_dir)
    addpath(genpath(save_dir))
end
savepath


cd(sim_dir)

fname = ['sim*-', concept, '-*', num2str(dnum)];
iqfiles = dir([fname, '.iq']);

nels = length(iqfiles);
if ~isequal(length(iqfiles), length(dir([fname, '.mat'])))
    for i = 1:nels
        filename = [iqfiles(i).folder '/' iqfiles(i).name];
        external_call = 1;
        checkiq
        
        if state_flag
            read_simstate
        end
    end
end

matfiles = dir([fname, '.mat']);


data = struct('iqh', [], 'iqv', [], 'zh', [], 'zv', [], 'vh', [], 'vv', [], ...
    'zdr', [], 'rhohv', [], 'xx', [], 'yy', [], 'zz', []);
swp = struct('el', [], 'az', [], 'r', [], 'dr', [], 'v', [], 'x', [], ...
    'y', [], 'z', [], 'uu', [], 'vv', [], 'ww', [], 'deltav', [], ...
    'deltav90', [], 'deltav75', [], 'vrmax', [], 'vr90', [], 'vr75', [], ...
    'vort_vol', [], 'axy', []);
swp.axy = struct('ur', [], 'vr', [], 'wr', []);


for i = 1:nels
    filename = [matfiles(i).folder '/' matfiles(i).name];
    load(filename)
    nsweeps = size(iqh,4);
    
    data.xx(:,:,i) = xx;
    data.yy(:,:,i) = yy;
    data.zz(:,:,i) = zz;
    vv = squeeze(-dat.params.va / pi * angle(mean(iqv(:,:,2:end,:) .* conj(iqv(:,:,1:end-1,:)),3)));
%     data.zh(:,:,i) = mean(zh,3);
%     data.zv(:,:,i) = mean(zv,3);
%     data.vh(:,:,i) = mean(vr,3);
%     data.vv(:,:,i) = mean(vv,3);
%     data.zdr(:,:,i) = mean(zdr,3);
%     data.rhohv(:,:,i) = mean(rhohv,3);
    
    np = uint16((dat.params.scan_end - dat.params.scan_start) / dat.params.scan_delta); % number of pulses per scan
    for n = 1:nsweeps
        data.iqh(:,:,:,n,i) = iqh(:,:,:,n);
        data.iqv(:,:,:,n,i) = iqv(:,:,:,n);
        data.zh(:,:,n,i) = zh(:,:,n);
        data.zv(:,:,n,i) = zv(:,:,n);
        data.vh(:,:,n,i) = vr(:,:,n);
        data.vv(:,:,n,i) = vv(:,:,n);
        data.zdr(:,:,n,i) = zdr(:,:,n);
        data.rhohv(:,:,n,i) = rhohv(:,:,n);
        
        swp(n).el(i) = dat.el_deg(1,1);
        swp(n).dr(i) = dat.params.dr;
        swp(n).t = dat.scan_time((n-1)*np+1 : n*np);
        swp(n).v(:,:,i) = vr(:,:,n);
        swp(n).x(:,:,i) = xx;
        swp(n).y(:,:,i) = yy;
        [swp(n).az(:,:,i), swp(n).r(:,:,i)] = meshgrid(az_rad, r);
        swp(n).z(:,:,i) = swp(n).r(:,:,i) * sind(swp(n).el(i));
    end
end

data.iqh = permute(data.iqh, [1 2 5 3 4]);
data.iqv = permute(data.iqv, [1 2 5 3 4]);
data.zh = permute(data.zh, [1 2 4 3]);
data.zv = permute(data.zv, [1 2 4 3]);
data.vh = permute(data.vh, [1 2 4 3]);
data.vv = permute(data.vv, [1 2 4 3]);
data.zdr = permute(data.zdr, [1 2 4 3]);
data.rhohv = permute(data.rhohv, [1 2 4 3]);


cd ~

if LES_flag && ~exist('les', 'var')
    % Load time variable ONLY from LES_all.mat to time-match between LES and SimRadar
    load([dir_loc '/les/' sim_name '/LES_all.mat'], 't_LES')
    dt1 = abs(t_LES - swp(1).t(1));
    dt2 = abs(t_LES - swp(nsweeps).t(end));
    ti1 = find(dt1 == min(dt1,[],'all'));
    ti2 = find(dt2 == min(dt2,[],'all'));
    fn1 = ceil(ti1 / 10);
    fn2 = ceil(ti2 / 10);
    
    gridvars = {'Xmf', 'Ymf', 'Zmf'};
    lesgrid = load([dir_loc '/les/' sim_name '/grid.mat'], gridvars{:});
    x_LES = lesgrid.Xmf;
    y_LES = lesgrid.Ymf;
    z_LES = lesgrid.Zmf;
    
    datavars = {'time', 'ustore', 'vstore', 'wstore', 'tkestore', 'pstore'};
    lesdata = load([dir_loc '/les/' sim_name '/LES_' num2str(fn1) '.mat'], datavars{:});
    t_LES = lesdata.time;
    u_LES = lesdata.ustore;
    v_LES = lesdata.vstore;
    w_LES = lesdata.wstore;
    tke_LES = lesdata.tkestore;
    p_LES = lesdata.pstore;
    if fn1 ~= fn2
        for fdx = fn1+1: fn2
            lesdata = load([dir_loc '/les/' sim_name '/LES_' num2str(fdx) '.mat'], datavars{:});
            t_LES = cat(2, t_LES, lesdata.time);
            u_LES = cat(4, u_LES, lesdata.ustore);
            v_LES = cat(4, v_LES, lesdata.vstore);
            w_LES = cat(4, w_LES, lesdata.wstore);
            tke_LES = cat(4, tke_LES, lesdata.tkestore);
            p_LES = cat(4, p_LES, lesdata.pstore);
        end
    end
    
    les = struct('x', x_LES, 'y', y_LES, 'z', z_LES, 't', t_LES, 'u', u_LES,...
        'v', v_LES, 'w', w_LES, 'tke', tke_LES, 'p', p_LES, 'ur', [], 'vr', [],...
        'vrmax', [], 'vr90', [], 'vr75', [], 'vort', []);
    les.axy = struct('r', [], 'z', [], 'u', [], 'v', [], 'w', [], 't', []);
    
    V = sqrt(u_LES.^2 + v_LES.^2);
    les.vrmax = max(V,[],'all');
    les.vr90 = prctile(V,90,'all');
    les.vr75 = prctile(V,75,'all');
    dvdx = gradient(v_LES,1) / (x_LES(2,1,1) - x_LES(1,1,1));
    dudy = gradient(u_LES,2) / (y_LES(1,2,1) - y_LES(1,1,1));
    les.vort = dvdx - dudy;
end


[az_vol, r_vol, el_vol] = meshgrid(az_rad, r, swp(1).el);
swp(n).vort_vol = ones(size(swp(1).x,1), size(swp(1).x,2), nels);
for n = 1:nsweeps
    if LES_flag == 1
        [swp(n).axy, elevs, les.axy(n)] = gbvtd(swp(n), les);
        
        tind(1) = find(les.t == les.axy(n).t(1));
        tind(2) = find(les.t == les.axy(n).t(2));
        dx = les.x(2,1,1) - les.x(1,1,1);
        dy = dx;
        dv = gradient(les.v(:,:,:,tind(1):tind(2)), 1);
        du = gradient(les.u(:,:,:,tind(1):tind(2)), 2);
        les.vort(:,:,:,n) = mean(dv/dx - du/dy, 4);
    else
        [swp(n).axy, elevs] = gbvtd(swp(n));
    end
    
    v_in = -1 * swp(n).v;
    v_in(v_in <= 0) = NaN;
    v_out = swp(n).v;
    v_out(v_out <= 0) = NaN;
    for i = 1:nels
        swp(n).deltav(i) = max(v_out(:,:,i),[],'all') + max(v_in(:,:,i),[],'all'); % maximum delta V
        swp(n).deltav90(i) = prctile(v_out(:,:,i),90,'all') + prctile(v_in(:,:,i),90,'all');
        swp(n).deltav75(i) = prctile(v_out(:,:,i),75,'all') + prctile(v_in(:,:,i),75,'all');
        vort = gradient(swp(n).v(:,:,i), 2) ./...
            (swp(n).r(:,:,i) .* gradient(swp(n).az(:,:,i), 2));
        swp(n).uu(:,:,i) = elevs(i).u;
        swp(n).vv(:,:,i) = elevs(i).v;
        swp(n).ww(:,:,i) = elevs(i).w;
        swp(n).vort_vol(:,:,i) = ones(size(swp(1).x,1), size(swp(1).x,2)) .* vort;
    end
end


%% Plot things
for n = 1:nsweeps
    if nsweeps > 1
        tstr = [str, ' - sweep ', num2str(n)];
    elseif nsweeps == 1
        tstr = str;
    end
    
    % delta V
    if plot_flag(1)
        if ishandle(1)
            clf(1)
        end
        
        figure(1)
        axis tight manual
        plot(swp(n).deltav, swp(n).el)
        % xlim([90 125]) % suctvort
        xlim([90 180]) % suctvort_large
        xlabel('\DeltaV (m/s)')
        ylabel('Elev. angle \theta (^{o})')
        title('Maximum \DeltaV')
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(tstr, 'FontSize', 14);
        axis off
        if nsweeps > 1 && plot_save_flag
            F = getframe(gcf);
            im = frame2im(F);
            [imind,cm] = rgb2ind(im,256);
            if n == 1
                imwrite(imind, cm, [fig_dir '/' img_name_base 'deltaV-height-anim.gif'],...
                    'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
            else
                imwrite(imind, cm, [fig_dir '/' img_name_base 'deltaV-height-anim.gif'],...
                    'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
            end
        elseif nsweeps == 1 && plot_save_flag
            print([fig_dir '/' img_name_base 'deltaV-height'], '-dpng')
        end
    end
    
    % pseudovorticity
    if plot_flag(2)
        if ishandle(2)
            clf(2)
        end
        
        figure(2)
        axis tight manual
        [f,v] = isosurface(az_vol, r_vol, el_vol, swp(n).vort_vol, 0.9); %1.5
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.5)
        hold on
        [f,v] = isosurface(az_vol, r_vol, el_vol, swp(n).vort_vol, 0.6); %1.0
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.2)
        [f,v] = isosurface(az_vol, r_vol, el_vol, swp(n).vort_vol, 0.3); %0.5
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.1)
        [f,v] = isosurface(az_vol, r_vol, el_vol, swp(n).vort_vol, 0.0); %0.1
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
        hold off
        xlim([-0.1 0.1]) % suctvort
        
        ylim([1800 2300]) % suctvort
        
        zlim([0 5])
        xlabel('Azimuth angle (radians)')
        ylabel('Radial distance (m)')
        zlabel('Elev. angle \theta (^{o})')
        title('Vertical pseudovorticity \zeta'' isosurfaces (s^{-1})')
        legend('/zeta''=0.9s^{-1}', '\zeta''=0.6s^{-1}', '\zeta''=0.3s^{-1}', '\zeta''=0.0s^{-1}')
        grid on
        view(3)
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(tstr, 'FontSize', 14);
        axis off
        
        if nsweeps > 1 && plot_save_flag
            F = getframe(gcf);
            im = frame2im(F);
            [imind,cm] = rgb2ind(im,256);
            if n == 1
                imwrite(imind, cm, [fig_dir '/' img_name_base 'vorticity-sfc-anim.gif'],...
                    'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
            else
                imwrite(imind, cm, [fig_dir '/' img_name_base 'vorticity-sfc-anim.gif'],...
                    'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
            end
        elseif nsweeps == 1 && plot_save_flag
            print([fig_dir '/' img_name_base 'vorticity-sfc'], '-dpng')
        end
    end
    
    % GBVTD 3D wind retrieval
    if plot_flag(3)
        if ishandle(3)
            clf(3)
        end
        
        figure(3)
        axis tight manual
        c = subplot(1,3,1);
        pcolor(swp(n).axy.r, swp(n).axy.z, swp(n).axy.u)
        caxis([-1 1] * max(abs(swp(n).axy.u),[],'all'))
        colormap(c, blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('GBVTD axisymmetric radial velocity (m/s)')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(2) = subplot(1,3,2);
        pcolor(swp(n).axy.r, swp(n).axy.z, swp(n).axy.v)
        caxis([-1 1] * max(abs(swp(n).axy.v),[],'all'))
        colormap(c(2), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('GBVTD axisymmetric tangential velocity (m/s)')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(3) = subplot(1,3,3);
        pcolor(swp(n).axy.r(2:end-1,:), swp(n).axy.z(2:end-1,:), swp(n).axy.w)
        caxis([-1 1] * max(abs(swp(n).axy.w),[],'all'))
        colormap(c(3), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('GBVTD axisymmetric vertical velocity (m/s)')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.8 0.01 0.01])
        title(tstr, 'FontSize', 14);
        axis off
        % set(gcf, 'Position', [left_bound bottom_bound width height]
        set(gcf,'Units','inches','Position',[10 10 14 5])
        
        if nsweeps > 1 && plot_save_flag
            F = getframe(gcf);
            im = frame2im(F);
            [imind,cm] = rgb2ind(im,256);
            if n == 1
                imwrite(imind, cm, [fig_dir '/' img_name_base 'gbvtd-winds-anim.gif'],...
                    'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
            else
                imwrite(imind, cm, [fig_dir '/' img_name_base 'gbvtd-winds-anim.gif'],...
                    'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
            end
        elseif nsweeps == 1 && plot_save_flag
            print([fig_dir '/' img_name_base 'gbvtd-winds'], '-dpng')
        end
    end
    
    
    if LES_flag
        if ~exist([fig_dir '/LES/'], 'dir')
            mkdir([fig_dir '/LES/'])
        end
        
        % need to get timestamps to do vorticity !!!
        tind(1) = find(les.t == les.axy(n).t(1));
        tind(2) = find(les.t == les.axy(n).t(2));
        les.axy(n).vort_vol = squeeze(mean(les.vort(:,:,:,tind(1):tind(2)), 4));
        
        if plot_flag(4)
            if ishandle(4)
                clf(4)
            end
            
            figure(4)
            axis tight manual
            [f,v] = isosurface(les.x, les.y, les.z, les.axy(n).vort_vol, 1.5);
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.5)
            hold on
            [f,v] = isosurface(les.x, les.y, les.z, les.axy(n).vort_vol, 1.0);
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.2)
            [f,v] = isosurface(les.x, les.y, les.z, les.axy(n).vort_vol, 0.5);
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.1)
            [f,v] = isosurface(les.x, les.y, les.z, les.axy(n).vort_vol, 0.1);
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
            hold off
            xlim([min(les.x,[],'all') max(les.x,[],'all')])
            ylim([min(les.y,[],'all') max(les.y,[],'all')])
            zlim([min(les.z,[],'all') max(les.z,[],'all')])
            xlabel('Zonal distance (m)')
            ylabel('Meridional distance (m)')
            zlabel('Height A.G.L. (m)')
            title('LES vertical vorticity \zeta isosurfaces (s^{-1})')
            legend('\zeta=1.5s^{-1}', '\zeta=1.0s^{-1}', '\zeta=0.5s^{-1}', '\zeta=0.1s^{-1}')
            grid on
            view(3)
            axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
            title(['LES: ' sim_name], 'FontSize', 14);
            axis off
            
            if nsweeps > 1 && plot_save_flag
                F = getframe(gcf);
                im = frame2im(F);
                [imind,cm] = rgb2ind(im,256);
                if n == 1
                    imwrite(imind, cm, [fig_dir '/LES/' sim_name '_vort-sfc-anim.gif'],...
                        'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
                else
                    imwrite(imind, cm, [fig_dir '/LES/' sim_name '_vort-sfc-anim.gif'],...
                        'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
                end
            elseif nsweeps == 1 && plot_save_flag
                print([fig_dir '/LES/' sim_name '_vort-sfc'], '-dpng')
            end
        end
        
        if plot_flag(5)
            if ishandle(5)
                clf(5)
            end
            
            figure(5)
            axis tight manual
            c = subplot(1,3,1);
            pcolor(les.axy(n).r, les.axy(n).z, les.axy(n).u)
            caxis([-1 1] * max(abs(les.axy(n).u),[],'all'))
            colormap(c, blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('Axisymmetric radial velocity (m/s)')
            xlabel('Distance from LES domain center (m)')
            ylabel('Height A.G.L. (m)')
            
            c(2) = subplot(1,3,2);
            pcolor(les.axy(n).r, les.axy(n).z, les.axy(n).v)
            caxis([-1 1] * max(abs(les.axy(n).v),[],'all'))
            colormap(c(2), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('Axisymmetric tangential velocity (m/s)')
            xlabel('Distance from LES domain center (m)')
            ylabel('Height A.G.L. (m)')
            
            c(3) = subplot(1,3,3);
            pcolor(les.axy(n).r, les.axy(n).z, les.axy(n).w)
            caxis([-1 1] * max(abs(les.axy(n).w),[],'all'))
            colormap(c(3), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('Axisymmetric vertical velocity (m/s)')
            xlabel('Distance from LES domain center (m)')
            ylabel('Height A.G.L. (m)')
            
            axes('Unit', 'Normalized', 'Position', [0.5 0.8 0.01 0.01])
            title(['LES: ', sim_name], 'FontSize', 14);
            axis off
            % set(gcf, 'Position', [left_bound bottom_bound width height]
            set(gcf,'Units','inches','Position',[10 10 14 5])
            
            if nsweeps > 1 && plot_save_flag
                F = getframe(gcf);
                im = frame2im(F);
                [imind,cm] = rgb2ind(im,256);
                if n == 1
                    imwrite(imind, cm, [fig_dir '/LES/' sim_name '_axisym-wind-anim.gif'],...
                        'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
                else
                    imwrite(imind, cm, [fig_dir '/LES/' sim_name '_axisym-wind-anim.gif'],...
                        'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
                end
            elseif nsweeps == 1 && plot_save_flag
                print([fig_dir '/LES/' sim_name '_axisym-wind'], '-dpng')
            end
        end
        
        if plot_flag(6)
            if ishandle(6)
                clf(6)
            end
            
            figure(6)
            axis tight manual
            % need to improve this
            %         cax_ulim = max(max(abs(swp(n).axy.u),[],'all'), max(abs(les.axy(n).u),[],'all'));
            %         cax_vlim = max(max(abs(swp(n).axy.v),[],'all'), max(abs(les.axy(n).v),[],'all'));
            %         cax_wlim = max(max(abs(swp(n).axy.w),[],'all'), max(abs(les.axy(n).w),[],'all'));
            
            clim = 60;
            
            c = subplot(3,3,1);
            pcolor(swp(n).axy.r, swp(n).axy.z, swp(n).axy.u)
            caxis([-clim clim])
            colormap(c, blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('GBVTD axisymmetric radial velocity (m/s)')
            xlabel('Distance from tornado center (m)')
            ylabel('Height A.R.L. (m)')
            
            c(2) = subplot(3,3,2);
            pcolor(swp(n).axy.r, swp(n).axy.z, swp(n).axy.v)
            caxis([-clim clim])
            colormap(c(2), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('GBVTD axisymmetric tangential velocity (m/s)')
            xlabel('Distance from tornado center (m)')
            ylabel('Height A.R.L. (m)')
            
            c(3) = subplot(3,3,3);
            pcolor(swp(n).axy.r(2:end-1,:), swp(n).axy.z(2:end-1,:), swp(n).axy.w)
            caxis([-clim clim])
            colormap(c(3), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('GBVTD axisymmetric vertical velocity (m/s)')
            xlabel('Distance from tornado center (m)')
            ylabel('Height A.R.L. (m)')
            
            c(4) = subplot(3,3,4);
            pcolor(les.axy(n).r, les.axy(n).z, les.axy(n).u)
            caxis([-clim clim])
            colormap(c(4), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('LES axisymmetric radial velocity (m/s)')
            xlabel('Distance from LES domain center (m)')
            ylabel('Height A.G.L. (m)')
            
            c(5) = subplot(3,3,5);
            pcolor(les.axy(n).r, les.axy(n).z, les.axy(n).v)
            caxis([-clim clim])
            colormap(c(5), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('LES axisymmetric tangential velocity (m/s)')
            xlabel('Distance from LES domain center (m)')
            ylabel('Height A.G.L. (m)')
            
            c(6) = subplot(3,3,6);
            pcolor(les.axy(n).r, les.axy(n).z, les.axy(n).w)
            caxis([-clim clim])
            colormap(c(6), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('LES axisymmetric vertical velocity (m/s)')
            xlabel('Distance from LES domain center (m)')
            ylabel('Height A.G.L. (m)')
            
            c(7) = subplot(3,3,7);
            r_dim = min([size(swp(n).axy.u,1), size(les.axy(n).u,1)]);
            rmean = (swp(n).axy.r(1:r_dim,:) + les.axy(n).r(1:r_dim,:)) / 2;
            zmean = (swp(n).axy.z(1:r_dim,:) + les.axy(n).z(1:r_dim,:)) / 2;
            udiff = swp(n).axy.u(1:r_dim,:) - les.axy(n).u(1:r_dim,:);
            pcolor(rmean, zmean, udiff)
            %         pcolor(swp(n).axy.r, swp(n).axy.z, swp(n).axy.u - ugrid)
            colormap(c(7), blib('rbmap'))
            caxis([-clim clim])
            colorbar
            shading flat
            axis square
            title('\DeltaU_{r}=U_r^{GBVTD}-U_r^{LES} (m/s)')
            xlabel('Distance from tornado center (m)')
            ylabel('Height A.G.L. (m)')
            
            c(8) = subplot(3,3,8);
            vdiff = swp(n).axy.v(1:r_dim,:) - les.axy(n).v(1:r_dim,:);
            pcolor(rmean, zmean, vdiff)
            %         pcolor(swp(n).axy.r, swp(n).axy.z, swp(n).axy.v - vgrid)
            caxis([-clim clim])
            colormap(c(8), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('\DeltaV_{r}=V_r^{GBVTD}-V_r^{LES} (m/s)')
            xlabel('Distance from tornado center (m)')
            ylabel('Height A.G.L. (m)')
            
            c(9) = subplot(3,3,9);
            wdiff = swp(n).axy.w(2:r_dim-1,:) - les.axy(n).w(2:r_dim-1,:);
            pcolor(rmean(2:end-1,:), zmean(2:end-1,:), wdiff)
            %         pcolor(swp(n).axy.r(2:end-1,:), swp(n).axy.z(2:end-1,:), swp(n).axy.w - wgrid(2:end-1,:))
            caxis([-clim clim])
            colormap(c(9), blib('rbmap'))
            colorbar
            shading flat
            axis square
            title('\DeltaW_{r}=W_r^{GBVTD}-W_r^{LES} (m/s)')
            xlabel('Distance from tornado center (m)')
            ylabel('Height A.G.L. (m)')
            
            
            axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
            title(tstr, 'FontSize', 14);
            axis off
            % set(gcf, 'Position', [left_bound bottom_bound width height]
            set(gcf,'Units','inches','Position',[10 10 14 12])
            
            if nsweeps > 1 && plot_save_flag
                F = getframe(gcf);
                im = frame2im(F);
                [imind,cm] = rgb2ind(im,256);
                if n == 1
                    imwrite(imind, cm, [fig_dir '/' img_name_base sim_name '_gbvtd-compare-anim.gif'],...
                        'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
                else
                    imwrite(imind, cm, [fig_dir '/' img_name_base sim_name '_gbvtd-compare-anim.gif'],...
                        'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
                end
            elseif nsweeps == 1 && plot_save_flag
                print([fig_dir '/' img_name_base sim_name '_gbvtd-compare'], '-dpng')
            end
        end
    end
end

return

%% Average over all sweeps

if nsweeps > 1
    
    avg = struct('swp', [], 'les', [], 'cmp', []);
    
    
    dv = zeros(nsweeps, nels);
    dv90 = dv;
    dv75 = dv;
    vort_vol = zeros(length(r), length(az_rad), nels, nsweeps);
    
    if LES_flag
        r_dim = min([size(swp(1).axy.r,1), size(les.axy(1).r,1)]);
    else
        r_dim = size(swp(1).axy.r,1);
    end
    
    u_axy = zeros(r_dim, nels, nsweeps);
    v_axy = u_axy;
    w_axy = u_axy(1:end-1,:,:);
    r_axy = u_axy;
    z_axy = u_axy;
    if LES_flag
        u_les = u_axy;
        v_les = u_axy;
        w_les = u_axy;
        r_les = u_axy;
        z_les = u_axy;
        vort_les = zeros(size(les.x,1), size(les.x,2), size(les.x,3), nsweeps);
    end
    
    for n = 1:nsweeps
        dv(n,:) = swp(n).deltav;
        dv90(n,:) = swp(n).deltav90;
        dv75(n,:) = swp(n).deltav75;
        vort_vol(:,:,:,n) = swp(n).vort_vol;
        
        u_axy(:,:,n) = swp(n).axy.u(1:r_dim,:);
        v_axy(:,:,n) = swp(n).axy.v(1:r_dim,:);
        w_axy(:,:,n) = swp(n).axy.w(1:r_dim-1,:);
        r_axy(:,:,n) = swp(n).axy.r(1:r_dim,:);
        z_axy(:,:,n) = swp(n).axy.z(1:r_dim,:);
        
        if LES_flag
            u_les(:,:,n) = les.axy(n).u(1:r_dim,:);
            v_les(:,:,n) = les.axy(n).v(1:r_dim,:);
            w_les(:,:,n) = les.axy(n).w(1:r_dim,:);
            r_les(:,:,n) = les.axy(n).r(1:r_dim,:);
            z_les(:,:,n) = les.axy(n).z(1:r_dim,:);
            
            vort_les(:,:,:,n) = les.axy(n).vort_vol;
        end
    end
    avg.swp = struct('r', [], 'z', [], 'u', [], 'v', [], 'w', [], ...
        'els', [], 'dv', [], 'vort', [], 'az_vol', az_vol, ...
        'r_vol', r_vol, 'el_vol', el_vol);
    
    avg.swp.els = swp(1).el;
    avg.swp.dv_err = std(dv,1);
    avg.swp.dv = squeeze(mean(dv,1));
    avg.swp.dv_max = squeeze(max(dv,[],1));
    avg.swp.dv_min = squeeze(min(dv,[],1));
    avg.swp.dv90 = squeeze(mean(dv90,1));
    avg.swp.dv75 = squeeze(mean(dv75,1));
    
    avg.swp.vort = squeeze(mean(vort_vol, 4));
    avg.swp.vort_max = squeeze(max(vort_vol, 4));
    avg.swp.vort_min = squeeze(min(vort_vol, 4));
    
    avg.swp.r = squeeze(mean(r_axy, 3));
    avg.swp.z = squeeze(mean(z_axy, 3));
    avg.swp.u = squeeze(mean(u_axy, 3));
    avg.swp.v = squeeze(mean(v_axy, 3));
    avg.swp.w = squeeze(mean(w_axy, 3));
    
    
    %---Turn this into a table---%
    
    UT = VelStatsMakeTable(avg.swp.r, u_axy);
    VT = VelStatsMakeTable(avg.swp.r, v_axy);
    WT = VelStatsMakeTable(avg.swp.r(1:r_dim-1,:), w_axy);
    
    vars = {{'Mean_050deg','Max_050deg','Min_050deg','ErrorL_050deg','ErrorU_050deg'},...
        {'Mean_045deg','Max_045deg','Min_045deg','ErrorL_045deg','ErrorU_045deg'},...
        {'Mean_040deg','Max_040deg','Min_040deg','ErrorL_040deg','ErrorU_040deg'},...
        {'Mean_035deg','Max_035deg','Min_035deg','ErrorL_035deg','ErrorU_035deg'},...
        {'Mean_030deg','Max_030deg','Min_030deg','ErrorL_030deg','ErrorU_030deg'},...
        {'Mean_025deg','Max_025deg','Min_025deg','ErrorL_025deg','ErrorU_025deg'},...
        {'Mean_020deg','Max_020deg','Min_020deg','ErrorL_020deg','ErrorU_020deg'},...
        {'Mean_015deg','Max_015deg','Min_015deg','ErrorL_015deg','ErrorU_015deg'},...
        {'Mean_010deg','Max_010deg','Min_010deg','ErrorL_010deg','ErrorU_010deg'},...
        {'Mean_005deg','Max_005deg','Min_005deg','ErrorL_005deg','ErrorU_005deg'}};
    
    if LES_flag
        r_les = squeeze(mean(r_les, 3));
        z_les = squeeze(mean(z_les, 3));
        r_mean = (avg.swp.r + r_les) / 2;
        z_mean = (avg.swp.z + z_les) / 2;
        
        u_diff = u_axy - u_les;
        v_diff = v_axy - v_les;
        w_diff = w_axy - w_les(1:r_dim-1,:,:);
        
        u_diff_mean = squeeze(mean(u_axy - u_les, 3));
        v_diff_mean = squeeze(mean(v_axy - v_les, 3));
        w_diff_mean = squeeze(mean(w_axy - w_les(1:r_dim-1,:,:), 3));
        
        UdiffT = VelStatsMakeTable(r_mean, u_diff);
        VdiffT = VelStatsMakeTable(r_mean, v_diff);
        WdiffT = VelStatsMakeTable(r_mean(1:r_dim-1,:), w_diff);
        
        u_les = squeeze(mean(u_les, 3));
        v_les = squeeze(mean(v_les, 3));
        w_les = squeeze(mean(w_les, 3));
        
        vort_les_max = squeeze(max(vort_les, 4));
        vort_les_min = squeeze(min(vort_les, 4));
        vort_les = squeeze(mean(vort_les, 4));
        
        avg.les = struct('r', r_les, 'z', z_les, 'u', u_les, 'v', v_les, 'w', w_les, ...
            'vort', vort_les, 'x_vol', les.x, 'y_vol', les.y, 'z_vol', les.z);
        avg.cmp = struct('r', r_mean, 'z', z_mean, 'u', u_diff_mean, 'v', v_diff_mean, ...
            'w', w_diff_mean);
    end
    
    
    
    if plot_flag(1)
        
        figure(7)
        axis tight manual
        errorbar(avg.swp.dv, avg.swp.els, avg.swp.dv_err, 'horizontal')
        hold on
            plot(avg.swp.dv_max, avg.swp.els, '.k')
            plot(avg.swp.dv_min, avg.swp.els, '.k')
        hold off
        xlabel('$\overline{\DeltaV_{max}} (m/s)$', 'Interpreter', 'Latex')
        ylabel('Elev. angle \theta (^{o})')
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(str, 'FontSize', 14);
        axis off
        
        if plot_save_flag
            print([fig_dir '/' img_name_base 'deltaV-height-mean'], '-dpng')
        end
    end
    
    
    if plot_flag(2)
        
        figure(8)
        axis tight manual
        [f,v] = isosurface(avg.swp.az_vol, avg.swp.r_vol, avg.swp.el_vol, avg.swp.vort, 0.9); %1.5
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.5)
        hold on
            [f,v] = isosurface(avg.swp.az_vol, avg.swp.r_vol, avg.swp.el_vol, avg.swp.vort, 0.6); %1.0
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.2)
            [f,v] = isosurface(avg.swp.az_vol, avg.swp.r_vol, avg.swp.el_vol, avg.swp.vort, 0.3); %0.5
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.1)
            [f,v] = isosurface(avg.swp.az_vol, avg.swp.r_vol, avg.swp.el_vol, avg.swp.vort, 0.0); %0.1
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
        hold off
        
        xlim([-0.1 0.1]) % suctvort
        ylim([1800 2300]) % suctvort
        zlim([0 5])
        xlabel('Azimuth angle (radians)')
        ylabel('Radial distance (m)')
        zlabel('Elev. angle \theta (^{o})')
        title('$\overline{\zeta''} isosurfaces (s^{-1})$', 'Interpreter', 'Latex')
        legend('0.9 s^{-1}', '0.6 s^{-1}', '0.3 s^{-1}', '0.0 s^{-1}')
        grid on
        view(3)
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(str, 'FontSize', 14);
        axis off
        
        if plot_save_flag
            print([fig_dir '/' img_name_base 'vorticity-sfc-mean'], '-dpng')
        end
    end
    
    
    if plot_flag(3)
        
        figure(9)
        axis tight manual
        c = subplot(1,3,1);
        pcolor(avg.swp.r, avg.swp.z, avg.swp.u)
        caxis([-1 1] * max(abs(avg.swp.u),[],'all'))
        colormap(c, blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{U_{GBVTD}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(2) = subplot(1,3,2);
        pcolor(avg.swp.r, avg.swp.z, avg.swp.v)
        caxis([-1 1] * max(abs(avg.swp.v),[],'all'))
        colormap(c(2), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{V_{GBVTD}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(3) = subplot(1,3,3);
        pcolor(avg.swp.r(1:end-1,:), avg.swp.z(1:end-1,:), avg.swp.w)
        caxis([-1 1] * max(abs(avg.swp.w),[],'all'))
        colormap(c(3), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{W_{GBVTD}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.8 0.01 0.01])
        title(str, 'FontSize', 14);
        axis off
        % set(gcf, 'Position', [left_bound bottom_bound width height]
        set(gcf,'Units','inches','Position',[10 10 14 5])
        
        if plot_save_flag
            print([fig_dir '/' img_name_base 'gbvtd-winds-mean'], '-dpng')
        end
        
        % mean, max, min, err
        
        
%         figure(10)
%         axis tight manual
%         subplot(1,3,1)
%         s = stackedplot(UT,vars,'XVariable','RadialDistance','Title','U stats');
%         for el = 1:nels
%             s.LineProperties(el).PlotType = 'plot';
%             s.LineProperties(el).LineStyle = {'-', '-.', '-.', 'none', 'none'};
%             s.LineProperties(el).Color = [0 0 1];
%             s.LineProperties(el).Marker = {'none', 'none', 'none', 'o', 'o'};
%             s.LineProperties(el).MarkerFaceColor = [1 1 1];
%             s.LineProperties(el).MarkerEdgeColor = [0 0 0];
%             h = findobj(gca,'Type','legend');
%             set(h,'visible','off')
%         end
%         
%         subplot(1,3,2)
%         s(2) = stackedplot(VT,vars,'XVariable','RadialDistance','Title','V stats');
%         for el = 1:nels
%             s(2).LineProperties(el).PlotType = 'plot';
%             s(2).LineProperties(el).LineStyle = {'-', '-.', '-.', 'none', 'none'};
%             s(2).LineProperties(el).Color = [0 0 1];
%             s(2).LineProperties(el).Marker = {'none', 'none', 'none', 'o', 'o'};
%             s(2).LineProperties(el).MarkerFaceColor = [1 1 1];
%             s(2).LineProperties(el).MarkerEdgeColor = [0 0 0];
%             h = findobj(gca,'Type','legend');
%             set(h,'visible','off')
%         end
%         
%         subplot(1,3,3)
%         s(3) = stackedplot(WT,vars,'XVariable','RadialDistance','Title','W stats');
%         for el = 1:nels
%             s(3).LineProperties(el).PlotType = 'plot';
%             s(3).LineProperties(el).LineStyle = {'-', '-.', '-.', 'none', 'none'};
%             s(3).LineProperties(el).Color = [0 0 1];
%             s(3).LineProperties(el).Marker = {'none', 'none', 'none', 'o', 'o'};
%             s(3).LineProperties(el).MarkerFaceColor = [1 1 1];
%             s(3).LineProperties(el).MarkerEdgeColor = [0 0 0];
%             h = findobj(gca,'Type','legend');
%             set(h,'visible','off')
%         end
%         
%         axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
%         title(str, 'FontSize', 14);
%         axis off
%         % set(gcf, 'Position', [left_bound bottom_bound width height]
%         set(gcf,'Units','inches','Position',[10 10 14 5])
%
%         if plot_save_flag
%             print([fig_dir '/' img_name_base 'gbvtd-stats'], '-dpng')
%         end

    end
    
    
    if plot_flag(4) && LES_flag
        
        figure(10)
        axis tight manual
        [f,v] = isosurface(les.x, les.y, les.z, vort_les, 1.5);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.5)
        hold on
            [f,v] = isosurface(les.x, les.y, les.z, vort_les, 1.0);
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.2)
            [f,v] = isosurface(les.x, les.y, les.z, vort_les, 0.5);
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.1)
            [f,v] = isosurface(les.x, les.y, les.z, vort_les, 0.1);
            patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
        hold off
        
        xlim([min(les.x,[],'all') max(les.x,[],'all')])
        ylim([min(les.y,[],'all') max(les.y,[],'all')])
        zlim([min(les.z,[],'all') max(les.z,[],'all')])
        xlabel('Zonal distance (m)')
        ylabel('Meridional distance (m)')
        zlabel('Height A.G.L. (m)')
        title('$\overline{\zeta} isosurfaces (s^{-1})$', 'Interpreter', 'Latex')
        legend('1.5 s^{-1}', '1.0 s^{-1}', '0.5 s^{-1}', '0.1 s^{-1}')
        grid on
        view(3)
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['LES: ' sim_name], 'FontSize', 14);
        axis off
        
        if plot_save_flag
            print([fig_dir '/LES/' sim_name '_vort-sfc-mean'], '-dpng')
        end
    end
    
    
    if plot_flag(5) && LES_flag
        
        figure(11)
        axis tight manual
        c = subplot(1,3,1);
        pcolor(r_les, z_les, u_les)
        caxis([-1 1] * max(abs(u_les),[],'all'))
        colormap(c, blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{U_{r}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from LES domain center (m)')
        ylabel('Height A.G.L. (m)')
        
        c(2) = subplot(1,3,2);
        pcolor(r_les, z_les, v_les)
        caxis([-1 1] * max(abs(v_les),[],'all'))
        colormap(c(2), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{V_{r}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from LES domain center (m)')
        ylabel('Height A.G.L. (m)')
        
        c(3) = subplot(1,3,3);
        pcolor(r_les, z_les, w_les)
        caxis([-1 1] * max(abs(w_les),[],'all'))
        colormap(c(3), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{W_{r}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from LES domain center (m)')
        ylabel('Height A.G.L. (m)')
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.8 0.01 0.01])
        title(['LES: ', sim_name], 'FontSize', 14);
        axis off
        % set(gcf, 'Position', [left_bound, bottom_bound, width, height]
        set(gcf, 'Units', 'inches', 'Position', [10 10 14 5])
        
        if plot_save_flag
            print([fig_dir '/LES/' sim_name '_axisym-wind-mean'], '-dpng')
        end
    end
    
    
    if plot_flag(6) && LES_flag
        
        figure(12)
        axis tight manual
        c = subplot(3,3,1);
        pcolor(avg.swp.r, avg.swp.z, avg.swp.u)
        caxis([-1 1] * max(abs(avg.swp.u),[],'all'))
        colormap(c, blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{U_{GBVTD}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(2) = subplot(3,3,2);
        pcolor(avg.swp.r, avg.swp.z, avg.swp.v)
        caxis([-1 1] * max(abs(avg.swp.v),[],'all'))
        colormap(c(2), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{V_{GBVTD}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(3) = subplot(3,3,3);
        pcolor(avg.swp.r(1:end-1,:), avg.swp.z(1:end-1,:), avg.swp.w)
        caxis([-1 1] * max(abs(avg.swp.w),[],'all'))
        colormap(c(3), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{W_{GBVTD}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(4) = subplot(3,3,4);
        pcolor(r_les, z_les, u_les)
        caxis([-1 1] * max(abs(u_les),[],'all'))
        colormap(c(4), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{U_{LES}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(5) = subplot(3,3,5);
        pcolor(r_les, z_les, v_les)
        caxis([-1 1] * max(abs(v_les),[],'all'))
        colormap(c(5), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{V_{LES}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(6) = subplot(3,3,6);
        pcolor(r_les, z_les, w_les)
        caxis([-1 1] * max(abs(w_les),[],'all'))
        colormap(c(6), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{W_{LES}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(7) = subplot(3,3,7);
        pcolor(r_mean, z_mean, u_diff_mean)
        caxis([-1 1] * max(abs(u_diff_mean),[],'all'))
        colormap(c(7), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{{\Delta}U_{GBVTD-LES}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(8) = subplot(3,3,8);
        pcolor(r_mean, z_mean, v_diff_mean)
        caxis([-1 1] * max(abs(v_diff_mean),[],'all'))
        colormap(c(8), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{{\Delta}V_{GBVTD-LES}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        c(9) = subplot(3,3,9);
        pcolor(r_mean(1:end-1,:), z_mean(1:end-1,:), w_diff_mean)
        caxis([-1 1] * max(abs(w_diff_mean),[],'all'))
        colormap(c(9), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('$\overline{{\Delta}W_{GBVTD-LES}} (m/s)$', 'Interpreter', 'Latex')
        xlabel('Distance from tornado center (m)')
        ylabel('Height A.R.L. (m)')
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(str, 'FontSize', 14);
        axis off
        % set(gcf, 'Position', [left_bound bottom_bound width height]
        set(gcf,'Units','inches','Position',[10 10 14 12])
        
        if plot_save_flag
            print([fig_dir '/' img_name_base sim_name '_gbvtd-compare-mean'], '-dpng')
        end
        
        
%         figure(13)
%         axis tight manual
%         s = stackedplot(UdiffT,vars,'XVariable','RadialDistance','Title','\DeltaU stats');
%         for el = 1:nels
%             s.LineProperties(el).PlotType = 'plot';
%             s.LineProperties(el).LineStyle = {'-', ':', ':', 'none', 'none'};
%             s.LineProperties(el).Color = [0 0 1];
%             s.LineProperties(el).Marker = {'none', 'none', 'none', 'o', 'o'};
%             s.LineProperties(el).MarkerFaceColor = [1 1 1];
%             s.LineProperties(el).MarkerEdgeColor = [0 0 0];
%         end
%         
%         axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
%         title(str, 'FontSize', 14);
%         axis off
%         % set(gcf, 'Position', [left_bound bottom_bound width height]
%         set(gcf,'Units','inches','Position',[10 10 14 5])
%         
%         if plot_save_flag
%             print([fig_dir '/' img_name_base sim_name '_gbvtd-compare-ustats'], '-dpng')
%         end
%         
%         figure(14)
%         axis tight manual
%         s = stackedplot(VdiffT,vars,'XVariable','RadialDistance','Title','\DeltaV stats');
%         for el = 1:nels
%             s.LineProperties(el).PlotType = 'plot';
%             s.LineProperties(el).LineStyle = {'-', ':', ':', 'none', 'none'};
%             s.LineProperties(el).Color = [0 0 1];
%             s.LineProperties(el).Marker = {'none', 'none', 'none', 'o', 'o'};
%             s.LineProperties(el).MarkerFaceColor = [1 1 1];
%             s.LineProperties(el).MarkerEdgeColor = [0 0 0];
%         end
%         
%         axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
%         title(str, 'FontSize', 14);
%         axis off
%         % set(gcf, 'Position', [left_bound bottom_bound width height]
%         set(gcf,'Units','inches','Position',[10 10 14 5])
%         
%         if plot_save_flag
%             print([fig_dir '/' img_name_base sim_name '_gbvtd-compare-vstats'], '-dpng')
%         end
%         
%         figure(15)
%         axis tight manual
%         s = stackedplot(WdiffT,vars,'XVariable','RadialDistance','Title','\DeltaW stats');
%         for el = 1:nels
%             s.LineProperties(el).PlotType = 'plot';
%             s.LineProperties(el).LineStyle = {'-', ':', ':', 'none', 'none'};
%             s.LineProperties(el).Color = [0 0 1];
%             s.LineProperties(el).Marker = {'none', 'none', 'none', 'o', 'o'};
%             s.LineProperties(el).MarkerFaceColor = [01 1 1];
%             s.LineProperties(el).MarkerEdgeColor = [0 0 0];
%         end
%         
%         axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
%         title(str, 'FontSize', 14);
%         axis off
%         % set(gcf, 'Position', [left_bound bottom_bound width height]
%         set(gcf,'Units','inches','Position',[10 10 14 5])
%         
%         if plot_save_flag
%             print([fig_dir '/' img_name_base sim_name '_gbvtd-compare-wstats'], '-dpng')
%         end
    end
end



external_call = external_call_main;

if var_save_flag
    cd(save_dir)
    
    if isempty(dnum)
        dnum = 'd';
    end
    
    if LES_flag && nsweeps > 1
        save(['n' num2str(dnum) '_' concept '_volume-stats.mat'], 'data', 'swp', 'les', 'avg')
    elseif LES_flag && nsweeps == 1
        save(['n' num2str(dnum) '_' concept '_volume-stats.mat'], 'data', 'swp', 'les')
    elseif ~LES_flag && nsweeps > 1
        save(['n' num2str(dnum) '_' concept '_volume-stats.mat'], 'data', 'swp', 'avg')
    else
        save(['n' num2str(dnum) '_' concept '_volume-stats.mat'], 'data', 'swp')
    end
    
    cd ~
end

