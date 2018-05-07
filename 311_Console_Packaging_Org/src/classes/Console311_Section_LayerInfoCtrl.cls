public with sharing class Console311_Section_LayerInfoCtrl {
  private String LAYER_NAME { get; set; }

  public String mObjJsonConfigFieldName { get; set; }
  public Incap311__Service_Type_Version__c mStv { get; set; }
  public String mStvId { get; set; }
  public List<Incap311.Base311_ESRI_Layer> mLayers { get; set; }

  public Console311_Section_LayerInfoCtrl() {
    LAYER_NAME = 'PWD Recycling Day';
    this.mObjJsonConfigFieldName = 'Incap311__Layer_Information__c';
  }

  public Console311_Section_LayerInfoCtrl(String jsonConfigFieldName) {
    this.mObjJsonConfigFieldName = jsonConfigFieldName != null ? jsonConfigFieldName : 'Incap311__Layer_Information__c';
  }

  public String getRecycleDate() {
    if (this.mLayers != null) {
      for (Incap311.Base311_ESRI_Layer layer : mLayers) {
        System.debug('----> Active LayerName: ' + layer.layerName);
        System.debug('----> Is PWD Recycling Day: ' + layer.layerName.equalsIgnoreCase(LAYER_NAME));
        if (layer.layerName.equalsIgnoreCase(LAYER_NAME)) {
          System.debug('----> Found layer to use. Returning ' + LAYER_NAME + ': ' + layer.value);
          return layer.value;
        }
      }
    }
    return '';
  }

  public List<Console311_Wrap_LayerInformation> getLayerInformation() {
    List<Console311_Wrap_LayerInformation> layersToReturn = new List<Console311_Wrap_LayerInformation>();

    if (this.mLayers != null && this.mStv != null) {
      if (this.mStv.get(mObjJsonConfigFieldName) != null) {        
        List<Console311_Wrap_LayerInformation> layerDataList = (List<Console311_Wrap_LayerInformation>) JSON.deserialize((String)this.mStv.get(mObjJsonConfigFieldName), List<Console311_Wrap_LayerInformation>.class);
        System.debug('----> layerDataList: ' + layerDataList);

        for (Console311_Wrap_LayerInformation li : layerDataList) {
          System.debug('----> [Inside Loop] => Console311_Wrap_LayerInformation: ' + li);
          for (Incap311.Base311_ESRI_Layer layer : mLayers) {
            System.debug('----> [Inside ESRI Loop] => Active LayerName: ' + layer.layerName);
            if (li.layer_name.equalsIgnoreCase(layer.layerName)) {
              System.debug('----> Found layer to use. Returning ' + layer.layerName + ': ' + layer.value);              

              if (li.layer_value.equalsIgnoreCase('value') && !String.isBlank(layer.value)) {
                layersToReturn.add(new Console311_Wrap_LayerInformation(layer.layerName, layer.value, li.layer_title));  
              } else if (li.layer_value.contains('attributes.')) {
                String attrName = (li.layer_value.split('\\.'))[1];

                if (layer.attributes.containsKey(attrName) && !String.isBlank(layer.attributes.get(attrName))) {
                  layersToReturn.add(new Console311_Wrap_LayerInformation(layer.layerName, layer.attributes.get(attrName), li.layer_title));
                }
              }
              break;
            }
          }     
        }
      }
    }
    System.debug('----> LayerInformation: ' + layersToReturn);
    return layersToReturn;
  }

  public Map<String, Console311_Wrap_LayerInformation> getLayerInformationMap() {
    Map<String, Console311_Wrap_LayerInformation> returnMapping = new Map<String, Console311_Wrap_LayerInformation>();

    if (this.mLayers != null && this.mStv != null) {
      if (this.mStv.get(mObjJsonConfigFieldName) != null) {        
        Map<String, Console311_Wrap_LayerInformation> layerDataList = (Map<String, Console311_Wrap_LayerInformation>) JSON.deserialize((String)this.mStv.get(mObjJsonConfigFieldName), Map<String, Console311_Wrap_LayerInformation>.class);
        System.debug('----> layerDataList: ' + layerDataList);

        for (String key : layerDataList.keySet()) {
          Console311_Wrap_LayerInformation li = layerDataList.get(key);
          System.debug('----> [Inside Loop] => Console311_Wrap_LayerInformation: ' + li);
          for (Incap311.Base311_ESRI_Layer layer : this.mLayers) {
            System.debug('----> [Inside ESRI Loop] => Active LayerName: ' + layer.layerName);
            if (li.layer_name.equalsIgnoreCase(layer.layerName)) {
              System.debug('----> Found layer to use. Returning ' + layer.layerName + ': ' + layer.value);              

              if (li.layer_value.equalsIgnoreCase('value')) {
                returnMapping.put(key, new Console311_Wrap_LayerInformation(layer.layerName, layer.value, li.layer_title, li.format));  
              } else if (li.layer_value.contains('attributes.')) {
                String attrName = (li.layer_value.split('\\.'))[1];

                if (layer.attributes.containsKey(attrName)) {
                  returnMapping.put(key, new Console311_Wrap_LayerInformation(layer.layerName, layer.attributes.get(attrName), li.layer_title, li.format));
                }
              }
              break;
            }
          }     
        }
      }
    }
    System.debug('----> [Console311_Section_LayerInfoCtrl] returnMapping: ' + returnMapping);
    return returnMapping;
  }
}