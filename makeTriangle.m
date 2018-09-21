function [ T ] = makeTriangle( pos, dir, sz )
%MAKETRIANGLE make a triangle whose centroid is the location of the ray,
% and normal is the direction of the ray.
% This is done by first create a triangle in xy-plane with centroid at
% origin, and then transform it.

% original triangle (each column is a vertex)
% normals need to be determined by left hand rule
% since POV-Ray uses left-handed coordinate system?
T = [ 0 sz/2 -sz/2;
       sz*2/3 -sz/3 -sz/3;
       0 0 0];

% rotate the triangle
z = [ 0; 0; 1 ];
dir = dir/norm(dir);
d = dir - z;
if (norm(d) ~= 0)
    e = cross(z, d);
    e = e / norm(e);
    e = repmat(e,1,3);
    theta = acos((z'*z+dir'*dir-d'*d)/(2*norm(z)*norm(dir)));
    
    T = cos(theta)*T+sin(theta)*cross(e,T)...
        +(1-cos(theta))*bsxfun(@times,dot(e,T),e);
end

% translate the triangle
T = bsxfun(@plus,T,pos);

% verify that requirements are met
debug = 0;
if debug
    centroid = (T(:,1)+T(:,2)+T(:,3)) / 3;
    normal = -cross(T(:,2)-T(:,1),T(:,3)-T(:,2));
    normal = normal / norm(normal);
    if (norm(centroid-pos)>sz*0.01 || dot(normal,dir) < 0.99)
        fprintf('Error:\n');
        disp(pos); disp(centroid);
        disp(dir); disp(normal);
    end
end

end

