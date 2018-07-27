clc;
clear;

F    = 15e3; % carrier spacing
M    = 64;
N    = 32;
Mcp  = 16;

SNRdB = inf;
fs    = M*F;

fd = 0;

DL = tukeywin(M+2,0);
DR = tukeywin(N+2,1);

DL = diag(DL(2:end-1));
DR = diag(DR(2:end-1));

ofdmMod = comm.OFDMModulator;
mod = comm.OFDMModulator('FFTLength',128,'NumSymbols',64,...
    'InsertDCNull',true);

mod.PilotInputPort = true;
mod.PilotCarrierIndices = [12;50;100];
showResourceMapping(mod)