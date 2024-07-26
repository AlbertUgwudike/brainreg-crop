

structure_filename = "~/.brainglobe/allen_mouse_25um_v1.2/structures.csv";

atlas_struct = AtlasStructure(structure_filename);

% CHANGE THESE AS REQUIRED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% registered atlas path
REG_ATLAS = "./registered_atlas.tiff";

% image data, can be downsampled or raw
IMAGE_DATA = "./downsampled.tiff";

% folder where you want the cropped images to go
OUTPUT_DIR = "./outputs";

% region acronym
REGION = 'HIP';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_SLICES = 620;

if (isfolder(OUTPUT_DIR))
    fprintf("Output folder: %s, Already exists!\n", OUTPUT_DIR);
else
    fprintf("Creating output folder: %s\n", OUTPUT_DIR);
    mkdir(OUTPUT_DIR);
end

for i = 1:N_SLICES

    % we want all rows/cols ([1, inf]) at slice i ([i, i])
    pxl_region = { [1, inf], [1, inf], [i, i] };

    % read atlas and corresponding raw data slices
    a_slice = tiffreadVolume(REG_ATLAS, 'PixelRegion', pxl_region);
    r_slice = tiffreadVolume(IMAGE_DATA, 'PixelRegion', pxl_region);

    % upscale the atlas slice to match size of raw data slice
    a_slice = imresize(a_slice, size(r_slice));

    % extract cropped image
    img = atlas_struct.CroppedRegion(REGION, a_slice, r_slice);

    % save img to output directory
    output_fn = fullfile(OUTPUT_DIR, ['slice_' num2str(i) '.tiff']);
    imwrite(img, output_fn);

    fprintf("Cropped slice %i/%i\n", i, N_SLICES)
end


% visualisation, notice the use of 'imadjust'
% comment out the above for-loop if you don't
% need it to generate cropped images again :)
for i = 1:10
    fn = fullfile(OUTPUT_DIR, ['slice_' num2str(300 + 10 * i) '.tiff']);
    img = imread(fn);
    figure()
    imshow(imadjust(img));
end



