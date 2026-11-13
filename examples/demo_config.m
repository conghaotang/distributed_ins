function [cfg,avp]=demo_config()
%DEMO_CONFIG Define the synthetic demonstration trajectory and its settings.
%
% Inputs
%   None.
%
% Outputs
%   cfg - SI experiment configuration with height aiding disabled.
%   avp - 121-by-7 standard 321 trajectory with source times 0:120 s.
%
% Related functions
%   Calls experiment_config.
%   Called by demo_main.
cfg=experiment_config();
cfg.sim.navigation.heightAiding=false;
t=(0:1:120)';
theta=0.03*sin(t/20);
phi=0.02*cos(t/15);
psi=0.2+0.04*sin(t/30);
B=30*pi/180+2e-5*sin(t/120);
L=114*pi/180+3e-5*sin(t/100);
H=30+0.2*sin(t/25);
avp=[theta,phi,psi,B,L,H,t];
end
