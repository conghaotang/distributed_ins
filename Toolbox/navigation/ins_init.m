function ins=ins_init(initial,cfg)
%INS_INIT Initialize a navigation state with one to six subsamples per update.
%
% Inputs
%   initial - Cbn is b-to-n, vn is ENU velocity (m/s), and pos is [B L H] (rad, rad, m).
%   cfg - Earth parameters and integer ins.subsampleCount from 1 to 6.
%
% Outputs
%   ins - State with Cbn, column vectors vn/pos, earth, and subs.
%
% Related functions
%   Called by navigation_cases.
subs=cfg.ins.subsampleCount;
assert(isscalar(subs) && subs>=1 && subs<=6 && subs==fix(subs), ...
    'dins:SubsampleCount','The subsample count must be an integer from 1 to 6.');
ins.Cbn=initial.Cbn;
ins.vn=initial.vn(:);
ins.pos=initial.pos(:);
ins.earth=cfg.earth;
ins.subs=subs;
end
