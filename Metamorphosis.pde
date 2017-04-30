import SimpleOpenNI.*; // For interfacing with the Kinect
import codeanticode.syphon.*; // For using syphon to send frames out

SimpleOpenNI kinect;
SyphonServer server;
boolean sendFrames   = false;
color[] userClr      = new color[]{
                         color(255,0,0),
                         color(0,255,0),
                         color(0,0,255),
                         color(255,255,0),
                         color(255,0,255),
                         color(0,255,255)};
PVector com                 = new PVector();                                   
PVector com2d               = new PVector(); 
PVector currentUserCom      = new PVector(); 
PVector currentUserCom2d    = new PVector();
int[] jointNames            = new int[15]; // the joint names are integer constants

int currentUser, oldCurrentUser; // kinect can track multiple users, but we only want to focus on one
int currentPhaseIndex;
PImage eggImg, caterpillarImg, chrysalisImg, butterflyImg, leafImg;
LifecyclePhase eggPhase, caterpillarPhase, chrysalisPhase, butterflyPhase;
LifecyclePhase[] lifecyclePhases = new LifecyclePhase[4];

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
  
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser();
  server = new SyphonServer(this, "Kinect Processing");
  
  eggImg             = loadImage("monarch-egg.png");
  caterpillarImg     = loadImage("monarch-caterpillar.png");
  chrysalisImg       = loadImage("monarch-chrysalis.png");
  butterflyImg       = loadImage("monarch-butterfly.png");
  leafImg            = loadImage("leaf.png");
  eggImg.resize(400, 450);
  caterpillarImg.resize(150, 500);
  chrysalisImg.resize(400, 450);
  butterflyImg.resize(450, 400);
  leafImg.resize(150, 150);
  
  eggPhase           = new EggPhase();
  caterpillarPhase   = new CaterpillarPhase();
  chrysalisPhase     = new ChrysalisPhase();
  butterflyPhase     = new ButterflyPhase();
  lifecyclePhases[0] = eggPhase;
  lifecyclePhases[1] = caterpillarPhase;
  lifecyclePhases[2] = chrysalisPhase;
  lifecyclePhases[3] = butterflyPhase;
  currentPhaseIndex  = -1;
  currentUser        = -1;
}

void draw(){
  clear();
  fill(255);
  kinect.update();
  image(kinect.userImage(), 0, 0, width, height);
  drawUsers();
  if (currentUser != -1){
    if (currentPhaseIndex != -1){
      lifecyclePhases[currentPhaseIndex].display();
      lifecyclePhases[currentPhaseIndex].showText();
      lifecyclePhases[currentPhaseIndex].detectGesture(currentUser);
    } else {
      text("Be an egg.", width/2, 30);
      detectCrouchingBallPosition(currentUser);
    }
  }
    
  if (sendFrames){
    server.sendScreen();
  }
}

void detectCrouchingBallPosition(int userId){
  boolean insideBallArea = false;
  int eggDiameterX       = 300;
  int eggDiameterY       = 450;  
  int innerDiameterX     = 100;
  int innerDiameterY     = 200;
  int innerRadiusX       = innerDiameterX/2;
  int innerRadiusY       = innerDiameterY/2;
  kinect.getCoM(userId, currentUserCom);  
  kinect.convertRealWorldToProjective(currentUserCom, currentUserCom2d);
  noFill();
  stroke(255, 0, 0);
  ellipse(width/2, height-50, eggDiameterX, eggDiameterY);
  ellipse(width/2, height-50, innerDiameterX, innerDiameterY);
  fill(255);
  ellipse(currentUserCom2d.x, currentUserCom2d.y, 10, 10);
  ellipse(width/2, height-50-innerRadiusY, 5, 5);
  ellipse(width/2, height-50+innerRadiusY, 5, 5);
  ellipse(width/2-innerRadiusX, height-50, 5, 5);
  ellipse(width/2+innerRadiusX, height-50, 5, 5);
  //println("User ID: " + userId + " COM: " + currentUserCom);
  if ((currentUserCom2d.x <= width/2 + innerRadiusX)
       &&  (currentUserCom2d.x >= width/2 - innerRadiusX) 
         && (currentUserCom2d.y <= (height-50) + innerRadiusY)
           && (currentUserCom2d.y >= (height-50) - innerRadiusY)){
           insideBallArea = true;
    }
  
  if (insideBallArea == true){
    currentPhaseIndex = 0;
  }
}


void drawUsers(){
  // draw the skeleton if it's available
  /*int[] userList = kinect.getUsers();
  for(int i=0;i<userList.length;i++){
    if(kinect.isTrackingSkeleton(userList[i])){
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);    
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
    }  */
    if(kinect.isTrackingSkeleton(currentUser)){
      stroke(userClr[(currentUser-1) % userClr.length ] );
      drawSkeleton(currentUser);    
    }      
        
    // draw the center of mass
    if(kinect.getCoM(currentUser, com)){
      kinect.convertRealWorldToProjective(com,com2d);
      stroke(100, 255, 0);
      strokeWeight(1);
      beginShape(LINES);
      vertex(com2d.x, com2d.y - 5);
      vertex(com2d.x, com2d.y + 5); 
      vertex(com2d.x - 5, com2d.y);
      vertex(com2d.x + 5, com2d.y);
      endShape();    
      fill(0,255,100);
      text(Integer.toString(currentUser), com2d.x, com2d.y);
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

void populateJointNamesArray(){
  jointNames[0]  = SimpleOpenNI.SKEL_HEAD;
  jointNames[1]  = SimpleOpenNI.SKEL_NECK;
  jointNames[2]  = SimpleOpenNI.SKEL_LEFT_SHOULDER;
  jointNames[3]  = SimpleOpenNI.SKEL_LEFT_ELBOW;
  jointNames[4]  = SimpleOpenNI.SKEL_LEFT_HAND;
  jointNames[5]  = SimpleOpenNI.SKEL_RIGHT_SHOULDER;
  jointNames[6]  = SimpleOpenNI.SKEL_RIGHT_ELBOW;
  jointNames[7]  = SimpleOpenNI.SKEL_RIGHT_HAND;
  jointNames[8]  = SimpleOpenNI.SKEL_TORSO;
  jointNames[9]  = SimpleOpenNI.SKEL_LEFT_HIP;
  jointNames[10] = SimpleOpenNI.SKEL_LEFT_KNEE;
  jointNames[11] = SimpleOpenNI.SKEL_LEFT_FOOT;
  jointNames[12] = SimpleOpenNI.SKEL_RIGHT_HIP;
  jointNames[13] = SimpleOpenNI.SKEL_RIGHT_KNEE;
  jointNames[14] = SimpleOpenNI.SKEL_RIGHT_FOOT;
}

void onNewUser(SimpleOpenNI curContext, int userId){
  println("onNewUser - userId: " + userId);
  curContext.startTrackingSkeleton(userId);
  currentUser = userId;
}

void onLostUser(SimpleOpenNI curContext, int userId){
  if (currentUser == userId){
    oldCurrentUser = currentUser;
    currentUser = -1;
  }
}

void onVisibleUser(SimpleOpenNI curContext, int userId){
  if (currentUser == -1 && oldCurrentUser == userId){
    currentUser = userId;
  }
}