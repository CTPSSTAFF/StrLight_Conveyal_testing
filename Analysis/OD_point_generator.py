import geopandas as gpd
import fiona
from shapely.ops import unary_union
from shapely.geometry import Point, LineString
from shapely import geometry
import pandas as pd

# EPSGs of coord systems we will be using
nad83 = "EPSG:4269"
wsg84 = "EPSG:4326"
utm = "EPSG:32619"

#import TAZ shapes that were used to download StreetLight data
working_dir = "C:/Users/bbact/Documents/GitHub/StrLight_Conveyal_testing"
taz_loc = working_dir + "/Data/TAZ/"

ma = gpd.read_file(taz_loc + "tl_2011_25_taz10/tl_2011_25_taz10.shp", crs=nad83)
ri = gpd.read_file(taz_loc + "tl_2011_44_taz10/tl_2011_44_taz10.shp", crs=nad83)

#removed unneeded columns
ma = ma[['GEOID10','geometry']]
ri = ri[['GEOID10','geometry']]

#combine mass and rhode island together
taz = gpd.GeoDataFrame(pd.concat([ma,ri], ignore_index=True))

# create a grid "fishnet" of points to serve as OD points in addition to centroids to help large TAZs have more accurate travel times
taz_utm = taz.to_crs(utm)
total_bounds = taz_utm.total_bounds
minX, minY, maxX, maxY = total_bounds

# interval of grid in meters
interval = 1000

x, y = (minX, minY)
x2, y2 = (maxX, maxY)
geom_array_ns = []
square_size = interval
while x <= maxX:
    geom = geometry.LineString([Point(x, y2), Point(x, y)])#.wkt
    geom_array_ns.append(geom)
    x += square_size
square_size = interval   
geom_array_ew = []
x, y = (minX, minY)
x2, y2 = (maxX, maxY) 
while y <= maxY:
    geom = geometry.LineString([Point(x, y), Point(x2, y)])#.wkt
    geom_array_ew.append(geom)
    y += square_size

v_lines = gpd.GeoDataFrame(geom_array_ns, columns=['geometry']).set_crs(utm)
h_lines = gpd.GeoDataFrame(geom_array_ew, columns=['geometry']).set_crs(utm)

v_lines = v_lines.unary_union
h_lines = h_lines.unary_union

fishnet = h_lines.intersection(v_lines)

fishnet = gpd.GeoDataFrame(fishnet, columns=['geometry']).set_crs(utm)
fishnet.to_file(taz_loc + 'fishnet_test.shp')










