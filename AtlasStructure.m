classdef AtlasStructure

    
    properties
        AbrMap containers.Map
        IdxMap containers.Map
    end

    methods (Access = public)

        function as = AtlasStructure(fn)
            structure = table2struct(readtable(fn));
            as.IdxMap = AtlasStructure.CreateIdxMap(structure);
            as.AbrMap = AtlasStructure.CreateAbrMap(structure);
        end

        function cropped = CroppedRegion(as, abbr, a_slice, r_slice)

            % find child idx of provided acronym and use it to 
            % generate the region mask
            idxs = as.AbbrToIdxSet(abbr);
            mask = ismember(a_slice, idxs);

            % get the linear indices of points within the mask
            points = find(mask);

            % if region is does not exist in this slice,
            % return tiny empty img.
            if numel(points) < 4
                cropped = zeros(1);
                return
            end

            % convert linear indices to subscripts and
            % use these to generate bounding box for crop
            [I, J] = ind2sub(size(mask), points);

            top     = min(I);
            bottom  = max(I);
            left    = min(J);
            right   = max(J);
        
            bbox = [left, top, right - left + 1, bottom - top + 1];
            
            % copy the unprocessed raw data to the output image
            cropped = r_slice;

            % remove pixels outside of region-of-interest and
            % apply crop
            cropped(~mask) = 0;
            cropped = imcrop(cropped, bbox);
        end

        function idx_set = AbbrToIdxSet(st, abbr)
            idx = st.AbrMap(abbr);
            idx_set = [idx, st.IdxMap(idx)];
        end

    end

    methods (Static)

        function imap = CreateIdxMap(st_table)
            all_idxs = [st_table.id];
            find_fun = @(id) AtlasStructure.ChildIdxsFromTable(st_table, id);
            idxs = arrayfun(find_fun, all_idxs, 'UniformOutput', false);
            imap = containers.Map(all_idxs, idxs);
        end

        function amap = CreateAbrMap(st_table)
            all_abrs = {st_table.acronym};
            all_idxs = [st_table.id];
            amap = containers.Map(all_abrs, all_idxs);
        end

        function idxs = ChildIdxsFromTable(st_table, idx)
            child_idxs = [st_table([st_table.parent_structure_id] == idx).id];
            if numel(child_idxs) == 0
                idxs = child_idxs;
                return
            end
            recursive_find = @(i) AtlasStructure.ChildIdxsFromTable(st_table, i);
            others = arrayfun(recursive_find, child_idxs, 'UniformOutput', false);
            idxs = [child_idxs, cell2mat(others)];
        end

    end

end

