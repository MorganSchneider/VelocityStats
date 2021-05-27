% A convenient script to browse and proecess an iq data file from the
% simulator
%
% Boon Leng Cheong
% Advanced Radar Research Center
% University of Oklahoma
% 2/9/2016


[st,~] = dbstack('-completenames');
if length(st) > 1
    external_call = 1;
else
    external_call = 0;
end


%---If running checkiq.m on its own---%
if ~external_call
    base_dir = '/Users/schneider/Documents/'; % Set to the directory where you run the script
    fig_dir = [base_dir 'imgs']; % Figure output directory
    dir_loc = [base_dir 'sims']; % Location of the IQ data
    % addpath('/Users/schneider/Documents/simradar/');
    sim_dir = uigetdir(dir_loc);
    
    if ~exist('iq_plot_flag', 'var')
        iq_plot_flag = 0;
    end
    if ~exist('iq_save_flag', 'var')
        iq_save_flag = 1;
    end
%---If calling checkiq.m from another script---%
else
    if ~exist('iq_plot_flag', 'var')
        iq_plot_flag = 0;
    end
    if ~exist('iq_save_flag', 'var')
        iq_save_flag = 1;
    end
end

if ~exist('skipload', 'var')
    if ~external_call
        if exist('~/Downloads/density', 'dir')
            filename = blib('choosefile', dirlist, '*.iq');
        else
            filename = blib('choosefile', sim_dir, '*.iq');
        end
    end
    
    if ~isempty(filename)
        dat = simradariq(filename);
    else
        disp('This file is empty, moron!')
        return
    end
end

rho_clims = [0.4, 1];
zdr_clims = [-5, 5];


% Sector width
sec = abs(dat.params.scan_end - dat.params.scan_start);
np_per_deg = 1.0 / dat.params.scan_delta;

% Number of pulses per ray
np = round(0.5 * np_per_deg);

fprintf('Using %d pulses per ray (%.1f deg)\n', np, np / np_per_deg);

% Total number of samples in the file
ns = numel(dat.az_deg);

% Maximum number of rays resulted
nray = floor(ns / np);

% Number of pulses per sweep
pps = (dat.params.scan_end - dat.params.scan_start) / dat.params.scan_delta;
if strcmp(dat.params.scan_mode, 'PPI')
    nrs = floor(pps / np);
else
    nrs = floor(pps / np);
end

% Number of sweeps in the file
nsweep = floor(nray / nrs);

%% Gather the scan attributes and data
az_rad = deg2rad(dat.az_deg(1 : np : np * nrs));
el_rad = deg2rad(dat.el_deg(1 : np : np * nrs));
r = (0 : dat.params.range_count - 1) * dat.params.range_delta + dat.params.range_start;
el = deg2rad(dat.el_deg(1));

iqh = reshape(dat.iqh(:, 1:nsweep * nrs * np), [dat.params.range_count, np, nrs, nsweep]);
iqh = permute(iqh, [1 3 2 4]);
iqv = reshape(dat.iqv(:, 1:nsweep * nrs * np), [dat.params.range_count, np, nrs, nsweep]);
iqv = permute(iqv, [1 3 2 4]);

% Some moment products
sh = real(mean(iqh .* conj(iqh), 3));
sv = real(mean(iqv .* conj(iqv), 3));
vr = -dat.params.va / pi * angle(mean(iqh(:, :, 2:end,:) .* conj(iqh(:, :, 1:end-1,:)), 3));
mh = repmat(mean(iqh, 3), [1 1 np 1]);
mv = repmat(mean(iqv, 3), [1 1 np 1]);
sh_ac = mean((iqh - mh) .* conj(iqh - mh), 3);
sv_ac = mean((iqv - mv) .* conj(iqv - mv), 3);

rhohv = abs(mean((iqh - mh) .* conj(iqv - mv), 3)) ./ sqrt(sh_ac .* sv_ac);

% Signal in dB, zdr in dB
sh = 10 * log10(squeeze(sh));
sv = 10 * log10(squeeze(sv));
vr = squeeze(vr);
rhohv = squeeze(rhohv);
zdr = sh - sv;

% Corrections factor to normalize tx power, Gt, Gr, lambda, etc.
zcor =  -10 * log10(dat.params.tx_power_watt) - dat.params.antenna_gain_dbi;

% Range correction for z like
rcor = 10 * log10(r(:) .^ 2);
rcor = repmat(rcor, [1 numel(az_rad) nsweep]);

% Now we apply the range correction factor and z correction factor
zh = sh + rcor + zcor;
zv = sv + rcor + zcor;


%% Moment plots

if strcmp(dat.params.scan_mode, 'PPI')
    [az_mat, r_mat] = meshgrid(az_rad, r);
    
    xx = r_mat .* sin(az_mat) * cos(el);
    yy = r_mat .* cos(az_mat) * cos(el);
    zz = r_mat * sin(el);
    
elseif strcmp(dat.params.scan_mode, 'RHI')
    [el_mat, r_mat] = meshgrid(el_rad, r);
    
    xx = r_mat .* cos(el_mat);
    zz = r_mat .* sin(el_mat);
end

if iq_plot_flag
    
    figure()
    
    if strcmp(dat.params.scan_mode, 'PPI')
        
        ha = subplot(2,2,1);
        hs = pcolor(xx, yy, zh(:,:,1));
        set(gca, 'DataAspect', [1 1 1])
        caxis([0 80])
        colormap(ha, blib('zmap'))
        shading flat
        colorbar
        set(gca, 'YDir', 'Normal')
        title('Z - Reflectivity (dBZ)')
        
        ha(2) = subplot(2,2,2);
        hs(2) = pcolor(xx, yy, vr(:,:,1));
        % caxis([-1 1] * dat.params.va)
        caxis([-1 1] * round(max(max(abs(vr(:,:,1)))), -1));
        colormap(ha(2), blib('rgmap2'))
        shading flat
        colorbar
        title('V - Velocity (m/s)')
        
        ha(3) = subplot(2,2,3);
        hs(3) = pcolor(xx, yy, zdr(:,:,1));
        colormap(ha(3), blib('nwsdmap'))
        colorbar
        caxis(zdr_clims)
        shading flat
        title('D - Differential Reflectivity (dB)')
        
        ha(4) = subplot(2,2,4);
        hs(4) = pcolor(xx, yy, real(rhohv(:,:,1)));
        colormap(ha(4), blib('nwsrmap'))
        colorbar
        caxis(rho_clims)
        shading flat
        title('R - RhoHV')
        
        
        set(ha, 'DataAspect', [1 1 1])
        
        
    elseif strcmp(dat.params.scan_mode, 'RHI')
        
        ha = subplot(2,2,1);
        hs = pcolor(xx, zz, zh(:,:,1));
        caxis([0 80])
        colormap(ha, blib('zmap'))
        colorbar
        shading flat
        set(gca, 'YDir', 'Normal')
        title('Z - Reflectivity (dBZ)')
        
        ha(2) = subplot(2,2,2);
        hs(2) = pcolor(xx, zz, vr(:,:,1));
        % caxis([-1 1] * dat.params.va)
        caxis([-1 1] * round(max(max(abs(vr(:,:,1)))), -1));
        colormap(ha(2), blib('rgmap2'))
        colorbar
        shading flat
        title('V - Velocity (m/s)')
        
        
        ha(3) = subplot(2,2,3);
        hs(3) = pcolor(xx, zz, zdr(:,:,1));
        set(gca, 'DataAspect', [1 1 1])
        colormap(ha(3), blib('nwsdmap'))
        colorbar
        shading flat
        caxis(zdr_clims)
        title('D - Differential Reflectivity (dB)')
        
        ha(4) = subplot(2,2,4);
        hs(4) = pcolor(xx, zz, real(rhohv(:,:,1)));
        colormap(ha(4), blib('nwsrmap'))
        colorbar
        caxis(rho_clims)
        shading flat
        title('R - RhoHV')
        
        set(ha, 'DataAspect', [1 1 1])
    else
        fprintf('Not a scan mode I know how to plot.\n');
    end
end

axes('Unit', 'Normalized', 'Position', [0.5 0.94 0.01 0.01])
title_str = filename(max(size(sim_dir)) + 1:max(size(filename)));
tstr = sprintf('%s', title_str);

if dat.debris_counts(3) > 0
    tstr = sprintf('%s (D = %.1f, w = %d, d = [%d %d])', tstr, dat.params.body_per_cell, dat.debris_counts(1:3));
    fig_name = [title_str '_' num2str(dat.params.body_per_cell) '_' num2str(dat.debris_counts(1)) '_' num2str(dat.debris_counts(2)) '_' num2str(dat.debris_counts(3))];
elseif dat.debris_counts(2) > 0
    tstr = sprintf('%s (D = %.1f, w = %d, d = [%d])', tstr, dat.params.body_per_cell, dat.debris_counts(1:2));
    fig_name = [title_str '_' num2str(dat.params.body_per_cell) '_' num2str(dat.debris_counts(1)) '_' num2str(dat.debris_counts(2))];
else
    tstr = sprintf('%s (D = %.1f, w = %d, no debris)', tstr, dat.params.body_per_cell, dat.debris_counts(1));
    fig_name = [title_str '_' num2str(dat.params.body_per_cell) '_' num2str(dat.debris_counts(1))];
end

if iq_plot_flag
    %title(tstr, 'FontSize', 14);
    axis off
    
    blib('bsizewin', gcf, [1400 700])
    set(gcf, 'PaperPositionMode', 'Auto')
    cd(fig_dir)
    print(fig_name, '-dpng')
    cd(base_dir)
    shg
end


%%

if iq_plot_flag && nsweep > 1
    for ii = 1:nsweep
        set(hs(1), 'CData', zh(:,:,ii))
        set(hs(2), 'CData', vr(:,:,ii))
        % set(hs(3), 'CData', zdr_ind(:,:,ii))
        % set(hs(4), 'CData', rhohv_ind(:,:,ii))
        set(hs(3), 'CData', zdr(:,:,ii))
        set(hs(4), 'CData', rhohv(:,:,ii))
        % pause(0.15)
        cd(fig_dir)
        % print([fig_name '_' num2str(ii)], '-dpng', '-r0');
        cd(base_dir)
    end
    pause(0.75)
end

% if class_save
%     param = dat.params;
%     iqh = dat.iqh;
%     iqv = dat.iqv;
%     az_deg_iq = dat.az_deg;
%     el_deg_iq = dat.el_deg;
%     scan_time_iq = dat.scan_time;
%     moms.zh = zh;
%     moms.zv = zv;
%     moms.zdr = zdr;
%     moms.rhohv = rhohv;
%     moms.vr = vr;
%     moms.az_rad = az_rad;
%     moms.el_rad = el_rad;
%     moms.range = r_mat;
%     moms.xx = xx;
%     moms.yy = yy;
%     moms.zz = zz;
%     
%     eval('cd class_proj')
%     save(['rs_' deb_title '_' num2str(roundn(el*180/pi,-1)) '.mat'], 'param', 'iqh', 'iqv', 'az_deg_iq', 'el_deg_iq', ...
%         'scan_time_iq', 'moms');
%     eval('cd ..')
% end


if iq_save_flag
    save([sim_dir title_str(1:end-3) '.mat'], 'dat', 'az_rad', 'r', 'el_rad', 'iqh', 'iqv', 'zh', 'zv', 'vr', 'zdr', 'rhohv', 'xx', 'yy', 'zz');
    clear dat az_rad r el_rad iqh iqv zh zv vr zdr rhohv xx yy zz
end

