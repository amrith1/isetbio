%{ 
    Plot testing set reconstruction statistics.
%} 

% For RGC selectivity sweep
sels
ssim_sels
mse_sels
r_square_sels

figure;
xlabel('RGC Selectivity (%)')
grid on;

yyaxis left
plot(sels*100, r_square_sels,'Marker','o');
ylabel('R-Squared')

yyaxis right
plot(sels*100, ssim_sels,'Marker','o');
ylabel('SSIM')

% For all other sweeps
eccs = [0 -5 -10 -15];
pos = ['0000'; '0500'; '1000'; '1500'];
ssim_sels_ecc = zeros(4,1);
mse_sels_ecc = zeros(4,1);
r_square_sels_ecc = zeros(4,1);

for e = 1:length(eccs)
    load(['dim1717_pos' pos(e,:) '_dist25_ecc_sweep.mat'],'mse_sels','ssim_sels','r_square_sels');
    ssim_sels_ecc(e) = ssim_sels;
    mse_sels_ecc(e) = mse_sels;
    r_square_sels_ecc(e) = r_square_sels;
end

figure;
xlabel('Eccentricity (Deg)')
grid on;

yyaxis left
plot(eccs, r_square_sels_ecc,'Marker','o');
ylabel('R-Squared')

yyaxis right
plot(eccs, ssim_sels_ecc,'Marker','o');
ylabel('SSIM')