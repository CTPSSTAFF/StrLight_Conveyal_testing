import geopandas as gpd
import fiona
from shapely.ops import unary_union
from shapely.geometry import Point, LineString
from shapely import geometry
import pandas as pd


def generate_fishnet(working_dir):
    # EPSGs of coord systems we will be using
    nad83 = "EPSG:4269"
    wgs84 = "EPSG:4326"
    utm = "EPSG:32619"

    #import TAZ shapes that were used to download StreetLight data
    #working_dir = "C:/Users/bbact/Documents/GitHub/StrLight_Conveyal_testing"
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
    fishnet = fishnet.to_crs(nad83)
    outdir = working_dir + '/Data/Processed/fishnet.geojson'
    fishnet.to_file(outdir, driver='GeoJSON')
    print("Complete. Fishnet generated at: " + outdir)
def generate_taz_centroids(working_dir):
    # EPSGs of coord systems we will be using
    nad83 = "EPSG:4269"
    wgs84 = "EPSG:4326"
    utm = "EPSG:32619"

    #import TAZ shapes that were used to download StreetLight data
    #working_dir = "C:/Users/bbact/Documents/GitHub/StrLight_Conveyal_testing"
    taz_loc = working_dir + "/Data/TAZ/"

    ma = gpd.read_file(taz_loc + "tl_2011_25_taz10/tl_2011_25_taz10.shp", crs=nad83)
    ri = gpd.read_file(taz_loc + "tl_2011_44_taz10/tl_2011_44_taz10.shp", crs=nad83)

    #removed unneeded columns
    ma = ma[['GEOID10','geometry']]
    ri = ri[['GEOID10','geometry']]

    #combine mass and rhode island together
    taz = gpd.GeoDataFrame(pd.concat([ma,ri], ignore_index=True))

    taz_utm = taz.to_crs(utm)

    roads = gpd.read_file(working_dir + "/Data/input/roads_ma_ri.geojson", driver = "GeoJSON")
    roads_utm = roads.to_crs(utm)
    road_buffer = roads_utm.buffer(100)
    road_buffer_union = gpd.GeoDataFrame(unary_union(road_buffer), geometry = 0, crs=utm)
    taz_road_buffer = taz_utm.clip(road_buffer_union,keep_geom_type=True)



    water = gpd.read_file(working_dir + "/Data/input/water_ma_ri.geojson", driver = "GeoJSON")
    water_utm = water.to_crs(utm)

    taz_road_no_water = gpd.overlay(taz_road_buffer,water_utm,how="difference")
    
    taz_rep_point = taz_road_no_water.representative_point()
    taz_rep_point = taz_rep_point.to_crs(wgs84)
    outdir = working_dir + '/Data/Processed/taz_rep_point.geojson'
    taz_rep_point.to_file(outdir,driver="GeoJSON")
    print("Complete. TAZ representative points generated at: " + outdir)














