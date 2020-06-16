function T = VelStatsMakeTable(r, u)

u_mean = squeeze(mean(u,3));
u_max = squeeze(max(u,[],3));
u_min = squeeze(min(u,[],3));
u_err = std(u,0,3);

RadialDistance = r(:,1);

Mean_005deg = u_mean(:,1);
Mean_010deg = u_mean(:,2);
Mean_015deg = u_mean(:,3);
Mean_020deg = u_mean(:,4);
Mean_025deg = u_mean(:,5);
Mean_030deg = u_mean(:,6);
Mean_035deg = u_mean(:,7);
Mean_040deg = u_mean(:,8);
Mean_045deg = u_mean(:,9);
Mean_050deg = u_mean(:,10);

Max_005deg = u_max(:,1);
Max_010deg = u_max(:,2);
Max_015deg = u_max(:,3);
Max_020deg = u_max(:,4);
Max_025deg = u_max(:,5);
Max_030deg = u_max(:,6);
Max_035deg = u_max(:,7);
Max_040deg = u_max(:,8);
Max_045deg = u_max(:,9);
Max_050deg = u_max(:,10);

Min_005deg = u_min(:,1);
Min_010deg = u_min(:,2);
Min_015deg = u_min(:,3);
Min_020deg = u_min(:,4);
Min_025deg = u_min(:,5);
Min_030deg = u_min(:,6);
Min_035deg = u_min(:,7);
Min_040deg = u_min(:,8);
Min_045deg = u_min(:,9);
Min_050deg = u_min(:,10);

ErrorL_005deg = u_mean(:,1) - u_err(:,1);
ErrorL_010deg = u_mean(:,2) - u_err(:,2);
ErrorL_015deg = u_mean(:,3) - u_err(:,3);
ErrorL_020deg = u_mean(:,4) - u_err(:,4);
ErrorL_025deg = u_mean(:,5) - u_err(:,5);
ErrorL_030deg = u_mean(:,6) - u_err(:,6);
ErrorL_035deg = u_mean(:,7) - u_err(:,7);
ErrorL_040deg = u_mean(:,8) - u_err(:,8);
ErrorL_045deg = u_mean(:,9) - u_err(:,9);
ErrorL_050deg = u_mean(:,10) - u_err(:,10);

ErrorU_005deg = u_mean(:,1) + u_err(:,1);
ErrorU_010deg = u_mean(:,2) + u_err(:,2);
ErrorU_015deg = u_mean(:,3) + u_err(:,3);
ErrorU_020deg = u_mean(:,4) + u_err(:,4);
ErrorU_025deg = u_mean(:,5) + u_err(:,5);
ErrorU_030deg = u_mean(:,6) + u_err(:,6);
ErrorU_035deg = u_mean(:,7) + u_err(:,7);
ErrorU_040deg = u_mean(:,8) + u_err(:,8);
ErrorU_045deg = u_mean(:,9) + u_err(:,9);
ErrorU_050deg = u_mean(:,10) + u_err(:,10);


T = table(RadialDistance, Mean_005deg, Mean_010deg, Mean_015deg, Mean_020deg, Mean_025deg, Mean_030deg, Mean_035deg, Mean_040deg, Mean_045deg, Mean_050deg,...
    Max_005deg, Max_010deg, Max_015deg, Max_020deg, Max_025deg, Max_030deg, Max_035deg, Max_040deg, Max_045deg, Max_050deg,...
    Min_005deg, Min_010deg, Min_015deg, Min_020deg, Min_025deg, Min_030deg, Min_035deg, Min_040deg, Min_045deg, Min_050deg,...
    ErrorL_005deg, ErrorL_010deg, ErrorL_015deg, ErrorL_020deg, ErrorL_025deg, ErrorL_030deg, ErrorL_035deg, ErrorL_040deg, ErrorL_045deg, ErrorL_050deg,...
    ErrorU_005deg, ErrorU_010deg, ErrorU_015deg, ErrorU_020deg, ErrorU_025deg, ErrorU_030deg, ErrorU_035deg, ErrorU_040deg, ErrorU_045deg, ErrorU_050deg);



end