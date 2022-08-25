import geopandas as gpd
import fiona
from shapely.ops import unary_union
#import matplotlib.pyplot as plt
#from shapely.geometry import Polygon
import time
import pandas as pd


def filter_fishnet(working_dir):
    
    # EPSGs of coord systems we will be using
    nad83 = "EPSG:4269"
    wgs84 = "EPSG:4326"
    utm = "EPSG:32619"
    #working_dir = "C:/Users/bbact/Documents/GitHub/StrLight_Conveyal_testing"

    #keep only points in the MBTA service area
    print("Importing fishnet...")
    pts = gpd.read_file(working_dir + "/Data/Processed/fishnet.geojson", driver = "GeoJSON")
    #mbta_area = gpd.read_file(working_dir + "/Data/input/mbta_service_area.geojson", driver = "GeoJSON")
    pts = pts.to_crs(utm)
    #mbta_area_utm = mbta_area.to_crs(utm)

    #pts_mbta = pts_utm.clip(mbta_area_utm,keep_geom_type=True)

    #keep only points that are not over water
    print("Importing water...")
    water = gpd.read_file(working_dir + "/Data/input/water_ma_ri.geojson", driver = "GeoJSON")
    water_utm = water.to_crs(utm)

    #pts_clip = pts_utm.clip(water_utm,keep_geom_type=True)
    #pts_clip = water_utm.clip(pts_utm,keep_geom_type=True)
    print("Removing points over water...")
    pts_no_water = gpd.overlay(pts,water_utm,how="difference")

    print("Importing roads...")
    roads = gpd.read_file(working_dir + "/Data/input/roads_ma_ri.geojson", driver = "GeoJSON")
    roads_utm = roads.to_crs(utm)
    buffersize = 100

    print("Creating", buffersize,"meter road buffer...")
    road_buffer = roads_utm.buffer(buffersize)
    road_buffer_union = gpd.GeoDataFrame(unary_union(road_buffer), geometry = 0, crs=utm)
    print("Removing points more than",buffersize,"meters away from roads...")
    pts_road_buffer = pts_no_water.clip(road_buffer_union,keep_geom_type=True)

    outdir = working_dir + "/Data/Processed/filtered_fishnet.geojson"
    pts_road_buffer = pts_road_buffer.to_crs(nad83)

    pts_road_buffer.to_file(outdir,driver = 'GeoJSON')
    print("Complete. Filtered fishnet generated at: " + outdir)


