function [axy, elev, varargout] = gbvtd(vol, varargin)

nels = size(vol.x,3); % number of elevation angles in the volume scan

% ELEV and AXY are struct arrays which will contain the retrieved axisymmetric winds.
elev = struct('u', [], 'v', [], 'w', []); % "PPI"-style view of wind components at each elevation
axy = struct('u', [], 'v', [], 'w', [], 'r', [], 'z', []); % "RHI"-style view of wind components
z = zeros(1,nels+1); % height values of each elevation scan
dz = zeros(1,nels); % height increments
dr = vol.dr(1); % radar range resolution, width of concentric GBVTD circles

%----------Find the coordinates of the tornado center----------%
% I assume that the tornado is centered in both the SimRadar and the
% LES simulation domains.

% Estimate X and Y coordinates of TOR center at each elevation
x_tor = ones(size(vol.x,1), size(vol.x,2), nels) .* repmat(min(abs(mean(vol.x,1))),...
    [size(vol.x,1), size(vol.x,2), 1]);
y_tor = ones(size(vol.y,1), size(vol.y,2), nels) .* repmat(median(mean(vol.y,2),1),...
    [size(vol.y,1), size(vol.y,2), 1]);
% Calculate X and Y distance of each grid point from TOR center
x_dist = vol.x - x_tor;
y_dist = vol.y - y_tor;

alpha = atan(x_dist ./ y_dist); % Azimuth angles w.r.t TOR center
alpha(y_dist < 0) = alpha(y_dist < 0) + pi; % adjust angles SE and SW of TOR center
alpha(x_dist < 0 & y_dist >= 0) = alpha(x_dist < 0 & y_dist >= 0) + 2*pi; % adjust angles NW of TOR center

% Total distance of each grid point from TOR center
r_dist = sqrt(x_dist.^2 + y_dist.^2);
nbins = ceil(max(r_dist,[],'all') / dr); % number of range bins


% "RHI"-style axisymmetric u, v, and r matrices
u = zeros(nbins, nels); 
v = zeros(nbins, nels);
r = zeros(nbins, nels);

for j = 1:nels % loop through elevations
    z(j+1) = mean(vol.z(:,:,j),'all'); % Z starts at surface (z=0)
    dz(j) = z(j+1) - z(j);
    theta = vol.az(:,:,j); % Azimuth angle w.r.t. radar
    C = 0; % translational speed of tornado
    beta = 0; % direction of tornado motion
    D = vol.v(:,:,j); % Doppler velocity
    
    % Ew geometry
    a = sin(alpha - theta);
    b = cos(alpha - theta);
    c = D - C*cos(beta - theta);
    
    u_mat = ones(size(D,1), size(D,2));
    v_mat = ones(size(D,1), size(D,2));
    r_mat = ones(size(D,1), size(D,2));
    utmp = zeros(1,nbins);
    vtmp = zeros(1,nbins);
    rtmp = zeros(1,nbins);
    r1 = zeros(1,nbins);
    r2 = zeros(1,nbins);
    r_ele = r_dist(:,:,j);
    % loop through range bins
    for k = 1:nbins
        r2(k) = k * dr; % far bound of range bin
        r1(k) = r2(k) - dr; % near bound of range bin
        % "PPI"-style matrix of mean binned range value
        r_mat(r_ele > r1(k) & r_ele < r2(k)) = mean(r1(k), r2(k));
        
        % Pull angle values within the current range bin
        aa = a(r_ele > r1(k) & r_ele < r2(k));
        bb = b(r_ele > r1(k) & r_ele < r2(k));
        cc = c(r_ele > r1(k) & r_ele < r2(k));
        
        % Estimate axisymmetric tornado-relative u, v, and r
        uu_num = sum(aa.^2) * sum(bb.*cc) - sum(aa.*bb) * sum(aa.*cc);
        uu_denom = sum(aa.^2) * sum(bb.^2) - (sum(aa.*bb))^2;
        vv_num = sum(bb.^2) * sum(aa.*cc) - sum(aa.*bb) * sum(bb.*cc);
        vv_denom = sum(aa.^2) * sum(bb.^2) - (sum(aa.*bb))^2;
        
        % Mean tornado-relative axisymmetric u, v, r of current bin
        utmp(k) = uu_num / uu_denom;
        vtmp(k) = vv_num / vv_denom;
        rtmp(k) = mean(r_ele(r_ele > r1(k) & r_ele < r2(k)), 'all');
        
        % Save mean values for each range bin in PPI matrix
        u_mat(r_ele > r1(k) & r_ele < r2(k)) = uu_num / uu_denom; % Radial
        v_mat(r_ele > r1(k) & r_ele < r2(k)) = vv_num / vv_denom; % Tangential
        
    end
    
    u(:,j) = utmp; % Axisymmetric RHI matrices
    v(:,j) = vtmp;
    r(:,j) = rtmp;
    elev(j).u = u_mat; % PPI matrices at each elevation
    elev(j).v = v_mat;
end

% Retrieve vertical wind component W
ru = r.*u;
w0 = 0; % zero vertical wind at surface
w = zeros(nbins-2, nels); % can't calculate w at the inner- or outermost range bins

for j = 1:nels % loop through elevations
    w_mat = nan(size(D,1), size(D,2));
    for i = 2:nbins-1 % loop through range bins
        if j == 1 % if at lowest elevation angle
            w(i-1,j) = w0 - dz(j)/(4*dr) * 1/r(i,j) * (ru(i+1,j) + 0 - ...
                ru(i-1,j) - 0);
        else
            w(i-1,j) = w(i-1,j-1) - dz(j)/(4*dr)/r(i,j) * (ru(i+1,j) + ru(i+1,j-1) - ...
                ru(i-1,j) - ru(i-1,j-1));
        end
        % Save mean values for each range bin in PPI matrix
        w_mat(r_ele > r1(i) & r_ele < r2(i)) = w(i-1,j);
    end
    elev(j).w = w_mat; % PPI matrix at each elevation
end

% Remove last range bin from axisymmetric calculations
u(end,:) = [];
v(end,:) = [];
w(end,:) = [];
r(end,:) = [];
z(1) = []; % Remove z=0

% Save RHI-style axisymmetric retrievals
axy.z = repmat(z, [nbins-1 1]); % Axisymmetric matrix of height values for plotting
axy.r = r;
axy.u = u;
axy.v = v;
axy.w = w;

%----------IF COMPARING TO LES----------%
if nargin == 2
    LES = varargin{1};
    
    zind = zeros(1,nels);
    
    phi = atan(LES.x(:,:,1) ./ LES.y(:,:,1)); % Azimuth angles w.r.t TOR center (domain center)
    % adjust angle values for each quadrant
    phi(LES.y(:,:,1) < 0) = phi(LES.y(:,:,1) < 0) + pi; % Lower 2 quadrants
    phi(LES.x(:,:,1) < 0 & LES.y(:,:,1) >= 0) = phi(LES.x(:,:,1) < 0 & LES.y(:,:,1) >= 0) + 2*pi; % Upper left quadrant
    
    r_LES = sqrt((LES.x(:,:,1) - mean(LES.x(:,:,1),'all')).^2 + ...
        (LES.y(:,:,1) - mean(LES.y(:,:,1),'all')).^2);
    nbins = ceil(max(r_LES,[],'all') / dr); % Same size range bins as GBVTD
    
    r_ax = zeros(nbins, nels);
    z_ax = zeros(nbins, nels);
    ur_ax = zeros(nbins, nels);
    vr_ax = zeros(nbins, nels);
    wr_ax = zeros(nbins, nels);
    for j = 1:nels
        % Match times between LES and SimRadar outputs
        tdiff1 = abs(LES.t - vol.t(1)); % Time diffs between all LES and scan start
        tind1 = find(tdiff1 == min(tdiff1)); % Find smallest time diff to get LES start time
        tdiff2 = abs(LES.t - vol.t(end)); % Time diffs between all LES and scan end
        tind2 = find(tdiff2 == min(tdiff2)); % find smallest time diff to get LES end time
        % Find LES heights closest to calculated scan elevations
        zdiff = abs(LES.z(1,1,:) - mean(vol.z(:,:,j), 'all'));
        zind(j) = find(zdiff == min(zdiff));
        
        % Mean u, v, w between start and end times at each elevation
        u = mean(LES.u(:,:,zind(j),tind1:tind2), 4);
        v = mean(LES.v(:,:,zind(j),tind1:tind2), 4);
        w = mean(LES.w(:,:,zind(j),tind1:tind2), 4);
        
        % Calculate radial and tangential component at each grid point
        ur_LES = u.*sin(phi) + v.*cos(phi);
        vr_LES = v.*sin(phi) - u.*cos(phi);
        
        r2 = zeros(1,nbins);
        r1 = zeros(1,nbins);
        
        for k = 1:nbins % loop through range bins
            r2(k) = k * dr;
            r1(k) = r2(k) - dr;
            r_ax(k,j) = mean(r1(k), r2(k));
            % Mean u, v, w, r, z within each range bin at each elevation
            z_ax(k,j) = LES.z(1,1,zind(j));
            ur_ax(k,j) = mean(ur_LES(r_LES > r1(k) & r_LES < r2(k)), 'all');
            vr_ax(k,j) = mean(vr_LES(r_LES > r1(k) & r_LES < r2(k)), 'all');
            wr_ax(k,j) = mean(w(r_LES > r1(k) & r_LES < r2(k)), 'all');
            r_ax(k,j) = mean(r_LES(r_LES > r1(k) & r_LES < r2(k)), 'all');
        end
    end
    varargout{1} = struct('r', r_ax, 'z', z_ax, 'u', ur_ax, 'v', vr_ax, 'w', wr_ax,...
        't', [LES.t(tind1) LES.t(tind2)]);
end


return