% This code creates CSV files for pore bodies and pore throats, which are needed to generate 3D pore microstructures in STAR-CCM+.

% Clear memory.
clear

% Add path to data and helper functions.
addpath('.\Data') 
addpath('.\HelperFunctions') 

% Enter Variables.
filename = "sample_b.csv"; % The file has four columns [pore body radius, frequency, porosity, representative pore-throat size].
number_of_pores = 10; 
porosity_adjustment = 0.92; % Hyperparameter to make up for the overlap in order to maintain given porosity. Requires some tuning. Increasing this value reduces porosity. if the tuning is too close to 1 or too close to 0.5, the code will likely crash.0.87 is optimal.
start = 1; % First sample generated.
finish = 1; % Last sample generated.
tolerance = 5; % Percentage tolerance for total number of pores connected in the rock domain.
tolerance = (100 - tolerance) / 100;

% Reading data.
pore_size_distribution = readmatrix(filename);
pore_throat_radius = pore_size_distribution(1,4);
porosity = pore_size_distribution(1,3) / 100; 
pore_throat_length = 1; % An assumption, we don't have a way of contstraining yet. Empirically, shorter length yeids higher permeability.

% Pore-microstructural modelling.
for ID= start:finish 
    disp(num2str(ID)); % Display current model running to help track current state of submitted job.

    if ~isfile(['sphere_' num2str(ID) '.csv']) % Skip if file with ID already exists.
        pore_size_distribution = readmatrix(filename); % Reload at each iteration because original file is overwritten through the process.
        pores = randsample(pore_size_distribution(:,1), number_of_pores, true, pore_size_distribution(:,2)); % Random sampling of pores.
        
        tic 
        rng shuffle 
        total_pore_volume = (4 / 3) * pi .* pores .^ 3; % Volume of each pore from the pore radii, assuming a spherical pore shape.
        total_pore_volume = sum(total_pore_volume);
        rock_volume = total_pore_volume / porosity; 
        rock_volume = rock_volume * porosity_adjustment; % Porosity_adjustment for overlap. 
        half_domain_length = nthroot(rock_volume, 3); % Estimate the length of the flow domain; assuming it is a cube.
        half_domain_length = half_domain_length / 2; % Half domain length since we want to make zero the center. so -half_domain_length to +half_domain_length.
        
        % Initiallizing the maximum X, minimum X, and number of tries to get a pore micorstructural network that meets the set conditions.
        mx = 0; 
        mn = 0;
        number_of_tries = 1;
        
        while mx<(half_domain_length) || mn>-(half_domain_length) || (last/number_of_pores) < tolerance || restart_trigger == 1 % ensures that the pores are connected all the way to inlet and outlet || meets a tolerance || and to help restart if algo is running a fool's errand
            disp('starting')
            clearvars -except filename mx mn number_of_tries pore_size_distribution pores ID porosity_adjustment half_domain_length number_of_pores porosity start finish tolerance pore_throat_length pore_throat_radius
            pore_radius = pores; % A copy of the generated pores, because the process overwrites ... needed if the process needed to restart.
            pore_radius = pore_radius(randperm(length(pore_radius))); % Shuffle order of pore radii in vector; re-ensuring the stochatic nature.
            pore_bodies = []; % An array to add details of pore details  that passes some tests.
            pore_bodies = cat(1, pore_bodies, pore_radius(1,:));
            pore_radius(1,:) = []; % As we add new pores to the list, the detil is deleted from the original collection of radius data to ensure they have equal weights
            pore_coordinates = [0, 0, 0]; % Coordinates of the first pore centered in the rock domain to [0,0,0] for  [x, y, z].
            pore_bodies_temp = cat(2, pore_coordinates, pore_bodies); % Initialize variable to collect pore location radii with the first pore data [x, y, z, radius].
            pore_coordinates_inorder = pore_bodies_temp; % For playing the added pore in sequence when showing using a plot to show the evolution of the pore microstructure.

            pore_throats = [0, 0, 0, 0, 0, 0];% Initializing pore throat [x1, y1, z1, x2, y2, z2] for a cylinder.
            number_of_branches= 0; % Initializing for number of branches in the flow domain.
            origin_check = 0; % Initializing a check to see if the pore microstructure ends at the origin as it will be for the first connection from the origin to the inlet or outlet. 0 means it ends at the origin.
                    
            while size(pore_radius,1) > 0  
                new_pore_coordinates = newPoreCood(pore_bodies_temp(end,1:3), pore_bodies_temp(end,4), pore_radius(1,:), half_domain_length, pore_throat_length); % Generates coodinates of new pores added to the computational domain.
                pore_bodies_temp2 = cat(2, new_pore_coordinates, pore_radius(1,:)); % Concatenates with the respective pore radius.
                number_of_attempts = 1; % Number of attempts made to add this new_pore_coordinates to overall pore microstructure.
                restart_trigger = 0; 
    
                while poreCon(pore_bodies_temp, pore_bodies_temp2, number_of_attempts, pore_throat_length) == 1 || pore_bodies_temp2(1) == pore_bodies_temp(end,1)% Ensures pores are connected and the number of pores connected to a single pore is minimal || second part is to cancel some mathematical problems that sometime result in the same coodinates for the previous pore and new pore.
                    number_of_attempts = number_of_attempts+1;
                    new_pore_coordinates = newPoreCood(pore_bodies_temp(end,1:3), pore_bodies_temp(end,4), pore_radius(1,:),half_domain_length, pore_throat_length);% Generates coodinates of new pore.
                    pore_bodies_temp2 = cat(2, new_pore_coordinates, pore_radius(1,:)); % Concatenates with the respective pore radius.
                    
                    if number_of_attempts == 50000 % Decided its a fools errand at this point, so cancel operation and trigger a restart.
                        disp(number_of_attempts)
                        restart_trigger = 1;
                        break
                    end
                    
                end
                
                if restart_trigger == 1 % Forcing the break of the outter loop because of the restart trigger.
                    break
                end
                
                pore_throats2 = cat(2, pore_bodies_temp(end,1:3), pore_bodies_temp2(end,1:3)); % Appending the repective location of the pore throats.
                pore_throats = cat(1, pore_throats, pore_throats2); % Appending the repective location of the pore throats.
                
                pore_bodies_temp = cat(1, pore_bodies_temp, pore_bodies_temp2); % The new pore data has passed the tests and added to the overall pore system.
                pore_coordinates_inorder = cat(1, pore_coordinates_inorder, pore_bodies_temp2);
                pore_radius(1,:) = []; % Deletes the pore radius from the list of pore sizes.
                
                if inOutCon(pore_bodies_temp2, half_domain_length) == 1 % Detects if a pore has gone past the inlet and outlet so the next pore not added to it.
                    
                    if pore_throats(end,4)<0 % Assign end of pore throats for terminal pores.
                        
                        pore_throats2 = cat(2, pore_bodies_temp2(end,1:3), pore_bodies_temp2(end,1:3));
                        pore_throats2(end,1) = half_domain_length*-1;
                        
                    else
                        
                        pore_throats2 = cat(2, pore_bodies_temp2(end,1:3), pore_bodies_temp2(end,1:3));
                        pore_throats2(end,1) = half_domain_length;
                        
                    end
                    
                    pore_throats = cat(1, pore_throats, pore_throats2);
    
                    if origin_check == 0 % i.e. Pore terminates at the origin.
                        origin_check = 1; % Tells the program that the other end of a complete connection between inlet and outlet is no longer the origin after this one time.
                        pore_bodies_temp = flipud(pore_bodies_temp); % Since pores terminate at origin, the next pore is added here.
                    else
                        pore_bodies_temp = pore_bodies_temp(randperm(size(pore_bodies_temp, 1)),:);% If we already have an initial end to end, randomly select a new pore to connect all the way to inlet or outlet.
                    end
                    
                    number_of_branches = number_of_branches+1;
                    count = 0;
                    while ~isempty(pore_radius) && pore_bodies_temp(end,4) * 2 < pore_radius(1,:) % Checking there is a pore left || and if the new pore is not more than twice the size of the pore its joining to.
                        pore_bodies_temp = pore_bodies_temp(randperm(size(pore_bodies_temp, 1)),:); % Shuffle the pore data again if this is the case.
                        count = count+1;
                        if count == number_of_pores % Use the number of pores as the limit of attempts.
                            disp('count == n')
                            restart_trigger = 1;% When limit is reached, trigger fools errand.
                            break
                        end
                        
                    end
                    last = length(pore_bodies_temp); % Identify the last pore added connected to inlet or outlet.
                end
                
                if restart_trigger == 1 % Forcing the break of the outter loop because of the restart trigger.
                    break
                end
                
            end
            
            pore_throats(1,:) = []; % Delete the initialization of the pore throat date
        
            mx = pore_bodies_temp(:,1) + pore_bodies_temp(:,4); % estimate the farthest pore in positive x axis
            mn = pore_bodies_temp(:,1) - pore_bodies_temp(:,4); % estimate the farthest pore in negative x axis
            mx = max(mx);  % estimate the farthest pore in positive x axis
            mn = min(mn);  % estimate the farthest pore in negative x axis
            number_of_tries = number_of_tries + 1; % to track no of attempts made to make a good pore body connecting inlet and outlet. 
            disp(number_of_tries);
            
        end
        
        % Post processing
        pore_bodies_temp(1,5) = half_domain_length; % Add domain length (half) to data output.
        
        if last ~= number_of_pores % Remove extra pores at the end that donts connect to an inlet or outlet.
            pore_bodies_temp = pore_bodies_temp(1:last,:);
            pore_coordinates_inorder = pore_coordinates_inorder(1:last,:);
            pore_throats = pore_throats(1:(end-(number_of_pores-last)),:);
        end
        
        pore_bodies_temp(1,6) = number_of_branches - 1; % Add number of branches to data output. subtrcating one because the first path connecting inlet to outlet is a single branch.
        pore_bodies_temp(:,4) = pore_bodies_temp(:,4); % Forgot what happened here, seems redundant, will review later.
        
        pore_throats(:,7) = ones( [1,length(pore_throats)] );
        pore_throats(:,7) = pore_throats(:,7)*pore_throat_radius;

        % Export data output as a csv file for use in star CCM+.

        % Pore bodies.
        pore_bodies_data_table = array2table(pore_bodies_temp); % Create a table from the data.
        headers = {'X', 'Y', 'Z', 'Pore body radius(microns)', 'Half domain length (microns)', 'Number of branches'}; % Add headers to the table.
        pore_bodies_data_table.Properties.VariableNames = headers; % Replace with your actual column names.
        filename = ['pore_bodies_' num2str(ID) '.csv'];
        writetable(pore_bodies_data_table, filename); % Write the table to a CSV file.
        
        % Pore throats.
        pore_throats_data_table = array2table(pore_throats); % Create a table from the data.
        headers = {'X_1', 'Y_1', 'Z_1', 'X_2', 'Y_2', 'Z_2', 'Pore throat radius(microns)'}; % Add headers to the table.
        pore_throats_data_table.Properties.VariableNames = headers; % Replace with your actual column names.
        filename = ['pore_throats_' num2str(ID) '.csv'];
        writetable(pore_throats_data_table, filename); % Write the table to a CSV file.

        toc 
    
    else
	    continue 
    end

end

% This line below runs a simulation of the process of adding the pores in order.
% plot_pore_body(pore_coordinates_inorder, half_domain_length) 

% This line below shows the network skeleton.
% plot_pore_throats(pore_throats, half_domain_length) 