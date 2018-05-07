public with sharing class Console311_Wrap_LayerInformation {
  public String layer_name { get; set; }
  public String layer_value { get; set; }
  public String layer_title { get; set; }
  public String format { get; set; }

  public Console311_Wrap_LayerInformation(){}
  public Console311_Wrap_LayerInformation(String name, String value){
    this.layer_name = name;
    this.layer_value = value;
  }

  public Console311_Wrap_LayerInformation(String name, String value, String title) {
    this(name, value);
    this.layer_title = title;
  }

  public Console311_Wrap_LayerInformation(String name, String value, String title, String format) {
    this(name, value, title);
    this.format = format;
  }
}