class LifecyclePhase{
  PImage image;
  
  LifecyclePhase(PImage img){
    this.image = img;
  }
  
  void display(){
    image(this.image, 0, 0);
  } 
  
  void showText(){}
  
  float detectGestureProbability(){
    return 0.0;
  }
}

class EggPhase extends LifecyclePhase{
  PImage image;
  
  EggPhase(PImage img){
    super(img);
  }
  
  void showText(){
    text("Be a caterpillar.", width/2, 30);
  }
  
  float detectGestureProbability(){
    return 0.0;
  }
  
}

class CaterpillarPhase extends LifecyclePhase{
  PImage image;
  
  CaterpillarPhase(PImage img){
    super(img);
  }
  
  void showText(){
    text("Be a chrysalis.", width/2, 30);
  }  
  
  float detectGestureProbability(){
    return 0.0;
  }
  
}

class ChrysalisPhase extends LifecyclePhase{
  PImage image;
  
  ChrysalisPhase(PImage img){
    super(img);
  }
  
  void showText(){
    text("Be a butterfly.", width/2, 30);
  }  
  
  float detectGestureProbability(){
    return 0.0;
  }
  
}

class ButterflyPhase extends LifecyclePhase{
  PImage image;
  
  ButterflyPhase(PImage img){
    super(img);
  }
  
  void showText(){
    text("Fly away.", width/2, 30);
  }  
  
  float detectGestureProbability(){
    return 0.0;
  }
  
}