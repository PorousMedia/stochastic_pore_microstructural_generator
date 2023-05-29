% Ensures pores are connected and the number of pores connected to a single
% pore is minimal. Goal is to prevent concentration of pores in one
% locations as they need to spread through the rock domain.  

function checker = poreCon(pore_data_1, pore_data_2, number_of_attempts, pore_throat_length)

    % pore_data_1 is an nX4 array that contains the x,y,z coodinates and the
    % radius of the pore respectively. n depends on the number of already
    % established connected pores
    
    % pore_data_2 is a 1X4 array that contains the x,y,z coodinates and the
    % radius of the pore respectively 
    
    % number_of_attempts is the number of number_of_attemptss made to cooenct an incoming pore to
    % an existing pore system

    % pore_throat_length is the length of the pore throat

    % Initiallizing a check detct if a logic is satisfied. the role of the counter is to identify if the number of
    % overlap surpasses the set limit and is greater than 0
    temp_check = 0;
    
    % Initiallizing a switch to help code detect if there is atleast an overlap or not
    counter = 0;
    
    % Initial number of overlaps a new pore can have
    limit = 1;
    
    % The limit is increased when the number of trials get higher
    if number_of_attempts > 40000
        limit = 2;
    end
    
%     if number_of_attempts > 30000
%         limit = 3;
%     end
%     
%     if number_of_attempts > 32000
%         limit = 4;
%     end
%     
%     if number_of_attempts > 35000
%         limit = 5;
%     end
%     
%     if number_of_attempts > 40000
%         limit = 6;
%     end
    
    % Identifying the existing pore network to help chenck if pore_data_2
    % intersect with any of them
    start= 1;
    stop = size(pore_data_1, 1);
    if start < 1
        start = 1;
    end
    
    % Running the logic check if the pore intersect as few pores as
    % possible

    % If temp_check==1, logic is not satisfies beacause the number of pore
    % intersections surpasses the set limit
    for x = start:stop
        temp = overlap(pore_data_1(x,:), pore_data_2, pore_throat_length);
        if temp(1) == 1
            counter= counter + 1;
            if counter > limit
                temp_check = 1;
                break
            end
        end
    end
    
    % Also, if there is no overlap "temp_check = 1", so it can still go back to
    % finding new cordinate to assign 
    if counter == 0
        temp_check = 1;
    end

    % Return temp_check, to help determine if the new pore_data_2 is accepted (0) of
    % not(1)
    checker = temp_check;
end