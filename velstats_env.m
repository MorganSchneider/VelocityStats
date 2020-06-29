% Outer script for velocitystats.m
clear

new_sims_flag = 1; % Generate the volume-stats.mat files if they don't already exist


% sim_bases: suctvort, suctvort_large, onecell, twocell, torgen
% sim_dates: 200116, 200122, 200615, 200621, 200622
sim_base = 'twocell';
sim_date = '200621';
base_dir = '/Users/schneider/Documents/'; % Directory where you run the script
dir_loc = [base_dir 'sims']; % SimRadar output directory

dtypes = 0:6;
dnums = [1000 10000 100000 1000000];
nd_concept = {'DCU'};
dd_concept = 'DCU';

if new_sims_flag
    
    iq_plot_flag = 0; % Generate checkiq.m plots
    iq_save_flag = 1; % Save checkiq.m variables into .mat file
    plot_flag = [0 0 0 0 0 0]; % Produce each plot from this script
    plot_save_flag = 0; % Save plots from this script
    LES_flag = 0; % Compare sim retrievals with LES ground truth
    var_save_flag = 1; % Save swp/les/avg variables
    
    
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

nd = struct('swp', [], 'avg', []);
dd = struct('num', []);
dd.num = struct('swp', [], 'avg', []);
dcmp = struct('num', []);
dcmp.num = struct('dv', [], 'vort', [], 'u', [], 'v', [], 'w', []);

load([base_dir 'stats/' sim_base '/nd/nd_DCU_volume-stats.mat'])

nd.swp = swp;
nd.avg = avg.swp;

els = avg.swp.els;
r = avg.swp.r;
z = avg.swp.z;
azv = avg.swp.az_vol;
rv = avg.swp.r_vol;
elv = avg.swp.el_vol;



for dt = dtypes(dtypes ~= 0)
    for n = 1:4
        load([base_dir 'stats/' sim_base '/d' num2str(dt) '/n' num2str(10^(n+2)) ...
            '_' dd_concept '_volume-stats.mat'])
        dd(dt).num(n).swp = swp;
        dd(dt).num(n).avg = avg.swp;
        
        dcmp(dt).num(n).dv = dd(dt).num(n).avg.dv - nd.avg.dv;
        dcmp(dt).num(n).vort = dd(dt).num(n).avg.vort - nd.avg.vort;
        dcmp(dt).num(n).u = dd(dt).num(n).avg.u - nd.avg.u;
        dcmp(dt).num(n).v = dd(dt).num(n).avg.v - nd.avg.v;
        dcmp(dt).num(n).w = dd(dt).num(n).avg.w - nd.avg.w;
    end
end

for dt = dtypes(dtypes ~= 0)
    fig_dir = [base_dir 'stats/' sim_base '/d' num2str(dt)];
    
    figure(1)
    clf
    plot(dcmp(dt).num(1).dv, els, ':b', 'LineWidth', 1)
    hold on
    plot(dcmp(dt).num(2).dv, els, '-.b', 'LineWidth', 1)
    plot(dcmp(dt).num(3).dv, els, '--b', 'LineWidth', 1)
    plot(dcmp(dt).num(4).dv, els, '-b', 'LineWidth', 1)
    hold off
    title(['Debris type ' num2str(dt) ': \DeltaV=f(n)'])
    xlabel('V (m/s)')
    ylabel('Elev. angle')
    legend('n=1,000', 'n=10,000', 'n=100,000', 'n=1,000,000', 'Location', 'best')
    grid on
    
    print([fig_dir '/deltaV-diff'], '-dpng')
    
    
    for n = 1:4
        % suctvort: [-0.2, -0.1, 0.1, 0.2]
        % suctvort_large: [-0.2, -0.1, 0.1, 0.2]
        % onecell: 
        % twocell: 
        % torgen: 
        % moore: 
        % 
        % 2d: [0.4, 0.07, 0.07, 0.4]
        % 3d: [0.3, 0.03, 0.03, 0.3]
        
        figure(2)
        clf
        axis tight manual
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, -0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
        hold on
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, -0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
        % [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, 0.0); %50th percentile
        % patch('Vertices', v, 'Faces', f, 'FaceColor', 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.05)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, 0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.03)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, 0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
        hold off
        xlim([round(min(azv,[],'all'),2), round(max(azv,[],'all'),2)])
        ylim([round(min(rv,[],'all'),-1), round(max(rv,[],'all'),-1)])
        zlim([0, 5])
        xlabel('Azim. angle')
        ylabel('Rad. distance (m)')
        zlabel('Elev. angle')
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+2)) ': pseudovorticity'])
        legend('-0.2s^{-1}', '-0.1s^{-1}', '0.1s^{-1}', '0.2s^{-1}', 'Location', 'eastoutside')
        grid on
        
        view(3)
        print([fig_dir '/n' num2str(10^(n+2)) '_vorticity-diff-3d'], '-dpng')
        
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
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, -0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
        hold on
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, -0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.07)
        % [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, 0.0); %50th percentile
        % patch('Vertices', v, 'Faces', f, 'FaceColor', 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.05)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, 0.1);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'magenta', 'EdgeColor', 'none', 'FaceAlpha', 0.07)
        [f,v] = isosurface(azv, rv, elv, dcmp(dt).num(n).vort, 0.2);
        patch('Vertices', v, 'Faces', f, 'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.4)
        hold off
        xlim([round(min(azv,[],'all'),2), round(max(azv,[],'all'),2)])
        ylim([round(min(rv,[],'all'),-1), round(max(rv,[],'all'),-1)])
        zlim([0, 5])
        xlabel('Azim. angle')
        ylabel('Rad. distance (m)')
        zlabel('Elev. angle')
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+2)) ': pseudovorticity'])
        legend('-0.2s^{-1}', '-0.1s^{-1}', '0.1s^{-1}', '0.2s^{-1}', 'Location', 'eastoutside')
        grid on
        
        view(2)
        print([fig_dir '/n' num2str(10^(n+2)) '_vorticity-diff-2d'], '-dpng')
        
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
        c = subplot(2,3,1);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).num(n).avg.u)
        caxis([-1 1] * max(abs(dd(dt).num(n).avg.u),[],'all'))
        colormap(c, blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('U_r (m/s)')
        xlabel('Distance from tor center (m)')
        ylabel('Height (m)')
        
        c(2) = subplot(2,3,2);
        pcolor(nd.avg.r, nd.avg.z, dd(dt).num(n).avg.v)
        caxis([-1 1] * max(abs(dd(dt).num(n).avg.v),[],'all'))
        colormap(c(2), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('V_r (m/s)')
        xlabel('Distance from tor center (m)')
        ylabel('Height (m)')
        
        c(3) = subplot(2,3,3);
        pcolor(nd.avg.r(2:end-1,:), nd.avg.z(2:end-1,:), dd(dt).num(n).avg.w)
        caxis([-1 1] * max(abs(dd(dt).num(n).avg.w),[],'all'))
        colormap(c(3), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('W_r (m/s)')
        xlabel('Distance from tor center (m)')
        ylabel('Height (m)')
        
        c(4) = subplot(2,3,4);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).num(n).u)
        caxis([-1 1] * max(abs(dcmp(dt).num(n).u),[],'all'))
        colormap(c(4), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('\DeltaU_r (m/s)')
        xlabel('Distance from tor center (m)')
        ylabel('Height (m)')
        
        c(5) = subplot(2,3,5);
        pcolor(nd.avg.r, nd.avg.z, dcmp(dt).num(n).v)
        caxis([-1 1] * max(abs(dcmp(dt).num(n).v),[],'all'))
        colormap(c(5), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('\DeltaV_r (m/s)')
        xlabel('Distance from tor center (m)')
        ylabel('Height (m)')
        
        c(6) = subplot(2,3,6);
        pcolor(nd.avg.r(2:end-1,:), nd.avg.z(2:end-1,:), dcmp(dt).num(n).w)
        caxis([-1 1] * max(abs(dcmp(dt).num(n).w),[],'all'))
        colormap(c(6), blib('rbmap'))
        colorbar
        shading flat
        axis square
        title('\DeltaW_r (m/s)')
        xlabel('Distance from tor center (m)')
        ylabel('Height (m)')
        
        axes('Unit', 'Normalized', 'Position', [0.5 0.95 0.01 0.01])
        title(['Debris type ' num2str(dt) ', n=' num2str(10^(n+2)) ': GBVTD comparison'], 'FontSize', 14);
        axis off
        % set(gcf, 'Position', [left_bound bottom_bound width height]
        set(gcf,'Units','inches','Position',[10 10 14 7])
        
        print([fig_dir '/n' num2str(10^(n+2)) '_gbvtd-diff'], '-dpng')
        
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






