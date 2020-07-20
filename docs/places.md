
STATEFP
Current state FIPS code

COUNTYFP
Current county FIPS code

PLACEFP
Current place FIPS code

NAME
Current name

NAMELSAD
Current name and the translated legal/statistical area description

LSAD
Current legal/statistical area description code

ALAND
Current land area

AWATER
Current water area

INTPTLAT
Current latitude of the internal point

INTPTLON
Current longitude of the internal point



==

https://www.census.gov/library/reference/code-lists/legal-status-codes.html

  LSAD = {
    '00' => 'state',                  # state or statistical equivalent of a state	-	state or statistical equivalent of a state
    '03' => 'city',                   # city and borough	City and Borough	legal county equivalent in Alaska
    '04' => 'county',                 # borough	Borough	legal county equivalent in Alaska
    '05' => 'county',                 # census area	Census Area	statistical equivalent of a county in Alaska
    '06' => 'county',                 # county	County	county in 48 states
    '07' => 'county',                 # district	District	legal county equivalent in American Samoa
    '08' => 'city',                   # independent city	city	legal county equivalent in Maryland, Missouri, and Virginia
    '09' => 'city',                   # independent city	-	legal county equivalent in Nevada
    '10' => 'county',                 # island	Island	legal county equivalent in the U.S. Virgin Islands
    '11' => 'county',                 # island	-	legal county equivalent in American Samoa and Marshall Islands
    '12' => 'county',                 # municipality	Municipality	legal county equivalent in the Northern Mariana Islands and Marshall Islands
    '13' => 'county',                 # municipio	Municipio	legal county equivalent in Puerto Rico
    '14' => 'county',                 # -	-	legal county equivalent (used for District of Columbia and Guam)
    '15' => 'county',                 # parish	Parish	legal county equivalent in Louisiana
    '19' => 'reservation',            # reservation	Reservation	legal county subdivision equivalent in Maine and New York (coextensive with all or part of an American Indian reservation)
    '20' => 'barrio',                 # barrio	barrio	legal county subdivision in Puerto Rico
    '21' => 'borough',                # borough	borough	legal county subdivision in New York; legal county subdivision equivalent in New Jersey and Pennsylvania
    '22' => 'census',                 # census county division	CCD	statistical equivalent of a county subdivision in 				21 States
    '23' => 'census',                 # census subarea	census subarea	statistical equivalent of a county subdivision in Alaska
    '24' => 'census subdistrict',     # census subdistrict	subdistrict	legal county subdivision equivalent in the U.S. Virgin Islands
    '25' => 'city',                   # city	city	legal county subdivision equivalent in 20 States and the District of Columbia
    '26' => 'county',                 # county	county	legal county subdivision in American Samoa
    '27' => 'district',               # district (election magisterial, or municipal, or road)	district	legal county subdivision in Pennsylvania, Virginia, West Virginia, Guam, and Northern Mariana Islands
    '28' => 'district',               # district (assessment, election, magisterial, super-visor's, parish governing authority,or municipal)	-	legal county subdivision in Louisiana, Maryland, Mississippi, Virginia, and West Virginia
    '29' => 'election precinct',      # election precinct	precinct	legal county subdivision in Illinois and Nebraska
    '30' => 'election precinct',      # election precinct	-	legal county subdivision in Illinois and Nebraska
    '31' => 'gore',                   # gore	gore	legal county subdivision in Maine and Vermont
    '32' => 'grant',                  # grant	grant	legal county subdivision in New Hampshire and Vermont
    '33' => 'city',                   # independent city	city	legal county subdivision equivalent in Maryland, Missouri, and Virginia
    '34' => 'city',                   # independent city	-	legal county subdivision equivalent in Nevada
    '35' => 'island',                 # island	-	legal county subdivision in American Samoa
    '36' => 'location',               # location	location	legal county subdivision in New Hampshire
    '38' => 'location',               # -	-	legal county subdivision equivalent for Arlington County, Virginia
    '39' => 'plantation',             # plantation	plantation	legal county subdivision in Maine
    '40' => 'plantation',             # -	-	legal county subdivision not defined
    '41' => 'barrio-pueblo',          # barrio-pueblo	barrio-pueblo	legal county subdivision in Puerto Rico
    '42' => 'purchase',               # purchase	purchase	legal county subdivision in New Hampshire
    '43' => 'city',                   # town	town	legal county subdivision in eight States; legal county subdivision equivalent in New Jersey, North Carolina, Pennsylvania, and South Dakota
    '44' => 'city',                   # township	township	legal county subdivision in 16 states
    '45' => 'city',                   # township	-	legal county subdivision in Kansas, Minnesota, Nebraska, and North Carolina
    '46' => 'unorganized territory',  # unorganized territory	UT	statistical equivalent of a county subdivision in 10 States
    '47' => 'city',                   # village	village	legal county subdivision equivalent in New Jersey, Ohio, South Dakota, and Wisconsin
    '49' => 'city',                   # charter township	charter township	legal county subdivision in Michigan
    '51' => 'subbarrio',              # subbarrio	subbarrio	legal sub-MCD in Puerto Rico
    '53' => 'city',                   # city and borough	city and borough	incorporated place in Alaska
    '54' => 'city',                   # municipality	municipality	incorporated place in Alaska
    '55' => 'city',                   # comunidad	comunidad 	statistical equivalent of a place in Puerto Rico
    '56' => 'city',                   # borough	borough	incorporated place in Connecticut, New Jersey, and Pennsylvania
    '57' => 'city',                   # census designated place	CDP	statistical equivalent of a place in all 50 states, Guam, Northern Mariana Islands, and the U.S. Virgin Islands
    '58' => 'city',                   # city	city	incorporated place in 49 States (not Hawaii) and District of Columbia
    '59' => 'city',                   # city	-	incorporated place having no legaldescription in three states; place equivalent in five states
    '60' => 'city',                   # town	town	incorporated place in 30 States and the U.S. Virgin Islands
    '61' => 'city',                   # village	village	incorporated place in 20 States and traditional place in American Samoa
    '62' => 'zona urbana',            # zona urbana	zona urbana	statistical equivalent of a place in Puerto Rico
    '65' => 'consolidated city',      # consolidated city	city 	consolidated city in Connecticut, Georgia, and Indiana
    '66' => 'consolidated city',      # consolidated city	-	consolidated city (with unique description or no description)
  }
