% Checks if two pores are connected. Goal is to prevent isolated pores to
% ensure all pores are connected to each other because we want all porosity=effective porosity 

function overlap_ = overlap(pore_data_1, pore_data_2, pore_throat_length)

    % poreData (1&2) is a 1X4 array that contains the x,y,z coodinates and the
    % radius of the pore respectively 

    % pore_throat_length is the length of the pore throat

    % Distance between the pores
    distance = sqrt((pore_data_1(1,1) - pore_data_2(1,1)) ^ 2 + (pore_data_1(1,2) - pore_data_2(1,2)) ^ 2 + (pore_data_1(1,3) - pore_data_2(1,3)) ^ 2);
    
    % Checking if their is an overlap between the pores, negative means they do not overlap and are seperated by this distance
    over = (pore_data_1(1,4) + pore_data_2(1,4) + pore_throat_length) - distance;
    
    if over > -0.1 % returns 1 if there is an overlap and 0 if there is no overlap
        checker = 1;
    else
        checker = 0;
    end
    
    % Returns if they overlap, the overlapping length, and the distance
    % between the center of the pores
    overlap_ = [checker, over, distance];
end