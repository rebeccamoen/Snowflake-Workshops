-- File Formats, PUTs, and COPY INTOs

list @~/uploads/dataloader;
SELECT * FROM vegetable_details;

-- CSV Uploader Generated Code:
COPY INTO IDENTIFIER('GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS')
from '@~/uploads/dataloader/bc53c15f8aa2a4e6f06bef20b9ad47e2'
file_format = (
    TYPE=csv,
    FIELD_OPTIONALLY_ENCLOSED_BY='"',
    ESCAPE_UNENCLOSED_FIELD=None,
    SKIP_HEADER=1,
    FIELD_DELIMITER = '|'
);

-- Create two file formates:
create file format garden_plants.veggies.PIPECOLSEP_ONEHEADROW 
    TYPE = 'CSV'--csv is used for any flat file (tsv, pipe-separated, etc)
    FIELD_DELIMITER = '|' --pipes as column separators
    SKIP_HEADER = 1 --one header row to skip
    ;

create file format garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW 
    TYPE = 'CSV'--csv for comma separated files
    SKIP_HEADER = 1 --one header row  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' --this means that some values will be wrapped in double-quotes bc they have commas in them
    ;

-- Remove Spinach row with "D" in the ROOT_DEPTH_CODE column
delete from vegetable_details
where plant_name = 'Spinach'
and root_depth_code = 'D';
