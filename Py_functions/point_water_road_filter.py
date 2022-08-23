import geopandas as gpd
import fiona
from shapely.ops import unary_union
#import matplotlib.pyplot as plt
#from shapely.geometry import Polygon
import time
import pandas as pd


#def point_water_filter(working_dir):
nad83 = "EPSG:4269"
wgs84 = "EPSG:4326"
utm = "EPSG:32619"
working_dir = "C:/Users/bbact/Documents/GitHub/StrLight_Conveyal_testing"

#keep only points in the MBTA service area
pts = gpd.read_file(working_dir + "/Data/Processed/MA_RI_1000m_pt_grid.geojson", driver = "GeoJSON")
mbta_area = gpd.read_file(working_dir + "/Data/input/mbta_service_area.geojson", driver = "GeoJSON")
pts_utm = pts.to_crs(utm)
mbta_area_utm = mbta_area.to_crs(utm)

pts_mbta = pts_utm.clip(mbta_area_utm,keep_geom_type=True)

#keep only points that are not over water
water = gpd.read_file(working_dir + "/Data/input/water_ma_ri.geojson", driver = "GeoJSON")
water_utm = water.to_crs(utm)

#pts_clip = pts_utm.clip(water_utm,keep_geom_type=True)
#pts_clip = water_utm.clip(pts_utm,keep_geom_type=True)

pts_mbta_no_water = gpd.overlay(pts_mbta,water_utm,how="difference")


roads = gpd.read_file(working_dir + "/Data/input/roads_ma_ri.geojson", driver = "GeoJSON")
roads_utm = roads.to_crs(utm)
road_buffer = roads_utm.buffer(100)
road_buffer_union = gpd.GeoDataFrame(unary_union(road_buffer), geometry = 0, crs=utm)
pts_road_buffer = pts_mbta_no_water.clip(road_buffer_union,keep_geom_type=True)


#water.to_file(working_dir + "/Data/TAZ/water_test.shp")
pts_road_buffer.to_file(working_dir + "/Data/TAZ/pts_road_buffer_test.shp")


