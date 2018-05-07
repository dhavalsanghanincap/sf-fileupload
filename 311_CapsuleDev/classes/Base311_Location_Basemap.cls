global class Base311_Location_Basemap {
    global class Base311_Basemap_Layers {
        global String url { get; set; }
    }
    
    global String title { get; set; }
    global String thumbnailUrl { get; set; }
    global List<Base311_Basemap_Layers> baseMapLayers { get; set; }
}