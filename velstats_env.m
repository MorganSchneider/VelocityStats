%% set flags and run sims
% Outer script for velocitystats.m
clear
close all

new_sims_flag = 0; % Generate the volume-stats.mat files if they don't already exist
seminar_figs_flag = 0; % Make nicer plots for presentations
thesis_figs_flag = 0; % Make nicer plots for thesis
article_figs_flag = 1; % Make beautiful amazing plots for article
plot_save = 1; % Flag each figure to save: 1=yes, 0=no
% 1 - delta V profiles
% 2 - GBVTD
% 3 - Bulk correlation scatter
% 4 - Bulk correlation 2D histogram colorfill

% sim_bases: suctvort, suctvort_large, onecell, twocell, torgen
% sim_dates: 200116, 200122, 200708/210604, 210614, 200622
sim_base = 'twocell';
sim_date = '210614';
%dd_date = '210614';
%nd_date = '211005';
base_dir = '/Users/schneider/Documents/'; % Directory where you run the script
dir_loc = [base_dir 'sims']; % SimRadar output directory

dtypes = 1:4;
dnums = [10000 100000];
dexp = length(num2str(dnums(1))) - 2;
nd_concept = 'U';
dd_concept = 'DCU';

if new_sims_flag
    
    iq_plot_flag = 0; % Generate checkiq.m plots
    iq_save_flag = 1; % Save checkiq.m variables into .mat file
    plot_flag = [0 0 0 0 0 0]; % Produce each plot from velocitystats.m
    plot_save_flag = 0; % Save plots from velocitystats.m
    LES_flag = 0; % Compare sim retrievals with LES in velocitystats.m
    var_save_flag = 1; % Save swp/les/avg variables from velocitystats.m
    state_flag = 0;
    
    
    for dtype = dtypes
        if dtype == 0 % no debris
            dnum = [];
            concept = nd_concept;
            %sim_date = nd_date;
            sim_dir = [dir_loc '/' sim_base '/' sim_date '/nodebris'];
            
            velocitystats
            
            if exist('dumbass_flag', 'var')
                return
            end
            
        else % with debris
            concept = dd_concept;
            %sim_date = dd_date;
            for dnum = dnums
                sim_dir = [dir_loc '/' sim_base '/' sim_date '/debris' num2str(dtype)];
                
                velocitystats
                
                if exist('dumbass_flag', 'var')
                    return
                end
            end
        end
    end
    
end



%% load and organize variables

nd = struct('dat', [], 'swp', [], 'avg', []);
dd = struct('conc', []);
dd.conc = struct('dat', [], 'swp', [], 'avg', []);
dcmp = struct('conc', []);
dcmp.conc = struct('dv', [], 'dv90', [], 'dv75', [], 'vort', [], 'u', [], 'v', [], 'w', []);


load([base_dir 'stats/' sim_base '/nd/nd_DCU_volume-stats.mat'])

nd.swp = swp;
nd.avg = avg.swp;
nd.dat = data;


nd.dat.zh = reshape(mean(nd.dat.zh, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
nd.dat.zv = reshape(mean(nd.dat.zv, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
nd.dat.vh = reshape(mean(nd.dat.vh, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
nd.dat.vv = reshape(mean(nd.dat.vv, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
nd.dat.zdr = reshape(mean(nd.dat.zdr, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
nd.dat.rhohv = reshape(mean(nd.dat.rhohv, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);

els = avg.swp.els;
r = avg.swp.r;
z = avg.swp.z;
azv = avg.swp.az_vol;
rv = avg.swp.r_vol;
elv = avg.swp.el_vol;


for dt = dtypes(dtypes ~= 0)
    for n = 1:length(dnums)
        load([base_dir 'stats/' sim_base '/d' num2str(dt) '/n' num2str(10^(n+dexp)) ...
            '_' dd_concept '_volume-stats.mat'])
        
        dd(dt).conc(n).swp = swp;
        dd(dt).conc(n).avg = avg.swp;
        dd(dt).conc(n).dat = data;
        
        dd(dt).conc(n).dat.zh = reshape(mean(dd(dt).conc(n).dat.zh, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
        dd(dt).conc(n).dat.zv = reshape(mean(dd(dt).conc(n).dat.zv, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
        dd(dt).conc(n).dat.vh = reshape(mean(dd(dt).conc(n).dat.vh, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
        dd(dt).conc(n).dat.vv = reshape(mean(dd(dt).conc(n).dat.vv, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
        dd(dt).conc(n).dat.zdr = reshape(mean(dd(dt).conc(n).dat.zdr, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
        dd(dt).conc(n).dat.rhohv = reshape(mean(dd(dt).conc(n).dat.rhohv, 4), [size(data.iqh,1)*size(data.iqh,2), size(data.iqh,3)]);
        dd(dt).conc(n).dat.vbias = dd(dt).conc(n).dat.vh - nd.dat.vh;
        dd(dt).conc(n).dat.diffv = dd(dt).conc(n).dat.vh - dd(dt).conc(n).dat.vv;
        
        
        ininds = find(dd(dt).conc(n).dat.vh < 0);
        outinds = find(dd(dt).conc(n).dat.vh > 0);
        dd(dt).conc(n).dat.vbias_in = dd(dt).conc(n).dat.vh(ininds) - nd.dat.vh(ininds);
        dd(dt).conc(n).dat.diffv_in = dd(dt).conc(n).dat.vh(ininds) - dd(dt).conc(n).dat.vv(ininds);
        dd(dt).conc(n).dat.vbias_out = dd(dt).conc(n).dat.vh(outinds) - nd.dat.vh(outinds);
        dd(dt).conc(n).dat.diffv_out = dd(dt).conc(n).dat.vh(outinds) - dd(dt).conc(n).dat.vv(outinds);
        dd(dt).conc(n).dat.zh_in = dd(dt).conc(n).dat.zh(ininds);
        dd(dt).conc(n).dat.zh_out = dd(dt).conc(n).dat.zh(outinds);
        dd(dt).conc(n).dat.zdr_in = dd(dt).conc(n).dat.zdr(ininds);
        dd(dt).conc(n).dat.zdr_out = dd(dt).conc(n).dat.zdr(outinds);
        dd(dt).conc(n).dat.rhohv_in = dd(dt).conc(n).dat.rhohv(ininds);
        dd(dt).conc(n).dat.rhohv_out = dd(dt).conc(n).dat.rhohv(outinds);
        
        dcmp(dt).conc(n).dv = dd(dt).conc(n).avg.dv - nd.avg.dv;
        dcmp(dt).conc(n).dv90 = dd(dt).conc(n).avg.dv90 - nd.avg.dv90;
        dcmp(dt).conc(n).dv75 = dd(dt).conc(n).avg.dv75 - nd.avg.dv75;
        dcmp(dt).conc(n).vort = dd(dt).conc(n).avg.vort - nd.avg.vort;
        dcmp(dt).conc(n).u = dd(dt).conc(n).avg.u - nd.avg.u;
        dcmp(dt).conc(n).v = dd(dt).conc(n).avg.v - nd.avg.v;
        dcmp(dt).conc(n).w = dd(dt).conc(n).avg.w - nd.avg.w;
    end
end





%% bias plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if false
for dt = dtypes(dtypes ~= 0)
    fig_dir = [base_dir 'imgs/' sim_base '/d' num2str(dt)];
    
    figure(1)
    clf
    
    subplot(1,2,1)
    plot(nd.avg.dv, els, '-r', 'LineWidth', 1.2)
    hold on
    plot(dd(dt).conc(1).avg.dv, els, ':k', 'LineWidth', 1.2)
    plot(dd(dt).conc(2).avg.dv, els, '--k', 'LineWidth', 1.2)
    plot(dd(dt).conc(3).avg.dv, els, '-k', 'LineWidth', 1.2)
    % plot(dd(dt).conc(4).avg.dv, els, '-k', 'LineWidth', 1)
    hold off
    xlim([0 200])
    xticks(0:25:200)
    title('(a) \Deltav', 'FontSize', 14)
    xlabel('m s^{-1}', 'FontSize', 14)
    ylabel('Elevation angle', 'FontSize', 14)
    legend('Truth', 'n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    grid on
    %axis square
    
    subplot(1,2,2)
    plot(dcmp(dt).conc(1).dv, els, ':b', 'LineWidth', 1.2)
    hold on
    plot(dcmp(dt).conc(2).dv, els, '--b', 'LineWidth', 1.2)
    plot(dcmp(dt).conc(3).dv, els, '-b', 'LineWidth', 1.2)
    % plot(dcmp(dt).conc(4).dv, els, '-b', 'LineWidth', 1)
    hold off
    xlim([-150 25])
    xticks(-150:25:25)
    title('(b) \Deltav bias', 'FontSize', 14)
    xlabel('m s^{-1}', 'FontSize', 14)
    ylabel('Elevation angle', 'FontSize', 14)
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    grid on
    %axis square
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 12 5])
    axes('Unit', 'Normalized', 'Position', [0.5 0.93 0.01 0.01])
    title(['Debris type ' num2str(dt)], 'FontSize', 14);
    axis off
    print([fig_dir '/d' num2str(dt) '-deltaV-diff'], '-dpng')
    

%     subplot(1,3,1)
%     plot(dcmp(dt).conc(1).dv, els, ':b', 'LineWidth', 1)
%     hold on
%     plot(dcmp(dt).conc(2).dv, els, '-.b', 'LineWidth', 1)
%     plot(dcmp(dt).conc(3).dv, els, '--b', 'LineWidth', 1)
%     % plot(dcmp(dt).conc(4).dv, els, '-b', 'LineWidth', 1)
%     hold off
%     xlim([-60 20])
%     title(['Debris type ' num2str(dt) ': Maximum \DeltaV residual'])
%     xlabel('V (m/s)')
%     ylabel('Elev. angle')
%     legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
%     grid on
%     axis square
%     
%     subplot(1,3,2)
%     plot(dcmp(dt).conc(1).dv90, els, ':b', 'LineWidth', 1)
%     hold on
%     plot(dcmp(dt).conc(2).dv90, els, '--b', 'LineWidth', 1)
%     plot(dcmp(dt).conc(3).dv90, els, '-b', 'LineWidth', 1)
%     % plot(dcmp(dt).conc(4).dv90, els, '-b', 'LineWidth', 1)
%     hold off
%     xlim([-60 20])
%     title(['Debris type ' num2str(dt) ': 90th percentile \DeltaV residual'])
%     xlabel('V (m/s)')
%     ylabel('Elev. angle')
%     legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
%     grid on
%     axis square
    
%     subplot(1,3,3)
%     plot(dcmp(dt).conc(1).dv75, els, ':b', 'LineWidth', 1)
%     hold on
%     plot(dcmp(dt).conc(2).dv75, els, '--b', 'LineWidth', 1)
%     plot(dcmp(dt).conc(3).dv75, els, '-b', 'LineWidth', 1)
%     % plot(dcmp(dt).conc(4).dv75, els, '-b', 'LineWidth', 1)
%     hold off
%     xlim([-60 20])
%     title(['Debris type ' num2str(dt) ': 75th percentile \DeltaV residual'])
%     xlabel('V (m/s)')
%     ylabel('Elev. angle')
%     legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
%     grid on
%     axis square
%     
%     set(gcf,'Units','inches','Position',[10 10 14 5])

    
    
    for n = 1:length(dnums)
        % [-0.2, -0.1, 0.1, 0.2]
        % 
        % 2d: [0.4, 0.07, 0.07, 0.4]
        % 3d: [0.3, 0.03, 0.03, 0.3]
        
%         figure(2)
%         clf
%         axis tight manual
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.2);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
%         hold on
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.1);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
%         % [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.0); %50th percentile
%         % patch('Vertices', v, 'Faces', f, 'FaceColor', 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.05)
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.1);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.2);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
%         hold off
%         xlim([round(min(azv,[],'all'),2), round(max(azv,[],'all'),2)])
%         ylim([round(min(rv,[],'all'),-1), round(max(rv,[],'all'),-1)])
%         zlim([0, 5])
%         xlabel('Azim. angle')
%         ylabel('Rad. distance (m)')
%         zlabel('Elev. angle')
%         title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp)) ': pseudovorticity'])
%         legend('-0.2s^{-1}', '-0.1s^{-1}', '0.1s^{-1}', '0.2s^{-1}', 'Location', 'eastoutside')
%         grid on
%         
%         view(3)
%         print([fig_dir '/n' num2str(10^(n+dexp)) '_vorticity-diff-3d'], '-dpng')
%         
%         F = getframe(gcf);
%         im = frame2im(F);
%         [imind,cm] = rgb2ind(im,256);
%         if n == 1
%             imwrite(imind, cm, [fig_dir '/vorticity-diff-3d.gif'],...
%                 'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
%         else
%             imwrite(imind, cm, [fig_dir '/vorticity-diff-3d.gif'],...
%                 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
%         end
%         
%         
%         figure(3)
%         clf
%         axis tight manual
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.2);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
%         hold on
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.1);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.07)
%         % [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.0); %50th percentile
%         % patch('Vertices', v, 'Faces', f, 'FaceColor', 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.05)
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.1);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.07)
%         [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.2);
%         patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
%         hold off
%         xlim([round(min(azv,[],'all'),2), round(max(azv,[],'all'),2)])
%         ylim([round(min(rv,[],'all'),-1), round(max(rv,[],'all'),-1)])
%         zlim([0, 5])
%         xlabel('Azim. angle')
%         ylabel('Rad. distance (m)')
%         zlabel('Elev. angle')
%         title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp)) ': pseudovorticity'])
%         legend('-0.2s^{-1}', '-0.1s^{-1}', '0.1s^{-1}', '0.2s^{-1}', 'Location', 'eastoutside')
%         grid on
%         
%         view(2)
%         axis square
%         print([fig_dir '/n' num2str(10^(n+dexp)) '_vorticity-diff-2d'], '-dpng')
%         
%         F = getframe(gcf);
%         im = frame2im(F);
%         [imind,cm] = rgb2ind(im,256);
%         if n == 1
%             imwrite(imind, cm, [fig_dir '/vorticity-diff-2d.gif'],...
%                 'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
%         else
%             imwrite(imind, cm, [fig_dir '/vorticity-diff-2d.gif'],...
%                 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
%         end
        
        
        figure(4)
        clf
        vlim = 60;
        
        ha = subplot(3,3,1);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).conc(n).avg.u)
        % caxis([-1 1] * max(abs(dd(dt).conc(n).avg.u),[],'all'))
        caxis([-vlim vlim])
        colormap(ha, blib('rbmap'))
        c = colorbar;
%         c.Label.String = 'm s^{-1}';
%         c.Label.FontSize = 14;
%         c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(a) u_{r,debris}', 'FontSize', 16)
        %title('u_r', 'FontSize', 18)
        %xlabel('Distance from tor center (m)')
        %ylabel('Height (m)', 'FontSize', 20)
        
        ha(2) = subplot(3,3,2);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).conc(n).avg.v)
        % caxis([-1 1] * max(abs(dd(dt).conc(n).avg.v),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(2), blib('rbmap'))
        c = colorbar;
%         c.Label.String = 'm s^{-1}';
%         c.Label.FontSize = 14;
%         c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(b) v_{t,debris}', 'FontSize', 16)
        %title('v_t', 'FontSize', 18)
        %xlabel('Tornado-relative {\it r} (m)', 'FontSize', 14)
        %ylabel('Height (m)')
        xlabel('Tornado-relative{\it r} (m)', 'FontSize', 16)
        ylabel('Height (m)', 'FontSize', 16)
        
        ha(3) = subplot(3,3,3);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dd(dt).conc(n).avg.w)
        % caxis([-1 1] * max(abs(dd(dt).conc(n).avg.w),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(3), blib('rbmap'))
        c = colorbar;
        c.Label.String = 'm s^{-1}';
        c.Label.FontSize = 14;
        c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(c) w_{debris}', 'FontSize', 16)
        %title('w', 'FontSize', 18)
        %xlabel('Distance from tor center (m)')
        %ylabel('Height (m)')
        
        ha(4) = subplot(3,3,4);
        pcolor(nd.avg.r, nd.avg.z, nd.avg.u)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).u),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(4), blib('rbmap'))
        c = colorbar;
%         c.Label.String = 'm s^{-1}';
%         c.Label.FontSize = 14;
%         c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(d) u_{r,rain}', 'FontSize', 16)
        %xlabel('Distance from tor center (m)')
        %ylabel('z (m)', 'FontSize', 16)
        
        ha(5) = subplot(3,3,5);
        pcolor(nd.avg.r, nd.avg.z, nd.avg.v)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).v),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(5), blib('rbmap'))
        c = colorbar;
%         c.Label.String = 'm s^{-1}';
%         c.Label.FontSize = 14;
%         c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(e) v_{t,rain}', 'FontSize', 16)
        %xlabel('Distance from tor center (m)')
%         xlabel('Tornado-relative {\it r} (m)', 'FontSize', 14)
%         ylabel('Height (m)', 'FontSize', 14)
        
        ha(6) = subplot(3,3,6);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), nd.avg.w)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).w),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(6), blib('rbmap'))
        c = colorbar;
        c.Label.String = 'm s^{-1}';
        c.Label.FontSize = 14;
        c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(f) w_{rain}', 'FontSize', 16)
        %xlabel('Distance from tor center (m)')
        %ylabel('Height (m)')
        
        ha(7) = subplot(3,3,7);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).conc(n).u)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).u),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(7), blib('rbmap'))
        c = colorbar;
%         c.Label.String = 'm s^{-1}';
%         c.Label.FontSize = 14;
%         c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(g) \Deltau_r', 'FontSize', 16)
        %xlabel('Distance from tor center (m)', 'FontSize', 18)
        %ylabel('Height (m)', 'FontSize', 20)
        
        ha(8) = subplot(3,3,8);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).conc(n).v)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).v),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(8), blib('rbmap'))
        c = colorbar;
%         c.Label.String = 'm s^{-1}';
%         c.Label.FontSize = 14;
%         c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(h) \Deltav_t', 'FontSize', 16)
        %xlabel('Distance from tornado center (m)', 'FontSize', 16)
        %ylabel('Height (m)')
        
        ha(9) = subplot(3,3,9);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dcmp(dt).conc(n).w)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).w),[],'all'))
        caxis([-vlim vlim])
        colormap(ha(9), blib('rbmap'))
        c = colorbar;
        c.Label.String = 'm s^{-1}';
        c.Label.FontSize = 14;
        c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        %title('(i) \Deltaw', 'FontSize', 16)
        %xlabel('Distance from tor center (m)', 'FontSize', 18)
        %ylabel('Height (m)')
        
        annotation('textbox', [0.02 0.8 0.08 0.03], 'String', 'Realistic',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.025 0.5 0.06 0.03], 'String', 'Truth',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        %annotation('textbox', [0.025 0.2 0.06 0.03], 'String', '{\it v} bias', 'FontSize', 16, 'FontWeight', 'bold', 'EdgeColor', 'k', 'LineWidth', 1, 'HorizontalAlignment', 'center')
%         annotation('textbox', [0.21 0.93 0.04 0.035], 'String', 'u_r', 'FontSize', 18, 'FontWeight', 'bold', 'EdgeColor', 'k', 'LineWidth', 1, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
%         annotation('textbox', [0.49 0.93 0.04 0.035], 'String', 'v_t', 'FontSize', 18, 'FontWeight', 'bold', 'EdgeColor', 'k', 'LineWidth', 1, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
%         annotation('textbox', [0.77 0.93 0.04 0.035], 'String', 'w', 'FontSize', 18, 'FontWeight', 'bold', 'EdgeColor', 'k', 'LineWidth', 1, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
        annotation('textbox', [0.14 0.93 0.17 0.03], 'String', 'Radial wind',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.42 0.93 0.17 0.03], 'String', 'Azimuthal wind',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.7 0.93 0.17 0.03], 'String', 'Vertical wind',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.14 0.33 0.17 0.03], 'String', 'Radial wind{\it bias}',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.42 0.33 0.17 0.03], 'String', 'Azimuthal wind{\it bias}',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.7 0.33 0.17 0.03], 'String', 'Vertical wind{\it bias}',...
            'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.03 0.01 0.01])
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp))], 'FontSize', 16);
        axis off
        % set(gcf, 'Position', [left_bound bottom_bound width height])
        set(gcf,'Units','inches','Position',[10 10 14 12])
        
        print([fig_dir '/d' num2str(dt) '-n' num2str(10^(n+dexp)) '_gbvtd-diff'], '-dpng')
        
%         F = getframe(gcf);
%         im = frame2im(F);
%         [imind,cm] = rgb2ind(im,256);
%         if n == 1
%             imwrite(imind, cm, [fig_dir '/gbvtd-diff.gif'],...
%                 'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
%         else
%             imwrite(imind, cm, [fig_dir '/gbvtd-diff.gif'],...
%                 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
%         end
        
        if seminar_figs_flag
            sdim = [1,3];
            fig_pos = [10 10 16 5];
            title_pos = [0.5 0.9 0.01 0.01];
            fig_orient = 'wide';
        elseif thesis_figs_flag
            sdim = [3,1];
            fig_pos = [10 10 5 12];
            title_pos = [0.5 0.95 0.01 0.01];
            fig_orient = 'tall';
        end
        
        if seminar_figs_flag || thesis_figs_flag
        
        figure(30)
        clf
        
        ha = subplot(sdim(1),sdim(2),1);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).conc(n).avg.u)
        caxis([-vlim vlim])
        colormap(ha, blib('rbmap'))
        c = colorbar;
        c.Label.String = 'm s^{-1}';
        c.Label.FontSize = 14;
        c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(a) u_{r,debris}', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        ha(2) = subplot(sdim(1),sdim(2),2);
        pcolor(nd.avg.r, nd.avg.z, nd.avg.u)
        caxis([-vlim vlim])
        colormap(ha(2), blib('rbmap'))
        c(2) = colorbar;
        c(2).Label.String = 'm s^{-1}';
        c(2).Label.FontSize = 14;
        c(2).Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(b) u_{r,rain}', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        ha(3) = subplot(sdim(1),sdim(2),3);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).conc(n).u)
        caxis([-vlim vlim])
        colormap(ha(3), blib('rbmap'))
        c(3) = colorbar;
        c(3).Label.String = 'm s^{-1}';
        c(3).Label.FontSize = 14;
        c(3).Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(c) Error \Deltau_r', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', fig_pos)
        axes('Unit', 'Normalized', 'Position', title_pos)
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp))], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-n' num2str(10^(n+dexp)) '_gbvtd-ur-' fig_orient], '-dpng')
        
        
        figure(31)
        clf
        
        ha(1) = subplot(sdim(1),sdim(2),1);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).conc(n).avg.v)
        caxis([-vlim vlim])
        colormap(ha(1), blib('rbmap'))
        c = colorbar;
        c.Label.String = 'm s^{-1}';
        c.Label.FontSize = 14;
        c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(a) v_{t,debris}', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        ha(2) = subplot(sdim(1),sdim(2),2);
        pcolor(nd.avg.r, nd.avg.z, nd.avg.v)
        caxis([-vlim vlim])
        colormap(ha(2), blib('rbmap'))
        c(2) = colorbar;
        c(2).Label.String = 'm s^{-1}';
        c(2).Label.FontSize = 14;
        c(2).Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(b) v_{t,rain}', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        ha(3) = subplot(sdim(1),sdim(2),3);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).conc(n).v)
        caxis([-vlim vlim])
        colormap(ha(3), blib('rbmap'))
        c(3) = colorbar;
        c(3).Label.String = 'm s^{-1}';
        c(3).Label.FontSize = 14;
        c(3).Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(c) Error \Deltav_t', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', fig_pos)
        axes('Unit', 'Normalized', 'Position', title_pos)
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp))], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-n' num2str(10^(n+dexp)) '_gbvtd-vt-' fig_orient], '-dpng')
        
        
        figure(32)
        clf
        
        ha(1) = subplot(sdim(1),sdim(2),1);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dd(dt).conc(n).avg.w)
        caxis([-vlim vlim])
        colormap(ha(1), blib('rbmap'))
        c = colorbar;
        c.Label.String = 'm s^{-1}';
        c.Label.FontSize = 14;
        c.Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(a) w_{debris}', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        ha(2) = subplot(sdim(1),sdim(2),2);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), nd.avg.w)
        caxis([-vlim vlim])
        colormap(ha(2), blib('rbmap'))
        c(2) = colorbar;
        c(2).Label.String = 'm s^{-1}';
        c(2).Label.FontSize = 14;
        c(2).Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(b) w_{rain}', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        ha(3) = subplot(sdim(1),sdim(2),3);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dcmp(dt).conc(n).w)
        caxis([-vlim vlim])
        colormap(ha(3), blib('rbmap'))
        c(3) = colorbar;
        c(3).Label.String = 'm s^{-1}';
        c(3).Label.FontSize = 14;
        c(3).Label.VerticalAlignment = 'middle';
        shading flat
        axis square
        title('(c) Error \Deltaw', 'FontSize', 14)
        xlabel('Range from tornado center (m)', 'FontSize', 14)
        ylabel('Height A.G.L. (m)', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', fig_pos)
        axes('Unit', 'Normalized', 'Position', title_pos)
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp))], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-n' num2str(10^(n+dexp)) '_gbvtd-w-' fig_orient], '-dpng')
        
        end
        
    end
end
end

%% original scatter plots
if false
for dt = dtypes(dtypes ~= 0)
    fig_dir = [base_dir 'imgs/' sim_base '/d' num2str(dt) '/scatter'];
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir)
        addpath(genpath(fig_dir))
        savepath
    end
    
    elind = 4;
    
    if false
    
    figure(5)
    clf
    s1 = scatter(dd(dt).conc(1).dat.rhohv(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.rhohv(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.rhohv(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2]; % green: [0.2 0.6 0.3]
    s2.MarkerEdgeColor = [0.7 0.3 0.6]; % purple
    s3.MarkerEdgeColor = [0.9 0.6 0.1]; % dark yellow
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Velocity bias and \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 14)
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-rhohv-vbias'], '-dpng')
    
    
    figure(6)
    clf
    s1 = scatter(dd(dt).conc(1).dat.rhohv(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.rhohv(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.rhohv(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Differential velocity and \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 14)
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-rhohv-diffv'], '-dpng')
    
    
    figure(7)
    clf
    s1 = scatter(dd(dt).conc(1).dat.zdr(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.zdr(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.zdr(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([-5 5])
    xticks(-5:5)
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Velocity bias and Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 14)
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-zdr-vbias'], '-dpng')
    
    
    figure(8)
    clf
    s1 = scatter(dd(dt).conc(1).dat.zdr(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.zdr(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.zdr(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
    hold off
    axis square
    xlim([-5 5])
    xticks(-5:5)
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Differential velocity and Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 14)
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-zdr-diffv'], '-dpng')
    
    
    figure(9)
    clf
    s1 = scatter(dd(dt).conc(1).dat.zh(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.zh(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.zh(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([0 80])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Velocity bias and Z_H (debris type ' num2str(dt) ')'], 'FontSize', 14)
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-zh-vbias'], '-dpng')
    
    
    figure(10)
    clf
    s1 = scatter(dd(dt).conc(1).dat.zh(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.zh(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.zh(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
    hold off
    axis square
    xlim([0 80])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Differential velocity and Z_H (debris type ' num2str(dt) ')'], 'FontSize', 14)
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-zh-diffv'], '-dpng')
    
    
    
    figure(11)
    clf
    
    subplot(2,3,1)
    s1 = scatter(dd(dt).conc(1).dat.rhohv(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.rhohv(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.rhohv(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
    title('(a) Velocity bias and \rho_{HV}', 'FontSize', 14)
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,2)
    s1(2) = scatter(dd(dt).conc(1).dat.zdr(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2(2) = scatter(dd(dt).conc(2).dat.zdr(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
    s3(2) = scatter(dd(dt).conc(3).dat.zdr(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([-5 5])
    ylim([-60 60])
    xticks(-5:5)
    s1(2).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(2).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(2).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
    title('(b) Velocity bias and Z_{DR}', 'FontSize', 14)
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    %ylabel('v_{error} (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,3)
    s1(3) = scatter(dd(dt).conc(1).dat.zh(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2(3) = scatter(dd(dt).conc(2).dat.zh(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
    s3(3) = scatter(dd(dt).conc(3).dat.zh(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([0 80])
    ylim([-60 60])
    s1(3).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(3).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(3).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
    title('(c) Velocity bias and Z_H', 'FontSize', 14)
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    %ylabel('v_{error} (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,4)
    s1(4) = scatter(dd(dt).conc(1).dat.rhohv(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
    hold on
    s2(4) = scatter(dd(dt).conc(2).dat.rhohv(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
    s3(4) = scatter(dd(dt).conc(3).dat.rhohv(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1(4).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(4).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(4).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
    title('(d) Differential velocity and \rho_{HV}', 'FontSize', 14)
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,5)
    s1(5) = scatter(dd(dt).conc(1).dat.zdr(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
    hold on
    s2(5) = scatter(dd(dt).conc(2).dat.zdr(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
    s3(5) = scatter(dd(dt).conc(3).dat.zdr(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
    hold off
    axis square
    xlim([-5 5])
    ylim([-60 60])
    xticks(-5:5)
    s1(5).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(5).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(5).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
    title('(e) Differential velocity and Z_{DR}', 'FontSize', 14)
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    %ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,6)
    s1(6) = scatter(dd(dt).conc(1).dat.zh(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
    hold on
    s2(6) = scatter(dd(dt).conc(2).dat.zh(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
    s3(6) = scatter(dd(dt).conc(3).dat.zh(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
    hold off
    axis square
    xlim([0 80])
    ylim([-60 60])
    s1(6).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(6).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(6).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
    title('Differential velocity and Z_H', 'FontSize', 14)
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    %ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 7 16 10])
    axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
    title(['Debris type ' num2str(dt)], 'FontSize', 16);
    axis off
    print([fig_dir '/d' num2str(dt) '-allvars'], '-dpng')
    
    
    % Compare vbias to differential v
    
    diffv_tmp = squeeze([dd(dt).conc(1).dat.diffv(:,elind); dd(dt).conc(2).dat.diffv(:,elind); dd(dt).conc(3).dat.diffv(:,elind)]);       
    vbias_tmp = squeeze([dd(dt).conc(1).dat.vbias(:,elind); dd(dt).conc(2).dat.vbias(:,elind); dd(dt).conc(3).dat.vbias(:,elind)]);
    
    cffs = polyfit(diffv_tmp, vbias_tmp, 1);
    inv_cffs = polyfit(vbias_tmp, diffv_tmp, 1);
    %diffv_fit = linspace(-40,20,1000);
    %vbias_fit = polyval(cffs, diffv_fit);
    vbias_fit = linspace(-60,60,500);
    diffv_fit = polyval(inv_cffs, vbias_fit);
    slp = 1 / inv_cffs(1);
    yint = -inv_cffs(2) / inv_cffs(1);
    str = ['v_{bias} = ' num2str(slp) 'v_D + ' num2str(yint)];
    
    figure(12)
    clf
    s1 = scatter(dd(dt).conc(1).dat.diffv(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.diffv(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
    s3 = scatter(dd(dt).conc(3).dat.diffv(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
    plot(diffv_fit, vbias_fit, '-k', 'LineWidth', 2)
    hold off
    axis square
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest', 'FontSize', 10)
    %title(['Debris type ' num2str(dt)], 'FontSize', 14)
    title('v_{bias} ={\it f}(v_D)', 'FontSize', 14)
    xlabel('v_D (m s^{-1})', 'FontSize', 16)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 16)
    xlim([-60 60])
    ylim([-60 60])
    text(-55, -10, str, 'FontSize', 13)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-dv-comp'], '-dpng')
    
    clear diffv_tmp vbias_tmp
    
    end
    
    
    if seminar_figs_flag || thesis_figs_flag
        
        figure(13)
        clf
        
        %subplot(2,2,1)
        subplot(1,3,1)
        s1 = scatter(dd(dt).conc(1).dat.zh(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
        hold off
        axis square
        %grid on
        xlim([0 80])
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        %title('(a) Z_H (dBZ)', 'FontSize', 14)
        %title('Reflectivity', 'FontSize', 20)
        xlabel('Z_H (dBZ)', 'FontSize', 16)
        %ylabel('Velocity Bias', 'FontSize', 20)
        
        %subplot(2,2,2)
        subplot(1,3,2)
        s1(2) = scatter(dd(dt).conc(1).dat.zdr(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
        hold on
        s2(2) = scatter(dd(dt).conc(2).dat.zdr(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
        s3(2) = scatter(dd(dt).conc(3).dat.zdr(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
        hold off
        axis square
        %grid on
        xlim([-5 5])
        xticks(-5:5)
        ylim([-60 60])
        s1(2).MarkerEdgeColor = [0.2 0.2 0.2];
        s2(2).MarkerEdgeColor = [0.7 0.3 0.6];
        s3(2).MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        %title('(b) Z_{DR} (dB)', 'FontSize', 14)
        %title('Differential reflectivity', 'FontSize', 20)
        xlabel('Z_{DR} (dB)', 'FontSize', 16)
        %ylabel('Velocity Bias', 'FontSize', 20)
        
        %subplot(2,2,[3,4])
        subplot(1,3,3)
        s1(3) = scatter(dd(dt).conc(1).dat.rhohv(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
        hold on
        s2(3) = scatter(dd(dt).conc(2).dat.rhohv(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
        s3(3) = scatter(dd(dt).conc(3).dat.rhohv(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
        hold off
        axis square
        %grid on
        xlim([0 1])
        ylim([-60 60])
        s1(3).MarkerEdgeColor = [0.2 0.2 0.2];
        s2(3).MarkerEdgeColor = [0.7 0.3 0.6];
        s3(3).MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        %title('(c) \rho_{HV}', 'FontSize', 14)
        %title('Correlation coefficient', 'FontSize', 20)
        xlabel('\rho_{HV}', 'FontSize', 16)
        %ylabel('Velocity Bias', 'FontSize', 20)
        
        
        set(gcf, 'Units', 'inches', 'Position', [6 10 20 6])
        
        annotation('textbox', [0.03 0.45 0.07 0.15], 'String', ['Velocity' newline 'Bias'],...
            'FontSize',20,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.14 0.9 0.2 0.07], 'String', 'Reflectivity',...
            'FontSize',20,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.42 0.9 0.2 0.07], 'String', 'Differential Reflectivity',...
            'FontSize',20,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
        annotation('textbox', [0.70 0.9 0.2 0.07], 'String', 'Correlation Coefficient',...
            'FontSize',20,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
%         axes('Unit', 'Normalized', 'Position', [0.5 0.93 0.01 0.01])
%         title(['Velocity bias (debris type ' num2str(dt) ')'], 'FontSize', 16);
%         axis off
        print([fig_dir '/d' num2str(dt) '-vbias-3p-wide'], '-dpng')
        
        
        
        if false
            
        figure(14)
        clf
        
        subplot(2,2,1)
        s1 = scatter(dd(dt).conc(1).dat.zh(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
        hold off
        axis square
        grid on
        xlim([0 80])
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(a) Z_H (dBZ)', 'FontSize', 14)
        %xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v_D (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,2)
        s1(2) = scatter(dd(dt).conc(1).dat.zdr(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
        hold on
        s2(2) = scatter(dd(dt).conc(2).dat.zdr(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
        s3(2) = scatter(dd(dt).conc(3).dat.zdr(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
        hold off
        axis square
        grid on
        xlim([-5 5])
        xticks(-5:5)
        ylim([-60 60])
        s1(2).MarkerEdgeColor = [0.2 0.2 0.2];
        s2(2).MarkerEdgeColor = [0.7 0.3 0.6];
        s3(2).MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(b) Z_{DR} (dB)', 'FontSize', 14)
        %xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v_D (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,[3,4])
        s1(3) = scatter(dd(dt).conc(1).dat.rhohv(:,elind), dd(dt).conc(1).dat.diffv(:,elind), '.');
        hold on
        s2(3) = scatter(dd(dt).conc(2).dat.rhohv(:,elind), dd(dt).conc(2).dat.diffv(:,elind), '.');
        s3(3) = scatter(dd(dt).conc(3).dat.rhohv(:,elind), dd(dt).conc(3).dat.diffv(:,elind), '.');
        hold off
        axis square
        grid on
        xlim([0 1])
        ylim([-60 60])
        s1(3).MarkerEdgeColor = [0.2 0.2 0.2];
        s2(3).MarkerEdgeColor = [0.7 0.3 0.6];
        s3(3).MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(c) \rho_{HV}', 'FontSize', 14)
        %xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v_D (m s^{-1})', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', [10 10 12 12])
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['Differential velocity (debris type ' num2str(dt) ')'], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-diffv-3p'], '-dpng')
        
        
        
        
        figure(15)
        clf
        
        subplot(2,2,1)
        s1 = scatter(dd(dt).conc(1).dat.zh(:,elind), dd(dt).conc(1).dat.vbias(:,elind), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh(:,elind), dd(dt).conc(2).dat.vbias(:,elind), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh(:,elind), dd(dt).conc(3).dat.vbias(:,elind), '.');
        hold off
        axis square
        xlim([0 80])
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(a) v_{bias}', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,2)
        s1 = scatter(dd(dt).conc(1).dat.zh(:,elind), abs(dd(dt).conc(1).dat.vbias(:,elind)), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh(:,elind), abs(dd(dt).conc(2).dat.vbias(:,elind)), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh(:,elind), abs(dd(dt).conc(3).dat.vbias(:,elind)), '.');
        hold off
        axis square
        xlim([0 80])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(b) |v_{bias}|', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,3)
        s1 = scatter(dd(dt).conc(1).dat.zh_out(:,elind), abs(dd(dt).conc(1).dat.vbias_out(:,elind)), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh_out(:,elind), abs(dd(dt).conc(2).dat.vbias_out(:,elind)), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh_out(:,elind), abs(dd(dt).conc(3).dat.vbias_out(:,elind)), '.');
        hold off
        axis square
        xlim([0 80])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(c) |v_{bias,out}|', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,4)
        s1 = scatter(dd(dt).conc(1).dat.zh_in(:,elind), abs(dd(dt).conc(1).dat.vbias_in(:,elind)), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh_in(:,elind), abs(dd(dt).conc(2).dat.vbias_in(:,elind)), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh_in(:,elind), abs(dd(dt).conc(3).dat.vbias_in(:,elind)), '.');
        hold off
        axis square
        xlim([0 80])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(d) |v_{bias,in}|', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', [10 10 12 12])
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['v_{bias}, Z_H (debris type ' num2str(dt) ')'], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-zh-vbias-4p'], '-dpng')
        
        
        
        figure(16)
        clf
        
        subplot(2,2,1)
        s1 = scatter(dd(dt).conc(1).dat.zdr, dd(dt).conc(1).dat.vbias, '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr, dd(dt).conc(2).dat.vbias, '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr, dd(dt).conc(3).dat.vbias, '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(a) v_{bias}', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,2)
        s1 = scatter(dd(dt).conc(1).dat.zdr, abs(dd(dt).conc(1).dat.vbias), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr, abs(dd(dt).conc(2).dat.vbias), '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr, abs(dd(dt).conc(3).dat.vbias), '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(b) |v_{bias}|', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,3)
        s1 = scatter(dd(dt).conc(1).dat.zdr_out, abs(dd(dt).conc(1).dat.vbias_out), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr_out, abs(dd(dt).conc(2).dat.vbias_out), '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr_out, abs(dd(dt).conc(3).dat.vbias_out), '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(c) |v_{bias,out}|', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,4)
        s1 = scatter(dd(dt).conc(1).dat.zdr_in, abs(dd(dt).conc(1).dat.vbias_in), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr_in, abs(dd(dt).conc(2).dat.vbias_in), '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr_in, abs(dd(dt).conc(3).dat.vbias_in), '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(d) |v_{bias,in}|', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', [10 10 10 9])
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['v_{bias}, Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-zdr-vbias-4p'], '-dpng')
        
        
        
        figure(17)
        clf
        
        subplot(2,2,1)
        s1 = scatter(dd(dt).conc(1).dat.rhohv, dd(dt).conc(1).dat.vbias, '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv, dd(dt).conc(2).dat.vbias, '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv, dd(dt).conc(3).dat.vbias, '.');
        hold off
        axis square
        xlim([0 1])
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(a) v_{bias}', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,2)
        s1 = scatter(dd(dt).conc(1).dat.rhohv, abs(dd(dt).conc(1).dat.vbias), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv, abs(dd(dt).conc(2).dat.vbias), '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv, abs(dd(dt).conc(3).dat.vbias), '.');
        hold off
        axis square
        xlim([0 1])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(b) |v_{bias}|', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,3)
        s1 = scatter(dd(dt).conc(1).dat.rhohv_out, abs(dd(dt).conc(1).dat.vbias_out), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv_out, abs(dd(dt).conc(2).dat.vbias_out), '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv_out, abs(dd(dt).conc(3).dat.vbias_out), '.');
        hold off
        axis square
        xlim([0 1])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(c) |v_{bias,out}|', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,4)
        s1 = scatter(dd(dt).conc(1).dat.rhohv_in, abs(dd(dt).conc(1).dat.vbias_in), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv_in, abs(dd(dt).conc(2).dat.vbias_in), '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv_in, abs(dd(dt).conc(3).dat.vbias_in), '.');
        hold off
        axis square
        xlim([0 1])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'southwest')
        title('(d) |v_{bias,in}|', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', [10 10 10 9])
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['v_{bias}, \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-rhohv-vbias-4p'], '-dpng')
        
        
        
        
        figure(18)
        clf
        
        subplot(2,2,1)
        s1 = scatter(dd(dt).conc(1).dat.zh, dd(dt).conc(1).dat.diffv, '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh, dd(dt).conc(2).dat.diffv, '.');
        s3 = scatter(dd(dt).conc(3).dat.zh, dd(dt).conc(3).dat.diffv, '.');
        hold off
        axis square
        xlim([0 80])
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(a) v_D', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,2)
        s1 = scatter(dd(dt).conc(1).dat.zh, abs(dd(dt).conc(1).dat.diffv), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh, abs(dd(dt).conc(2).dat.diffv), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh, abs(dd(dt).conc(3).dat.diffv), '.');
        hold off
        axis square
        xlim([0 80])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(b) |v_D|', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,3)
        s1 = scatter(dd(dt).conc(1).dat.zh_out, abs(dd(dt).conc(1).dat.diffv_out), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh_out, abs(dd(dt).conc(2).dat.diffv_out), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh_out, abs(dd(dt).conc(3).dat.diffv_out), '.');
        hold off
        axis square
        xlim([0 80])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(c) |v_{D,out}|', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,4)
        s1 = scatter(dd(dt).conc(1).dat.zh_in, abs(dd(dt).conc(1).dat.diffv_in), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zh_in, abs(dd(dt).conc(2).dat.diffv_in), '.');
        s3 = scatter(dd(dt).conc(3).dat.zh_in, abs(dd(dt).conc(3).dat.diffv_in), '.');
        hold off
        axis square
        xlim([0 80])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(d) |v_{D,in}|', 'FontSize', 14)
        xlabel('Z_H (dBZ)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', [10 10 10 9])
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['v_D, Z_H (debris type ' num2str(dt) ')'], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-zh-diffv-4p'], '-dpng')
        
        
        
        
        figure(19)
        clf
        
        subplot(2,2,1)
        s1 = scatter(dd(dt).conc(1).dat.zdr, dd(dt).conc(1).dat.diffv, '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr, dd(dt).conc(2).dat.diffv, '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr, dd(dt).conc(3).dat.diffv, '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(a) v_D', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,2)
        s1 = scatter(dd(dt).conc(1).dat.zdr, abs(dd(dt).conc(1).dat.diffv), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr, abs(dd(dt).conc(2).dat.diffv), '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr, abs(dd(dt).conc(3).dat.diffv), '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(b) |v_D|', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,3)
        s1 = scatter(dd(dt).conc(1).dat.zdr_out, abs(dd(dt).conc(1).dat.diffv_out), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr_out, abs(dd(dt).conc(2).dat.diffv_out), '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr_out, abs(dd(dt).conc(3).dat.diffv_out), '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(c) |v_{D,out}|', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,4)
        s1 = scatter(dd(dt).conc(1).dat.zdr_in, abs(dd(dt).conc(1).dat.diffv_in), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.zdr_in, abs(dd(dt).conc(2).dat.diffv_in), '.');
        s3 = scatter(dd(dt).conc(3).dat.zdr_in, abs(dd(dt).conc(3).dat.diffv_in), '.');
        hold off
        axis square
        xlim([-5 5])
        xticks(-5:5)
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(d) |v_{D,in}|', 'FontSize', 14)
        xlabel('Z_{DR} (dB)', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', [10 10 10 9])
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['v_D, Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-zdr-diffv-4p'], '-dpng')
        
        
        
        
        figure(20)
        clf
        
        subplot(2,2,1)
        s1 = scatter(dd(dt).conc(1).dat.rhohv, dd(dt).conc(1).dat.diffv, '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv, dd(dt).conc(2).dat.diffv, '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv, dd(dt).conc(3).dat.diffv, '.');
        hold off
        axis square
        xlim([0 1])
        ylim([-60 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(a) v_D', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,2)
        s1 = scatter(dd(dt).conc(1).dat.rhohv, abs(dd(dt).conc(1).dat.diffv), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv, abs(dd(dt).conc(2).dat.diffv), '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv, abs(dd(dt).conc(3).dat.diffv), '.');
        hold off
        axis square
        xlim([0 1])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(b) |v_D|', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,3)
        s1 = scatter(dd(dt).conc(1).dat.rhohv_out, abs(dd(dt).conc(1).dat.diffv_out), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv_out, abs(dd(dt).conc(2).dat.diffv_out), '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv_out, abs(dd(dt).conc(3).dat.diffv_out), '.');
        hold off
        axis square
        xlim([0 1])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(c) |v_{D,out}|', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        subplot(2,2,4)
        s1 = scatter(dd(dt).conc(1).dat.rhohv_in, abs(dd(dt).conc(1).dat.diffv_in), '.');
        hold on
        s2 = scatter(dd(dt).conc(2).dat.rhohv_in, abs(dd(dt).conc(2).dat.diffv_in), '.');
        s3 = scatter(dd(dt).conc(3).dat.rhohv_in, abs(dd(dt).conc(3).dat.diffv_in), '.');
        hold off
        axis square
        xlim([0 1])
        ylim([0 60])
        s1.MarkerEdgeColor = [0.2 0.2 0.2];
        s2.MarkerEdgeColor = [0.7 0.3 0.6];
        s3.MarkerEdgeColor = [0.9 0.6 0.1];
        legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
        title('(d) |v_{D,in}|', 'FontSize', 14)
        xlabel('\rho_{HV}', 'FontSize', 14)
        ylabel('v (m s^{-1})', 'FontSize', 14)
        
        set(gcf, 'Units', 'inches', 'Position', [10 10 10 9])
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['v_D, \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 16);
        axis off
        print([fig_dir '/d' num2str(dt) '-rhohv-diffv-4p'], '-dpng')
        
        end
    end
    
end    

end

%% color fill scatter plots

for dt = dtypes(dtypes ~= 0)
    vbias_min = round( min([min(dd(dt).conc(1).dat.vbias), min(dd(dt).conc(2).dat.vbias)]) / 5) * 5;
    vbias_max = round( max([max(dd(dt).conc(1).dat.vbias), max(dd(dt).conc(2).dat.vbias)]) / 5) * 5;
    diffv_min = round( min([min(dd(dt).conc(1).dat.diffv), min(dd(dt).conc(2).dat.diffv)]) / 2) * 2;
    diffv_max = round( max([max(dd(dt).conc(1).dat.diffv), max(dd(dt).conc(2).dat.diffv)]) / 2) * 2;
    
    [zh_grid1, vbias_grid1] = meshgrid(0:5:70, vbias_min+5:5:vbias_max);
    [zdr_grid1, vbias_grid2] = meshgrid(-5:0.5:5, vbias_min+5:5:vbias_max);
    [phv_grid1, vbias_grid3] = meshgrid(0:0.05:1, vbias_min+5:5:vbias_max);
    if (diffv_max - diffv_min) < (2 * length(vbias_min+5:5:vbias_max)) && (diffv_max - diffv_min) > (0.5 * length(vbias_min+5:5:vbias_max))
        [phv_grid2, diffv_grid1] = meshgrid(0:0.05:1, diffv_min+1:diffv_max);
        [zdr_grid2, diffv_grid2] = meshgrid(-5:0.5:5, diffv_min+1:diffv_max);
        [zh_grid2, diffv_grid3] = meshgrid(0:5:70, diffv_min+1:diffv_max);
        [vbias_grid4, diffv_grid4] = meshgrid(vbias_min+5:5:vbias_max, diffv_min+1:diffv_max);
        df = 1;
    elseif (diffv_max - diffv_min) >= (2 * length(vbias_min+5:5:vbias_max))
        [phv_grid2, diffv_grid1] = meshgrid(0:0.05:1, diffv_min+2:2:diffv_max);
        [zdr_grid2, diffv_grid2] = meshgrid(-5:0.5:5, diffv_min+2:2:diffv_max);
        [zh_grid2, diffv_grid3] = meshgrid(0:5:70, diffv_min+2:2:diffv_max);
        [vbias_grid4, diffv_grid4] = meshgrid(vbias_min+5:5:vbias_max, diffv_min+2:2:diffv_max);
        df = 2;
    elseif (diffv_max - diffv_min) <= (0.5 * length(vbias_min+5:5:vbias_max))
        [phv_grid2, diffv_grid1] = meshgrid(0:0.05:1, diffv_min+0.5:0.5:diffv_max);
        [zdr_grid2, diffv_grid2] = meshgrid(-5:0.5:5, diffv_min+0.5:0.5:diffv_max);
        [zh_grid2, diffv_grid3] = meshgrid(0:5:70, diffv_min+0.5:0.5:diffv_max);
        [vbias_grid4, diffv_grid4] = meshgrid(vbias_min+5:5:vbias_max, diffv_min+0.5:0.5:diffv_max);
        df = 0.5;
    end
    
    Cphv_vbias = zeros(size(phv_grid1,1), size(phv_grid1,2), 3);
    Czdr_vbias = zeros(size(zdr_grid1,1), size(zdr_grid1,2), 3);
    Czh_vbias = zeros(size(zh_grid1,1), size(zh_grid1,2), 3);
    Cphv_diffv = zeros(size(phv_grid2,1), size(phv_grid2,2), 4);
    Czdr_diffv = zeros(size(zdr_grid2,1), size(zdr_grid2,2), 4);
    Czh_diffv = zeros(size(zh_grid2,1), size(zh_grid2,2), 4);
    Cv = zeros(size(vbias_grid4,1), size(vbias_grid4,2), 4);
    
    
    for i = 1:size(vbias_grid1,1)
        for j = 1:size(phv_grid1,2)
            inds1 = find((dd(dt).conc(1).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(1).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(1).dat.rhohv > (j-1)*0.05) & (dd(dt).conc(1).dat.rhohv <= j*0.05));
            inds2 = find((dd(dt).conc(2).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(2).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(2).dat.rhohv > (j-1)*0.05) & (dd(dt).conc(2).dat.rhohv <= j*0.05));
            %inds3 = find((dd(dt).conc(3).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(3).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(3).dat.rhohv > (j-1)*0.05) & (dd(dt).conc(3).dat.rhohv <= j*0.05));
            Cphv_vbias(i,j,1) = length(inds1);
            Cphv_vbias(i,j,2) = length(inds2);
            Cphv_vbias(i,j,3) = length(inds1) + length(inds2);
            %Cphv_vbias(i,j,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for k = 1:size(zdr_grid1,2)
            inds1 = find((dd(dt).conc(1).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(1).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(1).dat.zdr > -5+(k-1)*0.5) & (dd(dt).conc(1).dat.zdr <= -5+k*0.5));
            inds2 = find((dd(dt).conc(2).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(2).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(2).dat.zdr > -5+(k-1)*0.5) & (dd(dt).conc(2).dat.zdr <= -5+k*0.5));
            %inds3 = find((dd(dt).conc(3).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(3).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(3).dat.zdr > -5+(k-1)*0.5) & (dd(dt).conc(3).dat.zdr <= -5+k*0.5));
            Czdr_vbias(i,k,1) = length(inds1);
            Czdr_vbias(i,k,2) = length(inds2);
            Czdr_vbias(i,k,3) = length(inds1) + length(inds2);
            %Czdr_vbias(i,k,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for l = 1:size(zh_grid1,2)
            inds1 = find((dd(dt).conc(1).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(1).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(1).dat.zh > (l-1)*5) & (dd(dt).conc(1).dat.zh <= l*5));
            inds2 = find((dd(dt).conc(2).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(2).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(2).dat.zh > (l-1)*5) & (dd(dt).conc(2).dat.zh <= l*5));
            %inds3 = find((dd(dt).conc(3).dat.vbias > vbias_min+(i-1)*5) & (dd(dt).conc(3).dat.vbias <= vbias_min + i*5) & (dd(dt).conc(3).dat.zh > (l-1)*5) & (dd(dt).conc(3).dat.zh <= l*5));
            Czh_vbias(i,l,1) = length(inds1);
            Czh_vbias(i,l,2) = length(inds2);
            Czh_vbias(i,l,3) = length(inds1) + length(inds2);
            %Czh_vbias(i,l,4) = length(inds1) + length(inds2) + length(inds3);
        end
    end
    
    if false
    for i = 1:size(diffv_grid2,1)
        for j = 1:size(phv_grid2,2)
            inds1 = find((dd(dt).conc(1).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(1).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(1).dat.rhohv > (j-1)*0.05) & (dd(dt).conc(1).dat.rhohv <= j*0.05));
            inds2 = find((dd(dt).conc(2).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(2).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(2).dat.rhohv > (j-1)*0.05) & (dd(dt).conc(2).dat.rhohv <= j*0.05));
            inds3 = find((dd(dt).conc(3).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(3).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(3).dat.rhohv > (j-1)*0.05) & (dd(dt).conc(3).dat.rhohv <= j*0.05));
            Cphv_diffv(i,j,1) = length(inds1);
            Cphv_diffv(i,j,2) = length(inds2);
            Cphv_diffv(i,j,3) = length(inds3);
            Cphv_diffv(i,j,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for k = 1:size(zdr_grid2,2)
            inds1 = find((dd(dt).conc(1).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(1).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(1).dat.zdr > -5+(k-1)*0.5) & (dd(dt).conc(1).dat.zdr <= -5+k*0.5));
            inds2 = find((dd(dt).conc(2).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(2).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(2).dat.zdr > -5+(k-1)*0.5) & (dd(dt).conc(2).dat.zdr <= -5+k*0.5));
            inds3 = find((dd(dt).conc(3).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(3).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(3).dat.zdr > -5+(k-1)*0.5) & (dd(dt).conc(3).dat.zdr <= -5+k*0.5));
            Czdr_diffv(i,k,1) = length(inds1);
            Czdr_diffv(i,k,2) = length(inds2);
            Czdr_diffv(i,k,3) = length(inds3);
            Czdr_diffv(i,k,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for l = 1:size(zh_grid2,2)
            inds1 = find((dd(dt).conc(1).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(1).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(1).dat.zh > (l-1)*5) & (dd(dt).conc(1).dat.zh <= l*5));
            inds2 = find((dd(dt).conc(2).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(2).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(2).dat.zh > (l-1)*5) & (dd(dt).conc(2).dat.zh <= l*5));
            inds3 = find((dd(dt).conc(3).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(3).dat.diffv <= diffv_grid4(i,1)) & (dd(dt).conc(3).dat.zh > (l-1)*5) & (dd(dt).conc(3).dat.zh <= l*5));
            Czh_diffv(i,l,1) = length(inds1);
            Czh_diffv(i,l,2) = length(inds2);
            Czh_diffv(i,l,3) = length(inds3);
            Czh_diffv(i,l,4) = length(inds1) + length(inds2) + length(inds3);
        end
    end
    
    for i = 1:size(diffv_grid4,1)
        for j = 1:size(vbias_grid4,2)
            inds1 = find((dd(dt).conc(1).dat.vbias > vbias_min+(j-1)*5) & (dd(dt).conc(1).dat.vbias <= vbias_min+j*5) & (dd(dt).conc(1).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(1).dat.diffv <= diffv_grid4(i,1)));
            inds2 = find((dd(dt).conc(2).dat.vbias > vbias_min+(j-1)*5) & (dd(dt).conc(2).dat.vbias <= vbias_min+j*5) & (dd(dt).conc(2).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(2).dat.diffv <= diffv_grid4(i,1)));
            inds3 = find((dd(dt).conc(3).dat.vbias > vbias_min+(j-1)*5) & (dd(dt).conc(3).dat.vbias <= vbias_min+j*5) & (dd(dt).conc(3).dat.diffv > diffv_min+(i-1)*df) & (dd(dt).conc(3).dat.diffv <= diffv_grid4(i,1)));
            Cv(i,j,1) = length(inds1);
            Cv(i,j,2) = length(inds2);
            Cv(i,j,3) = length(inds3);
            Cv(i,j,4) = length(inds1) + length(inds2) + length(inds3);
        end
    end
    end
    
    %cmap = pink(64);
    
%     Cphvd(Cphvd == 0) = NaN;
%     Czdrd(Czdrd == 0) = NaN;
%     Czhd(Czhd == 0) = NaN;
%     Cphvp(Cphvp == 0) = NaN;
%     Czdrp(Czdrp == 0) = NaN;
%     Czhp(Czhp == 0) = NaN;
%     Cv(Cv == 0) = NaN;
    
    
    
    if false
    
    figure(21)
    pcolor(phv_grid1, vbias_grid3, Cphv_vbias(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    %title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    title(['v_{bias}, \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 16);
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    %print([fig_dir '/rhohv-histo-1'], '-dpng')
    print([fig_dir '/d' num2str(dt) '-rhohv-vbias-color'], '-dpng')
    
    
    figure(22)
    pcolor(zdr_grid1, vbias_grid2, Czdr_vbias(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['v_{bias}, Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 16);
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    ylabel('v (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/d' num2str(dt) '-zdr-vbias-color'], '-dpng')
    
    
    figure(23)
    pcolor(zh_grid1, vbias_grid1, Czh_vbias(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['v_{bias}, Z_H (debris type ' num2str(dt) ')'], 'FontSize', 16);
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('v (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zh-vbias-color'], '-dpng')
    
    
    figure(24)
    pcolor(phv_grid2, diffv_grid1, Cphv_diffv(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    title(['v_D, \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 16);
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/rhohv-diffv-color'], '-dpng')
    
    
    figure(25)
    pcolor(zdr_grid2, diffv_grid2, Czdr_diffv(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['v_D, Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 16);
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    ylabel('v (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zdr-diffv-color'], '-dpng')
    
    
    figure(26)
    pcolor(zh_grid2, diffv_grid3, Czh_diffv(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['v_D, Z_H (debris type ' num2str(dt) ')'], 'FontSize', 16);
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('v (m s^{-1})', 'FontSize', 14)
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zh-diffv-color'], '-dpng')
    
    
    figure(27)
    clf
    
    subplot(2,3,1)
    pcolor(phv_grid1, vbias_grid3, Cphv_vbias(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    title(['v_{bias}, \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 14);
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,2)
    pcolor(zdr_grid1, vbias_grid2, Czdr_vbias(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['v_{bias}, Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 14);
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,3)
    pcolor(zh_grid1, vbias_grid1, Czh_vbias(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['v_{bias}, Z_H (debris type ' num2str(dt) ')'], 'FontSize', 14);
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('v_{bias} (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,4)
    pcolor(phv_grid2, diffv_grid1, Cphv_diffv(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    title(['v_D, \rho_{HV} (debris type ' num2str(dt) ')'], 'FontSize', 14);
    xlabel('\rho_{HV}', 'FontSize', 14)
    ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,5)
    pcolor(zdr_grid2, diffv_grid2, Czdr_diffv(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['v_D, Z_{DR} (debris type ' num2str(dt) ')'], 'FontSize', 14);
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    subplot(2,3,6)
    pcolor(zh_grid2, diffv_grid3, Czh_diffv(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['v_D, Z_H (debris type ' num2str(dt) ')'], 'FontSize', 14);
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('v_D (m s^{-1})', 'FontSize', 14)
    
    
    set(gcf, 'Units', 'inches', 'Position', [10 7 20 12])
    print([fig_dir '/allmoments-histo'], '-dpng')
    
    
    figure(28)
    pcolor(vbias_grid4, diffv_grid4, Cv(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    title(['Debris type ' num2str(dt) ': \DeltaV comparison'], 'FontSize', 14)
    xlabel('V_{H,debris} - V_{H,none}')
    ylabel('V_H - V_V')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/velbias-histo'], '-dpng')
    
    end
end

%% article plots

if article_figs_flag
    
    fig_dir = '~/Documents/articles/2021/';
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir)
        addpath(genpath(fig_dir))
        savepath
    end
    
    % Delta-V
    figure(1)
    clf
    
    hs = subplot(1,2,1);
    plot(nd.avg.dv, els, '-r', 'LineWidth', 2.5)
    hold on
    plot(dd(1).conc(1).avg.dv, els, 'Color', [0 0.5 0.9], 'LineStyle', ':', 'LineWidth', 2)
    plot(dd(1).conc(2).avg.dv, els, 'Color', [0 0.5 0.9], 'LineStyle', '--', 'LineWidth', 1.7)
    plot(dd(3).conc(1).avg.dv, els, ':k', 'LineWidth', 2)
    plot(dd(3).conc(2).avg.dv, els, '--k', 'LineWidth', 1.7)
    hold off
    xlim([0 200])
    xticks(0:25:200)
    title('\DeltaV', 'FontSize', 16)
    xlabel('Velocity (m s^{-1})', 'FontSize', 14)
    ylabel('Elevation angle (\circ)', 'FontSize', 14)
    legend('Truth', '10,000 leaves', '100,000 leaves', '10,000 wood boards',...
        '100,000 wood boards', 'Location', 'northeastoutside')
    set(hs, 'Position', [0.08 0.11 0.335 0.8150], 'Units', 'normalized')
    
    hs(2) = subplot(1,2,2);
    plot(dcmp(1).conc(1).dv, els, 'Color', [0 0.5 0.9], 'LineStyle', ':', 'LineWidth', 2)
    hold on
    plot(dcmp(1).conc(2).dv, els, 'Color', [0 0.5 0.9], 'LineStyle', '--', 'LineWidth', 1.7)
    plot(dcmp(3).conc(1).dv, els, ':k', 'LineWidth', 2)
    plot(dcmp(3).conc(2).dv, els, '--k', 'LineWidth', 1.7)
    hold off
    xlim([-150 25])
    xticks(-150:25:25)
    title('\DeltaV bias', 'FontSize', 16)
    xlabel('Velocity (m s^{-1})', 'FontSize', 14)
    ylabel('Elevation angle (\circ)', 'FontSize', 14)
    set(hs(2), 'Position', [0.62 0.11 0.335 0.8150], 'Units', 'normalized')
    
    annotation('textbox', [0.08 0.844 0.035 0.08], 'String', 'a',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.62 0.844 0.035 0.08], 'String', 'b',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    
    set(gcf, 'Units', 'inches', 'Position', [2 3 12 5])
    if plot_save
        print([fig_dir 'deltav'], '-dpng')
    end
    
    
    % GBVTD
    vlim = 60;
    
    figure(2)
    clf
    % Plot with axisymmetric nondragged sim instead -- run new sims
    
    ha = subplot(3,3,1);
    pcolor(nd.avg.r, nd.avg.z, nd.avg.u)
    caxis([-vlim vlim])
    colormap(ha, blib('rbmap'))
    shading flat
    title('u_{r, rain} (Truth)', 'FontSize', 14)
    ylabel('Height (m)', 'FontSize', 14)
    set(ha, 'Position', [0.1300 0.7200 0.1900 0.2240], 'Units', 'normalized')
    
    ha(2) = subplot(3,3,2);
    pcolor(nd.avg.r, nd.avg.z, nd.avg.v)
    caxis([-vlim vlim])
    colormap(ha(2), blib('rbmap'))
    shading flat
    title('v_{t, rain} (Truth)', 'FontSize', 14)
    set(ha(2), 'Position', [0.4158 0.7200 0.1900 0.2240], 'Units', 'normalized')
    
    ha(3) = subplot(3,3,3);
    pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), nd.avg.w)
    caxis([-vlim vlim])
    colormap(ha(3), blib('rbmap'))
    c = colorbar;
    c.Label.String = 'Velocity (m s^{-1})';
    c.Label.FontSize = 14;
    c.Label.VerticalAlignment = 'top';
    shading flat
    title('w_{rain} (Truth)', 'FontSize', 14)
    set(ha(3), 'Position', [0.6916 0.7200 0.1800 0.2240], 'Units', 'normalized')
    
    ha(4) = subplot(3,3,4);
    pcolor(nd.avg.r, nd.avg.z, dcmp(3).conc(1).u)
    caxis([-vlim vlim])
    colormap(ha(4), blib('rbmap'))
    shading flat
    title('u_r bias (n = 10,000)', 'FontSize', 14)
    ylabel('Height (m)', 'FontSize', 14)
    set(ha(4), 'Position', [0.1300 0.4096 0.1900 0.2240], 'Units', 'normalized')
    
    ha(5) = subplot(3,3,5);
    pcolor(nd.avg.r, nd.avg.z, dcmp(3).conc(1).v)
    caxis([-vlim vlim])
    colormap(ha(5), blib('rbmap'))
    shading flat
    title('v_t bias (n = 10,000)', 'FontSize', 14)
    set(ha(5), 'Position', [0.4158 0.4096 0.1900 0.2240], 'Units', 'normalized')
    
    ha(6) = subplot(3,3,6);
    pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dcmp(3).conc(1).w)
    caxis([-vlim vlim])
    colormap(ha(6), blib('rbmap'))
    c = colorbar;
    c.Label.String = 'Velocity bias (m s^{-1})';
    c.Label.FontSize = 14;
    c.Label.VerticalAlignment = 'top';
    shading flat
    title('w_ bias (n = 10,000)', 'FontSize', 14)
    set(ha(6), 'Position', [0.6916 0.4096 0.1800 0.2240], 'Units', 'normalized')
    
    ha(7) = subplot(3,3,7);
    pcolor(nd.avg.r, nd.avg.z, dcmp(3).conc(2).u)
    caxis([-vlim vlim])
    colormap(ha(7), blib('rbmap'))
    shading flat
    title('u_r bias (n = 100,000)', 'FontSize', 14)
    xlabel('Tornado-relative{\it r} (m)', 'FontSize', 14)
    ylabel('Height (m)', 'FontSize', 14)
    set(ha(7), 'Position', [0.1300 0.1000 0.1900 0.2240], 'Units', 'normalized')
    
    ha(8) = subplot(3,3,8);
    pcolor(nd.avg.r, nd.avg.z, dcmp(3).conc(2).v)
    caxis([-vlim vlim])
    colormap(ha(8), blib('rbmap'))
    shading flat
    title('v_t bias (n = 100,000)', 'FontSize', 14)
    xlabel('Tornado-relative{\it r} (m)', 'FontSize', 14)
    set(ha(8), 'Position', [0.4158 0.1000 0.1900 0.2240], 'Units', 'normalized')
    
    ha(9) = subplot(3,3,9);
    pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dcmp(3).conc(2).w)
    caxis([-vlim vlim])
    colormap(ha(9), blib('rbmap'))
    c = colorbar;
    c.Label.String = 'Velocity bias (m s^{-1})';
    c.Label.FontSize = 14;
    c.Label.VerticalAlignment = 'top';
    shading flat
    title('w_ bias (n = 100,000)', 'FontSize', 14)
    xlabel('Tornado-relative{\it r} (m)', 'FontSize', 14)
    set(ha(9), 'Position', [0.6916 0.1000 0.1800 0.2240], 'Units', 'normalized')
    
    
    annotation('textbox', [0.3000 0.9180 0.02 0.025], 'String', 'a',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.5860 0.9180 0.02 0.025], 'String', 'b',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.8515 0.9180 0.02 0.025], 'String', 'c',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.3000 0.6075 0.02 0.025], 'String', 'd',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.5860 0.6075 0.02 0.025], 'String', 'e',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.8515 0.6075 0.02 0.025], 'String', 'f',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.3000 0.2985 0.02 0.025], 'String', 'g',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.5860 0.2985 0.02 0.025], 'String', 'h',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.8515 0.2985 0.02 0.025], 'String', 'i',...
        'FontSize',16,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    
    set(gcf,'Units','inches','Position',[1 6 12 10])
    if plot_save
        print([fig_dir 'gbvtd'], '-dpng')
    end
    
    
    figure(3)
    clf
    elind = 4;
    
    subplot(1,3,1)
    s1 = scatter(dd(3).conc(1).dat.zh(:,elind), dd(3).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2 = scatter(dd(3).conc(2).dat.zh(:,elind), dd(3).conc(2).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([0 60])
    ylim([-80 80])
    s1.MarkerEdgeColor = 'k';
    s2.MarkerEdgeColor = [0.8 0.5 0.6];
    legend('10,000 wood boards', '100,000 wood boards', 'Location', 'northeast')
    title('Doppler velocity bias & Z_H', 'FontSize', 14)
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('Velocity bias (m s^{-1})', 'FontSize', 14)
    grid on
    
    subplot(1,3,2)
    s1(2) = scatter(dd(3).conc(1).dat.zdr(:,elind), dd(3).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2(2) = scatter(dd(3).conc(2).dat.zdr(:,elind), dd(3).conc(2).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([-3 3])
    ylim([-80 80])
    xticks(-5:5)
    s1(2).MarkerEdgeColor = 'k';
    s2(2).MarkerEdgeColor = [0.8 0.5 0.6];
    legend('10,000 wood boards', '100,000 wood boards', 'Location', 'northeast')
    title('Doppler velocity bias & Z_{DR}', 'FontSize', 14)
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    grid on
    
    subplot(1,3,3)
    s1(3) = scatter(dd(3).conc(1).dat.rhohv(:,elind), dd(3).conc(1).dat.vbias(:,elind), '.');
    hold on
    s2(3) = scatter(dd(3).conc(2).dat.rhohv(:,elind), dd(3).conc(2).dat.vbias(:,elind), '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-80 80])
    s1(3).MarkerEdgeColor = 'k';
    s2(3).MarkerEdgeColor = [0.8 0.5 0.6];
    legend('10,000 wood boards', '100,000 wood boards', 'Location', 'northeast')
    title('Doppler velocity bias & \rho_{HV}', 'FontSize', 14)
    xlabel('\rho_{HV}', 'FontSize', 14)
    grid on
    
    annotation('textbox', [0.1305 0.799 0.02 0.06], 'String', 'a',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.411 0.799 0.02 0.06], 'String', 'b',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.692 0.799 0.02 0.06], 'String', 'c',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    
    set(gcf, 'Units', 'inches', 'Position', [2 10 16 5])
    if plot_save
        print([fig_dir 'corr_scatter'], '-dpng')
    end
    
    
    figure(4)
    cmap = pink(64);
    
    hs = subplot(1,3,1);
    pcolor(zh_grid1, vbias_grid1, Czh_vbias(:,:,3))
    caxis([0 2000])
    colormap(cmap)
    xlim([0 60])
    ylim([-60 60])
    xticks(0:10:70)
    title('Doppler velocity bias & Z_H', 'FontSize', 14);
    xlabel('Z_H (dBZ)', 'FontSize', 14)
    ylabel('Velocity bias (m s^{-1})', 'FontSize', 14)
    hs(1).Position = [0.08 0.15 0.23 0.75];
    
    hs(2) = subplot(1,3,2);
    pcolor(zdr_grid1, vbias_grid2, Czdr_vbias(:,:,3))
    caxis([0 2000])
    colormap(cmap)
    xlim([-3 3])
    ylim([-60 60])
    xticks(-3:3)
    title('Doppler velocity bias & Z_{DR}', 'FontSize', 14);
    xlabel('Z_{DR} (dB)', 'FontSize', 14)
    hs(2).Position = [0.38 0.15 0.23 0.75];
    
    hs(3) = subplot(1,3,3);
    pcolor(phv_grid1, vbias_grid3, Cphv_vbias(:,:,3))
    caxis([0 2000])
    colormap(cmap)
    colorbar
    xlim([0 1])
    ylim([-60 60])
    xticks(0:0.2:1)
    title('Doppler velocity bias & \rho_{HV}', 'FontSize', 14);
    xlabel('\rho_{HV}', 'FontSize', 14)
    hs(3).Position = [0.68 0.15 0.23 0.75];
    
    annotation('textbox', [0.0805 0.8385 0.02 0.06], 'String', 'a',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.3806 0.8385 0.02 0.06], 'String', 'b',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    annotation('textbox', [0.6806 0.8385 0.02 0.06], 'String', 'c',...
        'FontSize',18,'FontWeight','bold','EdgeColor','k','LineWidth',1,...
        'HorizontalAlignment','center','VerticalAlignment','middle',...
        'BackgroundColor','w')
    
    set(gcf, 'Units', 'inches', 'Position', [2 10 16 5])
    if plot_save
        print([fig_dir 'corr_histo'], '-dpng')
    end
end




