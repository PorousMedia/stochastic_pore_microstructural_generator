% This is a function to plot 3D representation of the generated pore
% microstructure's skeleton. It plots the pore body only the pore throats with a ball at the connections.

function plot_pore_throats(pore_throat_distribution, half_domain_length)

    %   It reads in the pore_throat_distribution array expected to contain
    %   atleast two rows (two data points) and atleast six columns (first
    %   three cordinates are start of pore-throats and last three are coordinates of the end).

    %   The half_domain_length is half the length of the domain 

    start = pore_throat_distribution(:, 1:3);
    stop = pore_throat_distribution(:, 4:6);

    figure('Name','Pore throats');
   
    X = [start(:,1) stop(:,1)] ;
    Y = [start(:,2) stop(:,2)] ;
    Z = [start(:,3) stop(:,3)] ;

    plot3(X' ,Y' , Z','LineWidth',5)
    xlabel('X axis')
    ylabel('Y axis')
    zlabel('Z axis')
   
    hold on
    axis equal
    plot3(X', Y', Z', '.','MarkerSize',50)
    axis([-half_domain_length half_domain_length -half_domain_length half_domain_length -half_domain_length half_domain_length])
    shg

end

