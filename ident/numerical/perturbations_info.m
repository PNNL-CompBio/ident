% get all parameter perturbation values set in a structure array
function details = perturbations_info()

details = struct([]);
% wild type
details(1).id = 14;
details(1).change = 0;
% acetate perturbations
details(2).id = 14;
details(2).change = 4;
details(3).id = 14;
details(3).change = 9;
% k1cat perturbations
details(4).id = 11;
details(4).change = .1;
details(5).id = 11;
details(5).change = .5;
details(6).id = 11;
details(6).change = 1;
details(7).id = 11;
details(7).change = -.1;
details(8).id = 11;
details(8).change = -.5;
% V3max perturbations
details(9).id = 12;
details(9).change = .1;
details(10).id = 12;
details(10).change = .5;
details(11).id = 12;
details(11).change = 1;
details(12).id = 12;
details(12).change = -.1;
details(13).id = 12;
details(13).change = -.5;
% V2max perturbation
details(14).id = 13;
details(14).change = .1;
details(15).id = 13;
details(15).change = .5;
details(16).id = 13;
details(16).change = 1;
details(17).id = 13;
details(17).change = -.1;
details(18).id = 13;
details(18).change = -.5;
