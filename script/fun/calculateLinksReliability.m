function calculateLinksReliability(links,options)%the same information can be extracted by looking at the tension in the springs

%prepare some usefull variables
IDrx = cell2mat(links.IDrx);
IDtx = cell2mat(links.IDtx);
noOfLinks = size(links.IDrx,1);
links.decimatedSignal.distanceUnreliability = links.decimatedSignal.distance; %.decimatedSignal.distanceUnreliability will have the same dimensions of .decimatedSignal.distance

for i_link_id1_id2=1:noOfLinks %scan all LINKS and evaluate all possible 'triangles'. NB: selecting a line of 'LINKS' means selecting the firsts two nodes and the first link (i.e. it doesn't need a second cycle to select the second node)
    i_link_1 = i_link_id1_id2;
    id_1 = IDrx(1,i_link_id1_id2);
    id_2 = IDtx(2,i_link_id1_id2);
    
    if id_1 ~= id_2
        
        i_links_2_list = find(IDrx == id_2);
        
        for i_link_id3=i_links_2_list
            i_link_2 = i_link_id3;
            id_3 = LINKS(2,i_link_id3);
            i_links_3_list = find(( LINKS(2,:) == id_3 & LINKS(1,:) == id_1 ));
            if( size(i_links_3_list,2) == 1)
                i_link_3 = i_links_3_list(1);
                if PLOT_VERBOSITY > 2
                    fprintf('Analyzing triangle: %02x - %02x - %02x\n',id_1,id_2,id_3);
                end
                
                for timeIndexNo = 1:size(GRAPH_EDGES_M_FILT,1)
                    if (GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1)~=Inf) && (GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2)~=Inf) && (GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3)~=Inf)
                        if GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1) + GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2) <  0.8*GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3)
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                        end
                        if GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2) + GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3) <  0.8*GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1)
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                        end
                        if GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3) + GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1) <  0.8*GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2)
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                            LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                        end
                    end
                end
            else
                if( size(i_links_3_list,2) ~= 0)
                    error('The triangle is not single since between %02x and %02x there are more than one link....check the script!',id_3,id_1);
                    LINKS'
                end
            end
        end
    else
        %set the uneliability to NaN
    end
end
