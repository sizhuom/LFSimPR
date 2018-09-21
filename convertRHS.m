function [ Rl, tl ] = convertRHS( Rr, tr )
%CONVERTRHS convert right-handed coordinate to left-handed (used by
%POV-Ray)

Mr = [Rr tr(:); zeros(1,3) 1];
F = [1 0 0 0; 0 -1 0 0; 0 0 1 0; 0 0 0 1];
Ml = F * Mr * F;
Rl = Ml(1:3, 1:3);
tl = Ml(1:3, 4);

end

