function layout = layoutNodes(links,options)

%retrive the (sorted) list of nodes id
idList = sort(unique([cell2mat(links.IDrx);cell2mat(links.IDtx)]));
noOfNodes = size(idList,1);
noOfLinks = size(links.IDrx,1);

layout.ID = cell(noOfNodes,1);
layout.pos.xy = cell(noOfNodes,1);
layout.pos.timestamp = cell(noOfNodes,1);

for linkNo = 2 : noOfLinks
    if ~isempty(find(~(links.decimatedSignal.timestamp{1} == links.decimatedSignal.timestamp{linkNo}),1))
        warning('At least one of the links has the timestamp field different from the others!');
    end
end

for nodeIdx = 1 : noOfNodes
    
end