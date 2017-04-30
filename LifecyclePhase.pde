class LifecyclePhase{
  
  LifecyclePhase(){}
  void display(){} 
  void showText(){}
  void detectGesture(int userId){}
  
}

class EggPhase extends LifecyclePhase{
  
  EggPhase(){
    super();
  }
  
  void showText(){
    text("Break out of your egg to become a caterpillar.", width/2, 30);
  }
  
  void detectGesture(int userId){ // detect that user has broken out of egg
     PVector leftHandPos    = new PVector();
     PVector leftHandPos2d  = new PVector();
     PVector rightHandPos   = new PVector();
     PVector rightHandPos2d = new PVector();
     kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);  
     kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos); 
     kinect.convertRealWorldToProjective(leftHandPos, leftHandPos2d);
     kinect.convertRealWorldToProjective(rightHandPos, rightHandPos2d);
     PVector centerOfEgg = new PVector();
     centerOfEgg.x = width/2;
     centerOfEgg.y = height/2;
     if ((rightHandPos2d.x >= centerOfEgg.x+eggImg.width/2+5) ||
          (rightHandPos2d.x <= centerOfEgg.x-eggImg.width/2-5) ||
           (rightHandPos2d.y >= centerOfEgg.y+eggImg.height/2) ||
            (rightHandPos2d.y <= centerOfEgg.y-eggImg.height/2-5) ||
             (leftHandPos2d.x >= centerOfEgg.x+eggImg.width/2+5) ||
              (leftHandPos2d.x <= centerOfEgg.x-eggImg.width/2-5) ||
               (leftHandPos2d.y >= centerOfEgg.y+eggImg.height/2+5) ||
                (leftHandPos2d.y <= centerOfEgg.y-eggImg.height/2-5)){
        currentPhaseIndex = 1; 
     }
  }
  
  void display(){
    image(eggImg, width/2-eggImg.width/2, height/2-eggImg.height/2);
  } 
}

class CaterpillarPhase extends LifecyclePhase{
  
  CaterpillarPhase(){
    super();
  }
  
  void showText(){
    text("Touch the leaf to attach yourself to it to form your chrysalis.", width/2, 30);
  }  
  
  void detectGesture(int userId){ // detect that user has touched the leaf
     PVector leftHandPos    = new PVector();
     PVector leftHandPos2d  = new PVector();
     PVector rightHandPos   = new PVector();
     PVector rightHandPos2d = new PVector();
     kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);  
     kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos); 
     kinect.convertRealWorldToProjective(leftHandPos, leftHandPos2d);
     kinect.convertRealWorldToProjective(rightHandPos, rightHandPos2d);
     if (((rightHandPos2d.x >= width-leafImg.width && rightHandPos2d.x <= width) &&
           (rightHandPos2d.y >= 0 && rightHandPos2d.y <= leafImg.height)) ||
             ((leftHandPos2d.x >= width-leafImg.width && leftHandPos2d.x <= width) &&
               (leftHandPos2d.y >= 0 && leftHandPos2d.y <= leafImg.height))){
        currentPhaseIndex = 2; 
     }  
  }
  
  void display(){
    kinect.getCoM(currentUser, currentUserCom);  
    kinect.convertRealWorldToProjective(currentUserCom, currentUserCom2d);    
    image(caterpillarImg, currentUserCom2d.x-caterpillarImg.width/2, currentUserCom2d.y-caterpillarImg.height/2);
    image(leafImg, width-leafImg.width, 0);
  }   
  
}

class ChrysalisPhase extends LifecyclePhase{
  
  ChrysalisPhase(){
    super();
  }
  
  void showText(){
    text("Emerge from your chrysalis to become a butterfly!", width/2, 30); // detect that user has emerged from chrysalis
  }  
  
  void detectGesture(int userId){
  }
  
  void display(){
    image(chrysalisImg, width/2-chrysalisImg.width/2, height/2-chrysalisImg.height/2);
  }   
  
}

class ButterflyPhase extends LifecyclePhase{
  
  ButterflyPhase(){
    super();
  }
  
  void showText(){
    text("Fly away.", width/2, 30);
  }  
  
  void detectGesture(int userId){ // detect that use is flapping their arms
  }
  
}