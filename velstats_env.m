% Outer script for velocitystats.m
clear all
close all

new_sims_flag = 1; % Generate the volume-stats.mat files if they don't already exist


% sim_bases: suctvort, suctvort_large, onecell, twocell, torgen
% sim_dates: 200116, 200122, 200708, 200630, 200622
sim_base = 'twocell';
sim_date = '200630';
base_dir = '/Users/schneider/Documents/'; % Directory where you run the script
dir_loc = [base_dir 'sims']; % SimRadar output directory

dtypes = 0:14;
dnums = [10000 100000 1000000];
dexp = length(num2str(dnums(1))) - 2;
nd_concept = {'DCU'};
dd_concept = 'DCU';

if new_sims_flag
    
    iq_plot_flag = 0; % Generate checkiq.m plots
    iq_save_flag = 1; % Save checkiq.m variables into .mat file
    plot_flag = [1 1 1 0 0 1]; % Produce each plot from velocitystats.m
    plot_save_flag = 1; % Save plots from velocitystats.m
    LES_flag = 1; % Compare sim retrievals with LES in velocitystats.m
    var_save_flag = 1; % Save swp/les/avg variables from velocitystats.m
    state_flag = 0;
    
    
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
    
end

%%

nd = struct('dat', [], 'swp', [], 'avg', []);
dd = struct('conc', []);
dd.conc = struct('dat', [], 'swp', [], 'avg', []);
dcmp = struct('conc', []);
dcmp.conc = struct('dv', [], 'dv90', [], 'dv75', [], 'vort', [], 'u', [], 'v', [], 'w', []);

load([base_dir 'stats/' sim_base '/nd/nd_DCU_volume-stats.mat'])

nd.swp = swp;
nd.avg = avg.swp;
nd.dat = data;

nd.dat.ZH = reshape(mean(nd.dat.zh, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
nd.dat.ZV = reshape(mean(nd.dat.zv, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
nd.dat.VH = reshape(mean(nd.dat.vh, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
nd.dat.VV = reshape(mean(nd.dat.vv, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
nd.dat.ZDR = reshape(mean(nd.dat.zdr, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
nd.dat.rhoHV = reshape(mean(nd.dat.rhohv, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);

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
        
        dd(dt).conc(n).dat.ZH = reshape(mean(dd(dt).conc(n).dat.zh, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
        dd(dt).conc(n).dat.ZV = reshape(mean(dd(dt).conc(n).dat.zv, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
        dd(dt).conc(n).dat.VH = reshape(mean(dd(dt).conc(n).dat.vh, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
        dd(dt).conc(n).dat.VV = reshape(mean(dd(dt).conc(n).dat.vv, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
        dd(dt).conc(n).dat.ZDR = reshape(mean(dd(dt).conc(n).dat.zdr, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
        dd(dt).conc(n).dat.rhoHV = reshape(mean(dd(dt).conc(n).dat.rhohv, [3 4]), [1, size(data.iqh,1)*size(data.iqh,2)]);
        ininds = find(dd(dt).conc(n).dat.VH < 0);
        outinds = find(dd(dt).conc(n).dat.VH > 0);
        dd(dt).conc(n).dat.vbiasd_in = dd(dt).conc(n).dat.VH(ininds) - nd.dat.VH(ininds);
        dd(dt).conc(n).dat.vbiasp_in = dd(dt).conc(n).dat.VH(ininds) - dd(dt).conc(n).dat.VV(ininds);
        dd(dt).conc(n).dat.vbiasd_out = dd(dt).conc(n).dat.VH(outinds) - nd.dat.VH(outinds);
        dd(dt).conc(n).dat.vbiasp_out = dd(dt).conc(n).dat.VH(outinds) - dd(dt).conc(n).dat.VV(outinds);
        dd(dt).conc(n).dat.vbias_deb = dd(dt).conc(n).dat.VH - nd.dat.VH;
        dd(dt).conc(n).dat.vbias_pol = dd(dt).conc(n).dat.VH - dd(dt).conc(n).dat.VV;
        
        dcmp(dt).conc(n).dv = dd(dt).conc(n).avg.dv - nd.avg.dv;
        dcmp(dt).conc(n).dv90 = dd(dt).conc(n).avg.dv90 - nd.avg.dv90;
        dcmp(dt).conc(n).dv75 = dd(dt).conc(n).avg.dv75 - nd.avg.dv75;
        dcmp(dt).conc(n).vort = dd(dt).conc(n).avg.vort - nd.avg.vort;
        dcmp(dt).conc(n).u = dd(dt).conc(n).avg.u - nd.avg.u;
        dcmp(dt).conc(n).v = dd(dt).conc(n).avg.v - nd.avg.v;
        dcmp(dt).conc(n).w = dd(dt).conc(n).avg.w - nd.avg.w;
    end
end


%% 

for dt = dtypes(dtypes ~= 0)
    fig_dir = [base_dir 'imgs/' sim_base '/d' num2str(dt)];
    
    figure(1)
    clf
    
    subplot(1,2,1)
    plot(nd.avg.dv, els, '-r', 'LineWidth', 1)
    hold on
    plot(dd(dt).conc(1).avg.dv, els, ':k', 'LineWidth', 1)
    plot(dd(dt).conc(2).avg.dv, els, '--k', 'LineWidth', 1)
    plot(dd(dt).conc(3).avg.dv, els, '-k', 'LineWidth', 1)
    % plot(dd(dt).conc(4).avg.dv, els, '-k', 'LineWidth', 1)
    hold off
    xlim([0 200])
    title(['Debris type ' num2str(dt) ': \DeltaV'])
    xlabel('V (m/s)')
    ylabel('Elev. angle')
    legend('none', 'n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    grid on
    axis square
    
    subplot(1,2,2)
    plot(dcmp(dt).conc(1).dv, els, ':b', 'LineWidth', 1)
    hold on
    plot(dcmp(dt).conc(2).dv, els, '--b', 'LineWidth', 1)
    plot(dcmp(dt).conc(3).dv, els, '-b', 'LineWidth', 1)
    % plot(dcmp(dt).conc(4).dv, els, '-b', 'LineWidth', 1)
    hold off
    xlim([-150 0])
    title(['Debris type ' num2str(dt) ': Maximum \DeltaV residual'])
    xlabel('V (m/s)')
    ylabel('Elev. angle')
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    grid on
    axis square
    

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

    set(gcf, 'Units', 'inches', 'Position', [10 10 10 5])
    print([fig_dir '/deltaV-diff'], '-dpng')
    
    
    for n = 1:length(dnums)
        % [-0.2, -0.1, 0.1, 0.2]
        % 
        % 2d: [0.4, 0.07, 0.07, 0.4]
        % 3d: [0.3, 0.03, 0.03, 0.3]
        
        figure(2)
        clf
        axis tight manual
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
        hold on
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
        % [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.0); %50th percentile
        % patch('Vertices', v, 'Faces', f, 'FaceColor', 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.05)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
        hold off
        xlim([round(min(azv,[],'all'),2), round(max(azv,[],'all'),2)])
        ylim([round(min(rv,[],'all'),-1), round(max(rv,[],'all'),-1)])
        zlim([0, 5])
        xlabel('Azim. angle')
        ylabel('Rad. distance (m)')
        zlabel('Elev. angle')
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp)) ': pseudovorticity'])
        legend('-0.2s^{-1}', '-0.1s^{-1}', '0.1s^{-1}', '0.2s^{-1}', 'Location', 'eastoutside')
        grid on
        
        view(3)
        print([fig_dir '/n' num2str(10^(n+dexp)) '_vorticity-diff-3d'], '-dpng')
        
        F = getframe(gcf);
        im = frame2im(F);
        [imind,cm] = rgb2ind(im,256);
        if n == 1
            imwrite(imind, cm, [fig_dir '/vorticity-diff-3d.gif'],...
                'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
        else
            imwrite(imind, cm, [fig_dir '/vorticity-diff-3d.gif'],...
                'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
        end
        
        
        figure(3)
        clf
        axis tight manual
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
        hold on
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, -0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.07)
        % [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.0); %50th percentile
        % patch('Vertices', v, 'Faces', f, 'FaceColor', 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.05)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.07)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).conc(n).vort, 0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
        hold off
        xlim([round(min(azv,[],'all'),2), round(max(azv,[],'all'),2)])
        ylim([round(min(rv,[],'all'),-1), round(max(rv,[],'all'),-1)])
        zlim([0, 5])
        xlabel('Azim. angle')
        ylabel('Rad. distance (m)')
        zlabel('Elev. angle')
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp)) ': pseudovorticity'])
        legend('-0.2s^{-1}', '-0.1s^{-1}', '0.1s^{-1}', '0.2s^{-1}', 'Location', 'eastoutside')
        grid on
        
        view(2)
        axis square
        print([fig_dir '/n' num2str(10^(n+dexp)) '_vorticity-diff-2d'], '-dpng')
        
        F = getframe(gcf);
        im = frame2im(F);
        [imind,cm] = rgb2ind(im,256);
        if n == 1
            imwrite(imind, cm, [fig_dir '/vorticity-diff-2d.gif'],...
                'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
        else
            imwrite(imind, cm, [fig_dir '/vorticity-diff-2d.gif'],...
                'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
        end
        
        
        figure(4)
        clf
        vlim = 60;
        
        c = subplot(3,3,1);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).conc(n).avg.u)
        % caxis([-1 1] * max(abs(dd(dt).conc(n).avg.u),[],'all'))
        caxis([-vlim vlim])
        colormap(c, blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('Debris - U_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)')
        ylabel('Height (m)', 'FontSize', 20)
        
        c(2) = subplot(3,3,2);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).conc(n).avg.v)
        % caxis([-1 1] * max(abs(dd(dt).conc(n).avg.v),[],'all'))
        caxis([-vlim vlim])
        colormap(c(2), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('Debris - V_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)')
        %ylabel('Height (m)')
        
        c(3) = subplot(3,3,3);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dd(dt).conc(n).avg.w)
        % caxis([-1 1] * max(abs(dd(dt).conc(n).avg.w),[],'all'))
        caxis([-vlim vlim])
        colormap(c(3), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('Debris - W_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)')
        %ylabel('Height (m)')
        
        c(4) = subplot(3,3,4);
        pcolor(nd.avg.r, nd.avg.z, nd.avg.u)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).u),[],'all'))
        caxis([-vlim vlim])
        colormap(c(4), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('No debris - U_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)')
        ylabel('Height (m)', 'FontSize', 20)
        
        c(5) = subplot(3,3,5);
        pcolor(nd.avg.r, nd.avg.z, nd.avg.v)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).v),[],'all'))
        caxis([-vlim vlim])
        colormap(c(5), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('No debris - V_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)')
        %ylabel('Height (m)')
        
        c(6) = subplot(3,3,6);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), nd.avg.w)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).w),[],'all'))
        caxis([-vlim vlim])
        colormap(c(6), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('No debris - W_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)')
        %ylabel('Height (m)')
        
        c(7) = subplot(3,3,7);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).conc(n).u)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).u),[],'all'))
        caxis([-vlim vlim])
        colormap(c(7), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('\DeltaU_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)', 'FontSize', 18)
        ylabel('Height (m)', 'FontSize', 20)
        
        c(8) = subplot(3,3,8);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).conc(n).v)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).v),[],'all'))
        caxis([-vlim vlim])
        colormap(c(8), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('\DeltaV_r', 'FontSize', 20)
        xlabel('Distance from tor center (m)', 'FontSize', 20)
        %ylabel('Height (m)')
        
        c(9) = subplot(3,3,9);
        pcolor(nd.avg.r(1:end-1,:), nd.avg.z(1:end-1,:), dcmp(dt).conc(n).w)
        % caxis([-1 1] * max(abs(dcmp(dt).conc(n).w),[],'all'))
        caxis([-vlim vlim])
        colormap(c(9), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('\DeltaW_r', 'FontSize', 20)
        %xlabel('Distance from tor center (m)', 'FontSize', 18)
        %ylabel('Height (m)')
        
%         axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
%         title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+dexp)) ': GBVTD comparison'], 'FontSize', 14);
%         axis off
        % set(gcf, 'Position', [left_bound bottom_bound width height]
        set(gcf,'Units','inches','Position',[10 10 14 12])
        
        print([fig_dir '/n' num2str(10^(n+dexp)) '_gbvtd-diff'], '-dpng')
        
        F = getframe(gcf);
        im = frame2im(F);
        [imind,cm] = rgb2ind(im,256);
        if n == 1
            imwrite(imind, cm, [fig_dir '/gbvtd-diff.gif'],...
                'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
        else
            imwrite(imind, cm, [fig_dir '/gbvtd-diff.gif'],...
                'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
        end
    end
end


%% Bias scatter plots

for dt = dtypes(dtypes ~= 0)
    fig_dir = [base_dir 'imgs/' sim_base '/d' num2str(dt)];
    
    figure(5)
    clf
    s1 = scatter(dd(dt).conc(1).dat.rhoHV, dd(dt).conc(1).dat.vbias_deb, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.rhoHV, dd(dt).conc(2).dat.vbias_deb, '.');
    s3 = scatter(dd(dt).conc(3).dat.rhoHV, dd(dt).conc(3).dat.vbias_deb, '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2]; % green: [0.2 0.6 0.3]
    s2.MarkerEdgeColor = [0.7 0.3 0.6]; % purple
    s3.MarkerEdgeColor = [0.9 0.6 0.1]; % dark yellow
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/rhohv-bias-1'], '-dpng')
    
    
    figure(6)
    clf
    s1 = scatter(dd(dt).conc(1).dat.rhoHV, dd(dt).conc(1).dat.vbias_pol, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.rhoHV, dd(dt).conc(2).dat.vbias_pol, '.');
    s3 = scatter(dd(dt).conc(3).dat.rhoHV, dd(dt).conc(3).dat.vbias_pol, '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/rhohv-bias-2'], '-dpng')
    
    
    figure(7)
    clf
    s1 = scatter(dd(dt).conc(1).dat.ZDR, dd(dt).conc(1).dat.vbias_deb, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.ZDR, dd(dt).conc(2).dat.vbias_deb, '.');
    s3 = scatter(dd(dt).conc(3).dat.ZDR, dd(dt).conc(3).dat.vbias_deb, '.');
    hold off
    axis square
    xlim([-5 5])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_{DR} [dBZ]')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zdr-bias-1'], '-dpng')
    
    
    figure(8)
    clf
    s1 = scatter(dd(dt).conc(1).dat.ZDR, dd(dt).conc(1).dat.vbias_pol, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.ZDR, dd(dt).conc(2).dat.vbias_pol, '.');
    s3 = scatter(dd(dt).conc(3).dat.ZDR, dd(dt).conc(3).dat.vbias_pol, '.');
    hold off
    axis square
    xlim([-5 5])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_{DR} [dBZ]')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zdr-bias-2'], '-dpng')
    
    
    figure(9)
    clf
    s1 = scatter(dd(dt).conc(1).dat.ZH, dd(dt).conc(1).dat.vbias_deb, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.ZH, dd(dt).conc(2).dat.vbias_deb, '.');
    s3 = scatter(dd(dt).conc(3).dat.ZH, dd(dt).conc(3).dat.vbias_deb, '.');
    hold off
    axis square
    xlim([0 70])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_H [dBZ]')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zh-bias-1'], '-dpng')
    
    
    figure(10)
    clf
    s1 = scatter(dd(dt).conc(1).dat.ZH, dd(dt).conc(1).dat.vbias_pol, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.ZH, dd(dt).conc(2).dat.vbias_pol, '.');
    s3 = scatter(dd(dt).conc(3).dat.ZH, dd(dt).conc(3).dat.vbias_pol, '.');
    hold off
    axis square
    xlim([0 70])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_H [dBZ]')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zh-bias-2'], '-dpng')
    
    
    
    figure(11)
    clf
    
    subplot(2,3,1)
    s1 = scatter(dd(dt).conc(1).dat.rhoHV, dd(dt).conc(1).dat.vbias_deb, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.rhoHV, dd(dt).conc(2).dat.vbias_deb, '.');
    s3 = scatter(dd(dt).conc(3).dat.rhoHV, dd(dt).conc(3).dat.vbias_deb, '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,2)
    s1(2) = scatter(dd(dt).conc(1).dat.ZDR, dd(dt).conc(1).dat.vbias_deb, '.');
    hold on
    s2(2) = scatter(dd(dt).conc(2).dat.ZDR, dd(dt).conc(2).dat.vbias_deb, '.');
    s3(2) = scatter(dd(dt).conc(3).dat.ZDR, dd(dt).conc(3).dat.vbias_deb, '.');
    hold off
    axis square
    xlim([-5 5])
    ylim([-60 60])
    xticks(-5:5)
    s1(2).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(2).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(2).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_{DR}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,3)
    s1(3) = scatter(dd(dt).conc(1).dat.ZH, dd(dt).conc(1).dat.vbias_deb, '.');
    hold on
    s2(3) = scatter(dd(dt).conc(2).dat.ZH, dd(dt).conc(2).dat.vbias_deb, '.');
    s3(3) = scatter(dd(dt).conc(3).dat.ZH, dd(dt).conc(3).dat.vbias_deb, '.');
    hold off
    axis square
    xlim([0 70])
    ylim([-60 60])
    s1(3).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(3).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(3).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_H')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,4)
    s1(4) = scatter(dd(dt).conc(1).dat.rhoHV, dd(dt).conc(1).dat.vbias_pol, '.');
    hold on
    s2(4) = scatter(dd(dt).conc(2).dat.rhoHV, dd(dt).conc(2).dat.vbias_pol, '.');
    s3(4) = scatter(dd(dt).conc(3).dat.rhoHV, dd(dt).conc(3).dat.vbias_pol, '.');
    hold off
    axis square
    xlim([0 1])
    ylim([-60 60])
    s1(4).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(4).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(4).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,5)
    s1(5) = scatter(dd(dt).conc(1).dat.ZDR, dd(dt).conc(1).dat.vbias_pol, '.');
    hold on
    s2(5) = scatter(dd(dt).conc(2).dat.ZDR, dd(dt).conc(2).dat.vbias_pol, '.');
    s3(5) = scatter(dd(dt).conc(3).dat.ZDR, dd(dt).conc(3).dat.vbias_pol, '.');
    hold off
    axis square
    xlim([-5 5])
    ylim([-60 60])
    xticks(-5:5)
    s1(5).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(5).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(5).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_{DR}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,6)
    s1(6) = scatter(dd(dt).conc(1).dat.ZH, dd(dt).conc(1).dat.vbias_pol, '.');
    hold on
    s2(6) = scatter(dd(dt).conc(2).dat.ZH, dd(dt).conc(2).dat.vbias_pol, '.');
    s3(6) = scatter(dd(dt).conc(3).dat.ZH, dd(dt).conc(3).dat.vbias_pol, '.');
    hold off
    axis square
    xlim([0 70])
    ylim([-60 60])
    s1(6).MarkerEdgeColor = [0.2 0.2 0.2];
    s2(6).MarkerEdgeColor = [0.7 0.3 0.6];
    s3(6).MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_H')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 7 20 12])
    print([fig_dir '/allmoments-bias'], '-dpng')
    
    
    figure(12)
    s1 = scatter(dd(dt).conc(1).dat.vbias_deb, dd(dt).conc(1).dat.vbias_pol, '.');
    hold on
    s2 = scatter(dd(dt).conc(2).dat.vbias_deb, dd(dt).conc(2).dat.vbias_pol, '.');
    s3 = scatter(dd(dt).conc(3).dat.vbias_deb, dd(dt).conc(3).dat.vbias_pol, '.');
    hold off
    axis square
    s1.MarkerEdgeColor = [0.2 0.2 0.2];
    s2.MarkerEdgeColor = [0.7 0.3 0.6];
    s3.MarkerEdgeColor = [0.9 0.6 0.1];
    legend('n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'northwest')
    title(['Debris type ' num2str(dt) ': \DeltaV comparison'], 'FontSize', 14)
    xlabel('V_{H,debris} - V_{H,none}')
    ylabel('V_H - V_V')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/velbias-compare'], '-dpng')
    
    
    
    vdmin = round( min([min(dd(dt).conc(1).dat.vbias_deb), min(dd(dt).conc(2).dat.vbias_deb), min(dd(dt).conc(3).dat.vbias_deb)]) / 5) * 5;
    vdmax = round( max([max(dd(dt).conc(1).dat.vbias_deb), max(dd(dt).conc(2).dat.vbias_deb), max(dd(dt).conc(3).dat.vbias_deb)]) / 5) * 5;
    vpmin = round( min([min(dd(dt).conc(1).dat.vbias_pol), min(dd(dt).conc(2).dat.vbias_pol), min(dd(dt).conc(3).dat.vbias_pol)]) / 2) * 2;
    vpmax = round( max([max(dd(dt).conc(1).dat.vbias_pol), max(dd(dt).conc(2).dat.vbias_pol), max(dd(dt).conc(3).dat.vbias_pol)]) / 2) * 2;
    
    [phvgrid1, vdgrid1] = meshgrid(0:0.05:1, vdmin+5:5:vdmax);
    [zdrgrid1, vdgrid2] = meshgrid(-5:0.5:5, vdmin+5:5:vdmax);
    [zhgrid1, vdgrid3] = meshgrid(0:5:70, vdmin+5:5:vdmax);
    if (vpmax - vpmin) < (2 * length(vdmin+5:5:vdmax)) && (vpmax - vpmin) > (0.5 * length(vdmin+5:5:vdmax))
        [phvgrid2, vpgrid1] = meshgrid(0:0.05:1, vpmin+1:vpmax);
        [zdrgrid2, vpgrid2] = meshgrid(-5:0.5:5, vpmin+1:vpmax);
        [zhgrid2, vpgrid3] = meshgrid(0:5:70, vpmin+1:vpmax);
        [vdgrid4, vpgrid4] = meshgrid(vdmin+5:5:vdmax, vpmin+1:vpmax);
        df = 1;
    elseif (vpmax - vpmin) >= (2 * length(vdmin+5:5:vdmax))
        [phvgrid2, vpgrid1] = meshgrid(0:0.05:1, vpmin+2:2:vpmax);
        [zdrgrid2, vpgrid2] = meshgrid(-5:0.5:5, vpmin+2:2:vpmax);
        [zhgrid2, vpgrid3] = meshgrid(0:5:70, vpmin+2:2:vpmax);
        [vdgrid4, vpgrid4] = meshgrid(vdmin+5:5:vdmax, vpmin+2:2:vpmax);
        df = 2;
    elseif (vpmax - vpmin) <= (0.5 * length(vdmin+5:5:vdmax))
        [phvgrid2, vpgrid1] = meshgrid(0:0.05:1, vpmin+0.5:0.5:vpmax);
        [zdrgrid2, vpgrid2] = meshgrid(-5:0.5:5, vpmin+0.5:0.5:vpmax);
        [zhgrid2, vpgrid3] = meshgrid(0:5:70, vpmin+0.5:0.5:vpmax);
        [vdgrid4, vpgrid4] = meshgrid(vdmin+5:5:vdmax, vpmin+0.5:0.5:vpmax);
        df = 0.5;
    end
    
    Cphvd = zeros(size(phvgrid1,1), size(phvgrid1,2), 4);
    Czdrd = zeros(size(zdrgrid1,1), size(zdrgrid1,2), 4);
    Czhd = zeros(size(zhgrid1,1), size(zhgrid1,2), 4);
    Cphvp = zeros(size(phvgrid2,1), size(phvgrid2,2), 4);
    Czdrp = zeros(size(zdrgrid2,1), size(zdrgrid2,2), 4);
    Czhp = zeros(size(zhgrid2,1), size(zhgrid2,2), 4);
    Cv = zeros(size(vdgrid4,1), size(vdgrid4,2), 4);
    
    
    for i = 1:size(vdgrid1,1)
        for j = 1:size(phvgrid1,2)
            inds1 = find((dd(dt).conc(1).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(1).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(1).dat.rhoHV > (j-1)*0.05) & (dd(dt).conc(1).dat.rhoHV <= j*0.05));
            inds2 = find((dd(dt).conc(2).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(2).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(2).dat.rhoHV > (j-1)*0.05) & (dd(dt).conc(2).dat.rhoHV <= j*0.05));
            inds3 = find((dd(dt).conc(3).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(3).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(3).dat.rhoHV > (j-1)*0.05) & (dd(dt).conc(3).dat.rhoHV <= j*0.05));
            Cphvd(i,j,1) = length(inds1);
            Cphvd(i,j,2) = length(inds2);
            Cphvd(i,j,3) = length(inds3);
            Cphvd(i,j,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for k = 1:size(zdrgrid1,2)
            inds1 = find((dd(dt).conc(1).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(1).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(1).dat.ZDR > -5+(k-1)*0.5) & (dd(dt).conc(1).dat.ZDR <= -5+k*0.5));
            inds2 = find((dd(dt).conc(2).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(2).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(2).dat.ZDR > -5+(k-1)*0.5) & (dd(dt).conc(2).dat.ZDR <= -5+k*0.5));
            inds3 = find((dd(dt).conc(3).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(3).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(3).dat.ZDR > -5+(k-1)*0.5) & (dd(dt).conc(3).dat.ZDR <= -5+k*0.5));
            Czdrd(i,k,1) = length(inds1);
            Czdrd(i,k,2) = length(inds2);
            Czdrd(i,k,3) = length(inds3);
            Czdrd(i,k,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for l = 1:size(zhgrid1,2)
            inds1 = find((dd(dt).conc(1).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(1).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(1).dat.ZH > (l-1)*5) & (dd(dt).conc(1).dat.ZH <= l*5));
            inds2 = find((dd(dt).conc(2).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(2).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(2).dat.ZH > (l-1)*5) & (dd(dt).conc(2).dat.ZH <= l*5));
            inds3 = find((dd(dt).conc(3).dat.vbias_deb > vdmin+(i-1)*5) & (dd(dt).conc(3).dat.vbias_deb <= vdmin + i*5) & (dd(dt).conc(3).dat.ZH > (l-1)*5) & (dd(dt).conc(3).dat.ZH <= l*5));
            Czhd(i,l,1) = length(inds1);
            Czhd(i,l,2) = length(inds2);
            Czhd(i,l,3) = length(inds3);
            Czhd(i,l,4) = length(inds1) + length(inds2) + length(inds3);
        end
    end
    
    for i = 1:size(vpgrid2,1)
        for j = 1:size(phvgrid2,2)
            inds1 = find((dd(dt).conc(1).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(1).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(1).dat.rhoHV > (j-1)*0.05) & (dd(dt).conc(1).dat.rhoHV <= j*0.05));
            inds2 = find((dd(dt).conc(2).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(2).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(2).dat.rhoHV > (j-1)*0.05) & (dd(dt).conc(2).dat.rhoHV <= j*0.05));
            inds3 = find((dd(dt).conc(3).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(3).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(3).dat.rhoHV > (j-1)*0.05) & (dd(dt).conc(3).dat.rhoHV <= j*0.05));
            Cphvp(i,j,1) = length(inds1);
            Cphvp(i,j,2) = length(inds2);
            Cphvp(i,j,3) = length(inds3);
            Cphvp(i,j,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for k = 1:size(zdrgrid2,2)
            inds1 = find((dd(dt).conc(1).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(1).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(1).dat.ZDR > -5+(k-1)*0.5) & (dd(dt).conc(1).dat.ZDR <= -5+k*0.5));
            inds2 = find((dd(dt).conc(2).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(2).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(2).dat.ZDR > -5+(k-1)*0.5) & (dd(dt).conc(2).dat.ZDR <= -5+k*0.5));
            inds3 = find((dd(dt).conc(3).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(3).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(3).dat.ZDR > -5+(k-1)*0.5) & (dd(dt).conc(3).dat.ZDR <= -5+k*0.5));
            Czdrp(i,k,1) = length(inds1);
            Czdrp(i,k,2) = length(inds2);
            Czdrp(i,k,3) = length(inds3);
            Czdrp(i,k,4) = length(inds1) + length(inds2) + length(inds3);
        end
        
        for l = 1:size(zhgrid2,2)
            inds1 = find((dd(dt).conc(1).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(1).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(1).dat.ZH > (l-1)*5) & (dd(dt).conc(1).dat.ZH <= l*5));
            inds2 = find((dd(dt).conc(2).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(2).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(2).dat.ZH > (l-1)*5) & (dd(dt).conc(2).dat.ZH <= l*5));
            inds3 = find((dd(dt).conc(3).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(3).dat.vbias_pol <= vpgrid4(i,1)) & (dd(dt).conc(3).dat.ZH > (l-1)*5) & (dd(dt).conc(3).dat.ZH <= l*5));
            Czhp(i,l,1) = length(inds1);
            Czhp(i,l,2) = length(inds2);
            Czhp(i,l,3) = length(inds3);
            Czhp(i,l,4) = length(inds1) + length(inds2) + length(inds3);
        end
    end
    
    for i = 1:size(vpgrid4,1)
        for j = 1:size(vdgrid4,2)
            inds1 = find((dd(dt).conc(1).dat.vbias_deb > vdmin+(j-1)*5) & (dd(dt).conc(1).dat.vbias_deb <= vdmin+j*5) & (dd(dt).conc(1).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(1).dat.vbias_pol <= vpgrid4(i,1)));
            inds2 = find((dd(dt).conc(2).dat.vbias_deb > vdmin+(j-1)*5) & (dd(dt).conc(2).dat.vbias_deb <= vdmin+j*5) & (dd(dt).conc(2).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(2).dat.vbias_pol <= vpgrid4(i,1)));
            inds3 = find((dd(dt).conc(3).dat.vbias_deb > vdmin+(j-1)*5) & (dd(dt).conc(3).dat.vbias_deb <= vdmin+j*5) & (dd(dt).conc(3).dat.vbias_pol > vpmin+(i-1)*df) & (dd(dt).conc(3).dat.vbias_pol <= vpgrid4(i,1)));
            Cv(i,j,1) = length(inds1);
            Cv(i,j,2) = length(inds2);
            Cv(i,j,3) = length(inds3);
            Cv(i,j,4) = length(inds1) + length(inds2) + length(inds3);
        end
    end
    
    cmap = pink(64);
    
%     Cphvd(Cphvd == 0) = NaN;
%     Czdrd(Czdrd == 0) = NaN;
%     Czhd(Czhd == 0) = NaN;
%     Cphvp(Cphvp == 0) = NaN;
%     Czdrp(Czdrp == 0) = NaN;
%     Czhp(Czhp == 0) = NaN;
%     Cv(Cv == 0) = NaN;
    
    
    
    
    figure(13)
    clf
    pcolor(phvgrid1, vdgrid1, Cphvd(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/rhohv-histo-1'], '-dpng')
    
    
    figure(14)
    clf
    pcolor(zdrgrid1, vdgrid2, Czdrd(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_{DR}')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zdr-histo-1'], '-dpng')
    
    
    figure(15)
    clf
    pcolor(zhgrid1, vdgrid3, Czhd(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_H')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zh-histo-1'], '-dpng')
    
    
    figure(16)
    clf
    pcolor(phvgrid2, vpgrid1, Cphvp(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/rhohv-histo-2'], '-dpng')
    
    
    figure(17)
    clf
    pcolor(zdrgrid2, vpgrid2, Czdrp(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_{DR}')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zdr-histo-2'], '-dpng')
    
    
    figure(18)
    clf
    pcolor(zhgrid2, vpgrid3, Czhp(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_H')
    ylabel('\DeltaV [m/s]')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/zh-histo-2'], '-dpng')
    
    
    figure(19)
    clf
    
    subplot(2,3,1)
    pcolor(phvgrid1, vdgrid1, Cphvd(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,2)
    pcolor(zdrgrid1, vdgrid2, Czdrd(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_{DR}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,3)
    pcolor(zhgrid1, vdgrid3, Czhd(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['Debris type ' num2str(dt) ': V_{H,debris} - V_{H,none}'], 'FontSize', 14)
    xlabel('Z_H')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,4)
    pcolor(phvgrid2, vpgrid1, Cphvp(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 1])
    xticks(0:0.1:1)
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('\rho_{HV}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,5)
    pcolor(zdrgrid2, vpgrid2, Czdrp(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([-5 5])
    xticks(-5:5)
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_{DR}')
    ylabel('\DeltaV [m/s]')
    
    subplot(2,3,6)
    pcolor(zhgrid2, vpgrid3, Czhp(:,:,4))
    axis square
    colormap(cmap)
    %colorbar
    xlim([0 70])
    xticks(0:10:70)
    title(['Debris type ' num2str(dt) ': V_H - V_V'], 'FontSize', 14)
    xlabel('Z_H')
    ylabel('\DeltaV [m/s]')
    
    
    set(gcf, 'Units', 'inches', 'Position', [10 7 20 12])
    print([fig_dir '/allmoments-histo'], '-dpng')
    
    
    figure(20)
    pcolor(vdgrid4, vpgrid4, Cv(:,:,4))
    axis square
    colormap(cmap)
    colorbar
    title(['Debris type ' num2str(dt) ': \DeltaV comparison'], 'FontSize', 14)
    xlabel('V_{H,debris} - V_{H,none}')
    ylabel('V_H - V_V')
    
    set(gcf, 'Units', 'inches', 'Position', [10 10 7 7])
    print([fig_dir '/velbias-histo'], '-dpng')
end






