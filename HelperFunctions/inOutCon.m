% Checks if the pores connect to the designated inlet and outlet
% boundaries. Goal is to ensure all pores are connected to the inlet and outlet we want all porosity=effective porosity.

function checker = inOutCon(pore_data, half_domain_length)

    % pore_data is a 1X4 array that contains the x,y,z coodinates and the radius of the pore respectively. 
    
    % half_domain_length is half the designated length scale the rock
    % domain in the X-direction. since the digital rock is centerd at 0, the spatial length
    % of the rock along the X goes from -half_domain_length to +half_domain_length. Note the rock
    % domain is a perfect cube so this length scale is thee same in all directions. 

    % Defining the extreme limits of the incoming pore
    x_min = pore_data(1,1) - pore_data(1,4);
    x_max = pore_data(1,1) + pore_data(1,4);
    
    % Detecting if the incoming pore will go past the range of the core
    if x_min < -half_domain_length || x_max > half_domain_length % returns 1 if true and 0 if false
        checker = 1; 
    else
        checker = 0;
    end

end