public with sharing class Console311_Wrap_Config {
  public String mName { get; set; }
  public String mObjJson { get; set; }
  public String mType { get; set; }

  public Console311_Wrap_Config() {}

  public Console311_Wrap_Config(String mName, String mObjJson, String mType) {
    this.mName = mName;
    this.mObjJson = mObjJson;
    this.mType = mType;
  }

  /*public Map<String,Object> getObjectUntyped() {
    return (Map<String, Object>) JSON.deserializeUntyped(this.mObjJson);
  }

  public Type getType() {
    return Type.forName(this.mType);
  }*/
}