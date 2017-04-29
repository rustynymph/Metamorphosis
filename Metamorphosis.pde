import SimpleOpenNI.*; // For interfacing with the Kinect
import processing.opengl.*; // For implementing edge detection
import codeanticode.syphon.*; // For using syphon to send frames out

SimpleOpenNI kinect;
SyphonServer server;
PImage kinectImage;
boolean sendFrames = false;
color[] userClr = new color[]{ color(255,0,0),
                               color(0,255,0),
                               color(0,0,255),
                               color(255,255,0),
                               color(255,0,255),
                               color(0,255,255)
                              };
PVector com = new PVector();                                   
PVector com2d = new PVector(); 
PVector leftHandPos = new PVector();
PVector rightHandPos = new PVector();

int currentUser; // kinect can track multiple users, but we only want to focus on one
LifecyclePhase eggPhase, caterpillarPhase, chrysalisPhase, butterflyPhase;
LifecyclePhase[] lifecyclePhases = new LifecyclePhase[4];
int currentPhaseIndex;
PImage eggImg, caterpillarImg, chrysalisImg, butterflyImg;

void settings(){
  size(640, 480, P2D);
  PJOGL.profile=1; // prevents OPENGL error 1282 when sending frames through Syphon
}

void setup(){
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false){
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  kinect.enableDepth();
  kinect.enableUser();
  server = new SyphonServer(this, "Kinect Processing");
  
  eggImg = loadImage("egg.png");
  caterpillarImg = loadImage("caterpillar.png");
  chrysalisImg = loadImage("chrysalis.gif");
  butterflyImg = loadImage("butterfly.png");
  
  eggPhase = new EggPhase(eggImg);
  caterpillarPhase = new CaterpillarPhase(caterpillarImg);
  chrysalisPhase = new ChrysalisPhase(chrysalisImg);
  butterflyPhase = new ButterflyPhase(butterflyImg);
  lifecyclePhases[0] = eggPhase;
  lifecyclePhases[1] = caterpillarPhase;
  lifecyclePhases[2] = chrysalisPhase;
  lifecyclePhases[3] = butterflyPhase;
  
  currentPhaseIndex = -1;
}

void draw(){
  fill(255);
  kinect.update();
  //image(kinect.userImage(), 0, 0, width, height);
  drawUsers();
  drawLifecycleText();
    
  if (sendFrames){
    server.sendScreen();
  }
}

int phaseDetection(){
  float highestProbability = 0.0;
  int index = -1;
  for (int i = 0; i < 4; i++){
    float probability = lifecyclePhases[i].detectGestureProbability();
    if (probability >= highestProbability){
      highestProbability = probability;
      index = i;
    }
  }
  return index;
}

void drawLifecycleText(){
  if (currentPhaseIndex != -1){
    lifecyclePhases[currentPhaseIndex].showText();
  } else {
     text("Be an egg.", width/2, 30);
  }
}

void drawUsers(){
  // draw the skeleton if it's available
  int[] userList = kinect.getUsers();
  for(int i=0;i<userList.length;i++){
    if(kinect.isTrackingSkeleton(userList[i])){
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
      
      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
      kinect.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);      
    }      
        
    // draw the center of mass
    if(kinect.getCoM(userList[i],com)){
      kinect.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
      vertex(com2d.x,com2d.y - 5);
      vertex(com2d.x,com2d.y + 5); 
      vertex(com2d.x - 5,com2d.y);
      vertex(com2d.x + 5,com2d.y);
      endShape();    
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
      }
    }  
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId){
  /*
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  */
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}


// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId){
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton"); 
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId){
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId){
  //println("onVisibleUser - userId: " + userId);
}