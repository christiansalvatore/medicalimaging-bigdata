%-------------------------------------------------------------------------
% Matteo Interlenghi (IBFM-CNR)
% matteo.interlenghi@ibfm.cnr.it
%-------------------------------------------------------------------------

function [area, N] = compute__area(M, voxel__dimension)

    x = size(M,1);
    y = size(M,2);
    z = size(M,3);
    dx = voxel__dimension(1,1)/10;
    dy = voxel__dimension(1,2)/10;
    dz = voxel__dimension(1,3)/10;
    
    %Receive 3D matrix, matrix dimensions and voxel dimensions
    area = 0;
    N = zeros(x,y,z);
    for k=1:z
        for j=1:y
            if M(1,j,k)>0
                area=area+(dz*dy);
                N(1,j,k)=1;
            end
            if M(x,j,k)>0
                area=area+(dz*dy);
                N(x,j,k)=1;
            end

        end
    end
    for k=1:z
        for i=1:x
            if M(i,1,k)>0
                area=area+(dz*dx);
                N(i,1,k)=1;
            end
            if M(i,y,k)>0
                area=area+(dz*dx);
                N(i,y,k)=1;
            end

        end
    end
    for j=1:y
        for i=1:x
            if M(i,j,1)>0
                area=area+(dy*dx);
                N(i,j,1)=1;
            end
            if M(i,j,z)>0
                area=area+(dy*dx);
                N(i,j,z)=1;
            end

        end
    end
    for i=1:x
        for j=1:y
            for k=1:z
                if k>1 && M(i,j,k)>0 && M(i,j,k-1)==0
                    area=area+(dx*dy);
                    N(i,j,k)=1;
                end
                if k<z && M(i,j,k)>0 && M(i,j,k+1)==0
                    area=area+(dx*dy);
                    N(i,j,k)=1;
                end
                if i>1 && M(i,j,k)>0 && M(i-1,j,k)==0
                    area=area+(dz*dy);
                    N(i,j,k)=1;
                end
                if i<x && M(i,j,k)>0 && M(i+1,j,k)==0
                    area=area+(dz*dy);
                    N(i,j,k)=1;
                end
                if j>1 && M(i,j,k)>0 && M(i,j-1,k)==0
                    area=area+(dz*dx);
                    N(i,j,k)=1;
                end
                if j<y && M(i,j,k)>0 && M(i,j+1,k)==0
                    area=area+(dz*dx);
                    N(i,j,k)=1;
                end
            end
        end
    end
    
end

