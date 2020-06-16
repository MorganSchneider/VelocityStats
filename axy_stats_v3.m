%Computes axisymmetric statistics for u,v,w, and other desired variables
function [ur_mean, vr_mean, wr_mean, pr_mean, ang_mom_mean, tke_mean, stats, rtmp2, ztmp2] = axy_stats_v3(Xm, Ym, Zm, xtmp2, ytmp2, xmin, ymin, ustore, vstore, wstore, pstore, tkestore, avg_file, v0)

% for ldx=1:size(ustore,4)
    theta = zeros(max(size(xtmp2)), max(size(ytmp2)), size(Xm,3));
    rr = theta;
    ur = theta;
    vr = theta;
    for kdx = 1:size(Xm,3)
        theta(1:max(size(xtmp2)), 1:max(size(ytmp2)), kdx) = atan2(squeeze(Ym(xtmp2,ytmp2,kdx)) - ymin(kdx), squeeze(Xm(xtmp2,ytmp2,kdx)) - xmin(kdx));
        rr(1:max(size(xtmp2)), 1:max(size(ytmp2)), kdx) = sqrt((squeeze(Xm(xtmp2,ytmp2,kdx)) - xmin(kdx)) .^2 + (squeeze(Ym(xtmp2,ytmp2,kdx)) - ymin(kdx)) .^2 );
        ur(1:max(size(xtmp2)), 1:max(size(ytmp2)), kdx) = ustore(:,:,kdx) .* cos(theta(:,:,kdx)) + vstore(:,:,kdx) .* sin(theta(:,:,kdx));
        vr(1:max(size(xtmp2)), 1:max(size(ytmp2)), kdx) = -ustore(:,:,kdx) .* sin(theta(:,:,kdx)) + vstore(:,:,kdx) .* cos(theta(:,:,kdx));
    end
% end
% ur=squeeze(ur);
% vr=squeeze(vr);

dr = 30;
rtmp = 0: dr: dr * floor(nanmax(Xm(:))/dr);
%cnt_idx = 1;
%Loop through and find the maximum tangential velocity at each range bin
%and height
min_bound = 1;
% for ldx=1:size(ustore,4)
    ur_mean = zeros(max(size(rtmp))-1, size(Xm,3)-min_bound+1);
    vr_mean = ur_mean;
    wr_mean = ur_mean;
    pr_mean = ur_mean;
    tke_mean = ur_mean;
    for idx = 1:max(size(rtmp)) - 1
        yn = rr > rtmp(idx) & rr < rtmp(idx + 1); 
        for jdx = 1:size(Xm,3)
            yntmp = squeeze(yn(:,:,jdx));
            if size(pstore,1) > 1
                prtmp = squeeze(pstore(:,:,jdx));
            else
                prtmp = [];
            end
            wrtmp = squeeze(wstore(:,:,jdx));
            vrtmp = squeeze(vr(:,:,jdx));
            urtmp = squeeze(ur(:,:,jdx));
            if avg_file && size(tkestore,1) > 1
                tketmp = squeeze(tkestore(:,:,jdx));
            else
                tketmp = [];
            end
            ur_mean(idx, jdx-min_bound+1) = nanmean(urtmp(yntmp));
            vr_mean(idx, jdx-min_bound+1) = nanmean(vrtmp(yntmp));
            wr_mean(idx, jdx-min_bound+1) = nanmean(wrtmp(yntmp));
            if size(pstore,1) > 1
                pr_mean(idx, jdx-min_bound+1) = nanmean(prtmp(yntmp));
            else
                pr_mean(idx, jdx-min_bound+1) = NaN;
            end
            if avg_file && size(tkestore,1) > 1
                tke_mean(idx, jdx-min_bound+1) = nanmean(tketmp(yntmp)); 
            else
                tke_mean(idx, jdx-min_bound+1) = NaN;
            end
        end
    end
% end

if ~avg_file
    tke_mean = [];
end

%Apply a spatial filter to upper right corner where waves occur
r_start = round(max(size(rtmp))/3);
z_start = 20;
z_start2 = size(Xm,3) - 10;
urtmp = ur_mean;
vrtmp = vr_mean;
wrtmp = wr_mean;
prtmp = pr_mean;
tketmp = tke_mean;
for idx = r_start: max(size(rtmp))-1
    for jdx = z_start: z_start2-1
        ur_mean(idx,jdx) = urtmp(idx,jdx-1) * 0.25 + urtmp(idx,jdx) * 0.5 + urtmp(idx,jdx+1) * 0.25;
        vr_mean(idx,jdx) = vrtmp(idx,jdx-1) * 0.25 + vrtmp(idx,jdx) * 0.5 + vrtmp(idx,jdx+1) * 0.25;
        wr_mean(idx,jdx) = wrtmp(idx,jdx-1) * 0.25 + wrtmp(idx,jdx) * 0.5 + wrtmp(idx,jdx+1) * 0.25;
        pr_mean(idx,jdx) = prtmp(idx,jdx-1) * 0.25 + prtmp(idx,jdx) * 0.5 + prtmp(idx,jdx+1) * 0.25;
        tke_mean(idx,jdx) = tketmp(idx,jdx-1) * 0.25 + tketmp(idx,jdx) * 0.5 + tketmp(idx,jdx+1) * 0.25;
    end
end
for idx = 1:max(size(rtmp))-1
    for jdx = z_start2: size(Xm,3)-1
        ur_mean(idx,jdx) = urtmp(idx,jdx-1) * 0.25 + urtmp(idx,jdx) * 0.5 + urtmp(idx,jdx+1) * 0.25;
        vr_mean(idx,jdx) = vrtmp(idx,jdx-1) * 0.25 + vrtmp(idx,jdx) * 0.5 + vrtmp(idx,jdx+1) * 0.25;
        wr_mean(idx,jdx) = wrtmp(idx,jdx-1) * 0.25 + wrtmp(idx,jdx) * 0.5 + wrtmp(idx,jdx+1) * 0.25;
        pr_mean(idx,jdx) = prtmp(idx,jdx-1) * 0.25 + prtmp(idx,jdx) * 0.5 + prtmp(idx,jdx+1) * 0.25;
        tke_mean(idx,jdx) = tketmp(idx,jdx-1) * 0.25 + tketmp(idx,jdx) * 0.5 + tketmp(idx,jdx+1) * 0.25;
    end
end

rtmp = (rtmp(2:max(size(rtmp))) + rtmp(1:max(size(rtmp))-1)) / 2;
rtmp2 = repmat(rtmp, [size(Zm,3) 1]);
ztmp2 = repmat(squeeze(Zm(1,1,1:size(Zm,3))), [1 max(size(rtmp))]);
num_gamma = 5;

ztmps = squeeze(Zm(1,1,:));
z_mid = (ztmps(1:max(size(ztmps))-1) + ztmps(2:max(size(ztmps)))) / 2;
dz(1) = z_mid(1);
dz(2:max(size(z_mid))) = z_mid(2:max(size(z_mid))) - z_mid(1:max(size(z_mid))-1);
clear ztmps;

% for ldx=1:size(ustore,4)
    vr_mean_tmp = squeeze(vr_mean(:,:));
    ur_mean_tmp = squeeze(ur_mean(:,:));
    [vmax, ind] = nanmax(vr_mean_tmp,[],1);
    if min(size(ind)) > 0
        rmax = zeros(1,max(size(ind)));
        for jdx = 1:max(size(ind))
            %[c, ind] = nanmax(vr_mean,[],1);
            if ind(jdx) + 1 < max(size(rtmp))
                rmax(jdx) = nanmean(rtmp(ind(jdx): ind(jdx)+1));
            end
        end
        rmax_med = median(rmax(round(max(size(rmax))/2): max(size(rmax))));
        [c2,i2] = min(abs(rmax-rmax_med));
        yn = rmax(:) > rmax_med * 0.9;
        core_ind = find(yn);
        if min(size(core_ind)) == 0
            stats.vc = nanmax(vmax(round(max(size(vmax))/2): max(size(vmax))));
        else
            stats.vc = nanmax(vmax(core_ind));
        end
    else
        rmax(jdx) = [];
        rmax_med = [];
        stats_vc = NaN;
    end
%     %Values inside of RMW
%     stats.vmax=nanmax(nanmax(vr_mean(1:i2(1),:)));
%     stats.umin=nanmin(nanmin(ur_mean(1:i2(1),:)));
%     stats.wmin=nanmin(nanmin(wr_mean(1:i2(1),:)));
%     stats.wmax=nanmax(nanmax(wr_mean(1:i2(1),:)));
%     stats.ip=stats.vmax/stats.vc;
    
    ang_mom = rtmp2 .* vr_mean_tmp';
    ang_mom_mean(:,:) = ang_mom;
    store_i = zeros(1, size(ang_mom,1));
    for rdx = 1:size(ang_mom,1)
        [c,i] = nanmax(ang_mom(rdx,:));
        store_i(rdx) = i;
    end
    ang_mom_inf_all = ang_mom(:, ceil(median(store_i)));
    ang_mom_inf = median(ang_mom_inf_all);
    
    gamma_tmp = zeros(size(ur_mean,1), num_gamma);
    for idx = 1:num_gamma
       gamma_tmp(1:size(ur_mean,1), idx) = -2 * pi * (rtmp) .* ur_mean_tmp(:,idx)' .* (ang_mom_inf-ang_mom(idx,:)) * dz(idx); 
    end
    gamma = sum(gamma_tmp,2);

    stats.Sc = rmax_med * ang_mom_inf ^ 2 / nanmax(gamma);
% end

